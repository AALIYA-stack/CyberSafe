import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class AdminNotificationsScreen
    extends StatefulWidget {
  const AdminNotificationsScreen({
    super.key,
  });

  @override
  State<AdminNotificationsScreen>
  createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState
    extends State<AdminNotificationsScreen> {
  final List<_AdminNotification> _items = [
    _AdminNotification(
      title: 'New Complaint Submitted',
      message:
      'A new cybercrime complaint requires review.',
      time: 'Just now',
      icon: Icons.report_outlined,
      unread: true,
    ),
    _AdminNotification(
      title: 'Complaint Status Updated',
      message:
      'A complaint has been marked as resolved.',
      time: '20 min ago',
      icon: Icons.sync_rounded,
      unread: true,
    ),
    _AdminNotification(
      title: 'System Update',
      message:
      'CyberSafe demo data has been synchronized.',
      time: '1 hour ago',
      icon: Icons.system_update_outlined,
      unread: false,
    ),
  ];

  void _markAllRead() {
    setState(() {
      for (final item in _items) {
        item.unread = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final unread =
        _items.where((e) => e.unread).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Admin Notifications',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text(
                'Read all',
              ),
            ),
        ],
      ),
      body: _items.isEmpty
          ? const Center(
        child: Text(
          'No notifications',
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(18),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];

          return _NotificationCard(
            item: item,
            onTap: () {
              setState(() {
                item.unread = false;
              });
            },
          );
        },
      ),
    );
  }
}

class _AdminNotification {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  bool unread;

  _AdminNotification({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.unread,
  });
}

class _NotificationCard
    extends StatelessWidget {
  final _AdminNotification item;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
      const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: item.unread
            ? AppColors.primary.withValues(
          alpha: 0.04,
        )
            : AppColors.surface,
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color: item.unread
              ? AppColors.primary
              .withValues(alpha: 0.12)
              : AppColors.border,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding:
        const EdgeInsets.all(14),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary
                .withValues(alpha: 0.08),
            borderRadius:
            BorderRadius.circular(14),
          ),
          child: Icon(
            item.icon,
            color: AppColors.primary,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (item.unread)
              Container(
                width: 8,
                height: 8,
                decoration:
                const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding:
          const EdgeInsets.only(top: 5),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                item.message,
                style: TextStyle(
                  color:
                  Colors.grey.shade600,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                item.time,
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
    );
  }
}