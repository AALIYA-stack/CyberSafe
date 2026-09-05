import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_notification.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance =
  NotificationService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>>
  get _notificationsCollection =>
      _firestore.collection('notifications');

  // ============================================================
  // CREATE NOTIFICATION
  // ============================================================

  Future<String> createNotification({
    required String recipientId,
    required String type,
    required String title,
    required String message,
    String complaintId = '',
    String status = '',
  }) async {
    final cleanRecipientId = recipientId.trim();

    if (cleanRecipientId.isEmpty) {
      throw Exception(
        'Notification recipient ID is missing.',
      );
    }

    final doc = await _notificationsCollection.add({
      'recipientId': cleanRecipientId,
      'type': type.trim(),
      'title': title.trim(),
      'message': message.trim(),
      'complaintId': complaintId.trim(),
      'status': status.trim(),
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  // ============================================================
  // GET MY NOTIFICATIONS
  // ============================================================

  Future<List<AppNotification>> getMyNotifications(
      String userId,
      ) async {
    final cleanUserId = userId.trim();

    if (cleanUserId.isEmpty) {
      return [];
    }

    final snapshot = await _notificationsCollection
        .where(
      'recipientId',
      isEqualTo: cleanUserId,
    )
        .get();

    final notifications = snapshot.docs
        .map(
          (doc) => AppNotification.fromFirestore(doc),
    )
        .toList();

    notifications.sort(
          (a, b) => b.createdAt.compareTo(a.createdAt),
    );

    return notifications;
  }

  // ============================================================
  // REAL-TIME STREAM
  // ============================================================

  Stream<List<AppNotification>> notificationsStream(
      String userId,
      ) {
    final cleanUserId = userId.trim();

    if (cleanUserId.isEmpty) {
      return Stream.value([]);
    }

    return _notificationsCollection
        .where(
      'recipientId',
      isEqualTo: cleanUserId,
    )
        .snapshots()
        .map(
          (snapshot) {
        final notifications = snapshot.docs
            .map(
              (doc) => AppNotification.fromFirestore(doc),
        )
            .toList();

        notifications.sort(
              (a, b) => b.createdAt.compareTo(a.createdAt),
        );

        return notifications;
      },
    );
  }

  // ============================================================
  // UNREAD COUNT
  // ============================================================

  Future<int> unreadCount(String userId) async {
    final cleanUserId = userId.trim();

    if (cleanUserId.isEmpty) {
      return 0;
    }

    final snapshot = await _notificationsCollection
        .where(
      'recipientId',
      isEqualTo: cleanUserId,
    )
        .where(
      'isRead',
      isEqualTo: false,
    )
        .get();

    return snapshot.docs.length;
  }

  // ============================================================
  // MARK ONE AS READ
  // ============================================================

  Future<void> markAsRead(
      String notificationId,
      ) async {
    final cleanId = notificationId.trim();

    if (cleanId.isEmpty) {
      return;
    }

    await _notificationsCollection
        .doc(cleanId)
        .update({
      'isRead': true,
    });
  }

  // ============================================================
  // MARK ALL AS READ
  // ============================================================

  Future<void> markAllAsRead(
      String userId,
      ) async {
    final cleanUserId = userId.trim();

    if (cleanUserId.isEmpty) {
      return;
    }

    final snapshot = await _notificationsCollection
        .where(
      'recipientId',
      isEqualTo: cleanUserId,
    )
        .where(
      'isRead',
      isEqualTo: false,
    )
        .get();

    if (snapshot.docs.isEmpty) {
      return;
    }

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.update(
        doc.reference,
        {
          'isRead': true,
        },
      );
    }

    await batch.commit();
  }

  // ============================================================
  // DELETE NOTIFICATION
  // ============================================================

  Future<void> deleteNotification(
      String notificationId,
      ) async {
    final cleanId = notificationId.trim();

    if (cleanId.isEmpty) {
      return;
    }

    await _notificationsCollection
        .doc(cleanId)
        .delete();
  }

  // ============================================================
  // COMPLAINT NOTIFICATIONS
  // ============================================================

  Future<List<AppNotification>> getComplaintNotifications(
      String userId,
      ) async {
    final notifications =
    await getMyNotifications(userId);

    return notifications
        .where(
          (notification) =>
      notification.type ==
          'complaint_submitted' ||
          notification.type ==
              'complaint_status_updated',
    )
        .toList();
  }

  // ============================================================
  // ARTICLE NOTIFICATIONS
  // ============================================================

  Future<List<AppNotification>> getArticleNotifications(
      String userId,
      ) async {
    final notifications =
    await getMyNotifications(userId);

    return notifications
        .where(
          (notification) =>
      notification.type == 'article',
    )
        .toList();
  }

  // ============================================================
  // NOTIFICATIONS FOR ONE COMPLAINT
  // ============================================================

  Future<List<AppNotification>>
  getNotificationsForComplaint(
      String userId,
      String complaintId,
      ) async {
    final cleanUserId = userId.trim();
    final cleanComplaintId = complaintId.trim();

    if (cleanUserId.isEmpty ||
        cleanComplaintId.isEmpty) {
      return [];
    }

    final snapshot = await _notificationsCollection
        .where(
      'recipientId',
      isEqualTo: cleanUserId,
    )
        .where(
      'complaintId',
      isEqualTo: cleanComplaintId,
    )
        .get();

    final notifications = snapshot.docs
        .map(
          (doc) => AppNotification.fromFirestore(doc),
    )
        .toList();

    notifications.sort(
          (a, b) => b.createdAt.compareTo(a.createdAt),
    );

    return notifications;
  }

  // ============================================================
  // ADMIN - NEW COMPLAINT
  // ============================================================

  Future<String> notifyAdminNewComplaint({
    required String adminId,
    required String complaintId,
    String status = 'Submitted',
  }) async {
    return createNotification(
      recipientId: adminId,
      type: 'complaint_submitted',
      title: 'New Complaint Submitted',
      message:
      'A new complaint $complaintId has been submitted and requires review.',
      complaintId: complaintId,
      status: status,
    );
  }

  // ============================================================
  // ADMIN - MULTIPLE ADMINS
  // ============================================================

  Future<void> notifyAdminsNewComplaint({
    required List<String> adminIds,
    required String complaintId,
    String status = 'Submitted',
  }) async {
    final cleanAdminIds = adminIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    if (cleanAdminIds.isEmpty) {
      return;
    }

    for (final adminId in cleanAdminIds) {
      await notifyAdminNewComplaint(
        adminId: adminId,
        complaintId: complaintId,
        status: status,
      );
    }
  }

  // ============================================================
  // USER - COMPLAINT STATUS UPDATED
  // ============================================================

  Future<String?>
  notifyUserComplaintStatusChanged({
    required String userId,
    required String complaintId,
    required String status,
  }) async {
    final cleanUserId = userId.trim();
    final cleanComplaintId = complaintId.trim();
    final cleanStatus = status.trim();

    if (cleanUserId.isEmpty ||
        cleanComplaintId.isEmpty ||
        cleanStatus.isEmpty) {
      return null;
    }

    return createNotification(
      recipientId: cleanUserId,
      type: 'complaint_status_updated',
      title: 'Complaint Status Updated',
      message:
      'Your complaint $cleanComplaintId is now $cleanStatus.',
      complaintId: cleanComplaintId,
      status: cleanStatus,
    );
  }
}