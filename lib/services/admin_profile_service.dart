import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/admin_profile.dart';

class AdminProfileService {
AdminProfileService._();

static final AdminProfileService instance =
AdminProfileService._();

final FirebaseAuth _auth =
FirebaseAuth.instance;

final FirebaseFirestore _firestore =
FirebaseFirestore.instance;

static const String _usersCollection = 'users';
static const String _adminRole = 'admin';

// ==========================================================
// CURRENT USER
// ==========================================================

User? get currentUser =>
_auth.currentUser;

String? get currentUserId =>
_auth.currentUser?.uid;

// ==========================================================
// USER DOCUMENT
// ==========================================================

DocumentReference<Map<String, dynamic>>?
get _userDocument {
final user = _auth.currentUser;

if (user == null) {
return null;
}

return _firestore
    .collection(_usersCollection)
    .doc(user.uid);
}

// ==========================================================
// CHECK ADMIN
// ==========================================================

Future<bool> _isCurrentUserAdmin() async {
final user = _auth.currentUser;

if (user == null) {
return false;
}

final snapshot = await _firestore
    .collection(_usersCollection)
    .doc(user.uid)
    .get();

if (!snapshot.exists) {
return false;
}

final data = snapshot.data();

if (data == null) {
return false;
}

final role =
data['role']?.toString().trim().toLowerCase();

return role == _adminRole;
}

// ==========================================================
// GET PROFILE
// ==========================================================

Future<AdminProfile> getProfile() async {
final user = _auth.currentUser;

if (user == null) {
throw Exception(
'No authenticated admin found.',
);
}

final isAdmin =
await _isCurrentUserAdmin();

if (!isAdmin) {
throw Exception(
'Current user is not an administrator.',
);
}

final snapshot = await _firestore
    .collection(_usersCollection)
    .doc(user.uid)
    .get();

if (!snapshot.exists) {
return AdminProfile(
name: user.displayName?.trim().isNotEmpty == true
? user.displayName!.trim()
    : 'CyberSafe Admin',
email: user.email ?? '',
phone: '',
designation: 'System Administrator',
bio:
'CyberSafe Complaint Management Administrator',
profileImagePath: '',
);
}

final data = snapshot.data();

if (data == null) {
return AdminProfile.defaultProfile();
}

final profile =
AdminProfile.fromMap(data);

return AdminProfile(
name: profile.name.trim().isEmpty
? 'CyberSafe Admin'
    : profile.name,
email: profile.email.trim().isEmpty
? (user.email ?? '')
    : profile.email,
phone: profile.phone,
designation:
profile.designation.trim().isEmpty
? 'System Administrator'
    : profile.designation,
bio: profile.bio.trim().isEmpty
? 'CyberSafe Complaint Management Administrator'
    : profile.bio,

// Local image path only.
profileImagePath:
profile.profileImagePath,
);
}

// ==========================================================
// SAVE PROFILE
// ==========================================================

Future<void> saveProfile(
AdminProfile profile,
) async {
final user = _auth.currentUser;

if (user == null) {
throw Exception(
'No authenticated admin found.',
);
}

final isAdmin =
await _isCurrentUserAdmin();

if (!isAdmin) {
throw Exception(
'Only administrators can update this profile.',
);
}

final document = _userDocument;

if (document == null) {
throw Exception(
'Admin document not found.',
);
}

// --------------------------------------------------------
// IMPORTANT:
// Profile image is NOT uploaded to Firebase Storage.
//
// It remains a local device path.
// --------------------------------------------------------

final data = <String, dynamic>{
'name': profile.name.trim(),
'email': profile.email.trim(),
'phone': profile.phone.trim(),
'designation':
profile.designation.trim(),
'bio': profile.bio.trim(),

// Local path only.
'profileImagePath':
profile.profileImagePath.trim(),

// Make sure role remains admin.
'role': _adminRole,

'updatedAt':
FieldValue.serverTimestamp(),
};

await document.set(
data,
SetOptions(merge: true),
);
}

// ==========================================================
// REMOVE PROFILE IMAGE
// ==========================================================

Future<void> removeProfileImage() async {
final user = _auth.currentUser;

if (user == null) {
throw Exception(
'No authenticated admin found.',
);
}

final isAdmin =
await _isCurrentUserAdmin();

if (!isAdmin) {
throw Exception(
'Only administrators can remove the profile image.',
);
}

final document = _userDocument;

if (document == null) {
return;
}

await document.set(
{
'profileImagePath': '',
'updatedAt':
FieldValue.serverTimestamp(),
},
SetOptions(merge: true),
);
}

// ==========================================================
// CLEAR PROFILE
// ==========================================================

Future<void> clearProfile() async {
final user = _auth.currentUser;

if (user == null) {
throw Exception(
'No authenticated admin found.',
);
}

final isAdmin =
await _isCurrentUserAdmin();

if (!isAdmin) {
throw Exception(
'Only administrators can clear the profile.',
);
}

final document = _userDocument;

if (document == null) {
return;
}

await document.set(
{
'name': 'CyberSafe Admin',
'phone': '',
'designation':
'System Administrator',
'bio':
'CyberSafe Complaint Management Administrator',
'profileImagePath': '',
'role': _adminRole,
'updatedAt':
FieldValue.serverTimestamp(),
},
SetOptions(merge: true),
);
}
}
