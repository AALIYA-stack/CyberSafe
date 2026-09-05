import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/complaint.dart';
import '../../../models/complaint_status.dart';
import '../../../services/complaint_services.dart';
import '../../../widgets/complaint_card.dart';
import 'complaint_details_screen.dart';

class MyComplaintsScreen extends StatefulWidget {
  const MyComplaintsScreen({super.key});

  @override
  State<MyComplaintsScreen> createState() =>
      _MyComplaintsScreenState();
}

class _MyComplaintsScreenState extends State<MyComplaintsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  ComplaintStatus? _selectedStatus;

  List<Complaint> _complaints = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _loadComplaints();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ==========================================================
  // LOAD COMPLAINTS FROM FIRESTORE
  // ==========================================================

  Future<void> _loadComplaints() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final complaints =
      await ComplaintService.instance.getMyComplaints();

      if (!mounted) return;

      setState(() {
        _complaints = complaints;
        _isLoading = false;
      });

      _animationController.forward(from: 0);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _complaints = [];
        _isLoading = false;
        _errorMessage = 'Unable to load your complaints.';
      });
    }
  }

  // ==========================================================
  // FILTER
  // ==========================================================

  List<Complaint> _filteredComplaints() {
    if (_selectedStatus == null) {
      return _complaints;
    }

    return _complaints.where((complaint) {
      return complaint.status == _selectedStatus;
    }).toList();
  }

  // ==========================================================
  // ACTIVE STATUS
  // ==========================================================

  bool _isActive(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.submitted:
      case ComplaintStatus.underReview:
      case ComplaintStatus.inProgress:
        return true;

      case ComplaintStatus.resolved:
      case ComplaintStatus.closed:
        return false;
    }
  }

  // ==========================================================
  // COMPLETED STATUS
  // ==========================================================

  bool _isCompleted(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.submitted:
      case ComplaintStatus.underReview:
      case ComplaintStatus.inProgress:
        return false;

      case ComplaintStatus.resolved:
      case ComplaintStatus.closed:
        return true;
    }
  }

  // ==========================================================
  // ANIMATION
  // ==========================================================

  Widget _animatedItem({
    required int index,
    required Widget child,
  }) {
    final start = (index * 0.12).clamp(0.0, 0.7);

    final animation = CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        start,
        1.0,
        curve: Curves.easeOutCubic,
      ),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final complaints = _filteredComplaints();

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text(
          'My Complaints',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),

      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : RefreshIndicator(
        onRefresh: _loadComplaints,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ==================================================
            // SUMMARY
            // ==================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  16,
                ),
                child: _buildSummaryCard(),
              ),
            ),

            // ==================================================
            // ERROR
            // ==================================================

            if (_errorMessage != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: _buildErrorMessage(),
                ),
              ),

            // ==================================================
            // FILTERS
            // ==================================================

            SliverToBoxAdapter(
              child: _buildFilters(),
            ),

            // ==================================================
            // EMPTY
            // ==================================================

            if (complaints.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(),
              )

            // ==================================================
            // COMPLAINT LIST
            // ==================================================

            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  30,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final complaint =
                      complaints[index];

                      return _animatedItem(
                        index: index,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            bottom: 14,
                          ),
                          child:
                          _buildComplaintCard(
                            complaint,
                          ),
                        ),
                      );
                    },
                    childCount: complaints.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // ERROR MESSAGE
  // ==========================================================

  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.red,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SUMMARY CARD
  // ==========================================================

  Widget _buildSummaryCard() {
    final total = _complaints.length;

    final active = _complaints
        .where(
          (complaint) =>
          _isActive(complaint.status),
    )
        .length;

    final completed = _complaints
        .where(
          (complaint) =>
          _isCompleted(complaint.status),
    )
        .length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(
              alpha: 0.18,
            ),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Text(
            'Complaint Overview',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '$total',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),

          const Text(
            'Total complaints',
            style: TextStyle(
              color: Colors.white70,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _summaryItem(
                  'Active',
                  active.toString(),
                ),
              ),
              Expanded(
                child: _summaryItem(
                  'Completed',
                  completed.toString(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SUMMARY ITEM
  // ==========================================================

  Widget _summaryItem(
      String title,
      String value,
      ) {
    return Row(
      children: [
        Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: 0.14,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.shield_outlined,
            color: Colors.white,
            size: 20,
          ),
        ),

        const SizedBox(width: 10),

        Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================================
  // FILTERS
  // ==========================================================

  Widget _buildFilters() {
    return SizedBox(
      height: 46,
      child: ListView(
        padding:
        const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        children: [
          _filterChip(
            title: 'All',
            selected: _selectedStatus == null,
            onTap: () {
              setState(() {
                _selectedStatus = null;
              });
            },
          ),

          _filterChip(
            title: 'Submitted',
            selected:
            _selectedStatus ==
                ComplaintStatus.submitted,
            onTap: () {
              setState(() {
                _selectedStatus =
                    ComplaintStatus.submitted;
              });
            },
          ),

          _filterChip(
            title: 'Under Review',
            selected:
            _selectedStatus ==
                ComplaintStatus.underReview,
            onTap: () {
              setState(() {
                _selectedStatus =
                    ComplaintStatus.underReview;
              });
            },
          ),

          _filterChip(
            title: 'In Progress',
            selected:
            _selectedStatus ==
                ComplaintStatus.inProgress,
            onTap: () {
              setState(() {
                _selectedStatus =
                    ComplaintStatus.inProgress;
              });
            },
          ),

          _filterChip(
            title: 'Resolved',
            selected:
            _selectedStatus ==
                ComplaintStatus.resolved,
            onTap: () {
              setState(() {
                _selectedStatus =
                    ComplaintStatus.resolved;
              });
            },
          ),

          _filterChip(
            title: 'Closed',
            selected:
            _selectedStatus ==
                ComplaintStatus.closed,
            onTap: () {
              setState(() {
                _selectedStatus =
                    ComplaintStatus.closed;
              });
            },
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // FILTER CHIP
  // ==========================================================

  Widget _filterChip({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(title),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: selected
              ? Colors.white
              : AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide(
          color: selected
              ? AppColors.primary
              : AppColors.border,
        ),
      ),
    );
  }

  // ==========================================================
  // COMPLAINT CARD
  // ==========================================================

  Widget _buildComplaintCard(
      Complaint complaint,
      ) {
    return ComplaintCard(
      complaint: complaint,
      onTap: () {
        _openComplaint(complaint);
      },
    );
  }

  // ==========================================================
  // OPEN COMPLAINT
  // ==========================================================

  void _openComplaint(
      Complaint complaint,
      ) {
    final currentUser =
        ComplaintService.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please login to view your complaint.',
          ),
        ),
      );
      return;
    }

    if (complaint.userId != currentUser.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You can only access your own complaints.',
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ComplaintDetailsScreen(
          complaint: complaint,
        ),
      ),
    );
  }

  // ==========================================================
  // EMPTY STATE
  // ==========================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(
                begin: 0.7,
                end: 1.0,
              ),
              duration:
              const Duration(milliseconds: 600),
              curve: Curves.easeOutBack,
              builder: (
                  context,
                  value,
                  child,
                  ) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                height: 86,
                width: 86,
                decoration: BoxDecoration(
                  color: AppColors.primary
                      .withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.description_outlined,
                  size: 42,
                  color: AppColors.primary,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No Complaints Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _selectedStatus == null
                  ? 'You have not submitted any complaints yet.'
                  : 'No complaints match this status.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 20),

            OutlinedButton.icon(
              onPressed: _loadComplaints,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'Refresh',
              ),
            ),
          ],
        ),
      ),
    );
  }
}