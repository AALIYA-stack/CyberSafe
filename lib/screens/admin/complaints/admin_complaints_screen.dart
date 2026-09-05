import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/complaint.dart';
import '../../../models/complaint_status.dart';
import '../../../services/complaint_services.dart';
import '../../../widgets/status_chip.dart';
import 'admin_complaint_details_screen.dart';

class AdminComplaintsScreen extends StatefulWidget {
  const AdminComplaintsScreen({
    super.key,
  });

  @override
  State<AdminComplaintsScreen> createState() =>
      _AdminComplaintsScreenState();
}

class _AdminComplaintsScreenState
    extends State<AdminComplaintsScreen> {
  final ComplaintService _complaintService =
      ComplaintService.instance;

  List<Complaint> _complaints = [];

  bool _isLoading = true;
  String _searchQuery = '';
  ComplaintStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  // ==========================================================
  // LOAD COMPLAINTS
  // ==========================================================

  Future<void> _loadComplaints() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final complaints =
      await _complaintService.getAllComplaints();

      if (!mounted) return;

      setState(() {
        _complaints = complaints;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint(
        'ADMIN COMPLAINTS LOAD ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        _complaints = [];
        _isLoading = false;
      });

      _showMessage(
        _complaintService.lastError.isNotEmpty
            ? _complaintService.lastError
            : 'Unable to load complaints.',
        isError: true,
      );
    }
  }

  // ==========================================================
  // FILTERED COMPLAINTS
  // ==========================================================

  List<Complaint> get _filteredComplaints {
    final query =
    _searchQuery.trim().toLowerCase();

    return _complaints.where((complaint) {
      final matchesSearch =
          query.isEmpty ||
              complaint.id
                  .toLowerCase()
                  .contains(query) ||
              complaint.title
                  .toLowerCase()
                  .contains(query) ||
              complaint.user
                  .toLowerCase()
                  .contains(query) ||
              complaint.userEmail
                  .toLowerCase()
                  .contains(query) ||
              complaint.category
                  .toLowerCase()
                  .contains(query) ||
              complaint.platform
                  .toLowerCase()
                  .contains(query);

      final matchesStatus =
          _selectedStatus == null ||
              complaint.status == _selectedStatus;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  // ==========================================================
  // DATE
  // ==========================================================

  String _formatDate(DateTime date) {
    final day =
    date.day.toString().padLeft(2, '0');

    final month =
    date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void _showMessage(
      String message, {
        bool isError = false,
      }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(message),
              ),
            ],
          ),
          backgroundColor: isError
              ? Colors.red.shade700
              : Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(14),
          ),
        ),
      );
  }

  // ==========================================================
  // OPEN DETAILS
  // ==========================================================

  Future<void> _openDetails(
      Complaint complaint,
      ) async {
    final result =
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AdminComplaintDetailsScreen(
              complaint: complaint,
            ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      await _loadComplaints();
    }
  }

  // ==========================================================
  // CLEAR FILTERS
  // ==========================================================

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedStatus = null;
    });
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final complaints =
        _filteredComplaints;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Complaints',
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed:
            _isLoading
                ? null
                : _loadComplaints,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTopSection(),
          Expanded(
            child: _isLoading
                ? const Center(
              child:
              CircularProgressIndicator(),
            )
                : complaints.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
              onRefresh:
              _loadComplaints,
              child:
              ListView.builder(
                physics:
                const AlwaysScrollableScrollPhysics(),
                padding:
                const EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  30,
                ),
                itemCount:
                complaints.length,
                itemBuilder:
                    (context, index) {
                  return _buildComplaintCard(
                    complaints[index],
                    index,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // TOP SECTION
  // ==========================================================

  Widget _buildTopSection() {
    return Container(
      padding:
      const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        14,
      ),
      child: Column(
        children: [
          _buildSummaryCard(),

          const SizedBox(height: 14),

          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            textInputAction:
            TextInputAction.search,
            decoration: InputDecoration(
              hintText:
              'Search complaints...',
              prefixIcon: const Icon(
                Icons.search_rounded,
              ),
              suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                tooltip: 'Clear',
                onPressed: () {
                  setState(() {
                    _searchQuery =
                    '';
                  });
                },
                icon: const Icon(
                  Icons.clear_rounded,
                ),
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(
                  15,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          _buildStatusFilter(),
        ],
      ),
    );
  }

  // ==========================================================
  // SUMMARY
  // ==========================================================

  Widget _buildSummaryCard() {
    final total = _complaints.length;

    final submitted = _complaints
        .where(
          (item) =>
      item.status ==
          ComplaintStatus.submitted,
    )
        .length;

    final underReview = _complaints
        .where(
          (item) =>
      item.status ==
          ComplaintStatus.underReview,
    )
        .length;

    final inProgress = _complaints
        .where(
          (item) =>
      item.status ==
          ComplaintStatus.inProgress,
    )
        .length;

    final resolved = _complaints
        .where(
          (item) =>
      item.status ==
          ComplaintStatus.resolved,
    )
        .length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(
              alpha: 0.82,
            ),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons
                    .admin_panel_settings_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'Complaint Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '$total Total',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _summaryItem(
                  'Submitted',
                  submitted,
                ),
              ),
              Expanded(
                child: _summaryItem(
                  'Review',
                  underReview,
                ),
              ),
              Expanded(
                child: _summaryItem(
                  'Progress',
                  inProgress,
                ),
              ),
              Expanded(
                child: _summaryItem(
                  'Resolved',
                  resolved,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(
      String label,
      int value,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          '$value',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight:
            FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color:
            Colors.white.withValues(
              alpha: 0.78,
            ),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // STATUS FILTER
  // ==========================================================

  Widget _buildStatusFilter() {
    return DropdownButtonFormField<
        ComplaintStatus?>(
      value: _selectedStatus,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Filter by status',
        prefixIcon: const Icon(
          Icons.filter_list_rounded,
        ),
        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(15),
        ),
      ),
      items: [
        const DropdownMenuItem<
            ComplaintStatus?>(
          value: null,
          child: Text(
            'All Complaints',
          ),
        ),
        ...ComplaintStatus.values.map(
              (status) {
            return DropdownMenuItem<
                ComplaintStatus?>(
              value: status,
              child: Text(
                status.label,
              ),
            );
          },
        ),
      ],
      onChanged: (value) {
        setState(() {
          _selectedStatus = value;
        });
      },
    );
  }

  // ==========================================================
  // COMPLAINT CARD
  // ==========================================================

  Widget _buildComplaintCard(
      Complaint complaint,
      int index,
      ) {
    final userName =
    complaint.user.trim().isEmpty
        ? 'Unknown User'
        : complaint.user.trim();

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: 0,
        end: 1,
      ),
      duration: Duration(
        milliseconds:
        300 + (index.clamp(0, 8) * 50),
      ),
      curve: Curves.easeOut,
      builder:
          (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(
              0,
              12 * (1 - value),
            ),
            child: child,
          ),
        );
      },
      child: Card(
        margin:
        const EdgeInsets.only(
          bottom: 12,
        ),
        elevation: 0,
        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(18),
          side: BorderSide(
            color: Theme.of(context)
                .dividerColor
                .withValues(
              alpha: 0.25,
            ),
          ),
        ),
        child: InkWell(
          borderRadius:
          BorderRadius.circular(18),
          onTap: () {
            _openDetails(complaint);
          },
          child: Padding(
            padding:
            const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration:
                      BoxDecoration(
                        color: AppColors
                            .primary
                            .withValues(
                          alpha: 0.10,
                        ),
                        borderRadius:
                        BorderRadius
                            .circular(
                          13,
                        ),
                      ),
                      child: const Icon(
                        Icons
                            .report_problem_outlined,
                        color:
                        AppColors.primary,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          Text(
                            complaint.title
                                .trim()
                                .isEmpty
                                ? 'Untitled Complaint'
                                : complaint.title,
                            maxLines: 2,
                            overflow:
                            TextOverflow
                                .ellipsis,
                            style:
                            const TextStyle(
                              fontWeight:
                              FontWeight
                                  .w700,
                              fontSize: 15.5,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            'ID: ${complaint.id}',
                            maxLines: 1,
                            overflow:
                            TextOverflow
                                .ellipsis,
                            style: Theme.of(
                              context,
                            )
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                              fontWeight:
                              FontWeight
                                  .w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    StatusChip(
                      status:
                      complaint.status,
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Divider(
                  height: 1,
                  color: Theme.of(context)
                      .dividerColor
                      .withValues(
                    alpha: 0.25,
                  ),
                ),

                const SizedBox(height: 13),

                _complaintInfoRow(
                  icon:
                  Icons.person_outline_rounded,
                  value: userName,
                ),

                const SizedBox(height: 8),

                _complaintInfoRow(
                  icon:
                  Icons.category_outlined,
                  value:
                  complaint.category,
                ),

                const SizedBox(height: 8),

                _complaintInfoRow(
                  icon: Icons
                      .calendar_today_outlined,
                  value: _formatDate(
                    complaint.date,
                  ),
                ),

                const SizedBox(height: 13),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        complaint.userEmail
                            .trim()
                            .isEmpty
                            ? 'No email provided'
                            : complaint.userEmail,
                        maxLines: 1,
                        overflow:
                        TextOverflow
                            .ellipsis,
                        style:
                        Theme.of(context)
                            .textTheme
                            .bodySmall,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons
                          .arrow_forward_ios_rounded,
                      size: 15,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // INFO ROW
  // ==========================================================

  Widget _complaintInfoRow({
    required IconData icon,
    required String value,
  }) {
    final displayValue =
    value.trim().isEmpty
        ? 'Not provided'
        : value.trim();

    return Row(
      children: [
        Icon(
          icon,
          size: 17,
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            displayValue,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(
              fontWeight:
              FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // EMPTY STATE
  // ==========================================================

  Widget _buildEmptyState() {
    final hasFilter =
        _searchQuery
            .trim()
            .isNotEmpty ||
            _selectedStatus != null;

    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: AppColors.primary
                    .withValues(
                  alpha: 0.10,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasFilter
                    ? Icons
                    .search_off_rounded
                    : Icons.inbox_outlined,
                size: 42,
                color:
                AppColors.primary,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              hasFilter
                  ? 'No Matching Complaints'
                  : 'No Complaints Yet',
              textAlign:
              TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                fontWeight:
                FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              hasFilter
                  ? 'Try changing your search or status filter.'
                  : 'Submitted complaints will appear here.',
              textAlign:
              TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium,
            ),

            if (hasFilter) ...[
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(
                  Icons.clear_all_rounded,
                ),
                label: const Text(
                  'Clear Filters',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}