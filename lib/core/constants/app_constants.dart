class AppConstants {
  AppConstants._();

  // ==========================================================
  // APP INFORMATION
  // ==========================================================

  static const String appName = 'CyberSafe';

  static const String appTagline =
      'Stay Safe. Stay Aware. Stay Protected.';

  static const String appDescription =
      'CyberSafe is a cybercrime complaint and awareness '
      'management system designed to help users understand '
      'cyber threats, report incidents and track complaints.';

  static const String appVersion = '1.0.0';

  // ==========================================================
  // ASSETS
  // ==========================================================

  static const String aiImage =
      'assets/images/ai.png';

  static const String complaintImage =
      'assets/images/complaint.png';

  static const String securityImage =
      'assets/images/security.png';

  static const String cybercrimeImage =
      'assets/images/cybercrime.png';

  // ==========================================================
  // COMPLAINT CATEGORIES
  // ==========================================================

  static const List<String> complaintCategories = [
    'Phishing',
    'Online Fraud',
    'Hacking',
    'Fake Accounts',
    'Cyber Harassment',
    'Identity Theft',
    'Data Theft',
    'Scam Links',
  ];

  // ==========================================================
  // PLATFORMS
  // ==========================================================

  static const List<String> platforms = [
    'WhatsApp',
    'Facebook',
    'Instagram',
    'TikTok',
    'Email',
    'SMS',
    'Website',
    'Other',
  ];

  // ==========================================================
  // COMPLAINT STATUS
  // ==========================================================

  static const List<String> complaintStatuses = [
    'Pending',
    'In Review',
    'Investigation',
    'Resolved',
    'Rejected',
  ];

  // ==========================================================
  // PRIORITY
  // ==========================================================

  static const List<String> priorities = [
    'Low',
    'Medium',
    'High',
    'Critical',
  ];

  // ==========================================================
  // VALIDATION
  // ==========================================================

  static const int minimumNameLength = 3;

  static const int minimumPasswordLength = 6;

  static const int maximumComplaintDescriptionLength = 2000;

  // ==========================================================
  // UI
  // ==========================================================

  static const double screenPadding = 20.0;

  static const double cardRadius = 20.0;

  static const double buttonRadius = 14.0;

  static const double fieldRadius = 14.0;
}