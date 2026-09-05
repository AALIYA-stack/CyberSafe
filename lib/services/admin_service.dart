import 'package:shared_preferences/shared_preferences.dart';

class AdminService {
  AdminService._internal();

  static final AdminService instance = AdminService._internal();

  factory AdminService() {
    return instance;
  }

  // ==========================================================
  // KEYS
  // ==========================================================

  static const String _adminLoggedInKey = 'admin_logged_in';

  static const String _adminNameKey = 'admin_name';
  static const String _adminEmailKey = 'admin_email';
  static const String _adminPhoneKey = 'admin_phone';
  static const String _adminDesignationKey = 'admin_designation';

  // ==========================================================
  // DEMO ADMIN CREDENTIALS
  //
  // FRONTEND / DEMO ONLY
  // ==========================================================

  static const String demoAdminEmail = 'admin@cybersafe.com';
  static const String demoAdminPassword = 'admin123';

  // ==========================================================
  // ADMIN LOGIN
  // ==========================================================

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail != demoAdminEmail ||
        password != demoAdminPassword) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      _adminLoggedInKey,
      true,
    );

    // Save default profile if it does not exist.
    await prefs.setString(
      _adminNameKey,
      prefs.getString(_adminNameKey) ?? 'CyberSafe Administrator',
    );

    await prefs.setString(
      _adminEmailKey,
      prefs.getString(_adminEmailKey) ?? demoAdminEmail,
    );

    await prefs.setString(
      _adminPhoneKey,
      prefs.getString(_adminPhoneKey) ?? '',
    );

    await prefs.setString(
      _adminDesignationKey,
      prefs.getString(_adminDesignationKey) ??
          'Cyber Crime Administrator',
    );

    return true;
  }

  // ==========================================================
  // CHECK LOGIN
  // ==========================================================

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_adminLoggedInKey) ?? false;
  }

  // ==========================================================
  // PROFILE
  // ==========================================================

  Future<void> saveProfile({
    required String name,
    required String email,
    required String phone,
    required String designation,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _adminNameKey,
      name.trim(),
    );

    await prefs.setString(
      _adminEmailKey,
      email.trim().toLowerCase(),
    );

    await prefs.setString(
      _adminPhoneKey,
      phone.trim(),
    );

    await prefs.setString(
      _adminDesignationKey,
      designation.trim(),
    );
  }

  Future<String> getName() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_adminNameKey) ??
        'CyberSafe Administrator';
  }

  Future<String> getEmail() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_adminEmailKey) ??
        demoAdminEmail;
  }

  Future<String> getPhone() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_adminPhoneKey) ?? '';
  }

  Future<String> getDesignation() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_adminDesignationKey) ??
        'Cyber Crime Administrator';
  }

  // ==========================================================
  // LOGOUT
  // ==========================================================

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      _adminLoggedInKey,
      false,
    );
  }
}