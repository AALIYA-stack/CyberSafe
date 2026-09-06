import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  // ==========================================================
  // FIREBASE
  // ==========================================================

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ==========================================================
  // STORAGE KEYS
  // ==========================================================

  static const String _isLoggedInKey =
      'cybersafe_is_logged_in';

  static const String _userIdKey =
      'cybersafe_user_id';

  static const String _userEmailKey =
      'cybersafe_user_email';

  static const String _userNameKey =
      'cybersafe_user_name';

  static const String _userPhoneKey =
      'cybersafe_user_phone';

  static const String _userRoleKey =
      'cybersafe_user_role';

  static const String _onboardingKey =
      'cybersafe_onboarding_completed';

  // ==========================================================
  // FIRESTORE COLLECTION
  // ==========================================================

  static const String _usersCollection = 'users';

  // ==========================================================
  // EMAIL CACHE
  // ==========================================================

  static String? _cachedUserEmail;

  static String? get currentUserEmail =>
      _cachedUserEmail;

  // ==========================================================
  // CURRENT FIREBASE USER
  // ==========================================================

  User? get currentUser =>
      _auth.currentUser;

  // ==========================================================
  // AUTH STATE
  // ==========================================================

  Stream<User?> get authStateChanges =>
      _auth.authStateChanges();

  // ==========================================================
  // USER DOCUMENT
  // ==========================================================

  DocumentReference<Map<String, dynamic>>
  _userDocument(String uid) {
    return _firestore
        .collection(_usersCollection)
        .doc(uid);
  }

  // ==========================================================
  // SAVE PROFILE TO FIRESTORE
  // ==========================================================

  Future<bool> saveUserToFirestore({
    required String userId,
    required String userName,
    required String userEmail,
    String userPhone = '',
    String role = 'user',
  }) async {
    try {
      final uid = userId.trim();

      final name = userName.trim();

      final email =
      userEmail.trim().toLowerCase();

      final phone = userPhone.trim();

      final normalizedRole =
      role.trim().toLowerCase();

      if (uid.isEmpty ||
          name.isEmpty ||
          email.isEmpty) {
        return false;
      }

      // ------------------------------------------------------
      // SECURITY:
      // Normal signup should never create an admin account.
      // Admin must be created separately from Firebase Console.
      // ------------------------------------------------------

      final safeRole =
      normalizedRole == 'admin'
          ? 'admin'
          : 'user';

      await _userDocument(uid).set(
        {
          'uid': uid,
          'name': name,
          'email': email,
          'phone': phone,
          'role': safeRole,
          'updatedAt':
          FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      debugPrint(
        'FIRESTORE PROFILE SAVED: $uid',
      );

      debugPrint(
        'FIRESTORE ROLE SAVED: $safeRole',
      );

      return true;
    } catch (e) {
      debugPrint(
        'FIRESTORE PROFILE SAVE ERROR: $e',
      );

      return false;
    }
  }

  // ==========================================================
  // SAVE LOCAL SESSION
  // ==========================================================

  Future<bool> saveUser({
    required String userId,
    required String userName,
    required String userEmail,
    required String userPhone,
    required String password,
    String role = 'user',
  }) async {
    try {
      final prefs =
      await SharedPreferences.getInstance();

      final uid = userId.trim();

      final name = userName.trim();

      final email =
      userEmail.trim().toLowerCase();

      final phone = userPhone.trim();

      final normalizedRole =
      role.trim().toLowerCase();

      if (uid.isEmpty ||
          name.isEmpty ||
          email.isEmpty) {
        return false;
      }

      await prefs.setString(
        _userIdKey,
        uid,
      );

      await prefs.setString(
        _userNameKey,
        name,
      );

      await prefs.setString(
        _userEmailKey,
        email,
      );

      await prefs.setString(
        _userPhoneKey,
        phone,
      );

      await prefs.setString(
        _userRoleKey,
        normalizedRole.isEmpty
            ? 'user'
            : normalizedRole,
      );

      await prefs.setBool(
        _isLoggedInKey,
        true,
      );

      _cachedUserEmail = email;

      // Password intentionally NOT stored.

      return true;
    } catch (e) {
      debugPrint(
        'SAVE LOCAL USER ERROR: $e',
      );

      return false;
    }
  }

  // ==========================================================
  // SIGN UP
  // ==========================================================

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    String phone = '',
  }) async {
    try {
      final normalizedEmail =
      email.trim().toLowerCase();

      final trimmedName =
      name.trim();

      final trimmedPhone =
      phone.trim();

      if (normalizedEmail.isEmpty ||
          trimmedName.isEmpty ||
          password.length < 6) {
        return false;
      }

      debugPrint(
        'FIREBASE SIGNUP START',
      );

      // ------------------------------------------------------
      // CREATE FIREBASE ACCOUNT
      // ------------------------------------------------------

      final credential =
      await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        return false;
      }

      // ------------------------------------------------------
      // SAVE DISPLAY NAME
      // ------------------------------------------------------

      await user.updateDisplayName(
        trimmedName,
      );

      await user.reload();

      final current =
          _auth.currentUser;

      final finalName =
          current?.displayName ??
              trimmedName;

      final finalEmail =
          current?.email ??
              normalizedEmail;

      // ------------------------------------------------------
      // SAVE LOCAL SESSION
      // ------------------------------------------------------

      await saveUser(
        userId: user.uid,
        userName: finalName,
        userEmail: finalEmail,
        userPhone: trimmedPhone,
        password: password,
        role: 'user',
      );

      // ------------------------------------------------------
      // SAVE FIRESTORE PROFILE
      // ------------------------------------------------------

      await saveUserToFirestore(
        userId: user.uid,
        userName: finalName,
        userEmail: finalEmail,
        userPhone: trimmedPhone,
        role: 'user',
      );

      _cachedUserEmail =
          finalEmail.trim().toLowerCase();

      debugPrint(
        'FIREBASE SIGNUP SUCCESS',
      );

      debugPrint(
        'UID: ${user.uid}',
      );

      debugPrint(
        'ROLE: user',
      );

      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'SIGNUP ERROR '
            '[${e.code}]: ${e.message}',
      );

      return false;
    } catch (e) {
      debugPrint(
        'SIGNUP GENERAL ERROR: $e',
      );

      return false;
    }
  }

  // ==========================================================
  // LOGIN
  // ==========================================================

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      final normalizedEmail =
      email.trim().toLowerCase();

      if (normalizedEmail.isEmpty ||
          password.isEmpty) {
        return false;
      }

      debugPrint(
        'FIREBASE LOGIN START',
      );

      // ------------------------------------------------------
      // FIREBASE AUTHENTICATION
      // ------------------------------------------------------

      final credential =
      await _auth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        return false;
      }

      // ------------------------------------------------------
      // GET FIRESTORE PROFILE
      // ------------------------------------------------------

      final userDoc =
      await _userDocument(
        user.uid,
      ).get(
        const GetOptions(
          source: Source.server,
        ),
      );

      String name =
          user.displayName ?? '';

      String phone = '';

      String role = 'user';

      if (userDoc.exists) {
        final data =
        userDoc.data();

        if (data != null) {
          final firestoreName =
          data['name'];

          final firestorePhone =
          data['phone'];

          final firestoreRole =
          data['role'];

          // --------------------------------------------------
          // NAME
          // --------------------------------------------------

          if (firestoreName is String &&
              firestoreName
                  .trim()
                  .isNotEmpty) {
            name =
                firestoreName.trim();
          }

          // --------------------------------------------------
          // PHONE
          // --------------------------------------------------

          if (firestorePhone is String) {
            phone =
                firestorePhone.trim();
          }

          // --------------------------------------------------
          // ROLE
          // --------------------------------------------------

          if (firestoreRole is String &&
              firestoreRole
                  .trim()
                  .isNotEmpty) {
            role =
                firestoreRole
                    .trim()
                    .toLowerCase();
          }
        }
      } else {
        // ----------------------------------------------------
        // CREATE PROFILE FOR EXISTING AUTH USER
        // ----------------------------------------------------

        name = name.isNotEmpty
            ? name
            : 'CyberSafe User';

        role = 'user';

        await saveUserToFirestore(
          userId: user.uid,
          userName: name,
          userEmail:
          user.email ??
              normalizedEmail,
          userPhone: '',
          role: 'user',
        );
      }

      // ------------------------------------------------------
      // ONLY ACCEPT VALID ROLES
      // ------------------------------------------------------

      if (role != 'user' &&
          role != 'admin') {
        role = 'user';
      }

      // ------------------------------------------------------
      // SAVE SESSION
      // ------------------------------------------------------

      final prefs =
      await SharedPreferences.getInstance();

      await prefs.setString(
        _userIdKey,
        user.uid,
      );

      await prefs.setString(
        _userEmailKey,
        user.email ??
            normalizedEmail,
      );

      await prefs.setString(
        _userNameKey,
        name,
      );

      await prefs.setString(
        _userPhoneKey,
        phone,
      );

      await prefs.setString(
        _userRoleKey,
        role,
      );

      await prefs.setBool(
        _isLoggedInKey,
        true,
      );

      _cachedUserEmail =
          (user.email ??
              normalizedEmail)
              .trim()
              .toLowerCase();

      debugPrint(
        'LOGIN SUCCESS',
      );

      debugPrint(
        'UID: ${user.uid}',
      );

      debugPrint(
        'ROLE: $role',
      );

      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'LOGIN ERROR '
            '[${e.code}]: ${e.message}',
      );

      return false;
    } catch (e) {
      debugPrint(
        'LOGIN GENERAL ERROR: $e',
      );

      return false;
    }
  }

  // ==========================================================
  // ADMIN ROLE CHECK
  // ==========================================================
  //
  // IMPORTANT:
  // Admin verification is ALWAYS performed from Firestore.
  //
  // Firestore:
  //
  // users/{uid}
  //     role: "admin"
  //
  // SharedPreferences is NOT trusted for Admin verification.
  //
  // ==========================================================

  Future<bool> isAdmin() async {
    final user =
        _auth.currentUser;

    if (user == null) {
      debugPrint(
        'ADMIN CHECK: NO FIREBASE USER',
      );

      return false;
    }

    try {
      // ------------------------------------------------------
      // ALWAYS READ FRESH ROLE FROM FIRESTORE
      // ------------------------------------------------------

      final snapshot =
      await _userDocument(
        user.uid,
      ).get(
        const GetOptions(
          source: Source.server,
        ),
      );

      if (!snapshot.exists) {
        debugPrint(
          'ADMIN CHECK: '
              'USER DOCUMENT NOT FOUND',
        );

        return false;
      }

      final data =
      snapshot.data();

      if (data == null) {
        return false;
      }

      final role =
      data['role']
          ?.toString()
          .trim()
          .toLowerCase();

      final admin =
          role == 'admin';

      debugPrint(
        'ADMIN CHECK: $admin',
      );

      debugPrint(
        'FIRESTORE ROLE: $role',
      );

      debugPrint(
        'ADMIN UID: ${user.uid}',
      );

      return admin;
    } on FirebaseException catch (e) {
      debugPrint(
        'ADMIN CHECK FIREBASE ERROR '
            '[${e.code}]: ${e.message}',
      );

      return false;
    } catch (e) {
      debugPrint(
        'ADMIN CHECK ERROR: $e',
      );

      return false;
    }
  }

  // ==========================================================
  // GET USER ROLE
  // ==========================================================
  //
  // IMPORTANT:
  //
  // Current Firebase UID is the source of truth.
  //
  // Firestore:
  //
  // users/{CURRENT_UID}
  //
  // role:
  //     user
  //     admin
  //
  // SharedPreferences is NOT used when a Firebase user
  // is currently signed in.
  //
  // This prevents Admin/User role mixing.
  //
  // ==========================================================

  Future<String> getUserRole() async {
    try {
      final user =
          _auth.currentUser;

      // ------------------------------------------------------
      // NO FIREBASE USER
      // ------------------------------------------------------

      if (user == null) {
        final prefs =
        await SharedPreferences
            .getInstance();

        final savedRole =
        prefs.getString(
          _userRoleKey,
        );

        if (savedRole == null ||
            savedRole.trim().isEmpty) {
          return 'guest';
        }

        return savedRole
            .trim()
            .toLowerCase();
      }

      // ------------------------------------------------------
      // GET ROLE DIRECTLY FROM FIRESTORE
      // ------------------------------------------------------

      final doc =
      await _userDocument(
        user.uid,
      ).get(
        const GetOptions(
          source: Source.server,
        ),
      );

      // ------------------------------------------------------
      // USER DOCUMENT EXISTS
      // ------------------------------------------------------

      if (doc.exists) {
        final data =
        doc.data();

        final role =
        data?['role'];

        if (role is String &&
            role.trim().isNotEmpty) {
          final normalizedRole =
          role.trim().toLowerCase();

          // --------------------------------------------------
          // SAVE VERIFIED ROLE LOCALLY
          // --------------------------------------------------

          final prefs =
          await SharedPreferences
              .getInstance();

          await prefs.setString(
            _userRoleKey,
            normalizedRole,
          );

          debugPrint(
            'GET USER ROLE SUCCESS',
          );

          debugPrint(
            'CURRENT UID: ${user.uid}',
          );

          debugPrint(
            'FIRESTORE ROLE: '
                '$normalizedRole',
          );

          return normalizedRole;
        }
      }

      // ------------------------------------------------------
      // FIREBASE USER EXISTS BUT ROLE IS MISSING
      // ------------------------------------------------------
      //
      // If Firebase account exists but Firestore role is
      // missing, DO NOT use an old cached Admin role.
      //
      // Treat account as normal user.
      //
      // ------------------------------------------------------

      final prefs =
      await SharedPreferences
          .getInstance();

      await prefs.setString(
        _userRoleKey,
        'user',
      );

      debugPrint(
        'USER ROLE NOT FOUND',
      );

      debugPrint(
        'CURRENT UID: ${user.uid}',
      );

      debugPrint(
        'DEFAULT ROLE: user',
      );

      return 'user';
    } on FirebaseException catch (e) {
      debugPrint(
        'GET USER ROLE FIREBASE ERROR '
            '[${e.code}]: ${e.message}',
      );

      // ------------------------------------------------------
      // IMPORTANT:
      // Do not trust cached Admin role if Firestore
      // verification failed.
      // ------------------------------------------------------

      return 'guest';
    } catch (e) {
      debugPrint(
        'GET USER ROLE ERROR: $e',
      );

      return 'guest';
    }
  }

  // ==========================================================
  // IS USER
  // ==========================================================

  Future<bool> isUser() async {
    final role =
    await getUserRole();

    return role == 'user';
  }

  // ==========================================================
  // USER ID
  // ==========================================================

  Future<String> getUserId() async {
    final firebaseUser =
        _auth.currentUser;

    if (firebaseUser != null) {
      return firebaseUser.uid;
    }

    final prefs =
    await SharedPreferences
        .getInstance();

    return prefs.getString(
      _userIdKey,
    ) ??
        '';
  }

  // ==========================================================
  // USER NAME
  // ==========================================================

  Future<String> getUserName() async {
    final firebaseUser =
        _auth.currentUser;

    if (firebaseUser != null) {
      final displayName =
          firebaseUser.displayName;

      if (displayName != null &&
          displayName
              .trim()
              .isNotEmpty) {
        return displayName.trim();
      }

      try {
        final doc =
        await _userDocument(
          firebaseUser.uid,
        ).get();

        final data =
        doc.data();

        final name =
        data?['name'];

        if (name is String &&
            name.trim().isNotEmpty) {
          return name.trim();
        }
      } catch (_) {}
    }

    final prefs =
    await SharedPreferences
        .getInstance();

    return prefs.getString(
      _userNameKey,
    ) ??
        '';
  }

  // ==========================================================
  // USER EMAIL
  // ==========================================================

  Future<String> getUserEmail() async {
    final firebaseEmail =
        _auth.currentUser?.email;

    if (firebaseEmail != null &&
        firebaseEmail
            .trim()
            .isNotEmpty) {
      final email =
      firebaseEmail
          .trim()
          .toLowerCase();

      _cachedUserEmail =
          email;

      return email;
    }

    final prefs =
    await SharedPreferences
        .getInstance();

    final email =
    prefs.getString(
      _userEmailKey,
    );

    if (email != null) {
      _cachedUserEmail =
          email.trim().toLowerCase();

      return _cachedUserEmail!;
    }

    return '';
  }

  // ==========================================================
  // USER PHONE
  // ==========================================================

  Future<String> getUserPhone() async {
    final firebaseUser =
        _auth.currentUser;

    if (firebaseUser != null) {
      try {
        final doc =
        await _userDocument(
          firebaseUser.uid,
        ).get();

        final phone =
        doc.data()?['phone'];

        if (phone is String) {
          return phone.trim();
        }
      } catch (_) {}
    }

    final prefs =
    await SharedPreferences
        .getInstance();

    return prefs.getString(
      _userPhoneKey,
    ) ??
        '';
  }

  // ==========================================================
  // GET COMPLETE PROFILE
  // ==========================================================

  Future<Map<String, dynamic>?>
  getUserProfile() async {
    try {
      final user =
          _auth.currentUser;

      if (user == null) {
        return null;
      }

      final doc =
      await _userDocument(
        user.uid,
      ).get();

      if (!doc.exists) {
        return null;
      }

      return doc.data();
    } catch (e) {
      debugPrint(
        'GET USER PROFILE ERROR: $e',
      );

      return null;
    }
  }

  // ==========================================================
  // UPDATE PROFILE
  // ==========================================================

  Future<bool> updateProfile({
    required String name,
    String? email,
    String? phone,
  }) async {
    try {
      final trimmedName =
      name.trim();

      if (trimmedName.isEmpty) {
        return false;
      }

      final firebaseUser =
          _auth.currentUser;

      final prefs =
      await SharedPreferences
          .getInstance();

      String? normalizedEmail;

      if (email != null &&
          email.trim().isNotEmpty) {
        normalizedEmail =
            email.trim().toLowerCase();
      }

      // ------------------------------------------------------
      // FIREBASE DISPLAY NAME
      // ------------------------------------------------------

      if (firebaseUser != null) {
        await firebaseUser
            .updateDisplayName(
          trimmedName,
        );

        await firebaseUser.reload();
      }

      // ------------------------------------------------------
      // LOCAL DATA
      // ------------------------------------------------------

      await prefs.setString(
        _userNameKey,
        trimmedName,
      );

      if (normalizedEmail != null) {
        await prefs.setString(
          _userEmailKey,
          normalizedEmail,
        );

        _cachedUserEmail =
            normalizedEmail;
      }

      if (phone != null) {
        await prefs.setString(
          _userPhoneKey,
          phone.trim(),
        );
      }

      // ------------------------------------------------------
      // FIRESTORE
      // ------------------------------------------------------

      if (firebaseUser != null) {
        final data =
        <String, dynamic>{
          'name': trimmedName,

          if (normalizedEmail != null)
            'email': normalizedEmail,

          if (phone != null)
            'phone': phone.trim(),

          'updatedAt':
          FieldValue.serverTimestamp(),
        };

        await _userDocument(
          firebaseUser.uid,
        ).set(
          data,
          SetOptions(merge: true),
        );
      }

      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'UPDATE PROFILE AUTH ERROR '
            '[${e.code}]: ${e.message}',
      );

      return false;
    } catch (e) {
      debugPrint(
        'UPDATE PROFILE ERROR: $e',
      );

      return false;
    }
  }

  // ==========================================================
  // PASSWORD RESET EMAIL
  // ==========================================================

  Future<bool> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      final normalizedEmail =
      email.trim().toLowerCase();

      if (normalizedEmail.isEmpty) {
        return false;
      }

      await _auth
          .sendPasswordResetEmail(
        email: normalizedEmail,
      );

      debugPrint(
        'PASSWORD RESET EMAIL SENT',
      );

      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'PASSWORD RESET ERROR '
            '[${e.code}]: ${e.message}',
      );

      return false;
    } catch (e) {
      debugPrint(
        'PASSWORD RESET GENERAL ERROR: $e',
      );

      return false;
    }
  }

  // ==========================================================
  // CHANGE PASSWORD
  // ==========================================================

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      if (oldPassword.isEmpty ||
          newPassword.length < 6) {
        return false;
      }

      final user =
          _auth.currentUser;

      if (user == null ||
          user.email == null) {
        return false;
      }

      final credential =
      EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );

      await user
          .reauthenticateWithCredential(
        credential,
      );

      await user.updatePassword(
        newPassword,
      );

      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'CHANGE PASSWORD ERROR '
            '[${e.code}]: ${e.message}',
      );

      return false;
    } catch (e) {
      debugPrint(
        'CHANGE PASSWORD GENERAL ERROR: $e',
      );

      return false;
    }
  }

  // ==========================================================
  // UPDATE PASSWORD
  // ==========================================================

  Future<bool> updatePassword(
      String newPassword,
      ) async {
    try {
      if (newPassword.length < 6) {
        return false;
      }

      final user =
          _auth.currentUser;

      if (user == null) {
        return false;
      }

      await user.updatePassword(
        newPassword,
      );

      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'UPDATE PASSWORD ERROR '
            '[${e.code}]: ${e.message}',
      );

      return false;
    } catch (e) {
      debugPrint(
        'UPDATE PASSWORD GENERAL ERROR: $e',
      );

      return false;
    }
  }

  // ==========================================================
  // RESET PASSWORD
  // ==========================================================

  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    // Firebase client apps cannot directly
    // change another user's password.
    //
    // Official password reset email is used.

    return sendPasswordResetEmail(
      email: email,
    );
  }

  // ==========================================================
  // LOGOUT
  // ==========================================================

  Future<void> logout() async {
    try {
      await _auth.signOut();

      final prefs =
      await SharedPreferences
          .getInstance();

      await prefs.setBool(
        _isLoggedInKey,
        false,
      );

      await prefs.remove(
        _userIdKey,
      );

      await prefs.remove(
        _userEmailKey,
      );

      await prefs.remove(
        _userNameKey,
      );

      await prefs.remove(
        _userPhoneKey,
      );

      await prefs.remove(
        _userRoleKey,
      );

      _cachedUserEmail = null;

      debugPrint(
        'USER LOGGED OUT',
      );
    } catch (e) {
      debugPrint(
        'LOGOUT ERROR: $e',
      );
    }
  }

  // ==========================================================
  // IS LOGGED IN
  // ==========================================================

  Future<bool> isLoggedIn() async {
    try {
      // Firebase Authentication is the primary source.
      if (_auth.currentUser != null) {
        return true;
      }

      final prefs =
      await SharedPreferences
          .getInstance();

      return prefs.getBool(
        _isLoggedInKey,
      ) ??
          false;
    } catch (e) {
      debugPrint(
        'IS LOGGED IN ERROR: $e',
      );

      return false;
    }
  }

  // ==========================================================
  // ONBOARDING
  // ==========================================================

  Future<bool>
  isOnboardingCompleted() async {
    final prefs =
    await SharedPreferences
        .getInstance();

    return prefs.getBool(
      _onboardingKey,
    ) ??
        false;
  }

  // ==========================================================
  // COMPLETE ONBOARDING
  // ==========================================================

  Future<void>
  completeOnboarding() async {
    final prefs =
    await SharedPreferences
        .getInstance();

    await prefs.setBool(
      _onboardingKey,
      true,
    );
  }

  // ==========================================================
  // RESET ONBOARDING
  // ==========================================================

  Future<void>
  resetOnboarding() async {
    final prefs =
    await SharedPreferences
        .getInstance();

    await prefs.setBool(
      _onboardingKey,
      false,
    );
  }

  // ==========================================================
  // CLEAR SESSION
  // ==========================================================

  Future<void> clearSession() async {
    try {
      await _auth.signOut();

      final prefs =
      await SharedPreferences
          .getInstance();

      await prefs.setBool(
        _isLoggedInKey,
        false,
      );

      await prefs.remove(
        _userIdKey,
      );

      await prefs.remove(
        _userEmailKey,
      );

      await prefs.remove(
        _userNameKey,
      );

      await prefs.remove(
        _userPhoneKey,
      );

      await prefs.remove(
        _userRoleKey,
      );

      _cachedUserEmail = null;
    } catch (e) {
      debugPrint(
        'CLEAR SESSION ERROR: $e',
      );
    }
  }

  // ==========================================================
  // FULL LOCAL RESET
  // ==========================================================

  Future<void> clearAllData() async {
    try {
      await _auth.signOut();

      final prefs =
      await SharedPreferences
          .getInstance();

      await prefs.clear();

      _cachedUserEmail = null;

      debugPrint(
        'ALL LOCAL DATA CLEARED',
      );
    } catch (e) {
      debugPrint(
        'CLEAR ALL DATA ERROR: $e',
      );
    }
  }
}