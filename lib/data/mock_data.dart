import '../models/complaint.dart';
import '../models/complaint_status.dart';
import '../models/app_notification.dart';

class MockData {
  MockData._();

  // ==========================================================
  // DEMO USER IDs
  // ==========================================================

  static const String userAId = 'demo-user-001';

  static const String userBId = 'demo-user-002';

  static const String userCId = 'demo-user-003';

  // ==========================================================
  // DEMO USER EMAILS
  // ==========================================================

  static const String userAEmail =
      'user1@cybersafe.com';

  static const String userBEmail =
      'user2@cybersafe.com';

  static const String userCEmail =
      'user3@cybersafe.com';

  // ==========================================================
  // DEMO USER NAMES
  // ==========================================================

  static const String userAName =
      'Ayesha Khan';

  static const String userBName =
      'Sara Ahmed';

  static const String userCName =
      'Hamza Ali';

  // ==========================================================
  // DEMO PHONE NUMBERS
  // ==========================================================

  static const String userAPhone =
      '03001234567';

  static const String userBPhone =
      '03111234567';

  static const String userCPhone =
      '03221234567';

  // ==========================================================
  // CURRENT DEMO USER
  // ==========================================================

  static const String currentUserId = userAId;

  static const String currentUserEmail =
      userAEmail;

  static const String currentUserName =
      userAName;

  static const String currentUserPhone =
      userAPhone;

  // ==========================================================
  // ALL COMPLAINTS
  // ==========================================================

  static List<Complaint> complaints() {
    return [
      // ======================================================
      // USER A - COMPLAINT 1
      // ======================================================

      Complaint(
        id: 'CS-2026-00125',
        userId: userAId,
        title: 'Online Shopping Fraud',
        category: 'Online Fraud',
        user: userAName,
        userEmail: userAEmail,
        phone: userAPhone,
        date: DateTime(2026, 8, 10),
        platform: 'Instagram',
        location: 'Rawalpindi',
        suspect: 'FakeStore_PK',
        suspectContact: '03001234567',
        description:
        'I paid for an item through an online seller, '
            'but the seller stopped responding after receiving '
            'the payment. The product was never delivered.',
        evidence: [
          'payment_screenshot.png',
          'chat_screenshot.png',
        ],
        status: ComplaintStatus.underReview,
        submittedDate: DateTime(2026, 8, 11),
      ),

      // ======================================================
      // USER A - COMPLAINT 2
      // ======================================================

      Complaint(
        id: 'CS-2026-00131',
        userId: userAId,
        title: 'Suspicious Account Activity',
        category:
        'Hacking / Unauthorized Access',
        user: userAName,
        userEmail: userAEmail,
        phone: userAPhone,
        date: DateTime(2026, 8, 14),
        platform: 'Facebook',
        location: 'Rawalpindi',
        suspect: 'Unknown',
        suspectContact: '',
        description:
        'I noticed suspicious profile activity on my '
            'social media account. I received profile alerts '
            'from an unfamiliar location.',
        evidence: [
          'login_alert.png',
        ],
        status: ComplaintStatus.inProgress,
        submittedDate: DateTime(2026, 8, 15),
      ),

      // ======================================================
      // USER B - COMPLAINT 1
      // ======================================================

      Complaint(
        id: 'CS-2026-00138',
        userId: userBId,
        title: 'Fake Social Media Account',
        category:
        'Fake / Impersonation Account',
        user: userBName,
        userEmail: userBEmail,
        phone: userBPhone,
        date: DateTime(2026, 8, 16),
        platform: 'Instagram',
        location: 'Islamabad',
        suspect: 'fake_sara_786',
        suspectContact: '',
        description:
        'A fake social media account has been created '
            'using another person identity and is posting '
            'misleading content.',
        evidence: [
          'fake_profile.png',
        ],
        status: ComplaintStatus.submitted,
        submittedDate: DateTime(2026, 8, 17),
      ),

      // ======================================================
      // USER B - COMPLAINT 2
      // ======================================================

      Complaint(
        id: 'CS-2026-00142',
        userId: userBId,
        title: 'Phishing Message',
        category: 'Phishing / Scam',
        user: userBName,
        userEmail: userBEmail,
        phone: userBPhone,
        date: DateTime(2026, 8, 18),
        platform: 'WhatsApp',
        location: 'Islamabad',
        suspect: 'Unknown',
        suspectContact: '',
        description:
        'I received a suspicious message containing '
            'a link asking me to enter personal information.',
        evidence: [
          'phishing_message.png',
        ],
        status: ComplaintStatus.resolved,
        submittedDate: DateTime(2026, 8, 18),
      ),

      // ======================================================
      // USER C - COMPLAINT 1
      // ======================================================

      Complaint(
        id: 'CS-2026-00148',
        userId: userCId,
        title: 'Unauthorized Account Access',
        category:
        'Hacking / Unauthorized Access',
        user: userCName,
        userEmail: userCEmail,
        phone: userCPhone,
        date: DateTime(2026, 8, 19),
        platform: 'Gmail',
        location: 'Lahore',
        suspect: 'Unknown',
        suspectContact: '',
        description:
        'Someone appears to have accessed the account '
            'without authorization. Several security alerts '
            'were received.',
        evidence: [
          'security_alert.png',
        ],
        status: ComplaintStatus.inProgress,
        submittedDate: DateTime(2026, 8, 20),
      ),

      // ======================================================
      // USER C - COMPLAINT 2
      // ======================================================

      Complaint(
        id: 'CS-2026-00153',
        userId: userCId,
        title: 'Cyber Harassment',
        category: 'Cyber Harassment',
        user: userCName,
        userEmail: userCEmail,
        phone: userCPhone,
        date: DateTime(2026, 8, 20),
        platform: 'WhatsApp',
        location: 'Lahore',
        suspect: 'Unknown Contact',
        suspectContact: '',
        description:
        'I have received repeated unwanted messages '
            'from an unknown account.',
        evidence: [
          'message_screenshot.png',
        ],
        status: ComplaintStatus.closed,
        submittedDate: DateTime(2026, 8, 21),
      ),
    ];
  }

  // ==========================================================
  // USER COMPLAINTS
  // ==========================================================

  static List<Complaint> userComplaints(
      String email,
      ) {
    final normalizedEmail =
    email.trim().toLowerCase();

    return complaints()
        .where(
          (complaint) =>
      complaint.userEmail
          .trim()
          .toLowerCase() ==
          normalizedEmail,
    )
        .toList();
  }

  // ==========================================================
  // USER COMPLAINTS BY USER ID
  // ==========================================================

  static List<Complaint> userComplaintsById(
      String userId,
      ) {
    final normalizedId =
    userId.trim();

    if (normalizedId.isEmpty) {
      return [];
    }

    return complaints()
        .where(
          (complaint) =>
      complaint.userId.trim() ==
          normalizedId,
    )
        .toList();
  }

  // ==========================================================
  // FIND SINGLE COMPLAINT
  // ==========================================================

  static Complaint? findComplaint(
      String complaintId,
      ) {
    final id = complaintId.trim();

    for (final complaint in complaints()) {
      if (complaint.id == id) {
        return complaint;
      }
    }

    return null;
  }

  // ==========================================================
  // FIND COMPLAINT BY USER
  // ==========================================================

  static Complaint? findUserComplaint(
      String complaintId,
      String userId,
      ) {
    final complaint =
    findComplaint(complaintId);

    if (complaint == null) {
      return null;
    }

    if (complaint.userId.trim() !=
        userId.trim()) {
      return null;
    }

    return complaint;
  }

  // ==========================================================
  // CHECK COMPLAINT OWNERSHIP BY USER ID
  // ==========================================================

  static bool isComplaintOwnerById(
      Complaint complaint,
      String userId,
      ) {
    return complaint.userId.trim() ==
        userId.trim();
  }

  // ==========================================================
  // CHECK COMPLAINT OWNERSHIP BY EMAIL
  // ==========================================================

  static bool isComplaintOwner(
      Complaint complaint,
      String email,
      ) {
    return complaint.userEmail
        .trim()
        .toLowerCase() ==
        email.trim().toLowerCase();
  }

  // ==========================================================
  // ALL COMPLAINTS
  // ADMIN ONLY
  // ==========================================================

  static List<Complaint> allComplaints() {
    return complaints();
  }

  // ==========================================================
  // COMPLAINT COUNTS
  // ==========================================================

  static int totalComplaints() {
    return complaints().length;
  }

  static int submittedComplaints() {
    return complaints()
        .where(
          (complaint) =>
      complaint.status ==
          ComplaintStatus.submitted,
    )
        .length;
  }

  static int underReviewComplaints() {
    return complaints()
        .where(
          (complaint) =>
      complaint.status ==
          ComplaintStatus.underReview,
    )
        .length;
  }

  static int inProgressComplaints() {
    return complaints()
        .where(
          (complaint) =>
      complaint.status ==
          ComplaintStatus.inProgress,
    )
        .length;
  }

  static int resolvedComplaints() {
    return complaints()
        .where(
          (complaint) =>
      complaint.status ==
          ComplaintStatus.resolved,
    )
        .length;
  }

  static int closedComplaints() {
    return complaints()
        .where(
          (complaint) =>
      complaint.status ==
          ComplaintStatus.closed,
    )
        .length;
  }

  // ==========================================================
  // USER COMPLAINT COUNTS
  // ==========================================================

  static int userComplaintCount(
      String email,
      ) {
    return userComplaints(email).length;
  }

  static int userSubmittedComplaints(
      String email,
      ) {
    return userComplaints(email)
        .where(
          (complaint) =>
      complaint.status ==
          ComplaintStatus.submitted,
    )
        .length;
  }

  static int userUnderReviewComplaints(
      String email,
      ) {
    return userComplaints(email)
        .where(
          (complaint) =>
      complaint.status ==
          ComplaintStatus.underReview,
    )
        .length;
  }

  static int userInProgressComplaints(
      String email,
      ) {
    return userComplaints(email)
        .where(
          (complaint) =>
      complaint.status ==
          ComplaintStatus.inProgress,
    )
        .length;
  }

  static int userResolvedComplaints(
      String email,
      ) {
    return userComplaints(email)
        .where(
          (complaint) =>
      complaint.status ==
          ComplaintStatus.resolved,
    )
        .length;
  }

  static int userClosedComplaints(
      String email,
      ) {
    return userComplaints(email)
        .where(
          (complaint) =>
      complaint.status ==
          ComplaintStatus.closed,
    )
        .length;
  }

  // ==========================================================
  // NOTIFICATIONS
  // ==========================================================

  static List<AppNotification> notifications() {
    return [
      // ======================================================
      // USER A
      // ======================================================

      AppNotification(
        id: 'NOT-001',
        recipientId: userAId,
        title: 'Complaint Under Review',
        message:
        'Your complaint CS-2026-00125 is now under review.',
        type: 'complaint',
        createdAt:
        DateTime(2026, 8, 12, 10, 30),
        isRead: false,
        complaintId: 'CS-2026-00125',
      ),

      AppNotification(
        id: 'NOT-002',
        recipientId: userAId,
        title: 'Complaint Status Updated',
        message:
        'Your complaint CS-2026-00131 is now in progress.',
        type: 'complaint',
        createdAt:
        DateTime(2026, 8, 16, 14, 20),
        isRead: false,
        complaintId: 'CS-2026-00131',
      ),

      AppNotification(
        id: 'NOT-003',
        recipientId: userAId,
        title: 'Cybersecurity Awareness',
        message:
        'A new cybersecurity awareness article is available.',
        type: 'article',
        createdAt:
        DateTime(2026, 8, 20, 9, 15),
        isRead: true,
      ),

      // ======================================================
      // USER B
      // ======================================================

      AppNotification(
        id: 'NOT-004',
        recipientId: userBId,
        title: 'Complaint Submitted',
        message:
        'Your complaint CS-2026-00138 was submitted successfully.',
        type: 'complaint',
        createdAt:
        DateTime(2026, 8, 17, 11, 10),
        isRead: false,
        complaintId: 'CS-2026-00138',
      ),

      AppNotification(
        id: 'NOT-005',
        recipientId: userBId,
        title: 'Complaint Resolved',
        message:
        'Your complaint CS-2026-00142 has been resolved.',
        type: 'complaint',
        createdAt:
        DateTime(2026, 8, 19, 16, 45),
        isRead: true,
        complaintId: 'CS-2026-00142',
      ),

      // ======================================================
      // USER C
      // ======================================================

      AppNotification(
        id: 'NOT-006',
        recipientId: userCId,
        title: 'Complaint In Progress',
        message:
        'Your complaint CS-2026-00148 is currently in progress.',
        type: 'complaint',
        createdAt:
        DateTime(2026, 8, 21, 12, 30),
        isRead: false,
        complaintId: 'CS-2026-00148',
      ),

      AppNotification(
        id: 'NOT-007',
        recipientId: userCId,
        title: 'Complaint Closed',
        message:
        'Your complaint CS-2026-00153 has been closed.',
        type: 'complaint',
        createdAt:
        DateTime(2026, 8, 22, 15, 10),
        isRead: true,
        complaintId: 'CS-2026-00153',
      ),
    ];
  }

  // ==========================================================
  // CURRENT USER NOTIFICATIONS
  // BY USER ID
  // ==========================================================

  static List<AppNotification> userNotifications(
      String userId,
      ) {
    final normalizedId =
    userId.trim();

    if (normalizedId.isEmpty) {
      return [];
    }

    return notifications()
        .where(
          (notification) =>
      notification.recipientId.trim() ==
          normalizedId,
    )
        .toList();
  }

  // ==========================================================
  // UNREAD NOTIFICATIONS
  // BY USER ID
  // ==========================================================

  static int unreadNotificationCount(
      String userId,
      ) {
    return userNotifications(userId)
        .where(
          (notification) =>
      !notification.isRead,
    )
        .length;
  }
}