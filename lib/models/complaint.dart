import 'package:cloud_firestore/cloud_firestore.dart';

import 'complaint_status.dart';

class Complaint {
  final String id;
  final String userId;

  final String title;
  final String category;

  final String user;
  final String userEmail;
  final String phone;

  final DateTime date;
  final String platform;
  final String location;

  final String suspect;
  final String suspectContact;

  final String description;

  // Simple evidence file names.
  final List<String> evidence;

  // Detailed evidence information.
  //
  // Example:
  // {
  //   'name': 'image.png',
  //   'base64': '...',
  //   'type': 'image/png',
  // }
  final List<Map<String, dynamic>> evidenceFiles;

  final ComplaintStatus status;
  final DateTime submittedDate;

  const Complaint({
    required this.id,
    required this.userId,
    required this.title,
    required this.category,
    required this.user,
    required this.userEmail,
    required this.phone,
    required this.date,
    required this.platform,
    required this.location,
    required this.suspect,
    required this.suspectContact,
    required this.description,
    this.evidence = const [],
    this.evidenceFiles = const [],
    required this.status,
    required this.submittedDate,
  });

  // ==========================================================
  // FIRESTORE -> COMPLAINT
  // ==========================================================

  factory Complaint.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};

    return Complaint.fromMap(
      data,
      documentId: doc.id,
    );
  }

  // ==========================================================
  // MAP -> COMPLAINT
  // ==========================================================

  factory Complaint.fromMap(
      Map<String, dynamic> map, {
        String? documentId,
      }) {
    return Complaint(
      id: documentId ??
          map['id']?.toString() ??
          '',

      userId:
      map['userId']?.toString() ?? '',

      title:
      map['title']?.toString() ?? '',

      category:
      map['category']?.toString() ?? '',

      user:
      map['user']?.toString() ??
          map['name']?.toString() ??
          '',

      userEmail:
      map['userEmail']?.toString() ??
          map['email']?.toString() ??
          '',

      phone:
      map['phone']?.toString() ?? '',

      date: _parseDate(
        map['date'] ??
            map['incidentDate'],
      ),

      platform:
      map['platform']?.toString() ?? '',

      location:
      map['location']?.toString() ?? '',

      suspect:
      map['suspect']?.toString() ?? '',

      suspectContact:
      map['suspectContact']?.toString() ?? '',

      description:
      map['description']?.toString() ?? '',

      evidence:
      _parseEvidence(
        map['evidence'],
      ),

      evidenceFiles:
      _parseEvidenceFiles(
        map['evidenceFiles'],
      ),

      status:
      ComplaintStatusExtension
          .fromFirestoreValue(
        map['status'],
      ),

      submittedDate:
      _parseDate(
        map['submittedDate'] ??
            map['createdAt'],
      ),
    );
  }

  // ==========================================================
  // COMPLAINT -> MAP
  // ==========================================================

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,

      'title': title,
      'category': category,

      'user': user,
      'userEmail': userEmail,
      'phone': phone,

      'date': Timestamp.fromDate(date),

      'platform': platform,
      'location': location,

      'suspect': suspect,
      'suspectContact': suspectContact,

      'description': description,

      'evidence': List<String>.from(
        evidence,
      ),

      'evidenceFiles':
      evidenceFiles.map(
            (file) => {
          'name':
          file['name']?.toString() ?? '',
          'base64':
          file['base64']?.toString() ?? '',
          'type':
          file['type']?.toString() ?? '',
        },
      ).toList(),

      'status':
      status.firestoreValue,

      'submittedDate':
      Timestamp.fromDate(
        submittedDate,
      ),
    };
  }

  // ==========================================================
  // COPY WITH
  // ==========================================================

  Complaint copyWith({
    String? id,
    String? userId,
    String? title,
    String? category,
    String? user,
    String? userEmail,
    String? phone,
    DateTime? date,
    String? platform,
    String? location,
    String? suspect,
    String? suspectContact,
    String? description,
    List<String>? evidence,
    List<Map<String, dynamic>>?
    evidenceFiles,
    ComplaintStatus? status,
    DateTime? submittedDate,
  }) {
    return Complaint(
      id: id ?? this.id,
      userId: userId ?? this.userId,

      title: title ?? this.title,
      category: category ?? this.category,

      user: user ?? this.user,
      userEmail:
      userEmail ?? this.userEmail,
      phone: phone ?? this.phone,

      date: date ?? this.date,
      platform:
      platform ?? this.platform,
      location:
      location ?? this.location,

      suspect:
      suspect ?? this.suspect,
      suspectContact:
      suspectContact ??
          this.suspectContact,

      description:
      description ?? this.description,

      evidence:
      evidence ?? this.evidence,

      evidenceFiles:
      evidenceFiles ??
          this.evidenceFiles,

      status:
      status ?? this.status,

      submittedDate:
      submittedDate ??
          this.submittedDate,
    );
  }

  // ==========================================================
  // DATE PARSER
  // ==========================================================

  static DateTime _parseDate(
      dynamic value,
      ) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      final parsed =
      DateTime.tryParse(value);

      if (parsed != null) {
        return parsed;
      }
    }

    return DateTime.now();
  }

  // ==========================================================
  // EVIDENCE PARSER
  // ==========================================================

  static List<String> _parseEvidence(
      dynamic value,
      ) {
    if (value is! List) {
      return [];
    }

    return value
        .map(
          (item) =>
          item.toString(),
    )
        .where(
          (item) =>
      item.trim().isNotEmpty,
    )
        .toList();
  }

  // ==========================================================
  // EVIDENCE FILES PARSER
  // ==========================================================

  static List<Map<String, dynamic>>
  _parseEvidenceFiles(
      dynamic value,
      ) {
    if (value is! List) {
      return [];
    }

    final result =
    <Map<String, dynamic>>[];

    for (final item in value) {
      if (item is Map) {
        final map =
        Map<String, dynamic>.from(
          item,
        );

        result.add({
          'name':
          map['name']?.toString() ?? '',
          'base64':
          map['base64']?.toString() ?? '',
          'type':
          map['type']?.toString() ?? '',
        });
      }
    }

    return result;
  }

  // ==========================================================
  // DEBUG
  // ==========================================================

  @override
  String toString() {
    return 'Complaint('
        'id: $id, '
        'userId: $userId, '
        'title: $title, '
        'category: $category, '
        'status: ${status.firestoreValue}'
        ')';
  }
}