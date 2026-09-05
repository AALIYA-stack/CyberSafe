import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/complaint.dart';
import '../models/complaint_status.dart';
import 'auth_service.dart';

class ComplaintService {
  ComplaintService._();

  static final ComplaintService instance =
      ComplaintService._();

  // ==========================================================
  // FIRESTORE
  // ==========================================================

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static const String _complaintsCollection =
      'complaints';

  // ==========================================================
  // COLLECTION REFERENCE
  // ==========================================================

  CollectionReference<Map<String, dynamic>>
      get _complaintsCollectionRef {
    return _firestore.collection(
      _complaintsCollection,
    );
  }

  // ==========================================================
  // SAVE COMPLAINT
  // ==========================================================
  //
  // User ki complaint Firebase Firestore mein save hogi.
  //
  // Document ID = complaint.id
  //

  Future<void> saveComplaint(
    Complaint complaint,
  ) async {
    try {
      final currentEmail =
          await AuthService.instance.getUserEmail();

      if (currentEmail.trim().isEmpty) {
        throw Exception(
          'User is not logged in.',
        );
      }

      final normalizedUserEmail =
          currentEmail.trim().toLowerCase();

      // ------------------------------------------------------
      // SECURITY
      // ------------------------------------------------------
      //
      // Complaint ke userEmail ko current logged-in user ke
      // email se synchronize karte hain.
      //

      final complaintData =
          complaint.toMap();

      complaintData['userEmail'] =
          normalizedUserEmail;

      complaintData['createdAt'] =
          FieldValue.serverTimestamp();

      complaintData['updatedAt'] =
          FieldValue.serverTimestamp();

      // ------------------------------------------------------
      // USER ID
      // ------------------------------------------------------

      final currentUser =
          AuthService.instance.currentUser;

      if (currentUser != null) {
        complaintData['userId'] =
            currentUser.uid;
      }

      // ------------------------------------------------------
      // SAVE TO FIRESTORE
      // ------------------------------------------------------

      await _complaintsCollectionRef
          .doc(complaint.id)
          .set(
        complaintData,
        SetOptions(
          merge: true,
        ),
      );

      debugPrint(
        'COMPLAINT SAVED TO FIRESTORE: ${complaint.id}',
      );
    } catch (e) {
      debugPrint(
        'SAVE COMPLAINT ERROR: $e',
      );

      rethrow;
    }
  }

  // ==========================================================
  // GET ALL COMPLAINTS
  // ==========================================================
  //
  // Admin dashboard ke liye.
  //

  Future<List<Complaint>> getAllComplaints() async {
    try {
      final snapshot =
          await _complaintsCollectionRef
              .orderBy(
                'submittedDate',
                descending: true,
              )
              .get();

      final complaints =
          snapshot.docs.map((doc) {
        try {
          final data =
              Map<String, dynamic>.from(
            doc.data(),
          );

          // Agar document mein id missing ho
          // to Firestore document ID use karein.
          data['id'] ??= doc.id;

          return Complaint.fromMap(
            _normalizeFirestoreData(data),
          );
        } catch (e) {
          debugPrint(
            'COMPLAINT PARSE ERROR '
            '${doc.id}: $e',
          );

          return null;
        }
      }).whereType<Complaint>().toList();

      return complaints;
    } catch (e) {
      debugPrint(
        'GET ALL COMPLAINTS ERROR: $e',
      );

      return [];
    }
  }

  // ==========================================================
  // GET CURRENT USER COMPLAINTS
  // ==========================================================

  Future<List<Complaint>> getMyComplaints() async {
    try {
      final currentUser =
          AuthService.instance.currentUser;

      final email =
          await AuthService.instance.getUserEmail();

      if (email.trim().isEmpty) {
        return [];
      }

      // ------------------------------------------------------
      // Prefer UID when Firebase user available.
      // ------------------------------------------------------

      if (currentUser != null) {
        try {
          final snapshot =
              await _complaintsCollectionRef
                  .where(
                    'userId',
                    isEqualTo: currentUser.uid,
                  )
                  .orderBy(
                    'submittedDate',
                    descending: true,
                  )
                  .get();

          if (snapshot.docs.isNotEmpty) {
            return _parseDocuments(
              snapshot.docs,
            );
          }
        } catch (e) {
          debugPrint(
            'UID COMPLAINT QUERY FAILED: $e',
          );
        }
      }

      // ------------------------------------------------------
      // Email fallback
      // ------------------------------------------------------

      return getComplaintsByUserEmail(
        email,
      );
    } catch (e) {
      debugPrint(
        'GET MY COMPLAINTS ERROR: $e',
      );

      return [];
    }
  }

  // ==========================================================
  // GET COMPLAINTS BY USER EMAIL
  // ==========================================================

  Future<List<Complaint>> getComplaintsByUserEmail(
    String email,
  ) async {
    try {
      final normalizedEmail =
          email.trim().toLowerCase();

      if (normalizedEmail.isEmpty) {
        return [];
      }

      final snapshot =
          await _complaintsCollectionRef
              .where(
                'userEmail',
                isEqualTo: normalizedEmail,
              )
              .orderBy(
                'submittedDate',
                descending: true,
              )
              .get();

      return _parseDocuments(
        snapshot.docs,
      );
    } catch (e) {
      debugPrint(
        'GET USER COMPLAINTS ERROR: $e',
      );

      return [];
    }
  }

  // ==========================================================
  // GET SINGLE USER COMPLAINT
  // ==========================================================

  Future<Complaint?> getMyComplaintById(
    String complaintId,
  ) async {
    try {
      final currentUser =
          AuthService.instance.currentUser;

      final email =
          await AuthService.instance.getUserEmail();

      if (email.trim().isEmpty) {
        return null;
      }

      final document =
          await _complaintsCollectionRef
              .doc(complaintId)
              .get();

      if (!document.exists) {
        return null;
      }

      final data =
          Map<String, dynamic>.from(
        document.data() ?? {},
      );

      data['id'] ??= document.id;

      // ------------------------------------------------------
      // SECURITY CHECK
      // ------------------------------------------------------

      final complaintUserId =
          data['userId']?.toString();

      final complaintEmail =
          data['userEmail']
                  ?.toString()
                  .trim()
                  .toLowerCase() ??
              '';

      final isOwnerByUid =
          currentUser != null &&
          complaintUserId ==
              currentUser.uid;

      final isOwnerByEmail =
          complaintEmail ==
              email.trim().toLowerCase();

      if (!isOwnerByUid &&
          !isOwnerByEmail) {
        return null;
      }

      return Complaint.fromMap(
        _normalizeFirestoreData(data),
      );
    } catch (e) {
      debugPrint(
        'GET MY COMPLAINT ERROR: $e',
      );

      return null;
    }
  }

  // ==========================================================
  // GET COMPLAINT BY ID
  // ==========================================================
  //
  // Admin use ke liye.
  //

  Future<Complaint?> getComplaintById(
    String complaintId,
  ) async {
    try {
      final document =
          await _complaintsCollectionRef
              .doc(complaintId)
              .get();

      if (!document.exists) {
        return null;
      }

      final data =
          Map<String, dynamic>.from(
        document.data() ?? {},
      );

      data['id'] ??= document.id;

      return Complaint.fromMap(
        _normalizeFirestoreData(data),
      );
    } catch (e) {
      debugPrint(
        'GET COMPLAINT BY ID ERROR: $e',
      );

      return null;
    }
  }

  // ==========================================================
  // UPDATE COMPLAINT STATUS
  // ==========================================================
  //
  // Admin complaint status Firebase mein update karega.
  //

  Future<bool> updateComplaintStatus({
    required String complaintId,
    required ComplaintStatus status,
  }) async {
    try {
      final currentUser =
          AuthService.instance.currentUser;

      // ------------------------------------------------------
      // Admin check
      // ------------------------------------------------------

      final isAdmin =
          await AuthService.instance.isAdmin();

      if (!isAdmin) {
        debugPrint(
          'UPDATE STATUS DENIED: NOT ADMIN',
        );

        return false;
      }

      final document =
          await _complaintsCollectionRef
              .doc(complaintId)
              .get();

      if (!document.exists) {
        return false;
      }

      await _complaintsCollectionRef
          .doc(complaintId)
          .update(
        {
          'status': status.name,
          'updatedAt':
              FieldValue.serverTimestamp(),
          'updatedBy':
              currentUser?.uid ?? 'admin',
        },
      );

      debugPrint(
        'COMPLAINT STATUS UPDATED: '
        '$complaintId -> ${status.name}',
      );

      return true;
    } catch (e) {
      debugPrint(
        'UPDATE COMPLAINT STATUS ERROR: $e',
      );

      return false;
    }
  }

  // ==========================================================
  // DELETE COMPLAINT
  // ==========================================================
  //
  // Admin hi complaint delete kar sakta hai.
  //

  Future<bool> deleteComplaint(
    String complaintId,
  ) async {
    try {
      final isAdmin =
          await AuthService.instance.isAdmin();

      if (!isAdmin) {
        debugPrint(
          'DELETE DENIED: NOT ADMIN',
        );

        return false;
      }

      final document =
          await _complaintsCollectionRef
              .doc(complaintId)
              .get();

      if (!document.exists) {
        return false;
      }

      await _complaintsCollectionRef
          .doc(complaintId)
          .delete();

      debugPrint(
        'COMPLAINT DELETED: $complaintId',
      );

      return true;
    } catch (e) {
      debugPrint(
        'DELETE COMPLAINT ERROR: $e',
      );

      return false;
    }
  }

  // ==========================================================
  // GET STATUS COUNTS FOR CURRENT USER
  // ==========================================================

  Future<Map<ComplaintStatus, int>>
      getMyComplaintStatusCounts() async {
    final complaints =
        await getMyComplaints();

    final counts =
        <ComplaintStatus, int>{};

    for (final status
        in ComplaintStatus.values) {
      counts[status] = 0;
    }

    for (final complaint
        in complaints) {
      counts[complaint.status] =
          (counts[complaint.status] ?? 0) + 1;
    }

    return counts;
  }

  // ==========================================================
  // TOTAL CURRENT USER COMPLAINTS
  // ==========================================================

  Future<int> getMyComplaintCount() async {
    final complaints =
        await getMyComplaints();

    return complaints.length;
  }

  // ==========================================================
  // REFRESH / RELOAD
  // ==========================================================

  Future<List<Complaint>>
      refreshMyComplaints() async {
    return getMyComplaints();
  }

  // ==========================================================
  // CLEAR ALL COMPLAINTS
  // ==========================================================
  //
  // Development/testing ke liye.
  // Sirf admin use kar sakta hai.
  //

  Future<void> clearAllComplaints() async {
    try {
      final isAdmin =
          await AuthService.instance.isAdmin();

      if (!isAdmin) {
        debugPrint(
          'CLEAR ALL DENIED: NOT ADMIN',
        );

        return;
      }

      final snapshot =
          await _complaintsCollectionRef
              .get();

      final batch =
          _firestore.batch();

      for (final document
          in snapshot.docs) {
        batch.delete(
          document.reference,
        );
      }

      await batch.commit();

      debugPrint(
        'ALL COMPLAINTS CLEARED',
      );
    } catch (e) {
      debugPrint(
        'CLEAR ALL COMPLAINTS ERROR: $e',
      );
    }
  }

  // ==========================================================
  // PRIVATE: PARSE DOCUMENTS
  // ==========================================================

  List<Complaint> _parseDocuments(
    List<QueryDocumentSnapshot<Map<String, dynamic>>>
        documents,
  ) {
    final complaints =
        <Complaint>[];

    for (final document
        in documents) {
      try {
        final data =
            Map<String, dynamic>.from(
          document.data(),
        );

        data['id'] ??= document.id;

        complaints.add(
          Complaint.fromMap(
            _normalizeFirestoreData(data),
          ),
        );
      } catch (e) {
        debugPrint(
          'PARSE COMPLAINT ERROR '
          '${document.id}: $e',
        );
      }
    }

    return complaints;
  }

  // ==========================================================
  // PRIVATE: NORMALIZE FIRESTORE DATA
  // ==========================================================
  //
  // Complaint model DateTime expect karta hai.
  // Firestore Timestamp ko ISO String mein convert
  // karte hain.
  //

  Map<String, dynamic>
      _normalizeFirestoreData(
    Map<String, dynamic> data,
  ) {
    final normalized =
        Map<String, dynamic>.from(data);

    // ------------------------------------------------------
    // DATE
    // ------------------------------------------------------

    final dateValue =
        normalized['date'];

    if (dateValue is Timestamp) {
      normalized['date'] =
          dateValue.toDate().toIso8601String();
    }

    // ------------------------------------------------------
    // SUBMITTED DATE
    // ------------------------------------------------------

    final submittedDateValue =
        normalized['submittedDate'];

    if (submittedDateValue
        is Timestamp) {
      normalized['submittedDate'] =
          submittedDateValue
              .toDate()
              .toIso8601String();
    }

    // ------------------------------------------------------
    // EVIDENCE
    // ------------------------------------------------------

    final evidence =
        normalized['evidence'];

    if (evidence is List) {
      normalized['evidence'] =
          evidence
              .map(
                (item) =>
                    item.toString(),
              )
              .toList();
    } else {
      normalized['evidence'] =
          <String>[];
    }

    // ------------------------------------------------------
    // STATUS
    // ------------------------------------------------------

    if (normalized['status'] == null) {
      normalized['status'] =
          ComplaintStatus.submitted.name;
    }

    return normalized;
  }
}
