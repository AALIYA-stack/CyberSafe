import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_notification.dart';

class NotificationService {
NotificationService._();

static final NotificationService instance =
NotificationService._();

final FirebaseFirestore _firestore =
FirebaseFirestore.instance;

final FirebaseAuth _auth =
FirebaseAuth.instance;

// ============================================================
// FIRESTORE COLLECTION
// ============================================================

CollectionReference<Map<String, dynamic>>
get _notificationsCollection {
return _firestore.collection('notifications');
}

// ============================================================
// CURRENT USER ID
// ============================================================

String get _currentUserId {
return _auth.currentUser?.uid ?? '';
}

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
final cleanRecipientId =
recipientId.trim();

final cleanType =
type.trim();

final cleanTitle =
title.trim();

final cleanMessage =
message.trim();

final cleanComplaintId =
complaintId.trim();

final cleanStatus =
status.trim();

// ----------------------------------------------------------
// VALIDATION
// ----------------------------------------------------------

if (cleanRecipientId.isEmpty) {
throw Exception(
'Notification recipient ID is missing.',
);
}

if (cleanType.isEmpty) {
throw Exception(
'Notification type is missing.',
);
}

if (cleanTitle.isEmpty) {
throw Exception(
'Notification title is missing.',
);
}

if (cleanMessage.isEmpty) {
throw Exception(
'Notification message is missing.',
);
}

// ----------------------------------------------------------
// AUTHENTICATION
// ----------------------------------------------------------

final currentUser = _auth.currentUser;

if (currentUser == null) {
throw Exception(
'User is not logged in.',
);
}

// ----------------------------------------------------------
// SELF NOTIFICATION
// ----------------------------------------------------------
//
// Current Firestore rules user ko apne liye
// complaint_submitted notification create karne nahi deti.
//
// Isliye ComplaintService mein agar self-notification
// attempt hoti hai to usko safely skip kar denge.
//
// Admin -> User notification is condition se affected
// nahi hoti, kyunki admin currentUser alag hota hai.
//
// ----------------------------------------------------------

final isSelfNotification =
cleanRecipientId == _currentUserId;

if (isSelfNotification &&
cleanType == 'complaint_submitted') {
print(
'Self complaint notification skipped '
'because current Firestore rules do not allow it.',
);

return '';
}

// ----------------------------------------------------------
// NOTIFICATION DATA
// ----------------------------------------------------------

final notificationData =
<String, dynamic>{
'recipientId':
cleanRecipientId,

'type':
cleanType,

'title':
cleanTitle,

'message':
cleanMessage,

'complaintId':
cleanComplaintId,

'status':
cleanStatus,

'isRead':
false,

'createdAt':
FieldValue.serverTimestamp(),
};

// ----------------------------------------------------------
// SAVE NOTIFICATION
// ----------------------------------------------------------

final doc =
await _notificationsCollection.add(
notificationData,
);

return doc.id;
}

// ============================================================
// GET MY NOTIFICATIONS
// ============================================================

Future<List<AppNotification>>
getMyNotifications(
String userId,
) async {
final cleanUserId =
userId.trim();

if (cleanUserId.isEmpty) {
return [];
}

final currentUserId =
_currentUserId;

if (currentUserId.isEmpty) {
return [];
}

// User sirf apni notifications read kare.
if (cleanUserId != currentUserId) {
return [];
}

try {
final snapshot =
await _notificationsCollection
    .where(
'recipientId',
isEqualTo: cleanUserId,
)
    .get();

final notifications =
snapshot.docs
    .map(
(doc) =>
AppNotification
    .fromFirestore(doc),
)
    .toList();

notifications.sort(
(a, b) =>
b.createdAt.compareTo(
a.createdAt,
),
);

return notifications;
} catch (e) {
print(
'Failed to load notifications: $e',
);

return [];
}
}

// ============================================================
// REAL-TIME STREAM
// ============================================================

Stream<List<AppNotification>>
notificationsStream(
String userId,
) {
final cleanUserId =
userId.trim();

if (cleanUserId.isEmpty) {
return Stream.value([]);
}

final currentUserId =
_currentUserId;

if (currentUserId.isEmpty ||
cleanUserId != currentUserId) {
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
final notifications =
snapshot.docs
    .map(
(doc) =>
AppNotification
    .fromFirestore(doc),
)
    .toList();

notifications.sort(
(a, b) =>
b.createdAt.compareTo(
a.createdAt,
),
);

return notifications;
},
);
}

// ============================================================
// UNREAD COUNT
// ============================================================

Future<int> unreadCount(
String userId,
) async {
final cleanUserId =
userId.trim();

if (cleanUserId.isEmpty) {
return 0;
}

final currentUserId =
_currentUserId;

if (currentUserId.isEmpty ||
cleanUserId != currentUserId) {
return 0;
}

try {
final snapshot =
await _notificationsCollection
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
} catch (e) {
print(
'Failed to load unread count: $e',
);

return 0;
}
}

// ============================================================
// MARK ONE AS READ
// ============================================================

Future<void> markAsRead(
String notificationId,
) async {
final cleanId =
notificationId.trim();

if (cleanId.isEmpty) {
return;
}

try {
final doc =
await _notificationsCollection
    .doc(cleanId)
    .get();

if (!doc.exists) {
return;
}

final data =
doc.data();

if (data == null) {
return;
}

final recipientId =
(data['recipientId'] ??
'')
    .toString()
    .trim();

// Sirf apni notification update ho.
if (recipientId !=
_currentUserId) {
return;
}

await _notificationsCollection
    .doc(cleanId)
    .update({
'isRead': true,
});
} catch (e) {
print(
'Failed to mark notification as read: $e',
);
}
}

// ============================================================
// MARK ALL AS READ
// ============================================================

Future<void> markAllAsRead(
String userId,
) async {
final cleanUserId =
userId.trim();

if (cleanUserId.isEmpty) {
return;
}

if (cleanUserId !=
_currentUserId) {
return;
}

try {
final snapshot =
await _notificationsCollection
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

final batch =
_firestore.batch();

for (final doc
in snapshot.docs) {
batch.update(
doc.reference,
{
'isRead': true,
},
);
}

await batch.commit();
} catch (e) {
print(
'Failed to mark all notifications as read: $e',
);
}
}

// ============================================================
// DELETE NOTIFICATION
// ============================================================

Future<void> deleteNotification(
String notificationId,
) async {
final cleanId =
notificationId.trim();

if (cleanId.isEmpty) {
return;
}

try {
final doc =
await _notificationsCollection
    .doc(cleanId)
    .get();

if (!doc.exists) {
return;
}

final data =
doc.data();

if (data == null) {
return;
}

final recipientId =
(data['recipientId'] ??
'')
    .toString()
    .trim();

if (recipientId !=
_currentUserId) {
return;
}

await _notificationsCollection
    .doc(cleanId)
    .delete();
} catch (e) {
print(
'Failed to delete notification: $e',
);
}
}

// ============================================================
// COMPLAINT NOTIFICATIONS
// ============================================================

Future<List<AppNotification>>
getComplaintNotifications(
String userId,
) async {
final notifications =
await getMyNotifications(
userId,
);

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

Future<List<AppNotification>>
getArticleNotifications(
String userId,
) async {
final notifications =
await getMyNotifications(
userId,
);

return notifications
    .where(
(notification) =>
notification.type ==
'article',
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
final cleanUserId =
userId.trim();

final cleanComplaintId =
complaintId.trim();

if (cleanUserId.isEmpty ||
cleanComplaintId.isEmpty) {
return [];
}

if (cleanUserId !=
_currentUserId) {
return [];
}

try {
final snapshot =
await _notificationsCollection
    .where(
'recipientId',
isEqualTo: cleanUserId,
)
    .where(
'complaintId',
isEqualTo:
cleanComplaintId,
)
    .get();

final notifications =
snapshot.docs
    .map(
(doc) =>
AppNotification
    .fromFirestore(doc),
)
    .toList();

notifications.sort(
(a, b) =>
b.createdAt.compareTo(
a.createdAt,
),
);

return notifications;
} catch (e) {
print(
'Failed to load complaint notifications: $e',
);

return [];
}
}

// ============================================================
// ADMIN - NEW COMPLAINT
// ============================================================

Future<String>
notifyAdminNewComplaint({
required String adminId,
required String complaintId,
String status = 'Submitted',
}) async {
final cleanAdminId =
adminId.trim();

final cleanComplaintId =
complaintId.trim();

if (cleanAdminId.isEmpty) {
throw Exception(
'Admin ID is missing.',
);
}

if (cleanComplaintId.isEmpty) {
throw Exception(
'Complaint ID is missing.',
);
}

return createNotification(
recipientId: cleanAdminId,
type: 'complaint_submitted',
title: 'New Complaint Submitted',
message:
'A new complaint $cleanComplaintId has been submitted and requires review.',
complaintId:
cleanComplaintId,
status: status.trim(),
);
}

// ============================================================
// ADMIN - MULTIPLE ADMINS
// ============================================================

Future<void>
notifyAdminsNewComplaint({
required List<String> adminIds,
required String complaintId,
String status = 'Submitted',
}) async {
final cleanAdminIds =
adminIds
    .map(
(id) => id.trim(),
)
    .where(
(id) => id.isNotEmpty,
)
    .toSet()
    .toList();

if (cleanAdminIds.isEmpty) {
return;
}

for (final adminId
in cleanAdminIds) {
try {
await notifyAdminNewComplaint(
adminId: adminId,
complaintId: complaintId,
status: status,
);
} catch (e) {
print(
'Admin notification error for $adminId: $e',
);
}
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
final cleanUserId =
userId.trim();

final cleanComplaintId =
complaintId.trim();

final cleanStatus =
status.trim();

if (cleanUserId.isEmpty ||
cleanComplaintId.isEmpty ||
cleanStatus.isEmpty) {
return null;
}

// ----------------------------------------------------------
// IMPORTANT
// ----------------------------------------------------------
//
// Ye function normally ADMIN ke account se call hoga.
//
// Admin complaint status update karega:
//
// Admin
//   ↓
// NotificationService
//   ↓
// User notification
//
// Firestore rules is operation ko allow karti hain
// because admin is allowed to create notifications.
//
// ----------------------------------------------------------

try {
return await createNotification(
recipientId: cleanUserId,
type: 'complaint_status_updated',
title:
'Complaint Status Updated',
message:
'Your complaint $cleanComplaintId is now $cleanStatus.',
complaintId:
cleanComplaintId,
status: cleanStatus,
);
} catch (e) {
print(
'User status notification error: $e',
);

return null;
}
}
}

