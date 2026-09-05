import '../models/complaint.dart';
import '../models/complaint_status.dart';
import 'mock_data.dart';

class ComplaintStore {
  // ==========================================================
  // SINGLETON
  // ==========================================================

  ComplaintStore._internal();

  static final ComplaintStore instance =
  ComplaintStore._internal();

  // ==========================================================
  // INTERNAL COMPLAINT LIST
  // ==========================================================

  final List<Complaint> _complaints =
  List<Complaint>.from(
    MockData.complaints(),
  );

  // ==========================================================
  // GET ALL COMPLAINTS
  //
  // ADMIN USE
  // ==========================================================

  List<Complaint> getAllComplaints() {
    return List<Complaint>.unmodifiable(
      _complaints,
    );
  }

  // ==========================================================
  // GET CURRENT USER COMPLAINTS
  //
  // USER USE
  // ==========================================================

  List<Complaint> getComplaintsForUser(
      String email,
      ) {
    final normalizedEmail =
    email.trim().toLowerCase();

    if (normalizedEmail.isEmpty) {
      return [];
    }

    final result =
    _complaints.where(
          (complaint) {
        return complaint.userEmail
            .trim()
            .toLowerCase() ==
            normalizedEmail;
      },
    ).toList();

    // Latest complaint first
    result.sort(
          (a, b) => b.submittedDate.compareTo(
        a.submittedDate,
      ),
    );

    return result;
  }

  // ==========================================================
  // FIND COMPLAINT
  // ==========================================================

  Complaint? findComplaint(
      String complaintId,
      ) {
    final normalizedId =
    complaintId.trim().toLowerCase();

    if (normalizedId.isEmpty) {
      return null;
    }

    try {
      return _complaints.firstWhere(
            (complaint) =>
        complaint.id
            .trim()
            .toLowerCase() ==
            normalizedId,
      );
    } catch (_) {
      return null;
    }
  }

  // ==========================================================
  // ADD COMPLAINT
  //
  // IMPORTANT:
  // This method accepts a complete Complaint object.
  // ==========================================================

  void addComplaint(
      Complaint complaint,
      ) {
    _complaints.insert(
      0,
      complaint,
    );
  }

  // ==========================================================
  // UPDATE COMPLAINT
  // ==========================================================

  void updateComplaint(
      Complaint updatedComplaint,
      ) {
    final index =
    _complaints.indexWhere(
          (complaint) =>
      complaint.id ==
          updatedComplaint.id,
    );

    if (index == -1) {
      return;
    }

    _complaints[index] =
        updatedComplaint;
  }

  // ==========================================================
  // UPDATE STATUS
  //
  // ADMIN USE
  // ==========================================================

  void updateComplaintStatus(
      String complaintId,
      ComplaintStatus newStatus,
      ) {
    final index =
    _complaints.indexWhere(
          (complaint) =>
      complaint.id ==
          complaintId,
    );

    if (index == -1) {
      return;
    }

    _complaints[index] =
        _complaints[index].copyWith(
          status: newStatus,
        );
  }

  // ==========================================================
  // GENERATE COMPLAINT ID
  // ==========================================================

  String generateComplaintId() {
    final year =
        DateTime.now().year;

    final number =
        125 + _complaints.length;

    return 'CS-$year-${number.toString().padLeft(5, '0')}';
  }

  // ==========================================================
  // TOTAL COMPLAINTS
  // ==========================================================

  int get totalComplaints =>
      _complaints.length;

  // ==========================================================
  // STATUS COUNTS
  // ==========================================================

  int countByStatus(
      ComplaintStatus status,
      ) {
    return _complaints
        .where(
          (complaint) =>
      complaint.status ==
          status,
    )
        .length;
  }

  // ==========================================================
  // USER TOTAL
  // ==========================================================

  int countForUser(
      String email,
      ) {
    return getComplaintsForUser(
      email,
    ).length;
  }

  // ==========================================================
  // USER STATUS COUNT
  // ==========================================================

  int countUserByStatus(
      String email,
      ComplaintStatus status,
      ) {
    return getComplaintsForUser(
      email,
    ).where(
          (complaint) =>
      complaint.status ==
          status,
    ).length;
  }
}