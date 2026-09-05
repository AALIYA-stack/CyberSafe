import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/app_notification.dart';
import '../../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  final bool isGuest;

  const NotificationsScreen({
    super.key,
    this.isGuest = false,
  });

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  // ==========================================================
  // SERVICES
  // ==========================================================

  final NotificationService _notificationService =
      NotificationService.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ==========================================================
  // ANIMATION
  // ==========================================================

  late AnimationController _animationController;

  // ==========================================================
  // DATA
  // ==========================================================

  List<AppNotification> _notifications = [];

  bool _isLoading = true;

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 700,
      ),
    );

    _loadNotifications();
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ==========================================================
  // CURRENT USER ID
  // ==========================================================

  String? get _currentUserId {
    return _auth.currentUser?.uid;
  }

  // ==========================================================
  // LOAD NOTIFICATIONS
  // ==========================================================

  Future<void> _loadNotifications() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // ------------------------------------------------------
      // GUEST CHECK
      // ------------------------------------------------------

      if (widget.isGuest) {
        if (!mounted) return;

        setState(() {
          _notifications = [];
          _isLoading = false;
        });

        _animationController.forward(from: 0);
        return;
      }

      // ------------------------------------------------------
      // USER CHECK
      // ------------------------------------------------------

      final userId = _currentUserId;

      if (userId == null ||
          userId.trim().isEmpty) {
        if (!mounted) return;

        setState(() {
          _notifications = [];
          _isLoading = false;
        });

        _animationController.forward(from: 0);
        return;
      }

      // ------------------------------------------------------
      // FIRESTORE
      // ------------------------------------------------------

      final notifications =
      await _notificationService
          .getMyNotifications(
        userId,
      );

      if (!mounted) return;

      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });

      _animationController.forward(from: 0);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _notifications = [];
        _isLoading = false;
      });

      _animationController.forward(from: 0);

      _showMessage(
        'Unable to load notifications.',
      );
    }
  }

  // ==========================================================
  // UNREAD COUNT
  // ==========================================================

  int get _unreadCount {
    return _notifications
        .where(
          (notification) =>
      !notification.isRead,
    )
        .length;
  }

  // ==========================================================
  // MARK ONE AS READ
  // ==========================================================

  Future<void> _markAsRead(int index) async {
    if (index < 0 ||
        index >= _notifications.length) {
      return;
    }

    final notification =
    _notifications[index];

    if (notification.isRead) {
      return;
    }

    // --------------------------------------------------------
    // UPDATE UI FIRST
    // --------------------------------------------------------

    setState(() {
      _notifications[index] =
          notification.copyWith(
            isRead: true,
          );
    });

    // --------------------------------------------------------
    // UPDATE FIRESTORE
    // --------------------------------------------------------

    try {
      await _notificationService.markAsRead(
        notification.id,
      );
    } catch (_) {
      // Reload if Firestore update fails.
      await _loadNotifications();
    }
  }

  // ==========================================================
  // MARK ALL AS READ
  // ==========================================================

  Future<void> _markAllAsRead() async {
    if (_notifications.isEmpty) {
      return;
    }

    if (_unreadCount == 0) {
      _showMessage(
        'All notifications are already read.',
      );
      return;
    }

    final userId = _currentUserId;

    if (userId == null ||
        userId.trim().isEmpty) {
      return;
    }

    // --------------------------------------------------------
    // UPDATE UI
    // --------------------------------------------------------

    setState(() {
      _notifications =
          _notifications.map(
                (notification) {
              return notification.copyWith(
                isRead: true,
              );
            },
          ).toList();
    });

    // --------------------------------------------------------
    // UPDATE FIRESTORE
    // --------------------------------------------------------

    try {
      await _notificationService
          .markAllAsRead(
        userId,
      );

      _showMessage(
        'All notifications marked as read.',
      );
    } catch (_) {
      await _loadNotifications();

      _showMessage(
        'Unable to update notifications.',
      );
    }
  }

  // ==========================================================
  // DELETE ONE NOTIFICATION
  // ==========================================================

  Future<void> _deleteNotification(
      int index,
      ) async {
    if (index < 0 ||
        index >= _notifications.length) {
      return;
    }

    final notification =
    _notifications[index];

    // --------------------------------------------------------
    // REMOVE FROM UI
    // --------------------------------------------------------

    setState(() {
      _notifications.removeAt(index);
    });

    // --------------------------------------------------------
    // DELETE FROM FIRESTORE
    // --------------------------------------------------------

    try {
      await _notificationService
          .deleteNotification(
        notification.id,
      );

      _showMessage(
        'Notification removed.',
      );
    } catch (_) {
      await _loadNotifications();

      _showMessage(
        'Unable to remove notification.',
      );
    }
  }

  // ==========================================================
  // CLEAR ALL
  // ==========================================================

  Future<void> _clearAll() async {
    if (_notifications.isEmpty) {
      return;
    }

    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Clear Notifications?',
          ),
          content: const Text(
            'All your notifications will be permanently removed.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Clear',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final notifications =
    List<AppNotification>.from(
      _notifications,
    );

    // --------------------------------------------------------
    // REMOVE FROM UI
    // --------------------------------------------------------

    setState(() {
      _notifications.clear();
    });

    // --------------------------------------------------------
    // DELETE FROM FIRESTORE
    // --------------------------------------------------------

    try {
      for (final notification
      in notifications) {
        if (notification.id
            .trim()
            .isEmpty) {
          continue;
        }

        await _notificationService
            .deleteNotification(
          notification.id,
        );
      }

      _showMessage(
        'Notifications cleared.',
      );
    } catch (_) {
      await _loadNotifications();

      _showMessage(
        'Some notifications could not be removed.',
      );
    }
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void _showMessage(
      String message,
      ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        behavior:
        SnackBarBehavior.floating,
      ),
    );
  }

  // ==========================================================
  // DATE FORMAT
  // ==========================================================

  String _formatDate(
      DateTime date,
      ) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} '
        '${months[date.month - 1]} '
        '${date.year}';
  }

  // ==========================================================
  // TIME FORMAT
  // ==========================================================

  String _formatTime(
      DateTime date,
      ) {
    int hour =
        date.hour % 12;

    if (hour == 0) {
      hour = 12;
    }

    final minute =
    date.minute
        .toString()
        .padLeft(
      2,
      '0',
    );

    final period =
    date.hour >= 12
        ? 'PM'
        : 'AM';

    return '$hour:$minute $period';
  }

  // ==========================================================
  // NOTIFICATION ICON
  // ==========================================================

  IconData _notificationIcon(
      AppNotification notification,
      ) {
    switch (
    notification.type
        .trim()
        .toLowerCase()) {
      case 'complaint':
      case 'complaint_submitted':
      case 'complaint_status_updated':
        return Icons.assignment_outlined;

      case 'article':
        return Icons.menu_book_outlined;

      case 'security':
        return Icons.security_outlined;

      case 'warning':
        return Icons.warning_amber_rounded;

      default:
        return Icons.notifications_none_rounded;
    }
  }

  // ==========================================================
  // NOTIFICATION COLOR
  // ==========================================================

  Color _notificationColor(
      AppNotification notification,
      ) {
    switch (
    notification.type
        .trim()
        .toLowerCase()) {
      case 'complaint':
      case 'complaint_submitted':
      case 'complaint_status_updated':
        return AppColors.primary;

      case 'article':
        return Colors.blue;

      case 'security':
        return Colors.green;

      case 'warning':
        return Colors.orange;

      default:
        return AppColors.primary;
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      AppColors.background,

      // ======================================================
      // APP BAR
      // ======================================================

      appBar: AppBar(
        backgroundColor:
        Colors.transparent,
        foregroundColor:
        AppColors.primary,
        elevation: 0,

        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight:
            FontWeight.w700,
          ),
        ),

        actions: [
          if (_notifications.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert_rounded,
              ),

              onSelected:
                  (value) {
                if (value ==
                    'read') {
                  _markAllAsRead();
                }

                if (value ==
                    'clear') {
                  _clearAll();
                }
              },

              itemBuilder:
                  (context) {
                return const [
                  PopupMenuItem<String>(
                    value: 'read',
                    child: Row(
                      children: [
                        Icon(
                          Icons
                              .done_all_rounded,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Mark all as read',
                        ),
                      ],
                    ),
                  ),

                  PopupMenuItem<String>(
                    value: 'clear',
                    child: Row(
                      children: [
                        Icon(
                          Icons
                              .delete_outline_rounded,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Clear all',
                        ),
                      ],
                    ),
                  ),
                ];
              },
            ),
        ],
      ),

      // ======================================================
      // BODY
      // ======================================================

      body: _isLoading
          ? _buildLoadingState()
          : _notifications.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
        onRefresh:
        _loadNotifications,

        child: ListView(
          physics:
          const AlwaysScrollableScrollPhysics(
            parent:
            BouncingScrollPhysics(),
          ),

          padding:
          const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            30,
          ),

          children: [
            _buildHeader(),

            const SizedBox(
              height: 18,
            ),

            ...List.generate(
              _notifications.length,
                  (index) {
                return _buildAnimatedNotification(
                  index,
                  _notifications[index],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // LOADING
  // ==========================================================

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 38,
            height: 38,
            child:
            CircularProgressIndicator(
              strokeWidth: 3,
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          Text(
            'Loading notifications...',
            style: TextStyle(
              color:
              Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // HEADER
  // ==========================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,

      padding:
      const EdgeInsets.all(20),

      decoration:
      BoxDecoration(
        color:
        AppColors.primary,

        borderRadius:
        BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color:
            AppColors.primary
                .withValues(
              alpha: 0.14,
            ),
            blurRadius: 18,
            offset:
            const Offset(0, 8),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,

            decoration:
            BoxDecoration(
              color:
              Colors.white
                  .withValues(
                alpha: 0.14,
              ),
              shape:
              BoxShape.circle,
            ),

            child: const Icon(
              Icons
                  .notifications_active_outlined,
              color:
              Colors.white,
              size: 27,
            ),
          ),

          const SizedBox(
            width: 15,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stay Updated',
                  style:
                  TextStyle(
                    color:
                    Colors.white,
                    fontSize: 17,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  _unreadCount == 0
                      ? 'You are all caught up.'
                      : 'You have $_unreadCount '
                      'unread notification'
                      '${_unreadCount == 1 ? '' : 's'}.',

                  style:
                  TextStyle(
                    color:
                    Colors.white
                        .withValues(
                      alpha: 0.78,
                    ),
                    fontSize: 12,
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
  // ANIMATED NOTIFICATION
  // ==========================================================

  Widget _buildAnimatedNotification(
      int index,
      AppNotification notification,
      ) {
    final start =
    (index * 0.08)
        .clamp(
      0.0,
      0.65,
    );

    final end =
    (start + 0.35)
        .clamp(
      0.0,
      1.0,
    );

    final animation =
    CurvedAnimation(
      parent:
      _animationController,
      curve: Interval(
        start,
        end,
        curve:
        Curves.easeOutCubic,
      ),
    );

    return FadeTransition(
      opacity: animation,

      child: SlideTransition(
        position:
        Tween<Offset>(
          begin:
          const Offset(
            0,
            0.08,
          ),
          end:
          Offset.zero,
        ).animate(animation),

        child:
        _buildNotificationCard(
          index,
          notification,
        ),
      ),
    );
  }

  // ==========================================================
  // NOTIFICATION CARD
  // ==========================================================

  Widget _buildNotificationCard(
      int index,
      AppNotification notification,
      ) {
    final color =
    _notificationColor(
      notification,
    );

    return Dismissible(
      key: ValueKey(
        notification.id,
      ),

      direction:
      DismissDirection.endToStart,

      background: Container(
        margin:
        const EdgeInsets.only(
          bottom: 12,
        ),

        alignment:
        Alignment.centerRight,

        padding:
        const EdgeInsets.only(
          right: 20,
        ),

        decoration:
        BoxDecoration(
          color:
          Colors.red.shade50,
          borderRadius:
          BorderRadius.circular(
            18,
          ),
        ),

        child: const Icon(
          Icons
              .delete_outline_rounded,
          color:
          Colors.red,
        ),
      ),

      onDismissed: (_) {
        _deleteNotification(
          index,
        );
      },

      child: GestureDetector(
        onTap: () {
          _markAsRead(index);
        },

        child:
        AnimatedContainer(
          duration:
          const Duration(
            milliseconds: 300,
          ),

          margin:
          const EdgeInsets.only(
            bottom: 12,
          ),

          padding:
          const EdgeInsets.all(
            16,
          ),

          decoration:
          BoxDecoration(
            color:
            notification.isRead
                ? Colors.white
                : color.withValues(
              alpha: 0.055,
            ),

            borderRadius:
            BorderRadius.circular(
              18,
            ),

            border:
            Border.all(
              color:
              notification.isRead
                  ? Colors.grey
                  .shade200
                  : color.withValues(
                alpha: 0.18,
              ),
            ),

            boxShadow: [
              BoxShadow(
                color:
                Colors.black
                    .withValues(
                  alpha: 0.025,
                ),
                blurRadius: 12,
                offset:
                const Offset(
                  0,
                  5,
                ),
              ),
            ],
          ),

          child: Row(
            crossAxisAlignment:
            CrossAxisAlignment
                .start,

            children: [
              _buildNotificationIcon(
                color,
                notification,
              ),

              const SizedBox(
                width: 13,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

                  children: [
                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                      children: [
                        Expanded(
                          child:
                          Text(
                            notification
                                .title,

                            style:
                            TextStyle(
                              color:
                              AppColors
                                  .primary,
                              fontSize:
                              14,
                              fontWeight:
                              notification
                                  .isRead
                                  ? FontWeight
                                  .w600
                                  : FontWeight
                                  .w800,
                            ),
                          ),
                        ),

                        if (!notification
                            .isRead)
                          Container(
                            width: 8,
                            height: 8,

                            margin:
                            const EdgeInsets
                                .only(
                              top: 5,
                              left: 8,
                            ),

                            decoration:
                            const BoxDecoration(
                              color:
                              Colors.orange,
                              shape:
                              BoxShape.circle,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(
                      height: 7,
                    ),

                    Text(
                      notification
                          .message,

                      style:
                      const TextStyle(
                        color:
                        Colors.black54,
                        fontSize:
                        12,
                        height:
                        1.45,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Row(
                      children: [
                        const Icon(
                          Icons
                              .access_time_outlined,
                          size: 14,
                          color:
                          Colors.grey,
                        ),

                        const SizedBox(
                          width: 5,
                        ),

                        Text(
                          '${_formatDate(notification.createdAt)}'
                              ' • '
                              '${_formatTime(notification.createdAt)}',

                          style:
                          const TextStyle(
                            color:
                            Colors.grey,
                            fontSize:
                            10,
                          ),
                        ),
                      ],
                    ),

                    // ------------------------------------------------
                    // COMPLAINT ID
                    // ------------------------------------------------

                    if (notification
                        .complaintId
                        .trim()
                        .isNotEmpty) ...[
                      const SizedBox(
                        height: 9,
                      ),

                      Container(
                        padding:
                        const EdgeInsets
                            .symmetric(
                          horizontal:
                          9,
                          vertical:
                          5,
                        ),

                        decoration:
                        BoxDecoration(
                          color:
                          color.withValues(
                            alpha:
                            0.08,
                          ),

                          borderRadius:
                          BorderRadius
                              .circular(
                            8,
                          ),
                        ),

                        child:
                        Text(
                          notification
                              .complaintId,

                          style:
                          TextStyle(
                            color:
                            color,
                            fontSize:
                            10,
                            fontWeight:
                            FontWeight
                                .w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // NOTIFICATION ICON
  // ==========================================================

  Widget _buildNotificationIcon(
      Color color,
      AppNotification notification,
      ) {
    return Container(
      width: 45,
      height: 45,

      decoration:
      BoxDecoration(
        color:
        color.withValues(
          alpha: 0.10,
        ),

        borderRadius:
        BorderRadius.circular(
          14,
        ),
      ),

      child: Icon(
        _notificationIcon(
          notification,
        ),
        color:
        color,
        size: 23,
      ),
    );
  }

  // ==========================================================
  // EMPTY STATE
  // ==========================================================

  Widget _buildEmptyState() {
    return Center(
      child:
      SingleChildScrollView(
        physics:
        const AlwaysScrollableScrollPhysics(),

        padding:
        const EdgeInsets.all(
          30,
        ),

        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [
            TweenAnimationBuilder<
                double>(
              tween:
              Tween<double>(
                begin: 0.75,
                end: 1.0,
              ),

              duration:
              const Duration(
                milliseconds: 700,
              ),

              curve:
              Curves.easeOutBack,

              builder: (
                  context,
                  scale,
                  child,
                  ) {
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },

              child: Container(
                width: 100,
                height: 100,

                decoration:
                BoxDecoration(
                  color:
                  AppColors
                      .primary
                      .withValues(
                    alpha: 0.07,
                  ),
                  shape:
                  BoxShape.circle,
                ),

                child:
                const Icon(
                  Icons
                      .notifications_none_rounded,
                  color:
                  AppColors.primary,
                  size: 48,
                ),
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            const Text(
              'No Notifications',
              style:
              TextStyle(
                color:
                AppColors.primary,
                fontSize:
                20,
                fontWeight:
                FontWeight.w800,
              ),
            ),

            const SizedBox(
              height: 9,
            ),

            const Text(
              'You do not have any notifications yet.\n'
                  'Complaint updates and safety alerts '
                  'will appear here.',
              textAlign:
              TextAlign.center,
              style:
              TextStyle(
                color:
                Colors.grey,
                fontSize:
                13,
                height:
                1.5,
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            // ------------------------------------------------
            // REFRESH BUTTON
            // ------------------------------------------------

            OutlinedButton.icon(
              onPressed:
              _loadNotifications,

              icon:
              const Icon(
                Icons.refresh_rounded,
              ),

              label:
              const Text(
                'Refresh',
              ),
            ),
          ],
        ),
      ),
    );
  }
}