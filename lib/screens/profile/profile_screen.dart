import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../localization/app_localizations.dart';
import '../../models/complaint.dart';
import '../../models/complaint_status.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../widgets/status_chip.dart';

class ProfileScreen extends StatefulWidget {
final bool isGuest;

const ProfileScreen({
super.key,
this.isGuest = false,
});

@override
State<ProfileScreen> createState() =>
_ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
with SingleTickerProviderStateMixin {
// ==========================================================
// ANIMATION
// ==========================================================

late final AnimationController _animationController;
late final Animation<double> _fadeAnimation;
late final Animation<Offset> _slideAnimation;
late final Animation<double> _scaleAnimation;

// ==========================================================
// PROFILE DATA
// ==========================================================

String _name = 'User';
String _email = '';

String? _profileImageBase64;

bool _isLoading = true;
bool _isImageLoading = false;

static const String _profileImageKey =
'cybersafe_profile_image_base64';

// ==========================================================
// LOCALIZATION HELPER
// ==========================================================

String _text({
required String english,
required String urdu,
required String romanUrdu,
}) {
final language =
AppLocalizations.of(context).language;

switch (language) {
case 'اردو':
return urdu;

case 'Roman Urdu':
return romanUrdu;

case 'English':
default:
return english;
}
}

// ==========================================================
// INIT
// ==========================================================

@override
void initState() {
super.initState();

_animationController = AnimationController(
vsync: this,
duration: const Duration(
milliseconds: 700,
),
);

_fadeAnimation = CurvedAnimation(
parent: _animationController,
curve: Curves.easeOut,
);

_slideAnimation = Tween<Offset>(
begin: const Offset(0, 0.08),
end: Offset.zero,
).animate(
CurvedAnimation(
parent: _animationController,
curve: Curves.easeOutCubic,
),
);

_scaleAnimation = Tween<double>(
begin: 0.85,
end: 1.0,
).animate(
CurvedAnimation(
parent: _animationController,
curve: Curves.easeOutBack,
),
);

_loadProfileImage();
_loadProfile();
}

// ==========================================================
// FIREBASE UID
// ==========================================================

String? get _currentUserId {
return FirebaseAuth.instance.currentUser?.uid;
}

// ==========================================================
// LOAD PROFILE IMAGE
// ==========================================================

Future<void> _loadProfileImage() async {
try {
final prefs =
await SharedPreferences.getInstance();

final localImage = prefs.getString(
_profileImageKey,
);

if (localImage != null &&
localImage.isNotEmpty) {
if (!mounted) return;

setState(() {
_profileImageBase64 = localImage;
});
}

if (widget.isGuest) {
return;
}

final uid = _currentUserId;

if (uid == null || uid.isEmpty) {
return;
}

final doc = await FirebaseFirestore.instance
    .collection('users')
    .doc(uid)
    .get();

if (!doc.exists) {
return;
}

final data = doc.data();

final firebaseImage =
data?['profileImageBase64'];

if (firebaseImage is String &&
firebaseImage.isNotEmpty) {
await prefs.setString(
_profileImageKey,
firebaseImage,
);

if (!mounted) return;

setState(() {
_profileImageBase64 = firebaseImage;
});
}
} catch (e) {
debugPrint(
'PROFILE IMAGE LOAD ERROR: $e',
);
}
}

// ==========================================================
// LOAD PROFILE
// ==========================================================

Future<void> _loadProfile() async {
if (widget.isGuest) {
if (!mounted) return;

setState(() {
_name = 'Guest';
_email = '';
_isLoading = false;
});

_animationController.forward();
return;
}

try {
final userName =
await AuthService.instance.getUserName();

String userEmail = '';

try {
userEmail =
await AuthService.instance.getUserEmail();
} catch (e) {
debugPrint(
'EMAIL LOAD ERROR: $e',
);

userEmail =
FirebaseAuth.instance.currentUser?.email ??
'';
}

if (!mounted) return;

setState(() {
_name = userName.trim().isEmpty
? 'User'
    : userName.trim();

_email = userEmail.trim();

_isLoading = false;
});

_animationController.forward();
} catch (e) {
debugPrint(
'PROFILE LOAD ERROR: $e',
);

if (!mounted) return;

final firebaseEmail =
FirebaseAuth.instance.currentUser?.email ??
'';

setState(() {
_name = 'User';
_email = firebaseEmail;
_isLoading = false;
});

_animationController.forward();
}
}

// ==========================================================
// USER COMPLAINTS
// ==========================================================

List<Complaint> get _userComplaints {
return [];
}

// ==========================================================
// TOTAL
// ==========================================================

int get _totalComplaints {
return _userComplaints.length;
}

// ==========================================================
// RESOLVED
// ==========================================================

int get _resolvedComplaints {
return _userComplaints.where(
(complaint) {
return complaint.status ==
ComplaintStatus.resolved ||
complaint.status ==
ComplaintStatus.closed;
},
).length;
}

// ==========================================================
// ACTIVE
// ==========================================================

int get _activeComplaints {
return _userComplaints.where(
(complaint) {
return complaint.status ==
ComplaintStatus.submitted ||
complaint.status ==
ComplaintStatus.underReview ||
complaint.status ==
ComplaintStatus.inProgress;
},
).length;
}

// ==========================================================
// INITIAL
// ==========================================================

String get _initial {
if (_name.trim().isEmpty) {
return 'U';
}

return _name.trim()[0].toUpperCase();
}

// ==========================================================
// IMAGE BYTES
// ==========================================================

Uint8List? get _profileImageBytes {
if (_profileImageBase64 == null ||
_profileImageBase64!.isEmpty) {
return null;
}

try {
return base64Decode(
_profileImageBase64!,
);
} catch (e) {
debugPrint(
'IMAGE DECODE ERROR: $e',
);

return null;
}
}

// ==========================================================
// DISPOSE
// ==========================================================

@override
void dispose() {
_animationController.dispose();
super.dispose();
}

// ==========================================================
// PROFILE IMAGE OPTIONS
// ==========================================================

void _showProfileImageOptions() {
if (widget.isGuest) {
_showLoginRequired();
return;
}

showModalBottomSheet(
context: context,
backgroundColor: Colors.transparent,
builder: (context) {
final theme =
Theme.of(context);

return Container(
padding:
const EdgeInsets.fromLTRB(
24,
20,
24,
28,
),
decoration: BoxDecoration(
color: theme
    .scaffoldBackgroundColor,
borderRadius:
const BorderRadius.vertical(
top: Radius.circular(28),
),
),
child: Column(
mainAxisSize:
MainAxisSize.min,
children: [
Container(
width: 42,
height: 4,
decoration: BoxDecoration(
color:
Colors.grey.shade400,
borderRadius:
BorderRadius.circular(
20,
),
),
),

const SizedBox(height: 24),

Text(
_text(
english: 'Profile Photo',
urdu: 'پروفائل تصویر',
romanUrdu: 'Profile Photo',
),
style: const TextStyle(
fontSize: 21,
fontWeight:
FontWeight.w800,
),
),

const SizedBox(height: 6),

Text(
_text(
english:
'Choose how you want to update your photo.',
urdu:
'منتخب کریں کہ آپ اپنی تصویر کیسے اپ ڈیٹ کرنا چاہتے ہیں۔',
romanUrdu:
'Select karein ke aap apni photo kaise update karna chahte hain.',
),
textAlign:
TextAlign.center,
style: TextStyle(
color:
Colors.grey.shade600,
fontSize: 13,
),
),

const SizedBox(height: 20),

// GALLERY
ListTile(
contentPadding:
const EdgeInsets
    .symmetric(
horizontal: 4,
),
leading: CircleAvatar(
backgroundColor:
theme
    .colorScheme
    .primary
    .withValues(
alpha: 0.10,
),
child: Icon(
Icons
    .photo_library_outlined,
color: theme
    .colorScheme
    .primary,
),
),
title: Text(
_text(
english:
'Choose from Gallery',
urdu:
'گیلری سے منتخب کریں',
romanUrdu:
'Gallery se Select Karein',
),
style: const TextStyle(
fontWeight:
FontWeight.w600,
),
),
subtitle: Text(
_text(
english:
'Select a photo from your device',
urdu:
'اپنے ڈیوائس سے تصویر منتخب کریں',
romanUrdu:
'Apne device se photo select karein',
),
),
onTap: () {
Navigator.pop(
context,
);

_pickProfileImage(
ImageSource.gallery,
);
},
),

const SizedBox(height: 6),

// CAMERA
ListTile(
contentPadding:
const EdgeInsets
    .symmetric(
horizontal: 4,
),
leading: CircleAvatar(
backgroundColor:
theme
    .colorScheme
    .primary
    .withValues(
alpha: 0.10,
),
child: Icon(
Icons
    .camera_alt_outlined,
color: theme
    .colorScheme
    .primary,
),
),
title: Text(
_text(
english: 'Take a Photo',
urdu: 'تصویر لیں',
romanUrdu: 'Photo Lein',
),
style: const TextStyle(
fontWeight:
FontWeight.w600,
),
),
subtitle: Text(
_text(
english:
'Use your device camera',
urdu:
'اپنے ڈیوائس کا کیمرہ استعمال کریں',
romanUrdu:
'Apne device ka camera use karein',
),
),
onTap: () {
Navigator.pop(
context,
);

_pickProfileImage(
ImageSource.camera,
);
},
),

// REMOVE
if (_profileImageBase64 !=
null &&
_profileImageBase64!
    .isNotEmpty) ...[
const SizedBox(height: 6),

ListTile(
contentPadding:
const EdgeInsets
    .symmetric(
horizontal: 4,
),
leading: CircleAvatar(
backgroundColor:
theme
    .colorScheme
    .error
    .withValues(
alpha: 0.10,
),
child: Icon(
Icons
    .delete_outline_rounded,
color: theme
    .colorScheme
    .error,
),
),
title: Text(
_text(
english: 'Remove Photo',
urdu: 'تصویر حذف کریں',
romanUrdu:
'Photo Remove Karein',
),
style: const TextStyle(
fontWeight:
FontWeight.w600,
),
),
subtitle: Text(
_text(
english:
'Remove your current profile photo',
urdu:
'اپنی موجودہ پروفائل تصویر حذف کریں',
romanUrdu:
'Apni current profile photo remove karein',
),
),
onTap: () {
Navigator.pop(
context,
);

_removeProfileImage();
},
),
],
],
),
);
},
);
}

// ==========================================================
// PICK PROFILE IMAGE
// ==========================================================

Future<void> _pickProfileImage(
ImageSource source,
) async {
if (widget.isGuest) {
_showLoginRequired();
return;
}

try {
if (mounted) {
setState(() {
_isImageLoading = true;
});
}

final picker =
ImagePicker();

final XFile? image =
await picker.pickImage(
source: source,
imageQuality: 60,
maxWidth: 500,
maxHeight: 500,
);

if (image == null) {
if (mounted) {
setState(() {
_isImageLoading = false;
});
}

return;
}

final Uint8List bytes =
await image.readAsBytes();

if (bytes.isEmpty) {
throw Exception(
'Selected image is empty.',
);
}

if (bytes.length >
700 * 1024) {
if (!mounted) return;

setState(() {
_isImageLoading = false;
});

ScaffoldMessenger.of(context)
    .showSnackBar(
SnackBar(
content: Text(
_text(
english:
'Image is too large. Please select a smaller image.',
urdu:
'تصویر بہت بڑی ہے۔ براہ کرم چھوٹی تصویر منتخب کریں۔',
romanUrdu:
'Image bohat bari hai. Choti image select karein.',
),
),
behavior:
SnackBarBehavior.floating,
),
);

return;
}

final base64Image =
base64Encode(bytes);

// ========================================================
// LOCAL SAVE
// ========================================================

final prefs =
await SharedPreferences
    .getInstance();

await prefs.setString(
_profileImageKey,
base64Image,
);

// ========================================================
// FIREBASE
// ========================================================

final uid = _currentUserId;

if (uid != null &&
uid.isNotEmpty) {
await FirebaseFirestore
    .instance
    .collection('users')
    .doc(uid)
    .set(
{
'profileImageBase64':
base64Image,
'profileImageUpdatedAt':
FieldValue
    .serverTimestamp(),
},
SetOptions(
merge: true,
),
);
}

// ========================================================
// UPDATE SCREEN
// ========================================================

if (!mounted) return;

setState(() {
_profileImageBase64 =
base64Image;

_isImageLoading = false;
});

ScaffoldMessenger.of(context)
    .showSnackBar(
SnackBar(
content: Text(
_text(
english:
'Profile photo updated successfully.',
urdu:
'پروفائل تصویر کامیابی سے اپ ڈیٹ ہو گئی۔',
romanUrdu:
'Profile photo successfully update ho gayi.',
),
),
behavior:
SnackBarBehavior.floating,
),
);
} catch (e) {
debugPrint(
'PROFILE IMAGE ERROR: $e',
);

if (!mounted) return;

setState(() {
_isImageLoading = false;
});

ScaffoldMessenger.of(context)
    .showSnackBar(
SnackBar(
content: Text(
_text(
english:
'Unable to update profile photo.',
urdu:
'پروفائل تصویر اپ ڈیٹ نہیں ہو سکی۔',
romanUrdu:
'Profile photo update nahi ho saki.',
),
),
behavior:
SnackBarBehavior.floating,
),
);
}
}

// ==========================================================
// REMOVE PROFILE IMAGE
// ==========================================================

Future<void> _removeProfileImage() async {
try {
final prefs =
await SharedPreferences
    .getInstance();

await prefs.remove(
_profileImageKey,
);

final uid = _currentUserId;

if (uid != null &&
uid.isNotEmpty) {
await FirebaseFirestore
    .instance
    .collection('users')
    .doc(uid)
    .set(
{
'profileImageBase64':
FieldValue.delete(),
'profileImageUpdatedAt':
FieldValue
    .serverTimestamp(),
},
SetOptions(
merge: true,
),
);
}

if (!mounted) return;

setState(() {
_profileImageBase64 = null;
});

ScaffoldMessenger.of(context)
    .showSnackBar(
SnackBar(
content: Text(
_text(
english:
'Profile photo removed.',
urdu:
'پروفائل تصویر حذف کر دی گئی۔',
romanUrdu:
'Profile photo remove kar di gayi.',
),
),
behavior:
SnackBarBehavior.floating,
),
);
} catch (e) {
debugPrint(
'REMOVE PROFILE IMAGE ERROR: $e',
);

if (!mounted) return;

ScaffoldMessenger.of(context)
    .showSnackBar(
SnackBar(
content: Text(
_text(
english:
'Unable to remove profile photo.',
urdu:
'پروفائل تصویر حذف نہیں ہو سکی۔',
romanUrdu:
'Profile photo remove nahi ho saki.',
),
),
behavior:
SnackBarBehavior.floating,
),
);
}
}

// ==========================================================
// EDIT PROFILE
// ==========================================================

Future<void> _editProfile() async {
if (widget.isGuest) {
_showLoginRequired();
return;
}

final nameController =
TextEditingController(
text: _name,
);

final result =
await showModalBottomSheet<String>(
context: context,
isScrollControlled: true,
backgroundColor:
Colors.transparent,
builder: (context) {
final theme =
Theme.of(context);

return Padding(
padding: EdgeInsets.only(
bottom: MediaQuery.of(context)
    .viewInsets
    .bottom,
),
child: Container(
padding:
const EdgeInsets.fromLTRB(
24,
20,
24,
28,
),
decoration:
BoxDecoration(
color: theme
    .scaffoldBackgroundColor,
borderRadius:
const BorderRadius
    .vertical(
top: Radius.circular(28),
),
),
child: Column(
mainAxisSize:
MainAxisSize.min,
crossAxisAlignment:
CrossAxisAlignment
    .start,
children: [
Center(
child: Container(
width: 42,
height: 4,
decoration:
BoxDecoration(
color:
Colors.grey.shade400,
borderRadius:
BorderRadius
    .circular(
20,
),
),
),
),

const SizedBox(
height: 24,
),

Text(
_text(
english: 'Edit Profile',
urdu: 'پروفائل میں ترمیم کریں',
romanUrdu:
'Profile Edit Karein',
),
style: const TextStyle(
fontSize: 22,
fontWeight:
FontWeight.w700,
),
),

const SizedBox(
height: 8,
),

Text(
_text(
english:
'Update your profile information.',
urdu:
'اپنی پروفائل کی معلومات اپ ڈیٹ کریں۔',
romanUrdu:
'Apni profile information update karein.',
),
style: TextStyle(
color:
Colors.grey.shade600,
),
),

const SizedBox(
height: 24,
),

// PROFILE IMAGE
Center(
child:
GestureDetector(
onTap:
_showProfileImageOptions,
child: Stack(
alignment:
Alignment.center,
children: [
Container(
width: 92,
height: 92,
decoration:
BoxDecoration(
shape:
BoxShape
    .circle,
border:
Border.all(
color: theme
    .colorScheme
    .primary
    .withValues(
alpha: 0.25,
),
width: 3,
),
),
child:
ClipOval(
child:
_buildProfileImage(
size: 92,
),
),
),

Positioned(
right: 0,
bottom: 0,
child:
Container(
width: 30,
height: 30,
decoration:
BoxDecoration(
color: theme
    .colorScheme
    .primary,
shape:
BoxShape
    .circle,
border:
Border.all(
color: theme
    .scaffoldBackgroundColor,
width: 2,
),
),
child:
const Icon(
Icons
    .camera_alt_rounded,
size: 15,
color: Colors
    .white,
),
),
),
],
),
),
),

const SizedBox(
height: 10,
),

Center(
child: Text(
_text(
english:
'Tap photo to change',
urdu:
'تصویر تبدیل کرنے کے لیے ٹیپ کریں',
romanUrdu:
'Photo change karne ke liye tap karein',
),
style: TextStyle(
fontSize: 12,
color: Colors
    .grey
    .shade600,
),
),
),

const SizedBox(
height: 24,
),

TextField(
controller:
nameController,
textCapitalization:
TextCapitalization
    .words,
decoration:
InputDecoration(
labelText:
_text(
english: 'Full Name',
urdu: 'پورا نام',
romanUrdu:
'Poora Naam',
),
prefixIcon:
const Icon(
Icons
    .person_outline_rounded,
),
border:
OutlineInputBorder(
borderRadius:
BorderRadius
    .circular(
14,
),
),
),
),

const SizedBox(
height: 20,
),

SizedBox(
width:
double.infinity,
height: 52,
child:
ElevatedButton(
onPressed: () {
final value =
nameController
    .text
    .trim();

if (value.isEmpty) {
return;
}

Navigator.pop(
context,
value,
);
},
child:
Text(
_text(
english:
'Save Changes',
urdu:
'تبدیلیاں محفوظ کریں',
romanUrdu:
'Changes Save Karein',
),
style:
const TextStyle(
fontWeight:
FontWeight.w600,
),
),
),
),
],
),
),
);
},
);

nameController.dispose();

if (result == null ||
result.trim().isEmpty) {
return;
}

try {
await AuthService.instance
    .updateProfile(
name: result.trim(),
);
} catch (e) {
debugPrint(
'UPDATE PROFILE ERROR: $e',
);
}

if (!mounted) return;

setState(() {
_name = result.trim();
});

ScaffoldMessenger.of(context)
    .showSnackBar(
SnackBar(
content: Text(
_text(
english:
'Profile updated successfully.',
urdu:
'پروفائل کامیابی سے اپ ڈیٹ ہو گئی۔',
romanUrdu:
'Profile successfully update ho gayi.',
),
),
behavior:
SnackBarBehavior.floating,
),
);
}

// ==========================================================
// PROFILE IMAGE WIDGET
// ==========================================================

Widget _buildProfileImage({
required double size,
}) {
final bytes =
_profileImageBytes;

if (bytes != null &&
bytes.isNotEmpty) {
return Image.memory(
bytes,
width: size,
height: size,
fit: BoxFit.cover,
gaplessPlayback: true,
errorBuilder:
(context, error, stackTrace) {
return _buildInitialAvatar(
size,
);
},
);
}

return _buildInitialAvatar(
size,
);
}

// ==========================================================
// INITIAL AVATAR
// ==========================================================

Widget _buildInitialAvatar(
double size,
) {
final theme =
Theme.of(context);

return Container(
width: size,
height: size,
color: theme
    .colorScheme
    .primary
    .withValues(
alpha: 0.10,
),
alignment:
Alignment.center,
child: Text(
_initial,
style: TextStyle(
fontSize:
size * 0.37,
fontWeight:
FontWeight.w800,
color: theme
    .colorScheme
    .primary,
),
),
);
}

// ==========================================================
// LOGIN REQUIRED
// ==========================================================

void _showLoginRequired() {
showModalBottomSheet(
context: context,
backgroundColor:
Colors.transparent,
builder: (context) {
final theme =
Theme.of(context);

return Container(
padding:
const EdgeInsets.fromLTRB(
24,
28,
24,
24,
),
decoration:
BoxDecoration(
color: theme
    .scaffoldBackgroundColor,
borderRadius:
const BorderRadius
    .vertical(
top: Radius.circular(28),
),
),
child: Column(
mainAxisSize:
MainAxisSize.min,
children: [
Container(
width: 64,
height: 64,
decoration:
BoxDecoration(
color: AppColors
    .primary
    .withValues(
alpha: 0.08,
),
shape:
BoxShape.circle,
),
child: const Icon(
Icons
    .lock_outline_rounded,
color:
AppColors.primary,
size: 30,
),
),

const SizedBox(
height: 18,
),

Text(
_text(
english: 'Login Required',
urdu: 'لاگ اِن ضروری ہے',
romanUrdu:
'Login Zaroori Hai',
),
style: const TextStyle(
fontSize: 21,
fontWeight:
FontWeight.w800,
),
),

const SizedBox(
height: 8,
),

Text(
_text(
english:
'Please login to access your personal profile.',
urdu:
'اپنی ذاتی پروفائل تک رسائی کے لیے براہ کرم لاگ اِن کریں۔',
romanUrdu:
'Apni personal profile access karne ke liye login karein.',
),
textAlign:
TextAlign.center,
style: const TextStyle(
color: AppColors
    .textSecondary,
height: 1.5,
),
),

const SizedBox(
height: 24,
),

SizedBox(
width:
double.infinity,
height: 52,
child:
ElevatedButton(
onPressed: () {
Navigator.pop(
context,
);

Navigator.pushNamed(
context,
AppRoutes.login,
);
},
style:
ElevatedButton
    .styleFrom(
backgroundColor:
AppColors
    .primary,
foregroundColor:
Colors.white,
elevation: 0,
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius
    .circular(
15,
),
),
),
child: Text(
_text(
english: 'Login',
urdu: 'لاگ اِن',
romanUrdu: 'Login',
),
style:
const TextStyle(
fontWeight:
FontWeight.w700,
),
),
),
),

const SizedBox(
height: 10,
),

SizedBox(
width:
double.infinity,
height: 48,
child:
OutlinedButton(
onPressed: () {
Navigator.pop(
context,
);

Navigator.pushNamed(
context,
AppRoutes.signup,
);
},
child: Text(
_text(
english:
'Create Account',
urdu:
'اکاؤنٹ بنائیں',
romanUrdu:
'Account Banayein',
),
style:
const TextStyle(
fontWeight:
FontWeight.w700,
),
),
),
),

const SizedBox(
height: 8,
),
],
),
);
},
);
}

// ==========================================================
// LOGOUT
// ==========================================================

Future<void> _logout() async {
if (widget.isGuest) {
Navigator.pushNamedAndRemoveUntil(
context,
AppRoutes.login,
(route) => false,
);

return;
}

final shouldLogout =
await showDialog<bool>(
context: context,
builder: (context) {
return AlertDialog(
title: Text(
_text(
english: 'Logout',
urdu: 'لاگ آؤٹ',
romanUrdu: 'Logout',
),
),
content: Text(
_text(
english:
'Are you sure you want to logout?',
urdu:
'کیا آپ واقعی لاگ آؤٹ کرنا چاہتے ہیں؟',
romanUrdu:
'Kya aap waqai logout karna chahte hain?',
),
),
actions: [
TextButton(
onPressed: () {
Navigator.pop(
context,
false,
);
},
child: Text(
_text(
english: 'Cancel',
urdu: 'منسوخ کریں',
romanUrdu:
'Cancel Karein',
),
),
),
ElevatedButton(
onPressed: () {
Navigator.pop(
context,
true,
);
},
child: Text(
_text(
english: 'Logout',
urdu: 'لاگ آؤٹ',
romanUrdu: 'Logout',
),
),
),
],
);
},
);

if (shouldLogout != true) {
return;
}

await AuthService.instance
    .logout();

if (!mounted) return;

Navigator.pushNamedAndRemoveUntil(
context,
AppRoutes.login,
(route) => false,
);
}

// ==========================================================
// OPEN COMPLAINTS
// ==========================================================

void _openComplaints() {
if (widget.isGuest) {
_showLoginRequired();
return;
}

Navigator.pushNamed(
context,
'/my-complaints',
);
}

// ==========================================================
// OPEN SETTINGS
// ==========================================================

void _openSettings() {
Navigator.pushNamed(
context,
AppRoutes.settings,
);
}

// ==========================================================
// BUILD
// ==========================================================

@override
Widget build(BuildContext context) {
final theme =
Theme.of(context);

final l10n =
AppLocalizations.of(context);

if (_isLoading) {
return const Scaffold(
body: Center(
child:
CircularProgressIndicator(),
),
);
}

return Scaffold(
appBar: AppBar(
title: Text(
l10n.profile,
style: const TextStyle(
fontWeight:
FontWeight.w700,
),
),
centerTitle: false,
actions: [
if (!widget.isGuest)
IconButton(
tooltip:
_text(
english: 'Edit Profile',
urdu:
'پروفائل میں ترمیم کریں',
romanUrdu:
'Profile Edit Karein',
),
onPressed:
_editProfile,
icon: const Icon(
Icons
    .edit_outlined,
),
),
],
),
body: SafeArea(
child:
FadeTransition(
opacity:
_fadeAnimation,
child:
SlideTransition(
position:
_slideAnimation,
child:
SingleChildScrollView(
physics:
const BouncingScrollPhysics(),
padding:
const EdgeInsets.fromLTRB(
20,
12,
20,
32,
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,
children: [
_buildProfileHeader(
theme,
),

const SizedBox(
height: 22,
),

_buildStatistics(
theme,
),

const SizedBox(
height: 26,
),

_buildSectionTitle(
_text(
english: 'Account',
urdu: 'اکاؤنٹ',
romanUrdu:
'Account',
),
),

const SizedBox(
height: 10,
),

if (!widget.isGuest)
_buildMenuCard(
icon: Icons
    .description_outlined,
title:
l10n.myComplaints,
subtitle:
_text(
english:
'View and track your submitted complaints',
urdu:
'اپنی جمع کرائی گئی شکایات دیکھیں اور ٹریک کریں',
romanUrdu:
'Apni submitted complaints dekhein aur track karein',
),
trailing:
_totalComplaints
    .toString(),
onTap:
_openComplaints,
),

if (!widget.isGuest)
const SizedBox(
height: 10,
),

_buildMenuCard(
icon: Icons
    .settings_outlined,
title:
l10n.settings,
subtitle:
_text(
english:
'Language, theme and notification preferences',
urdu:
'زبان، تھیم اور اطلاعات کی ترجیحات',
romanUrdu:
'Language, theme aur notification preferences',
),
onTap:
_openSettings,
),

const SizedBox(
height: 26,
),

_buildSectionTitle(
_text(
english:
'Recent Complaint',
urdu:
'حالیہ شکایت',
romanUrdu:
'Recent Complaint',
),
),

const SizedBox(
height: 10,
),

_buildRecentComplaint(
theme,
),

const SizedBox(
height: 26,
),

_buildSectionTitle(
_text(
english:
'Security & Privacy',
urdu:
'سیکیورٹی اور پرائیویسی',
romanUrdu:
'Security & Privacy',
),
),

const SizedBox(
height: 10,
),

_buildMenuCard(
icon: Icons
    .lock_outline_rounded,
title:
_text(
english:
'Privacy & Security',
urdu:
'پرائیویسی اور سیکیورٹی',
romanUrdu:
'Privacy & Security',
),
subtitle:
_text(
english:
'Learn how CyberSafe protects your information',
urdu:
'جانیں کہ CyberSafe آپ کی معلومات کی حفاظت کیسے کرتا ہے',
romanUrdu:
'Janein ke CyberSafe aapki information ko kaise protect karta hai',
),
onTap:
_showPrivacyDialog,
),

const SizedBox(
height: 10,
),

_buildMenuCard(
icon: Icons
    .info_outline_rounded,
title:
l10n.aboutCyberSafe,
subtitle:
_text(
english:
'Application information and version',
urdu:
'ایپلیکیشن کی معلومات اور ورژن',
romanUrdu:
'Application information aur version',
),
onTap:
_showAboutDialog,
),

const SizedBox(
height: 28,
),

SizedBox(
width:
double.infinity,
height: 52,
child:
OutlinedButton.icon(
onPressed:
_logout,
icon:
const Icon(
Icons
    .logout_rounded,
),
label: Text(
widget.isGuest
? l10n.login
    : l10n.logout,
style:
const TextStyle(
fontWeight:
FontWeight.w600,
),
),
style:
OutlinedButton
    .styleFrom(
foregroundColor:
theme
    .colorScheme
    .error,
side:
BorderSide(
color: theme
    .colorScheme
    .error
    .withValues(
alpha:
0.35,
),
),
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius
    .circular(
15,
),
),
),
),
),
],
),
),
),
),
),
);
}

// ==========================================================
// PROFILE HEADER
// ==========================================================

Widget _buildProfileHeader(
ThemeData theme,
) {
return ScaleTransition(
scale:
_scaleAnimation,
child: Container(
width:
double.infinity,
padding:
const EdgeInsets.all(22),
decoration:
BoxDecoration(
gradient:
LinearGradient(
colors: [
theme
    .colorScheme
    .primary,
theme
    .colorScheme
    .primary
    .withValues(
alpha: 0.82,
),
],
begin:
Alignment.topLeft,
end:
Alignment.bottomRight,
),
borderRadius:
BorderRadius.circular(
24,
),
boxShadow: [
BoxShadow(
blurRadius: 20,
offset:
const Offset(0, 10),
color:
Colors.black
    .withValues(
alpha: 0.10,
),
),
],
),
child: Row(
children: [
GestureDetector(
onTap: widget.isGuest
? _showLoginRequired
    : _showProfileImageOptions,
child: Stack(
children: [
Container(
width: 76,
height: 76,
decoration:
BoxDecoration(
color: Colors.white
    .withValues(
alpha: 0.16,
),
shape:
BoxShape.circle,
border:
Border.all(
color: Colors
    .white
    .withValues(
alpha: 0.35,
),
width: 2,
),
),
child:
ClipOval(
child:
_buildHeaderImage(),
),
),

if (_isImageLoading)
Positioned.fill(
child:
Container(
decoration:
BoxDecoration(
color: Colors
    .black
    .withValues(
alpha:
0.35,
),
shape:
BoxShape
    .circle,
),
child:
const Center(
child:
SizedBox(
width: 22,
height: 22,
child:
CircularProgressIndicator(
strokeWidth:
2,
color: Colors
    .white,
),
),
),
),
),

if (!widget.isGuest)
Positioned(
right: 0,
bottom: 0,
child:
Container(
width: 27,
height: 27,
decoration:
BoxDecoration(
color: Colors
    .white,
shape:
BoxShape
    .circle,
border:
Border.all(
color: theme
    .colorScheme
    .primary,
width: 2,
),
),
child:
Icon(
Icons
    .camera_alt_rounded,
size: 14,
color: theme
    .colorScheme
    .primary,
),
),
),
],
),
),

const SizedBox(
width: 18,
),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,
children: [
Text(
_name,
maxLines: 1,
overflow:
TextOverflow
    .ellipsis,
style:
const TextStyle(
color:
Colors.white,
fontSize: 21,
fontWeight:
FontWeight.w700,
),
),

if (_email
    .isNotEmpty) ...[
const SizedBox(
height: 6,
),

Text(
_email,
maxLines: 2,
overflow:
TextOverflow
    .ellipsis,
style:
TextStyle(
color: Colors
    .white
    .withValues(
alpha: 0.82,
),
fontSize: 13,
),
),
],

const SizedBox(
height: 10,
),

Container(
padding:
const EdgeInsets
    .symmetric(
horizontal: 10,
vertical: 5,
),
decoration:
BoxDecoration(
color: Colors
    .white
    .withValues(
alpha: 0.14,
),
borderRadius:
BorderRadius
    .circular(
20,
),
),
child:
Text(
widget.isGuest
? _text(
english:
'Guest',
urdu:
'مہمان',
romanUrdu:
'Guest',
)
    : _text(
english:
'Verified User',
urdu:
'تصدیق شدہ صارف',
romanUrdu:
'Verified User',
),
style:
const TextStyle(
color:
Colors.white,
fontSize: 11,
fontWeight:
FontWeight.w600,
),
),
),
],
),
),

if (!widget.isGuest)
IconButton(
onPressed:
_editProfile,
icon:
const Icon(
Icons
    .edit_outlined,
color:
Colors.white,
),
),
],
),
),
);
}

// ==========================================================
// HEADER IMAGE
// ==========================================================

Widget _buildHeaderImage() {
final bytes =
_profileImageBytes;

if (bytes != null &&
bytes.isNotEmpty) {
return Image.memory(
bytes,
width: 76,
height: 76,
fit: BoxFit.cover,
gaplessPlayback: true,
errorBuilder:
(context, error, stackTrace) {
return _buildHeaderInitial();
},
);
}

return _buildHeaderInitial();
}

// ==========================================================
// HEADER INITIAL
// ==========================================================

Widget _buildHeaderInitial() {
return Center(
child: Text(
_initial,
style:
const TextStyle(
color: Colors.white,
fontSize: 30,
fontWeight:
FontWeight.w700,
),
),
);
}

// ==========================================================
// STATISTICS
// ==========================================================

Widget _buildStatistics(
ThemeData theme,
) {
return Row(
children: [
Expanded(
child:
_buildStatCard(
title: _text(
english: 'Total',
urdu: 'کل',
romanUrdu: 'Kul',
),
value:
_totalComplaints
    .toString(),
icon:
Icons.folder_outlined,
),
),

const SizedBox(
width: 10,
),

Expanded(
child:
_buildStatCard(
title: _text(
english: 'Active',
urdu: 'فعال',
romanUrdu: 'Active',
),
value:
_activeComplaints
    .toString(),
icon: Icons
    .pending_actions_outlined,
),
),

const SizedBox(
width: 10,
),

Expanded(
child:
_buildStatCard(
title: l10nResolved,
value:
_resolvedComplaints
    .toString(),
icon: Icons
    .check_circle_outline_rounded,
),
),
],
);
}

String get l10nResolved {
return _text(
english: 'Resolved',
urdu: 'حل شدہ',
romanUrdu: 'Hal Shuda',
);
}

// ==========================================================
// STAT CARD
// ==========================================================

Widget _buildStatCard({
required String title,
required String value,
required IconData icon,
}) {
return Container(
padding:
const EdgeInsets.symmetric(
vertical: 18,
horizontal: 10,
),
decoration:
BoxDecoration(
color: Theme.of(context)
    .colorScheme
    .surface,
borderRadius:
BorderRadius.circular(
18,
),
border: Border.all(
color: Theme.of(context)
    .dividerColor
    .withValues(
alpha: 0.6,
),
),
),
child: Column(
children: [
Icon(
icon,
size: 22,
color: Theme.of(context)
    .colorScheme
    .primary,
),

const SizedBox(
height: 8,
),

Text(
value,
style:
const TextStyle(
fontSize: 21,
fontWeight:
FontWeight.w800,
),
),

const SizedBox(
height: 3,
),

Text(
title,
style: TextStyle(
fontSize: 11,
color:
Colors.grey.shade600,
fontWeight:
FontWeight.w500,
),
),
],
),
);
}

// ==========================================================
// SECTION TITLE
// ==========================================================

Widget _buildSectionTitle(
String title,
) {
return Text(
title,
style:
const TextStyle(
fontSize: 17,
fontWeight:
FontWeight.w700,
),
);
}

// ==========================================================
// MENU CARD
// ==========================================================

Widget _buildMenuCard({
required IconData icon,
required String title,
required String subtitle,
String? trailing,
required VoidCallback onTap,
}) {
return Material(
color: Theme.of(context)
    .colorScheme
    .surface,
borderRadius:
BorderRadius.circular(
18,
),
child: InkWell(
onTap: onTap,
borderRadius:
BorderRadius.circular(
18,
),
child: Container(
padding:
const EdgeInsets.all(
16,
),
decoration:
BoxDecoration(
borderRadius:
BorderRadius.circular(
18,
),
border: Border.all(
color: Theme.of(context)
    .dividerColor
    .withValues(
alpha: 0.55,
),
),
),
child: Row(
children: [
Container(
width: 46,
height: 46,
decoration:
BoxDecoration(
color: Theme.of(
context,
)
    .colorScheme
    .primary
    .withValues(
alpha: 0.10,
),
borderRadius:
BorderRadius
    .circular(
14,
),
),
child: Icon(
icon,
color: Theme.of(
context,
)
    .colorScheme
    .primary,
),
),

const SizedBox(
width: 14,
),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,
children: [
Text(
title,
style:
const TextStyle(
fontWeight:
FontWeight.w700,
fontSize: 14,
),
),

const SizedBox(
height: 4,
),

Text(
subtitle,
maxLines: 2,
overflow:
TextOverflow
    .ellipsis,
style:
TextStyle(
fontSize: 12,
color: Colors
    .grey
    .shade600,
),
),
],
),
),

if (trailing != null) ...[
Container(
padding:
const EdgeInsets
    .symmetric(
horizontal: 9,
vertical: 5,
),
decoration:
BoxDecoration(
color: Theme.of(
context,
)
    .colorScheme
    .primary
    .withValues(
alpha: 0.10,
),
borderRadius:
BorderRadius
    .circular(
10,
),
),
child: Text(
trailing,
style:
TextStyle(
color: Theme.of(
context,
)
    .colorScheme
    .primary,
fontWeight:
FontWeight.w700,
),
),
),

const SizedBox(
width: 8,
),
],

Icon(
Icons
    .chevron_right_rounded,
color:
Colors.grey.shade500,
),
],
),
),
),
);
}

// ==========================================================
// RECENT COMPLAINT
// ==========================================================

Widget _buildRecentComplaint(
ThemeData theme,
) {
if (_userComplaints.isEmpty) {
return Container(
width:
double.infinity,
padding:
const EdgeInsets.all(
22,
),
decoration:
BoxDecoration(
borderRadius:
BorderRadius.circular(
18,
),
border: Border.all(
color:
theme.dividerColor,
),
),
child: Column(
children: [
Icon(
Icons
    .description_outlined,
size: 42,
color: theme
    .colorScheme
    .primary,
),

const SizedBox(
height: 12,
),

Text(
_text(
english:
'No complaints yet',
urdu:
'ابھی کوئی شکایت نہیں',
romanUrdu:
'Abhi koi complaint nahi',
),
style:
const TextStyle(
fontWeight:
FontWeight.w700,
),
),

const SizedBox(
height: 5,
),

Text(
widget.isGuest
? _text(
english:
'Login to submit and track your complaints.',
urdu:
'اپنی شکایات جمع کرانے اور ٹریک کرنے کے لیے لاگ اِن کریں۔',
romanUrdu:
'Apni complaints submit aur track karne ke liye login karein.',
)
    : _text(
english:
'Your submitted complaints will appear here.',
urdu:
'آپ کی جمع کرائی گئی شکایات یہاں ظاہر ہوں گی۔',
romanUrdu:
'Aapki submitted complaints yahan nazar aayengi.',
),
textAlign:
TextAlign.center,
style: TextStyle(
color: Colors
    .grey
    .shade600,
fontSize: 12,
),
),
],
),
);
}

final complaint =
_userComplaints.first;

return Material(
color: Theme.of(context)
    .colorScheme
    .surface,
borderRadius:
BorderRadius.circular(
18,
),
child: InkWell(
onTap: () {
Navigator.pushNamed(
context,
AppRoutes
    .complaintDetails,
arguments: complaint,
);
},
borderRadius:
BorderRadius.circular(
18,
),
child: Container(
padding:
const EdgeInsets.all(
17,
),
decoration:
BoxDecoration(
borderRadius:
BorderRadius.circular(
18,
),
border: Border.all(
color:
theme.dividerColor,
),
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,
children: [
Row(
children: [
Expanded(
child: Text(
complaint.title,
maxLines: 1,
overflow:
TextOverflow
    .ellipsis,
style:
const TextStyle(
fontSize: 15,
fontWeight:
FontWeight.w700,
),
),
),

StatusChip(
status:
complaint.status,
),
],
),

const SizedBox(
height: 10,
),

Text(
complaint.id,
style:
TextStyle(
fontSize: 12,
fontWeight:
FontWeight.w600,
color: theme
    .colorScheme
    .primary,
),
),

const SizedBox(
height: 8,
),

Text(
complaint.category,
style:
TextStyle(
fontSize: 12,
color: Colors
    .grey
    .shade600,
),
),

const SizedBox(
height: 14,
),

Row(
children: [
Icon(
Icons
    .calendar_today_outlined,
size: 14,
color: Colors
    .grey
    .shade500,
),

const SizedBox(
width: 6,
),

Text(
_formatDate(
complaint
    .submittedDate,
),
style:
TextStyle(
fontSize: 11,
color: Colors
    .grey
    .shade600,
),
),

const Spacer(),

Text(
_text(
english:
'View Details',
urdu:
'تفصیلات دیکھیں',
romanUrdu:
'Details Dekhein',
),
style:
const TextStyle(
fontSize: 12,
fontWeight:
FontWeight.w700,
),
),

const SizedBox(
width: 3,
),

const Icon(
Icons
    .arrow_forward_rounded,
size: 15,
),
],
),
],
),
),
),
);
}

// ==========================================================
// PRIVACY
// ==========================================================

void _showPrivacyDialog() {
showDialog(
context: context,
builder: (context) {
return AlertDialog(
title: Text(
_text(
english:
'Privacy & Security',
urdu:
'پرائیویسی اور سیکیورٹی',
romanUrdu:
'Privacy & Security',
),
),
content: Text(
_text(
english:
'CyberSafe is designed to keep your complaint information private. Your complaint history is displayed only for the currently logged-in user.',
urdu:
'CyberSafe آپ کی شکایت کی معلومات کو نجی رکھنے کے لیے بنایا گیا ہے۔ آپ کی شکایات کی تاریخ صرف موجودہ لاگ اِن صارف کو دکھائی جاتی ہے۔',
romanUrdu:
'CyberSafe aapki complaint information ko private rakhne ke liye design kiya gaya hai. Aapki complaint history sirf currently logged-in user ko dikhai jati hai.',
),
),
actions: [
TextButton(
onPressed: () {
Navigator.pop(
context,
);
},
child:
Text(
_text(
english: 'Close',
urdu: 'بند کریں',
romanUrdu:
'Close Karein',
),
),
),
],
);
},
);
}

// ==========================================================
// ABOUT
// ==========================================================

void _showAboutDialog() {
showAboutDialog(
context: context,
applicationName:
'CyberSafe',
applicationVersion:
'1.0.0',
applicationIcon:
const Icon(
Icons.security_rounded,
size: 40,
),
children: [
Text(
_text(
english:
'A professional Cyber Crime Complaint and Awareness Management System.',
urdu:
'ایک پیشہ ور سائبر کرائم شکایت اور آگاہی مینجمنٹ سسٹم۔',
romanUrdu:
'Ek professional Cyber Crime Complaint aur Awareness Management System.',
),
),
],
);
}

// ==========================================================
// DATE
// ==========================================================

String _formatDate(
DateTime date,
) {
return '${date.day.toString().padLeft(2, '0')}/'
'${date.month.toString().padLeft(2, '0')}/'
'${date.year}';
}
}