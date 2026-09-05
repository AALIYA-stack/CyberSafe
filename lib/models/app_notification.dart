import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String recipientId;
  final String type;
  final String title;
  final String message;
  final String complaintId;
  final bool isRead;
  final DateTime createdAt;
  final String status;

  const AppNotification({
    required this.id,
    required this.recipientId,
    required this.type,
    required this.title,
    required this.message,
    this.complaintId = '',
    this.isRead = false,
    required this.createdAt,
    this.status = '',
  });

  factory AppNotification.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};

    DateTime createdAt = DateTime.now();

    final timestamp = data['createdAt'];

    if (timestamp is Timestamp) {
      createdAt = timestamp.toDate();
    } else if (timestamp is DateTime) {
      createdAt = timestamp;
    }

    return AppNotification(
      id: doc.id,
      recipientId: (data['recipientId'] ?? '').toString(),
      type: (data['type'] ?? '').toString(),
      title: (data['title'] ?? '').toString(),
      message: (data['message'] ?? '').toString(),
      complaintId: (data['complaintId'] ?? '').toString(),
      isRead: data['isRead'] == true,
      createdAt: createdAt,
      status: (data['status'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'recipientId': recipientId,
      'type': type,
      'title': title,
      'message': message,
      'complaintId': complaintId,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
    };
  }

  AppNotification copyWith({
    String? id,
    String? recipientId,
    String? type,
    String? title,
    String? message,
    String? complaintId,
    bool? isRead,
    DateTime? createdAt,
    String? status,
  }) {
    return AppNotification(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      complaintId: complaintId ?? this.complaintId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}