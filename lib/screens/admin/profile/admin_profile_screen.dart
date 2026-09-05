import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/admin_profile.dart';
import '../../../services/admin_profile_service.dart';

class AdminProfileScreen extends StatefulWidget {
const AdminProfileScreen({
super.key,
});

@override
State<AdminProfileScreen> createState() =>
_AdminProfileScreenState();
}

class _AdminProfileScreenState
extends State<AdminProfileScreen> {
final _formKey =
GlobalKey<FormState>();

final _nameController =
TextEditingController();

final _emailController =
TextEditingController();

final _phoneController =
TextEditingController();

final _designationController =
TextEditingController();

final _bioController =
TextEditingController();

final ImagePicker _imagePicker =
ImagePicker();

String _profileImagePath = '';

bool _isLoading = true;
bool _isSaving = false;

// ==========================================================
// INIT
// ==========================================================

@override
void initState() {
super.initState();
_loadProfile();
}

// ==========================================================
// LOAD PROFILE
// ==========================================================

Future<void> _loadProfile() async {
try {
final profile =
await AdminProfileService
    .instance
    .getProfile();

if (!mounted) return;

setState(() {
_nameController.text =
profile.name;

_emailController.text =
profile.email;

_phoneController.text =
profile.phone;

_designationController.text =
profile.designation;

_bioController.text =
profile.bio;

_profileImagePath =
profile.profileImagePath;

_isLoading = false;
});
} catch (e) {
if (!mounted) return;

setState(() {
_isLoading = false;
});

_showMessage(
'Unable to load admin profile.',
isError: true,
);
}
}

// ==========================================================
// CAMERA
// ==========================================================

Future<void> _pickFromCamera() async {
try {
final XFile? image =
await _imagePicker.pickImage(
source: ImageSource.camera,
imageQuality: 85,
maxWidth: 1200,
maxHeight: 1200,
);

if (image == null) return;

if (!mounted) return;

setState(() {
_profileImagePath =
image.path;
});
} catch (e) {
_showMessage(
'Unable to open camera.',
isError: true,
);
}
}

// ==========================================================
// GALLERY
// ==========================================================

Future<void> _pickFromGallery() async {
try {
final XFile? image =
await _imagePicker.pickImage(
source: ImageSource.gallery,
imageQuality: 85,
maxWidth: 1200,
maxHeight: 1200,
);

if (image == null) return;

if (!mounted) return;

setState(() {
_profileImagePath =
image.path;
});
} catch (e) {
_showMessage(
'Unable to open gallery.',
isError: true,
);
}
}

// ==========================================================
// FILE PICKER
// ==========================================================

Future<void> _pickFromFile() async {
try {
final result =
await FilePicker.platform.pickFiles(
type: FileType.image,
allowMultiple: false,
);

if (result == null ||
result.files.isEmpty) {
return;
}

final path =
result.files.single.path;

if (path == null ||
path.isEmpty) {
_showMessage(
'Unable to access selected file.',
isError: true,
);
return;
}

// ------------------------------------------------------
// FORMAT CHECK
// ------------------------------------------------------

final extension =
_getImageExtension(path);

if (!_isSupportedImage(extension)) {
_showMessage(
'Only JPG, JPEG and PNG images are supported.',
isError: true,
);
return;
}

if (!mounted) return;

setState(() {
_profileImagePath =
path;
});
} catch (e) {
_showMessage(
'Unable to select file.',
isError: true,
);
}
}

// ==========================================================
// IMAGE EXTENSION
// ==========================================================

String _getImageExtension(
String filePath,
) {
final cleanPath =
filePath.split('?').first;

final lastDot =
cleanPath.lastIndexOf('.');

if (lastDot == -1) {
return '';
}

return cleanPath
    .substring(lastDot + 1)
    .toLowerCase();
}

// ==========================================================
// SUPPORTED IMAGE
// ==========================================================

bool _isSupportedImage(
String extension,
) {
return extension == 'jpg' ||
extension == 'jpeg' ||
extension == 'png';
}

// ==========================================================
// IMAGE OPTIONS
// ==========================================================

void _showImageOptions() {
showModalBottomSheet(
context: context,
showDragHandle: true,
backgroundColor:
Theme.of(context)
    .scaffoldBackgroundColor,
builder: (context) {
return SafeArea(
child: Padding(
padding:
const EdgeInsets.fromLTRB(
20,
8,
20,
24,
),
child: Column(
mainAxisSize:
MainAxisSize.min,
children: [
const Text(
'Profile Picture',
style: TextStyle(
fontSize: 19,
fontWeight:
FontWeight.w700,
),
),

const SizedBox(
height: 20,
),

_imageOption(
icon:
Icons.camera_alt_outlined,
title: 'Camera',
subtitle:
'Take a new picture',
onTap: () {
Navigator.pop(
context,
);
_pickFromCamera();
},
),

_imageOption(
icon:
Icons.photo_library_outlined,
title: 'Gallery',
subtitle:
'JPG, JPEG or PNG',
onTap: () {
Navigator.pop(
context,
);
_pickFromGallery();
},
),

_imageOption(
icon:
Icons.folder_outlined,
title: 'Files',
subtitle:
'JPG, JPEG or PNG',
onTap: () {
Navigator.pop(
context,
);
_pickFromFile();
},
),

if (_profileImagePath
    .isNotEmpty)
_imageOption(
icon:
Icons.delete_outline,
title:
'Remove Picture',
subtitle:
'Delete profile picture',
onTap: () {
Navigator.pop(
context,
);
_removeProfileImage();
},
),
],
),
),
);
},
);
}

// ==========================================================
// IMAGE OPTION
// ==========================================================

Widget _imageOption({
required IconData icon,
required String title,
required String subtitle,
required VoidCallback onTap,
}) {
return ListTile(
contentPadding:
const EdgeInsets.symmetric(
vertical: 4,
),
leading: Container(
width: 46,
height: 46,
decoration: BoxDecoration(
color: AppColors.primary
    .withValues(
alpha: 0.08,
),
borderRadius:
BorderRadius.circular(14),
),
child: Icon(
icon,
color:
AppColors.primary,
),
),
title: Text(
title,
style:
const TextStyle(
fontWeight:
FontWeight.w600,
),
),
subtitle:
Text(subtitle),
onTap: onTap,
);
}

// ==========================================================
// REMOVE PROFILE IMAGE
// ==========================================================

Future<void> _removeProfileImage() async {
if (_isSaving) return;

// --------------------------------------------------------
// If image is only local and not uploaded yet,
// simply remove it from preview.
// --------------------------------------------------------

if (_profileImagePath.isNotEmpty &&
!_isFirebaseUrl(
_profileImagePath,
)) {
if (!mounted) return;

setState(() {
_profileImagePath = '';
});

_showMessage(
'Profile picture removed.',
);

return;
}

// --------------------------------------------------------
// Firebase image
// --------------------------------------------------------

setState(() {
_isSaving = true;
});

try {
await AdminProfileService
    .instance
    .removeProfileImage();

if (!mounted) return;

setState(() {
_profileImagePath = '';
_isSaving = false;
});

_showMessage(
'Profile picture removed successfully.',
);
} catch (e) {
if (!mounted) return;

setState(() {
_isSaving = false;
});

_showMessage(
'Unable to remove profile picture.',
isError: true,
);
}
}

// ==========================================================
// SAVE PROFILE
// ==========================================================

Future<void> _saveProfile() async {
if (!_formKey.currentState!
    .validate()) {
return;
}

if (_isSaving) return;

setState(() {
_isSaving = true;
});

try {
final profile =
AdminProfile(
name:
_nameController.text.trim(),
email:
_emailController.text.trim(),
phone:
_phoneController.text.trim(),
designation:
_designationController
    .text
    .trim(),
bio:
_bioController.text.trim(),
profileImagePath:
_profileImagePath,
);

await AdminProfileService
    .instance
    .saveProfile(profile);

if (!mounted) return;

setState(() {
_isSaving = false;
});

_showMessage(
'Admin profile updated successfully.',
);

// ------------------------------------------------------
// Reload Firebase data
// ------------------------------------------------------

await _loadProfile();
} catch (e) {
if (!mounted) return;

setState(() {
_isSaving = false;
});

_showMessage(
'Unable to save profile.',
isError: true,
);
}
}

// ==========================================================
// FIREBASE URL CHECK
// ==========================================================

bool _isFirebaseUrl(
String value,
) {
return value.startsWith(
'https://firebasestorage.googleapis.com/',
) ||
value.startsWith(
'https://firebasestorage.app/',
);
}

// ==========================================================
// MESSAGE
// ==========================================================

void _showMessage(
String message, {
bool isError = false,
}) {
if (!mounted) return;

ScaffoldMessenger.of(context)
    .showSnackBar(
SnackBar(
content:
Text(message),
behavior:
SnackBarBehavior.floating,
backgroundColor:
isError
? Colors.red
    : null,
),
);
}

// ==========================================================
// NAME VALIDATOR
// ==========================================================

String? _validateName(
String? value,
) {
if (value == null ||
value.trim().isEmpty) {
return 'Name is required';
}

if (value.trim().length < 3) {
return 'Enter a valid name';
}

return null;
}

// ==========================================================
// EMAIL VALIDATOR
// ==========================================================

String? _validateEmail(
String? value,
) {
if (value == null ||
value.trim().isEmpty) {
return 'Email is required';
}

final regex = RegExp(
r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
);

if (!regex.hasMatch(
value.trim(),
)) {
return 'Enter a valid email';
}

return null;
}

// ==========================================================
// PHONE VALIDATOR
// ==========================================================

String? _validatePhone(
String? value,
) {
if (value == null ||
value.trim().isEmpty) {
return null;
}

final phone = value
    .trim()
    .replaceAll(' ', '');

final regex = RegExp(
r'^(03\d{9}|\+923\d{9})$',
);

if (!regex.hasMatch(phone)) {
return 'Enter a valid Pakistani phone number';
}

return null;
}

// ==========================================================
// FIELD
// ==========================================================

Widget _field({
required TextEditingController
controller,
required String label,
required String hint,
required IconData icon,
TextInputType? keyboardType,
int maxLines = 1,
String? Function(String?)?
validator,
}) {
return TextFormField(
controller:
controller,
keyboardType:
keyboardType,
maxLines:
maxLines,
validator:
validator,
decoration:
InputDecoration(
labelText:
label,
hintText:
hint,
prefixIcon:
Icon(icon),
),
);
}

// ==========================================================
// AVATAR
// ==========================================================

Widget _buildAvatar() {
final path =
_profileImagePath.trim();

final hasLocalImage =
path.isNotEmpty &&
!_isFirebaseUrl(path) &&
File(path).existsSync();

final hasFirebaseImage =
path.isNotEmpty &&
_isFirebaseUrl(path);

Widget avatarContent;

// --------------------------------------------------------
// LOCAL IMAGE
// --------------------------------------------------------

if (hasLocalImage) {
avatarContent =
Image.file(
File(path),
fit: BoxFit.cover,
errorBuilder:
(
context,
error,
stackTrace,
) {
return _defaultAvatar();
},
);
}

// --------------------------------------------------------
// FIREBASE IMAGE
// --------------------------------------------------------

else if (hasFirebaseImage) {
avatarContent =
Image.network(
path,
fit: BoxFit.cover,
loadingBuilder:
(
context,
child,
loadingProgress,
) {
if (loadingProgress ==
null) {
return child;
}

return const Center(
child:
CircularProgressIndicator(
strokeWidth: 2,
),
);
},
errorBuilder:
(
context,
error,
stackTrace,
) {
return _defaultAvatar();
},
);
}

// --------------------------------------------------------
// DEFAULT AVATAR
// --------------------------------------------------------

else {
avatarContent =
_defaultAvatar();
}

return Stack(
clipBehavior:
Clip.none,
children: [
Container(
width: 112,
height: 112,
decoration:
BoxDecoration(
shape:
BoxShape.circle,
color: AppColors
    .primary
    .withValues(
alpha: 0.10,
),
border:
Border.all(
color: AppColors
    .primary
    .withValues(
alpha: 0.18,
),
width: 2,
),
),
child:
ClipOval(
child:
avatarContent,
),
),

Positioned(
right: -2,
bottom: 2,
child:
Material(
color:
AppColors.primary,
shape:
const CircleBorder(),
child:
InkWell(
customBorder:
const CircleBorder(),
onTap:
_showImageOptions,
child:
const Padding(
padding:
EdgeInsets.all(
10,
),
child:
Icon(
Icons
    .camera_alt_outlined,
size: 20,
color:
Colors.white,
),
),
),
),
),
],
);
}

// ==========================================================
// DEFAULT AVATAR
// ==========================================================

Widget _defaultAvatar() {
return const Center(
child: Icon(
Icons
    .admin_panel_settings_outlined,
size: 55,
color:
AppColors.primary,
),
);
}

// ==========================================================
// DISPOSE
// ==========================================================

@override
void dispose() {
_nameController.dispose();
_emailController.dispose();
_phoneController.dispose();
_designationController.dispose();
_bioController.dispose();

super.dispose();
}

// ==========================================================
// BUILD
// ==========================================================

@override
Widget build(
BuildContext context,
) {
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
title:
const Text(
'Admin Profile',
),
centerTitle:
true,
),
body: SafeArea(
child: Form(
key: _formKey,
child:
SingleChildScrollView(
padding:
const EdgeInsets.fromLTRB(
20,
20,
20,
32,
),
child:
Column(
children: [
// ==================================================
// PROFILE IMAGE
// ==================================================

_buildAvatar(),

const SizedBox(
height: 16,
),

Text(
_nameController
    .text
    .trim()
    .isEmpty
? 'Admin Profile'
    : _nameController
    .text
    .trim(),
style:
const TextStyle(
fontSize: 22,
fontWeight:
FontWeight.w800,
),
),

const SizedBox(
height: 5,
),

Text(
'Tap the camera icon to change profile picture',
textAlign:
TextAlign.center,
style:
TextStyle(
fontSize: 12,
color: Colors
    .grey
    .shade600,
),
),

const SizedBox(
height: 30,
),

// ==================================================
// NAME
// ==================================================

_field(
controller:
_nameController,
label:
'Full Name',
hint:
'Enter admin name',
icon:
Icons
    .person_outline,
validator:
_validateName,
),

const SizedBox(
height: 16,
),

// ==================================================
// EMAIL
// ==================================================

_field(
controller:
_emailController,
label:
'Email',
hint:
'Enter admin email',
icon:
Icons
    .email_outlined,
keyboardType:
TextInputType
    .emailAddress,
validator:
_validateEmail,
),

const SizedBox(
height: 16,
),

// ==================================================
// PHONE
// ==================================================

_field(
controller:
_phoneController,
label:
'Contact Number',
hint:
'03XXXXXXXXX',
icon:
Icons
    .phone_outlined,
keyboardType:
TextInputType
    .phone,
validator:
_validatePhone,
),

const SizedBox(
height: 16,
),

// ==================================================
// DESIGNATION
// ==================================================

_field(
controller:
_designationController,
label:
'Designation',
hint:
'System Administrator',
icon:
Icons
    .badge_outlined,
),

const SizedBox(
height: 16,
),

// ==================================================
// BIO
// ==================================================

_field(
controller:
_bioController,
label:
'Bio',
hint:
'Enter admin bio',
icon:
Icons
    .description_outlined,
maxLines: 4,
),

const SizedBox(
height: 28,
),

// ==================================================
// SAVE
// ==================================================

SizedBox(
width:
double.infinity,
height: 54,
child:
ElevatedButton
    .icon(
onPressed:
_isSaving
? null
    : _saveProfile,
icon: _isSaving
? const SizedBox(
width: 20,
height: 20,
child:
CircularProgressIndicator(
strokeWidth:
2,
color:
Colors.white,
),
)
    : const Icon(
Icons
    .save_outlined,
),
label:
Text(
_isSaving
? 'Saving...'
    : 'Save Profile',
),
),
),
],
),
),
),
),
);
}
}