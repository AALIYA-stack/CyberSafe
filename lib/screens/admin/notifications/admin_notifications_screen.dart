import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/app_notification.dart';
import '../../../services/notification_service.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({
    super.key,
  });

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState
    extends State<AdminNotificationsScreen> {
  final NotificationService _notificationService =
      NotificationService.instance;

  String get _currentUserId {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  // ============================================================
  // MARK ALL AS READ
  // ============================================================

  Future<void> _markAllRead() async {
    final userId = _currentUserId;

    if (userId.isEmpty) {
      return;
    }

    await _notificationService.markAllAsRead(
      userId,
    );
  }

  // ============================================================
  // MARK ONE AS READ
  // ============================================================

  Future<void> _markAsRead(
      AppNotification notification,
      ) async {
    if (notification.isRead) {
      return;
    }

    await _notificationService.markAsRead(
      notification.id,
    );
  }

  // ============================================================
  // DELETE NOTIFICATION
  // ============================================================

  Future<void> _deleteNotification(
      AppNotification notification,
      ) async {
    await _notificationService.deleteNotification(
      notification.id,
    );
  }

  // ============================================================
  // GET NOTIFICATION ICON
  // ============================================================

  IconData _getNotificationIcon(
      String type,
      ) {
    switch (type) {
      case 'complaint_submitted':
        return Icons.report_outlined;

      case 'complaint_status_updated':
        return Icons.sync_rounded;

      case 'article':
        return Icons.article_outlined;

      case 'system':
        return Icons.system_update_outlined;

      default:
        return Icons.notifications_outlined;
    }
  }

  // ============================================================
  // GET NOTIFICATION TIME
  // ============================================================

  String _getTimeText(
      DateTime dateTime,
      ) {
    final now = DateTime.now();

    final difference =
    now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      final minutes =
          difference.inMinutes;

      return '$minutes min ago';
    }

    if (difference.inHours < 24) {
      final hours =
          difference.inHours;

      return '$hours hour${hours == 1 ? '' : 's'} ago';
    }

    if (difference.inDays < 7) {
      final days =
          difference.inDays;

      return '$days day${days == 1 ? '' : 's'} ago';
    }

    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year}';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final userId =
        _currentUserId;

    if (userId.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Admin session not found.',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
      AppColors.background,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        title: const Text(
          'Admin Notifications',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),

        actions: [
          StreamBuilder<List<AppNotification>>(
            stream:
            _notificationService
                .notificationsStream(
              userId,
            ),
            builder: (
                context,
                snapshot,
                ) {
              final notifications =
                  snapshot.data ??
                      [];

              final unreadCount =
                  notifications
                      .where(
                        (notification) =>
                    !notification.isRead,
                  )
                      .length;

              if (unreadCount == 0) {
                return const SizedBox.shrink();
              }

              return TextButton(
                onPressed:
                _markAllRead,
                child: const Text(
                  'Read all',
                ),
              );
            },
          ),
        ],
      ),

      // ========================================================
      // FIRESTORE REAL-TIME NOTIFICATIONS
      // ========================================================

      body: StreamBuilder<List<AppNotification>>(
        stream:
        _notificationService
            .notificationsStream(
          userId,
        ),

        builder: (
            context,
            snapshot,
            ) {
          // ----------------------------------------------------
          // ERROR
          // ----------------------------------------------------

          if (snapshot.hasError) {
            return _ErrorState(
              message:
              'Unable to load notifications.',
              onRetry: () {
                setState(() {});
              },
            );
          }

          // ----------------------------------------------------
          // LOADING
          // ----------------------------------------------------

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          final notifications =
              snapshot.data ??
                  [];

          // ----------------------------------------------------
          // EMPTY
          // ----------------------------------------------------

          if (notifications.isEmpty) {
            return const _EmptyState();
          }

          // ----------------------------------------------------
          // NOTIFICATION LIST
          // ----------------------------------------------------

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },

            child: ListView.builder(
              padding:
              const EdgeInsets.all(
                18,
              ),

              itemCount:
              notifications.length,

              itemBuilder:
                  (
                  context,
                  index,
                  ) {
                final notification =
                notifications[index];

                return _NotificationCard(
                  notification:
                  notification,

                  icon:
                  _getNotificationIcon(
                    notification.type,
                  ),

                  time:
                  _getTimeText(
                    notification.createdAt,
                  ),

                  onTap: () {
                    _markAsRead(
                      notification,
                    );
                  },

                  onDelete: () {
                    _deleteNotification(
                      notification,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ==================================================================
// NOTIFICATION CARD
// ==================================================================

class _NotificationCard
    extends StatelessWidget {
  final AppNotification notification;
  final IconData icon;
  final String time;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.notification,
    required this.icon,
    required this.time,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final bool unread =
    !notification.isRead;

    return Dismissible(
      key: ValueKey(
        notification.id,
      ),

      direction:
      DismissDirection.endToStart,

      confirmDismiss:
          (_) async {
        return true;
      },

      onDismissed:
          (_) {
        onDelete();
      },

      background: Container(
        margin:
        const EdgeInsets.only(
          bottom: 12,
        ),

        alignment:
        Alignment.centerRight,

        padding:
        const EdgeInsets.only(
          right: 24,
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

        child: Icon(
          Icons.delete_outline,
          color:
          Colors.red.shade700,
        ),
      ),

      child: Container(
        margin:
        const EdgeInsets.only(
          bottom: 12,
        ),

        decoration:
        BoxDecoration(
          color: unread
              ? AppColors.primary
              .withValues(
            alpha: 0.04,
          )
              : AppColors.surface,

          borderRadius:
          BorderRadius.circular(
            18,
          ),

          border:
          Border.all(
            color: unread
                ? AppColors.primary
                .withValues(
              alpha: 0.12,
            )
                : AppColors.border,
          ),
        ),

        child: ListTile(
          onTap: onTap,

          contentPadding:
          const EdgeInsets.all(
            14,
          ),

          // ----------------------------------------------------
          // ICON
          // ----------------------------------------------------

          leading: Container(
            width: 48,
            height: 48,

            decoration:
            BoxDecoration(
              color: AppColors.primary
                  .withValues(
                alpha: 0.08,
              ),

              borderRadius:
              BorderRadius.circular(
                14,
              ),
            ),

            child: Icon(
              icon,
              color:
              AppColors.primary,
            ),
          ),

          // ----------------------------------------------------
          // TITLE
          // ----------------------------------------------------

          title: Row(
            children: [
              Expanded(
                child: Text(
                  notification.title,
                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ),

              if (unread)
                Container(
                  width: 8,
                  height: 8,

                  decoration:
                  const BoxDecoration(
                    color:
                    AppColors.primary,
                    shape:
                    BoxShape.circle,
                  ),
                ),
            ],
          ),

          // ----------------------------------------------------
          // MESSAGE + TIME
          // ----------------------------------------------------

          subtitle:
          Padding(
            padding:
            const EdgeInsets.only(
              top: 5,
            ),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,

              children: [
                Text(
                  notification.message,
                  style: TextStyle(
                    color:
                    Colors.grey.shade600,
                    height: 1.35,
                  ),
                ),

                // Complaint ID
                if (notification
                    .complaintId
                    .trim()
                    .isNotEmpty)
                  Padding(
                    padding:
                    const EdgeInsets
                        .only(
                      top: 6,
                    ),

                    child: Text(
                      'Complaint ID: '
                          '${notification.complaintId}',
                      style:
                      TextStyle(
                        color:
                        AppColors.primary,
                        fontSize: 12,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),

                const SizedBox(
                  height: 7,
                ),

                Text(
                  time,
                  style: TextStyle(
                    color:
                    Colors.grey.shade500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// EMPTY STATE
// ==================================================================

class _EmptyState
    extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(
      BuildContext context,
      ) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(
          30,
        ),

        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [
            Container(
              width: 76,
              height: 76,

              decoration:
              BoxDecoration(
                color:
                AppColors.primary
                    .withValues(
                  alpha: 0.08,
                ),

                shape:
                BoxShape.circle,
              ),

              child: Icon(
                Icons.notifications_none_rounded,
                size: 38,
                color:
                AppColors.primary,
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            const Text(
              'No notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.w800,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              'You will see new complaint '
                  'notifications here.',
              textAlign:
              TextAlign.center,
              style: TextStyle(
                color:
                Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// ERROR STATE
// ==================================================================

class _ErrorState
    extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(
          30,
        ),

        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color:
              Colors.red.shade400,
            ),

            const SizedBox(
              height: 14,
            ),

            Text(
              message,
              textAlign:
              TextAlign.center,
              style: const TextStyle(
                fontWeight:
                FontWeight.w600,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            ElevatedButton(
              onPressed: onRetry,
              child: const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }
}