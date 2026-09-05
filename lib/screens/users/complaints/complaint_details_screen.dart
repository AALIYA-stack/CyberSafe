import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/complaint.dart';
import '../../../models/complaint_status.dart';
import '../../../services/complaint_services.dart';
import '../../../widgets/status_chip.dart';

class ComplaintDetailsScreen extends StatefulWidget {
  final Complaint complaint;

  const ComplaintDetailsScreen({
    super.key,
    required this.complaint,
  });

  @override
  State<ComplaintDetailsScreen> createState() =>
      _ComplaintDetailsScreenState();
}

class _ComplaintDetailsScreenState
    extends State<ComplaintDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  bool _isCheckingAccess = true;
  bool _hasAccess = false;

  String _currentUserId = '';

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _checkComplaintAccess();
  }

  // ==========================================================
  // CHECK USER ACCESS
  // ==========================================================

  Future<void> _checkComplaintAccess() async {
    try {
      final currentUser =
          ComplaintService.instance.currentUser;

      if (!mounted) {
        return;
      }

      if (currentUser == null) {
        setState(() {
          _isCheckingAccess = false;
          _hasAccess = false;
        });
        return;
      }

      _currentUserId = currentUser.uid;

      final complaintUserId =
      widget.complaint.userId.trim();

      final currentEmail =
      (currentUser.email ?? '').trim().toLowerCase();

      final complaintEmail =
      widget.complaint.userEmail.trim().toLowerCase();

      final hasUidAccess =
          complaintUserId.isNotEmpty &&
              complaintUserId == currentUser.uid;

      final hasEmailAccess =
          complaintUserId.isEmpty &&
              currentEmail.isNotEmpty &&
              complaintEmail.isNotEmpty &&
              currentEmail == complaintEmail;

      final hasAccess =
          hasUidAccess || hasEmailAccess;

      setState(() {
        _hasAccess = hasAccess;
        _isCheckingAccess = false;
      });

      if (hasAccess) {
        _controller.forward(from: 0);
      }
    } catch (e) {
      debugPrint(
        'CHECK COMPLAINT ACCESS ERROR: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isCheckingAccess = false;
        _hasAccess = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ==========================================================
  // DATE FORMATTER
  // ==========================================================

  String _formatDate(DateTime date) {
    final day =
    date.day.toString().padLeft(2, '0');

    final month =
    date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    final day =
    date.day.toString().padLeft(2, '0');

    final month =
    date.month.toString().padLeft(2, '0');

    final hour = date.hour == 0
        ? 12
        : date.hour > 12
        ? date.hour - 12
        : date.hour;

    final minute =
    date.minute.toString().padLeft(2, '0');

    final period =
    date.hour >= 12 ? 'PM' : 'AM';

    return '$day/$month/${date.year} • '
        '$hour:$minute $period';
  }

  // ==========================================================
  // STATUS INDEX
  // ==========================================================

  int _statusIndex(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.submitted:
        return 0;

      case ComplaintStatus.underReview:
        return 1;

      case ComplaintStatus.inProgress:
        return 2;

      case ComplaintStatus.resolved:
        return 3;

      case ComplaintStatus.closed:
        return 4;
    }
  }

  // ==========================================================
  // STATUS ICON
  // ==========================================================

  IconData _statusIcon(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.submitted:
        return Icons.send_rounded;

      case ComplaintStatus.underReview:
        return Icons.search_rounded;

      case ComplaintStatus.inProgress:
        return Icons.manage_search_rounded;

      case ComplaintStatus.resolved:
        return Icons.check_circle_outline_rounded;

      case ComplaintStatus.closed:
        return Icons.lock_outline_rounded;
    }
  }

  // ==========================================================
  // MAIN BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAccess) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Complaint Details',
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_hasAccess) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Complaint Details',
          ),
        ),
        body: _buildAccessDenied(),
      );
    }

    return StreamBuilder<Complaint?>(
      stream: ComplaintService.instance
          .complaintStream(
        widget.complaint.id,
      ),
      builder: (
          context,
          snapshot,
          ) {
        // ====================================================
        // LOADING
        // ====================================================

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Complaint Details',
              ),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // ====================================================
        // ERROR
        // ====================================================

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Complaint Details',
              ),
            ),
            body: _buildErrorState(
              'Unable to load complaint details.',
            ),
          );
        }

        // ====================================================
        // NOT FOUND
        // ====================================================

        final complaint = snapshot.data;

        if (complaint == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Complaint Details',
              ),
            ),
            body: _buildErrorState(
              'This complaint no longer exists.',
            ),
          );
        }

        // ====================================================
        // PRIVACY CHECK
        // ====================================================

        if (complaint.userId.isNotEmpty &&
            complaint.userId != _currentUserId) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Complaint Details',
              ),
            ),
            body: _buildAccessDenied(),
          );
        }

        // ====================================================
        // CONTENT
        // ====================================================

        return Scaffold(
          backgroundColor:
          Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text(
              'Complaint Details',
            ),
            centerTitle: false,
          ),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                physics:
                const BouncingScrollPhysics(),
                padding:
                const EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  32,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    _buildHeader(
                      complaint,
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    _buildCurrentStatus(
                      complaint,
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    _buildTimeline(
                      complaint,
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    _buildIncidentInformation(
                      complaint,
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    _buildDescription(
                      complaint,
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    _buildEvidence(
                      complaint,
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    _buildSubmissionInformation(
                      complaint,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // ACCESS DENIED
  // ==========================================================

  Widget _buildAccessDenied() {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 70,
              color: AppColors.primary,
            ),

            const SizedBox(
              height: 18,
            ),

            Text(
              'Access Restricted',
              style:
              Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              'You can only view your own complaints.',
              textAlign:
              TextAlign.center,
              style:
              Theme.of(context)
                  .textTheme
                  .bodyMedium,
            ),

            const SizedBox(
              height: 20,
            ),

            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_rounded,
              ),
              label: const Text(
                'Go Back',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // ERROR STATE
  // ==========================================================

  Widget _buildErrorState(
      String message,
      ) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 70,
              color: AppColors.primary,
            ),

            const SizedBox(
              height: 18,
            ),

            Text(
              message,
              textAlign:
              TextAlign.center,
              style:
              Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                fontWeight:
                FontWeight.w600,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_rounded,
              ),
              label: const Text(
                'Go Back',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // HEADER
  // ==========================================================

  Widget _buildHeader(
      Complaint complaint,
      ) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(20),
      decoration:
      BoxDecoration(
        gradient:
        LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary
                .withValues(
              alpha: 0.85,
            ),
          ],
          begin:
          Alignment.topLeft,
          end:
          Alignment.bottomRight,
        ),
        borderRadius:
        BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary
                .withValues(
              alpha: 0.18,
            ),
            blurRadius: 18,
            offset:
            const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration:
                BoxDecoration(
                  color:
                  Colors.white.withValues(
                    alpha: 0.15,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    14,
                  ),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color:
                  Colors.white,
                  size: 26,
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              Expanded(
                child: Text(
                  complaint.title,
                  maxLines: 2,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  const TextStyle(
                    color:
                    Colors.white,
                    fontSize: 19,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 18,
          ),

          Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration:
            BoxDecoration(
              color:
              Colors.white.withValues(
                alpha: 0.12,
              ),
              borderRadius:
              BorderRadius.circular(
                10,
              ),
            ),
            child: Row(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                const Icon(
                  Icons
                      .confirmation_number_outlined,
                  color:
                  Colors.white,
                  size: 17,
                ),

                const SizedBox(
                  width: 7,
                ),

                Text(
                  complaint.id,
                  style:
                  const TextStyle(
                    color:
                    Colors.white,
                    fontWeight:
                    FontWeight.w600,
                    letterSpacing:
                    0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // CURRENT STATUS
  // ==========================================================

  Widget _buildCurrentStatus(
      Complaint complaint,
      ) {
    return _sectionCard(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            icon:
            Icons.track_changes_rounded,
            title:
            'Current Status',
          ),

          const SizedBox(
            height: 16,
          ),

          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration:
                BoxDecoration(
                  color:
                  AppColors.primary
                      .withValues(
                    alpha: 0.10,
                  ),
                  shape:
                  BoxShape.circle,
                ),
                child: Icon(
                  _statusIcon(
                    complaint.status,
                  ),
                  color:
                  AppColors.primary,
                  size: 25,
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    StatusChip(
                      status:
                      complaint.status,
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Text(
                      complaint.status
                          .description,
                      style:
                      Theme.of(context)
                          .textTheme
                          .bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // TIMELINE
  // ==========================================================

  Widget _buildTimeline(
      Complaint complaint,
      ) {
    final currentIndex =
    _statusIndex(
      complaint.status,
    );

    const statuses = [
      ComplaintStatus.submitted,
      ComplaintStatus.underReview,
      ComplaintStatus.inProgress,
      ComplaintStatus.resolved,
      ComplaintStatus.closed,
    ];

    return _sectionCard(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            icon:
            Icons.timeline_rounded,
            title:
            'Complaint Timeline',
          ),

          const SizedBox(
            height: 22,
          ),

          ...List.generate(
            statuses.length,
                (index) {
              final status =
              statuses[index];

              final completed =
                  index <= currentIndex;

              final isLast =
                  index ==
                      statuses.length - 1;

              return _timelineItem(
                status:
                status,
                completed:
                completed,
                isLast:
                isLast,
                index:
                index,
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // TIMELINE ITEM
  // ==========================================================

  Widget _timelineItem({
    required ComplaintStatus status,
    required bool completed,
    required bool isLast,
    required int index,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(
        begin: 0,
        end: 1,
      ),
      duration: Duration(
        milliseconds:
        450 + (index * 120),
      ),
      curve:
      Curves.easeOut,
      builder:
          (context, value, child) {
        return Opacity(
          opacity: value,
          child:
          Transform.translate(
            offset: Offset(
              0,
              14 * (1 - value),
            ),
            child:
            child,
          ),
        );
      },
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 34,
            child: Column(
              children: [
                AnimatedContainer(
                  duration:
                  const Duration(
                    milliseconds: 350,
                  ),
                  width: 30,
                  height: 30,
                  decoration:
                  BoxDecoration(
                    color: completed
                        ? AppColors.primary
                        : Theme.of(context)
                        .dividerColor
                        .withValues(
                      alpha: 0.35,
                    ),
                    shape:
                    BoxShape.circle,
                  ),
                  child: Icon(
                    completed
                        ? Icons.check_rounded
                        : Icons
                        .circle_outlined,
                    size: completed
                        ? 18
                        : 15,
                    color: completed
                        ? Colors.white
                        : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(
                      alpha: 0.45,
                    ),
                  ),
                ),

                if (!isLast)
                  Container(
                    width: 2,
                    height: 52,
                    color: completed
                        ? AppColors.primary
                        .withValues(
                      alpha: 0.45,
                    )
                        : Theme.of(context)
                        .dividerColor
                        .withValues(
                      alpha: 0.30,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Padding(
              padding:
              const EdgeInsets.only(
                top: 4,
                bottom: 20,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    status.label,
                    style:
                    TextStyle(
                      fontSize: 15,
                      fontWeight: completed
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: completed
                          ? Theme.of(context)
                          .colorScheme
                          .onSurface
                          : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(
                        alpha: 0.55,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    status.description,
                    style:
                    Theme.of(context)
                        .textTheme
                        .bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // INCIDENT INFORMATION
  // ==========================================================

  Widget _buildIncidentInformation(
      Complaint complaint,
      ) {
    return _sectionCard(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            icon:
            Icons.info_outline_rounded,
            title:
            'Incident Information',
          ),

          const SizedBox(
            height: 18,
          ),

          _infoRow(
            icon:
            Icons.category_outlined,
            label:
            'Category',
            value:
            complaint.category,
          ),

          _infoDivider(),

          _infoRow(
            icon:
            Icons.public_rounded,
            label:
            'Platform',
            value:
            complaint.platform,
          ),

          _infoDivider(),

          _infoRow(
            icon:
            Icons.calendar_today_outlined,
            label:
            'Incident Date',
            value:
            _formatDate(
              complaint.date,
            ),
          ),

          _infoDivider(),

          _infoRow(
            icon:
            Icons.location_on_outlined,
            label:
            'Location',
            value:
            complaint.location.isEmpty
                ? 'Not provided'
                : complaint.location,
          ),

          _infoDivider(),

          _infoRow(
            icon:
            Icons.person_outline_rounded,
            label:
            'Suspect',
            value:
            complaint.suspect.isEmpty
                ? 'Unknown'
                : complaint.suspect,
          ),

          if (complaint
              .suspectContact
              .isNotEmpty) ...[
            _infoDivider(),

            _infoRow(
              icon:
              Icons.phone_outlined,
              label:
              'Suspect Contact',
              value:
              complaint.suspectContact,
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================================
  // DESCRIPTION
  // ==========================================================

  Widget _buildDescription(
      Complaint complaint,
      ) {
    return _sectionCard(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            icon:
            Icons.description_outlined,
            title:
            'Complaint Description',
          ),

          const SizedBox(
            height: 14,
          ),

          Text(
            complaint.description
                .trim()
                .isEmpty
                ? 'No description provided.'
                : complaint.description,
            style:
            Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // EVIDENCE
  // ==========================================================

  Widget _buildEvidence(
      Complaint complaint,
      ) {
    final evidence =
        complaint.evidence;

    return _sectionCard(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            icon:
            Icons.attach_file_rounded,
            title:
            'Evidence',
          ),

          const SizedBox(
            height: 14,
          ),

          if (evidence.isEmpty)
            _emptyEvidence()
          else
            Column(
              children: evidence
                  .map(
                    (file) =>
                    _evidenceTile(file),
              )
                  .toList(),
            ),
        ],
      ),
    );
  }

  // ==========================================================
  // EVIDENCE TILE
  // ==========================================================

  Widget _evidenceTile(
      String fileName,
      ) {
    final lower =
    fileName.toLowerCase();

    final isImage =
        lower.endsWith('.png') ||
            lower.endsWith('.jpg') ||
            lower.endsWith('.jpeg') ||
            lower.endsWith('.webp');

    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 10,
      ),
      padding:
      const EdgeInsets.all(12),
      decoration:
      BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(
          alpha: 0.45,
        ),
        borderRadius:
        BorderRadius.circular(14),
        border:
        Border.all(
          color: Theme.of(context)
              .dividerColor
              .withValues(
            alpha: 0.35,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration:
            BoxDecoration(
              color:
              AppColors.primary
                  .withValues(
                alpha: 0.10,
              ),
              borderRadius:
              BorderRadius.circular(
                11,
              ),
            ),
            child: Icon(
              isImage
                  ? Icons.image_outlined
                  : Icons
                  .insert_drive_file_outlined,
              color:
              AppColors.primary,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Text(
              fileName,
              maxLines: 2,
              overflow:
              TextOverflow.ellipsis,
              style:
              const TextStyle(
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ),

          IconButton(
            tooltip:
            'View',
            onPressed: () {
              _showEvidencePreview(
                fileName,
              );
            },
            icon:
            const Icon(
              Icons
                  .visibility_outlined,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // EMPTY EVIDENCE
  // ==========================================================

  Widget _emptyEvidence() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(18),
      decoration:
      BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(
          alpha: 0.4,
        ),
        borderRadius:
        BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: 38,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(
              alpha: 0.45,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          const Text(
            'No evidence attached',
            style:
            TextStyle(
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // EVIDENCE PREVIEW
  // ==========================================================

  void _showEvidencePreview(
      String fileName,
      ) {
    showModalBottomSheet(
      context: context,
      showDragHandle:
      true,
      builder:
          (context) {
        return SafeArea(
          child: Padding(
            padding:
            const EdgeInsets.fromLTRB(
              20,
              10,
              20,
              30,
            ),
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                const Icon(
                  Icons
                      .insert_drive_file_outlined,
                  size: 48,
                ),

                const SizedBox(
                  height: 14,
                ),

                Text(
                  fileName,
                  textAlign:
                  TextAlign.center,
                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.w700,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                const Text(
                  'Evidence preview is available in the demo interface.',
                  textAlign:
                  TextAlign.center,
                ),

                const SizedBox(
                  height: 18,
                ),

                SizedBox(
                  width:
                  double.infinity,
                  child:
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );
                    },
                    child:
                    const Text(
                      'Close',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // SUBMISSION INFORMATION
  // ==========================================================

  Widget _buildSubmissionInformation(
      Complaint complaint,
      ) {
    return _sectionCard(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            icon:
            Icons.history_rounded,
            title:
            'Submission Information',
          ),

          const SizedBox(
            height: 16,
          ),

          _infoRow(
            icon:
            Icons.confirmation_number_outlined,
            label:
            'Complaint ID',
            value:
            complaint.id,
          ),

          _infoDivider(),

          _infoRow(
            icon:
            Icons.schedule_outlined,
            label:
            'Submitted',
            value:
            _formatDateTime(
              complaint.submittedDate,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SECTION CARD
  // ==========================================================

  Widget _sectionCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(18),
      decoration:
      BoxDecoration(
        color:
        Theme.of(context).cardColor,
        borderRadius:
        BorderRadius.circular(20),
        border:
        Border.all(
          color: Theme.of(context)
              .dividerColor
              .withValues(
            alpha: 0.30,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(
              alpha: 0.03,
            ),
            blurRadius: 14,
            offset:
            const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  // ==========================================================
  // SECTION TITLE
  // ==========================================================

  Widget _sectionTitle({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration:
          BoxDecoration(
            color:
            AppColors.primary
                .withValues(
              alpha: 0.09,
            ),
            borderRadius:
            BorderRadius.circular(
              11,
            ),
          ),
          child: Icon(
            icon,
            color:
            AppColors.primary,
            size: 20,
          ),
        ),

        const SizedBox(
          width: 11,
        ),

        Expanded(
          child: Text(
            title,
            style:
            const TextStyle(
              fontSize: 17,
              fontWeight:
              FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // INFO ROW
  // ==========================================================

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color:
          AppColors.primary,
        ),

        const SizedBox(
          width: 12,
        ),

        SizedBox(
          width: 105,
          child: Text(
            label,
            style:
            Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(
          width: 8,
        ),

        Expanded(
          child: Text(
            value.trim().isEmpty
                ? 'Not provided'
                : value,
            textAlign:
            TextAlign.right,
            style:
            Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // DIVIDER
  // ==========================================================

  Widget _infoDivider() {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        vertical: 13,
      ),
      child: Divider(
        height: 1,
        color: Theme.of(context)
            .dividerColor
            .withValues(
          alpha: 0.25,
        ),
      ),
    );
  }
}