import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_notification.dart';
import '../models/complaint.dart';
import '../models/complaint_status.dart';
import 'notification_service.dart';

class ComplaintService {
  ComplaintService._();

  static final ComplaintService instance = ComplaintService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ============================================================
  // ERROR HANDLING
  // ============================================================

  String _lastError = '';

  String get lastError => _lastError;

  // ============================================================
  // FIRESTORE COLLECTION
  // ============================================================

  CollectionReference<Map<String, dynamic>>
  get _complaintsCollection {
    return _firestore.collection('complaints');
  }

  // ============================================================
  // CURRENT USER ID
  // ============================================================

  String get _currentUserId {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  // ============================================================
  // CURRENT USER
  // ============================================================

  User? get currentUser {
    return FirebaseAuth.instance.currentUser;
  }

  // ============================================================
  // GET SINGLE ADMIN ID
  // ============================================================
  //
  // Firestore structure:
  //
  // app_config
  //    └── admins
  //         └── adminId: "ADMIN_UID"
  //
  // Sirf ONE admin use ho raha hai.
  //
  // ============================================================

  Future<String> _getAdminId() async {
    try {
      final doc = await _firestore
          .collection('app_config')
          .doc('admins')
          .get();

      if (!doc.exists) {
        print('Admin configuration document not found.');
        return '';
      }

      final data = doc.data();

      if (data == null) {
        print('Admin configuration data is missing.');
        return '';
      }

      final adminId =
      (data['adminId'] ?? '').toString().trim();

      if (adminId.isEmpty) {
        print('Admin ID is empty.');
        return '';
      }

      print('Admin ID found successfully.');

      return adminId;
    } catch (e) {
      print('Failed to get admin ID: $e');
      return '';
    }
  }

  // ============================================================
  // CREATE COMPLAINT
  // ============================================================

  Future<String> createComplaint({
    required String userId,
    required String name,
    required String email,
    required String phone,
    required String title,
    required String description,
    required String category,
    required String platform,
    required DateTime incidentDate,
    String location = '',
    String suspect = '',
    String suspectContact = '',
    List<String> evidence = const [],
    List<Map<String, dynamic>> evidenceFiles = const [],
  }) async {
    _lastError = '';

    try {
      // ----------------------------------------------------------
      // CLEAN DATA
      // ----------------------------------------------------------

      final cleanUserId = userId.trim();
      final cleanName = name.trim();
      final cleanEmail = email.trim();
      final cleanPhone = phone.trim();
      final cleanTitle = title.trim();
      final cleanDescription = description.trim();
      final cleanCategory = category.trim();
      final cleanPlatform = platform.trim();
      final cleanLocation = location.trim();
      final cleanSuspect = suspect.trim();
      final cleanSuspectContact = suspectContact.trim();

      // ----------------------------------------------------------
      // AUTHENTICATION VALIDATION
      // ----------------------------------------------------------

      final loggedInUser =
          FirebaseAuth.instance.currentUser;

      if (loggedInUser == null) {
        throw Exception(
          'User is not logged in. Please login again.',
        );
      }

      final loggedInUserId = loggedInUser.uid;

      if (cleanUserId.isEmpty) {
        throw Exception(
          'User ID is missing.',
        );
      }

      // Firestore rule:
      // request.resource.data.userId == request.auth.uid

      if (cleanUserId != loggedInUserId) {
        throw Exception(
          'User authentication mismatch. Please login again.',
        );
      }

      // ----------------------------------------------------------
      // BASIC VALIDATION
      // ----------------------------------------------------------

      if (cleanName.isEmpty) {
        throw Exception(
          'Name is required.',
        );
      }

      if (cleanEmail.isEmpty) {
        throw Exception(
          'Email is required.',
        );
      }

      if (cleanPhone.isEmpty) {
        throw Exception(
          'Phone number is required.',
        );
      }

      if (cleanTitle.isEmpty) {
        throw Exception(
          'Complaint title is required.',
        );
      }

      if (cleanDescription.isEmpty) {
        throw Exception(
          'Complaint description is required.',
        );
      }

      if (cleanCategory.isEmpty) {
        throw Exception(
          'Complaint category is required.',
        );
      }

      if (cleanPlatform.isEmpty) {
        throw Exception(
          'Platform is required.',
        );
      }

      // ----------------------------------------------------------
      // INCIDENT DATE VALIDATION
      // ----------------------------------------------------------

      final today = DateTime.now();

      final todayOnly = DateTime(
        today.year,
        today.month,
        today.day,
      );

      final incidentDateOnly = DateTime(
        incidentDate.year,
        incidentDate.month,
        incidentDate.day,
      );

      if (incidentDateOnly.isAfter(todayOnly)) {
        throw Exception(
          'Incident date cannot be in the future.',
        );
      }

      // ----------------------------------------------------------
      // GENERATE COMPLAINT ID
      // ----------------------------------------------------------

      final complaintId =
      await _generateComplaintId();

      final now = DateTime.now();

      // ----------------------------------------------------------
      // PREPARE EVIDENCE FILES
      // ----------------------------------------------------------

      final cleanedEvidenceFiles =
      evidenceFiles
          .map<Map<String, dynamic>>(
            (file) {
          return <String, dynamic>{
            'name':
            file['name']
                ?.toString()
                .trim() ??
                '',
            'base64':
            file['base64']
                ?.toString() ??
                '',
            'type':
            file['type']
                ?.toString()
                .trim() ??
                '',
          };
        },
      )
          .where(
            (file) {
          final fileName =
              file['name']
                  ?.toString()
                  .trim() ??
                  '';

          return fileName.isNotEmpty;
        },
      )
          .toList();

      // ----------------------------------------------------------
      // PREPARE EVIDENCE NAMES
      // ----------------------------------------------------------

      final cleanedEvidence =
      evidence
          .map(
            (item) => item.toString().trim(),
      )
          .where(
            (item) => item.isNotEmpty,
      )
          .toList();

      // ----------------------------------------------------------
      // COMPLAINT DATA
      // ----------------------------------------------------------

      final complaintData =
      <String, dynamic>{
        'id': complaintId,

        'complaintId': complaintId,

        // Owner
        'userId': cleanUserId,

        'ownerId': cleanUserId,

        // Complaint information
        'title': cleanTitle,

        'category': cleanCategory,

        // User information
        'user': cleanName,

        'name': cleanName,

        'userEmail': cleanEmail,

        'email': cleanEmail,

        'phone': cleanPhone,

        // Incident information
        'date': Timestamp.fromDate(
          incidentDate,
        ),

        'incidentDate': Timestamp.fromDate(
          incidentDate,
        ),

        'platform': cleanPlatform,

        'location': cleanLocation,

        'suspect': cleanSuspect,

        'suspectContact': cleanSuspectContact,

        'description': cleanDescription,

        // Evidence
        'evidence': cleanedEvidence,

        'evidenceFiles': cleanedEvidenceFiles,

        // Status
        'status':
        ComplaintStatus.submitted.firestoreValue,

        // Dates
        'submittedDate':
        Timestamp.fromDate(now),

        'createdAt':
        FieldValue.serverTimestamp(),

        'updatedAt':
        FieldValue.serverTimestamp(),

        // Analytics
        'year': now.year,
      };

      // ----------------------------------------------------------
      // SAVE COMPLAINT TO FIRESTORE
      // ----------------------------------------------------------

      await _complaintsCollection
          .doc(complaintId)
          .set(complaintData);

      print(
        'Complaint saved successfully: $complaintId',
      );

      // ==========================================================
      // USER → ADMIN NOTIFICATION
      // ==========================================================
      //
      // ONE ADMIN ONLY
      //
      // User
      //   ↓
      // Complaint saved
      //   ↓
      // Get Admin UID
      //   ↓
      // Create notification
      //   ↓
      // Admin 🔔
      //
      // ==========================================================

      try {
        final adminId = await _getAdminId();

        if (adminId.isNotEmpty) {
          final notificationId =
          await NotificationService.instance
              .notifyAdminNewComplaint(
            adminId: adminId,
            complaintId: complaintId,
            status:
            ComplaintStatus
                .submitted
                .firestoreValue,
          );

          if (notificationId.isNotEmpty) {
            print(
              'Admin notification created successfully.',
            );
          } else {
            print(
              'Admin notification was skipped.',
            );
          }
        } else {
          print(
            'No Admin ID found. Complaint notification was not created.',
          );
        }
      } catch (e) {
        // Notification fail hone par
        // complaint submission fail nahi hogi.
        print(
          'Admin notification creation error: $e',
        );
      }

      // ----------------------------------------------------------
      // SUCCESS
      // ----------------------------------------------------------

      return complaintId;
    } catch (e) {
      _lastError =
      'Failed to create complaint: $e';

      rethrow;
    }
  }

  // ============================================================
  // SAVE COMPLAINT
  // ============================================================

  Future<String> saveComplaint(
      Complaint complaint,
      ) async {
    _lastError = '';

    try {
      return await createComplaint(
        userId: complaint.userId,
        name: complaint.user,
        email: complaint.userEmail,
        phone: complaint.phone,
        title: complaint.title,
        description: complaint.description,
        category: complaint.category,
        platform: complaint.platform,
        incidentDate: complaint.date,
        location: complaint.location,
        suspect: complaint.suspect,
        suspectContact: complaint.suspectContact,
        evidence: complaint.evidence,
        evidenceFiles: complaint.evidenceFiles,
      );
    } catch (e) {
      _lastError =
      'Failed to save complaint: $e';

      rethrow;
    }
  }

  // ============================================================
  // GENERATE COMPLAINT ID
  // ============================================================

  Future<String> _generateComplaintId() async {
    final year = DateTime.now().year;

    final timestamp =
    DateTime.now()
        .millisecondsSinceEpoch
        .toString();

    final lastFive =
    timestamp.substring(
      timestamp.length - 5,
    );

    return 'CS-$year-$lastFive';
  }

  // ============================================================
  // GET USER COMPLAINTS
  // ============================================================

  Future<List<Complaint>> getUserComplaints(
      String userId,
      ) async {
    _lastError = '';

    try {
      final cleanUserId = userId.trim();

      if (cleanUserId.isEmpty) {
        return [];
      }

      final snapshot =
      await _complaintsCollection
          .where(
        'userId',
        isEqualTo: cleanUserId,
      )
          .get();

      final complaints =
      snapshot.docs
          .map(
            (doc) =>
            Complaint.fromFirestore(doc),
      )
          .toList();

      complaints.sort(
            (a, b) => b.submittedDate.compareTo(
          a.submittedDate,
        ),
      );

      return complaints;
    } catch (e) {
      _lastError =
      'Failed to load user complaints: $e';

      return [];
    }
  }

  // ============================================================
  // GET CURRENT USER COMPLAINTS
  // ============================================================

  Future<List<Complaint>> getMyComplaints() async {
    _lastError = '';

    try {
      final userId = _currentUserId;

      if (userId.isEmpty) {
        return [];
      }

      return await getUserComplaints(userId);
    } catch (e) {
      _lastError =
      'Failed to load my complaints: $e';

      return [];
    }
  }

  // ============================================================
  // GET CURRENT USER COMPLAINT BY ID
  // ============================================================

  Future<Complaint?> getMyComplaintById(
      String complaintId,
      ) async {
    _lastError = '';

    try {
      final userId = _currentUserId;

      if (userId.isEmpty) {
        _lastError =
        'User is not logged in.';

        return null;
      }

      final cleanId = complaintId.trim();

      if (cleanId.isEmpty) {
        _lastError =
        'Complaint ID is missing.';

        return null;
      }

      final complaint =
      await getComplaint(cleanId);

      if (complaint == null) {
        return null;
      }

      if (complaint.userId != userId) {
        _lastError =
        'You can only access your own complaint.';

        return null;
      }

      return complaint;
    } catch (e) {
      _lastError =
      'Failed to load my complaint: $e';

      return null;
    }
  }

  // ============================================================
  // USER - GET TOTAL COMPLAINT COUNT
  // ============================================================

  Future<int> getMyComplaintCount() async {
    _lastError = '';

    try {
      final userId = _currentUserId;

      if (userId.isEmpty) {
        return 0;
      }

      final snapshot =
      await _complaintsCollection
          .where(
        'userId',
        isEqualTo: userId,
      )
          .get();

      return snapshot.docs.length;
    } catch (e) {
      _lastError =
      'Failed to load complaint count: $e';

      return 0;
    }
  }

  // ============================================================
  // USER - GET COMPLAINT STATUS COUNTS
  // ============================================================

  Future<Map<ComplaintStatus, int>>
  getMyComplaintStatusCounts() async {
    _lastError = '';

    final counts =
    <ComplaintStatus, int>{
      ComplaintStatus.submitted: 0,
      ComplaintStatus.underReview: 0,
      ComplaintStatus.inProgress: 0,
      ComplaintStatus.resolved: 0,
      ComplaintStatus.closed: 0,
    };

    try {
      final userId = _currentUserId;

      if (userId.isEmpty) {
        return counts;
      }

      final snapshot =
      await _complaintsCollection
          .where(
        'userId',
        isEqualTo: userId,
      )
          .get();

      for (final doc in snapshot.docs) {
        try {
          final complaint =
          Complaint.fromFirestore(doc);

          counts[complaint.status] =
              (counts[complaint.status] ?? 0) + 1;
        } catch (e) {
          print(
            'Complaint parsing error: $e',
          );
        }
      }

      return counts;
    } catch (e) {
      _lastError =
      'Failed to load complaint status counts: $e';

      return counts;
    }
  }

  // ============================================================
  // GET SINGLE COMPLAINT
  // ============================================================

  Future<Complaint?> getComplaint(
      String complaintId,
      ) async {
    _lastError = '';

    try {
      final cleanId = complaintId.trim();

      if (cleanId.isEmpty) {
        _lastError =
        'Complaint ID is missing.';

        return null;
      }

      final doc =
      await _complaintsCollection
          .doc(cleanId)
          .get();

      if (!doc.exists) {
        _lastError =
        'Complaint not found.';

        return null;
      }

      return Complaint.fromFirestore(doc);
    } catch (e) {
      _lastError =
      'Failed to load complaint: $e';

      return null;
    }
  }

  // ============================================================
  // GET SINGLE COMPLAINT BY ID
  // ============================================================

  Future<Complaint?> getComplaintById(
      String complaintId,
      ) async {
    return getComplaint(complaintId);
  }

  // ============================================================
  // SINGLE COMPLAINT STREAM
  // ============================================================

  Stream<Complaint?> complaintStream(
      String complaintId,
      ) {
    final cleanId = complaintId.trim();

    if (cleanId.isEmpty) {
      return Stream.value(null);
    }

    return _complaintsCollection
        .doc(cleanId)
        .snapshots()
        .map(
          (doc) {
        if (!doc.exists) {
          return null;
        }

        try {
          return Complaint.fromFirestore(doc);
        } catch (e) {
          print(
            'Complaint stream parsing error: $e',
          );

          return null;
        }
      },
    );
  }

  // ============================================================
  // USER COMPLAINT STREAM
  // ============================================================

  Stream<List<Complaint>> userComplaintsStream(
      String userId,
      ) {
    final cleanUserId = userId.trim();

    if (cleanUserId.isEmpty) {
      return Stream.value([]);
    }

    return _complaintsCollection
        .where(
      'userId',
      isEqualTo: cleanUserId,
    )
        .snapshots()
        .map(
          (snapshot) {
        final complaints =
        snapshot.docs
            .map(
              (doc) =>
              Complaint.fromFirestore(doc),
        )
            .toList();

        complaints.sort(
              (a, b) =>
              b.submittedDate.compareTo(
                a.submittedDate,
              ),
        );

        return complaints;
      },
    );
  }

  // ============================================================
  // ADMIN - GET ALL COMPLAINTS
  // ============================================================

  Future<List<Complaint>> getAllComplaints() async {
    _lastError = '';

    try {
      final snapshot =
      await _complaintsCollection.get();

      final complaints =
      snapshot.docs
          .map(
            (doc) =>
            Complaint.fromFirestore(doc),
      )
          .toList();

      complaints.sort(
            (a, b) =>
            b.submittedDate.compareTo(
              a.submittedDate,
            ),
      );

      return complaints;
    } catch (e) {
      _lastError =
      'Failed to load complaints: $e';

      return [];
    }
  }

  // ============================================================
  // ADMIN - ALL COMPLAINT STREAM
  // ============================================================

  Stream<List<Complaint>>
  allComplaintsStream() {
    return _complaintsCollection
        .snapshots()
        .map(
          (snapshot) {
        final complaints =
        snapshot.docs
            .map(
              (doc) =>
              Complaint.fromFirestore(doc),
        )
            .toList();

        complaints.sort(
              (a, b) =>
              b.submittedDate.compareTo(
                a.submittedDate,
              ),
        );

        return complaints;
      },
    );
  }

  // ============================================================
  // ADMIN - UPDATE COMPLAINT STATUS
  // ============================================================

  Future<bool> updateComplaintStatus({
    required String complaintId,
    required ComplaintStatus status,
  }) async {
    _lastError = '';

    try {
      final cleanComplaintId =
      complaintId.trim();

      if (cleanComplaintId.isEmpty) {
        _lastError =
        'Complaint ID is missing.';

        return false;
      }

      final complaintDoc =
      await _complaintsCollection
          .doc(cleanComplaintId)
          .get();

      if (!complaintDoc.exists) {
        _lastError =
        'Complaint not found.';

        return false;
      }

      final data = complaintDoc.data();

      if (data == null) {
        _lastError =
        'Complaint data is missing.';

        return false;
      }

      // --------------------------------------------------------
      // GET COMPLAINT OWNER
      // --------------------------------------------------------

      final userId =
      (data['userId'] ??
          data['ownerId'] ??
          '')
          .toString()
          .trim();

      final statusValue =
          status.firestoreValue;

      // --------------------------------------------------------
      // UPDATE STATUS
      // --------------------------------------------------------

      await _complaintsCollection
          .doc(cleanComplaintId)
          .update({
        'status': statusValue,
        'updatedAt':
        FieldValue.serverTimestamp(),
      });

      // ========================================================
      // ADMIN → USER NOTIFICATION
      // ========================================================

      if (userId.isNotEmpty) {
        try {
          await NotificationService.instance
              .notifyUserComplaintStatusChanged(
            userId: userId,
            complaintId: cleanComplaintId,
            status: status.displayName,
          );
        } catch (e) {
          print(
            'Status notification error: $e',
          );
        }
      }

      return true;
    } catch (e) {
      _lastError =
      'Failed to update complaint status: $e';

      return false;
    }
  }

  // ============================================================
  // SEARCH COMPLAINT BY ID
  // ============================================================

  Future<Complaint?> searchComplaintById(
      String complaintId,
      ) async {
    _lastError = '';

    try {
      final cleanId = complaintId.trim();

      if (cleanId.isEmpty) {
        _lastError =
        'Complaint ID is missing.';

        return null;
      }

      // --------------------------------------------------------
      // FIRST: DOCUMENT ID
      // --------------------------------------------------------

      final directDoc =
      await _complaintsCollection
          .doc(cleanId)
          .get();

      if (directDoc.exists) {
        return Complaint.fromFirestore(
          directDoc,
        );
      }

      // --------------------------------------------------------
      // SECOND: complaintId FIELD
      // --------------------------------------------------------

      final snapshot =
      await _complaintsCollection
          .where(
        'complaintId',
        isEqualTo: cleanId,
      )
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        _lastError =
        'Complaint not found.';

        return null;
      }

      return Complaint.fromFirestore(
        snapshot.docs.first,
      );
    } catch (e) {
      _lastError =
      'Failed to search complaint: $e';

      return null;
    }
  }

  // ============================================================
  // DELETE COMPLAINT
  // ============================================================

  Future<bool> deleteComplaint(
      String complaintId,
      ) async {
    _lastError = '';

    try {
      final cleanId = complaintId.trim();

      if (cleanId.isEmpty) {
        _lastError =
        'Complaint ID is missing.';

        return false;
      }

      final doc =
      await _complaintsCollection
          .doc(cleanId)
          .get();

      if (!doc.exists) {
        _lastError =
        'Complaint not found.';

        return false;
      }

      await _complaintsCollection
          .doc(cleanId)
          .delete();

      return true;
    } catch (e) {
      _lastError =
      'Failed to delete complaint: $e';

      return false;
    }
  }

  // ============================================================
  // COMPLAINT NOTIFICATIONS
  // ============================================================

  Future<List<AppNotification>>
  getComplaintNotifications(
      String userId,
      ) async {
    return NotificationService.instance
        .getComplaintNotifications(
      userId,
    );
  }

  // ============================================================
  // COMPLAINT STATISTICS
  // ============================================================

  Future<Map<String, int>>
  getComplaintStatistics() async {
    _lastError = '';

    try {
      final complaints =
      await getAllComplaints();

      int submitted = 0;
      int underReview = 0;
      int inProgress = 0;
      int resolved = 0;
      int closed = 0;

      for (final complaint in complaints) {
        switch (complaint.status) {
          case ComplaintStatus.submitted:
            submitted++;
            break;

          case ComplaintStatus.underReview:
            underReview++;
            break;

          case ComplaintStatus.inProgress:
            inProgress++;
            break;

          case ComplaintStatus.resolved:
            resolved++;
            break;

          case ComplaintStatus.closed:
            closed++;
            break;
        }
      }

      return {
        'total': complaints.length,
        'submitted': submitted,
        'underReview': underReview,
        'inProgress': inProgress,
        'resolved': resolved,
        'closed': closed,
      };
    } catch (e) {
      _lastError =
      'Failed to load complaint statistics: $e';

      return {
        'total': 0,
        'submitted': 0,
        'underReview': 0,
        'inProgress': 0,
        'resolved': 0,
        'closed': 0,
      };
    }
  }

  // ============================================================
  // WEEKLY COMPLAINT ANALYTICS
  // ============================================================

  Future<Map<String, int>>
  getWeeklyComplaintAnalytics() async {
    _lastError = '';

    try {
      final complaints =
      await getAllComplaints();

      final now = DateTime.now();

      final startOfWeek =
      DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(
        Duration(
          days: now.weekday - 1,
        ),
      );

      final today =
      DateTime(
        now.year,
        now.month,
        now.day,
      );

      final analytics =
      <String, int>{
        'Monday': 0,
        'Tuesday': 0,
        'Wednesday': 0,
        'Thursday': 0,
        'Friday': 0,
        'Saturday': 0,
        'Sunday': 0,
      };

      for (final complaint in complaints) {
        final date =
            complaint.submittedDate;

        final dateOnly =
        DateTime(
          date.year,
          date.month,
          date.day,
        );

        if (dateOnly.isBefore(startOfWeek) ||
            dateOnly.isAfter(today)) {
          continue;
        }

        switch (date.weekday) {
          case DateTime.monday:
            analytics['Monday'] =
                analytics['Monday']! + 1;
            break;

          case DateTime.tuesday:
            analytics['Tuesday'] =
                analytics['Tuesday']! + 1;
            break;

          case DateTime.wednesday:
            analytics['Wednesday'] =
                analytics['Wednesday']! + 1;
            break;

          case DateTime.thursday:
            analytics['Thursday'] =
                analytics['Thursday']! + 1;
            break;

          case DateTime.friday:
            analytics['Friday'] =
                analytics['Friday']! + 1;
            break;

          case DateTime.saturday:
            analytics['Saturday'] =
                analytics['Saturday']! + 1;
            break;

          case DateTime.sunday:
            analytics['Sunday'] =
                analytics['Sunday']! + 1;
            break;
        }
      }

      return analytics;
    } catch (e) {
      _lastError =
      'Failed to load weekly analytics: $e';

      return {
        'Monday': 0,
        'Tuesday': 0,
        'Wednesday': 0,
        'Thursday': 0,
        'Friday': 0,
        'Saturday': 0,
        'Sunday': 0,
      };
    }
  }
}