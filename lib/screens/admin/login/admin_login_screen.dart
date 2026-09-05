import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';

class AdminLoginScreen extends StatefulWidget {
const AdminLoginScreen({super.key});

@override
State<AdminLoginScreen> createState() =>
_AdminLoginScreenState();
}

class _AdminLoginScreenState
extends State<AdminLoginScreen> {
// ==========================================================
// FORM
// ==========================================================

final _formKey =
GlobalKey<FormState>();

// ==========================================================
// CONTROLLERS
// ==========================================================

final _emailController =
TextEditingController();

final _passwordController =
TextEditingController();

// ==========================================================
// STATE
// ==========================================================

bool _obscurePassword = true;

bool _isLoading = false;

// ==========================================================
// ADMIN LOGIN
// ==========================================================

Future<void> _login() async {
FocusScope.of(context).unfocus();

// --------------------------------------------------------
// VALIDATE FORM
// --------------------------------------------------------

if (!_formKey.currentState!.validate()) {
return;
}

if (_isLoading) {
return;
}

setState(() {
_isLoading = true;
});

try {
final email =
_emailController.text
    .trim()
    .toLowerCase();

final password =
_passwordController.text;

// ======================================================
// STEP 1
// FIREBASE AUTHENTICATION
// ======================================================

final success =
await AuthService.instance.login(
email: email,
password: password,
);

if (!mounted) {
return;
}

// ------------------------------------------------------
// AUTHENTICATION FAILED
// ------------------------------------------------------

if (!success) {
setState(() {
_isLoading = false;
});

_showMessage(
'Invalid admin email or password.',
isError: true,
);

return;
}

// ======================================================
// STEP 2
// VERIFY ADMIN ROLE FROM FIRESTORE
// ======================================================

final isAdmin =
await AuthService.instance.isAdmin();

if (!mounted) {
return;
}

// ======================================================
// NOT ADMIN
// ======================================================

if (!isAdmin) {
await AuthService.instance.logout();

if (!mounted) {
return;
}

setState(() {
_isLoading = false;
});

_showMessage(
'Access denied. Admin account required.',
isError: true,
);

return;
}

// ======================================================
// ADMIN LOGIN SUCCESS
// ======================================================

setState(() {
_isLoading = false;
});

_showMessage(
'Admin login successful.',
isError: false,
);

// Small delay so the success message can appear.
await Future.delayed(
const Duration(
milliseconds: 300,
),
);

if (!mounted) {
return;
}

// ======================================================
// OPEN ADMIN SHELL
// ======================================================

Navigator.pushNamedAndRemoveUntil(
context,
AppRoutes.adminShell,
(route) => false,
);
} on FirebaseAuthException catch (e) {
if (!mounted) {
return;
}

setState(() {
_isLoading = false;
});

_showMessage(
_firebaseErrorMessage(e),
isError: true,
);
} on FirebaseException catch (e) {
if (!mounted) {
return;
}

setState(() {
_isLoading = false;
});

_showMessage(
_firebaseFirestoreErrorMessage(e),
isError: true,
);
} catch (e) {
if (!mounted) {
return;
}

setState(() {
_isLoading = false;
});

_showMessage(
'Unable to login. Please try again.',
isError: true,
);
}
}

// ==========================================================
// FIREBASE AUTH ERROR MESSAGE
// ==========================================================

String _firebaseErrorMessage(
FirebaseAuthException error,
) {
switch (error.code) {
case 'invalid-email':
return 'Please enter a valid email address.';

case 'user-not-found':
return 'No account was found with this email.';

case 'wrong-password':
return 'Incorrect password.';

case 'invalid-credential':
return 'Invalid email or password.';

case 'user-disabled':
return 'This account has been disabled.';

case 'too-many-requests':
return 'Too many login attempts. Please try again later.';

case 'network-request-failed':
return 'Network error. Please check your internet connection.';

case 'operation-not-allowed':
return 'Email/password login is not enabled in Firebase.';

default:
return 'Unable to login. Please try again.';
}
}

// ==========================================================
// FIRESTORE ERROR MESSAGE
// ==========================================================

String _firebaseFirestoreErrorMessage(
FirebaseException error,
) {
switch (error.code) {
case 'permission-denied':
return 'Access denied by Firebase security rules.';

case 'unavailable':
return 'Firebase is temporarily unavailable.';

case 'failed-precondition':
return 'Firebase configuration is incomplete.';

default:
return 'Unable to verify administrator account.';
}
}

// ==========================================================
// SHOW MESSAGE
// ==========================================================

void _showMessage(
String message, {
required bool isError,
}) {
if (!mounted) {
return;
}

ScaffoldMessenger.of(context)
    .hideCurrentSnackBar();

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Row(
children: [
Icon(
isError
? Icons.error_outline_rounded
    : Icons.check_circle_outline_rounded,
color: Colors.white,
),
const SizedBox(width: 10),
Expanded(
child: Text(message),
),
],
),
behavior:
SnackBarBehavior.floating,
duration: const Duration(
seconds: 3,
),
),
);
}

// ==========================================================
// EMAIL VALIDATOR
// ==========================================================

String? _validateEmail(
String? value,
) {
final email =
value?.trim() ?? '';

if (email.isEmpty) {
return 'Admin email is required';
}

final regex = RegExp(
r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
);

if (!regex.hasMatch(email)) {
return 'Enter a valid email address';
}

return null;
}

// ==========================================================
// PASSWORD VALIDATOR
// ==========================================================

String? _validatePassword(
String? value,
) {
if (value == null ||
value.isEmpty) {
return 'Password is required';
}

if (value.length < 6) {
return 'Password must contain at least 6 characters';
}

return null;
}

// ==========================================================
// DISPOSE
// ==========================================================

@override
void dispose() {
_emailController.dispose();
_passwordController.dispose();

super.dispose();
}

// ==========================================================
// BUILD
// ==========================================================

@override
Widget build(
BuildContext context,
) {
return Scaffold(
appBar: AppBar(
title: const Text(
'Admin Login',
style: TextStyle(
fontWeight: FontWeight.w700,
),
),
),

body: SafeArea(
child: SingleChildScrollView(
padding:
const EdgeInsets.fromLTRB(
24,
30,
24,
32,
),
child: Form(
key: _formKey,
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
// ==================================================
// ADMIN ICON
// ==================================================

Center(
child: Container(
width: 82,
height: 82,
decoration:
BoxDecoration(
color:
AppColors.primary,
borderRadius:
BorderRadius.circular(
24,
),
boxShadow: [
BoxShadow(
color: AppColors
    .primary
    .withValues(
alpha: 0.18,
),
blurRadius: 24,
offset:
const Offset(
0,
10,
),
),
],
),
child: const Icon(
Icons
    .admin_panel_settings_outlined,
color: Colors.white,
size: 44,
),
),
),

const SizedBox(
height: 28,
),

// ==================================================
// TITLE
// ==================================================

const Text(
'Admin Login',
style: TextStyle(
fontSize: 30,
fontWeight:
FontWeight.w800,
),
),

const SizedBox(
height: 8,
),

Text(
'Sign in to securely manage '
'CyberSafe complaints and users.',
style: TextStyle(
fontSize: 14,
height: 1.5,
color:
Colors.grey.shade600,
),
),

const SizedBox(
height: 32,
),

// ==================================================
// EMAIL
// ==================================================

TextFormField(
controller:
_emailController,
keyboardType:
TextInputType
    .emailAddress,
textInputAction:
TextInputAction.next,
enabled: !_isLoading,
validator:
_validateEmail,
decoration:
InputDecoration(
labelText:
'Admin Email',
hintText:
'Enter admin email',
prefixIcon:
const Icon(
Icons.email_outlined,
),
border:
OutlineInputBorder(
borderRadius:
BorderRadius.circular(
15,
),
),
enabledBorder:
OutlineInputBorder(
borderRadius:
BorderRadius.circular(
15,
),
borderSide:
BorderSide(
color: Colors
    .grey.shade300,
),
),
focusedBorder:
OutlineInputBorder(
borderRadius:
BorderRadius.circular(
15,
),
borderSide:
BorderSide(
color:
AppColors.primary,
width: 1.5,
),
),
),
),

const SizedBox(
height: 18,
),

// ==================================================
// PASSWORD
// ==================================================

TextFormField(
controller:
_passwordController,
obscureText:
_obscurePassword,
textInputAction:
TextInputAction.done,
enabled: !_isLoading,
onFieldSubmitted:
(_) {
if (!_isLoading) {
_login();
}
},
validator:
_validatePassword,
decoration:
InputDecoration(
labelText:
'Password',
hintText:
'Enter admin password',
prefixIcon:
const Icon(
Icons
    .lock_outline_rounded,
),
suffixIcon:
IconButton(
onPressed:
_isLoading
? null
    : () {
setState(() {
_obscurePassword =
!_obscurePassword;
});
},
icon: Icon(
_obscurePassword
? Icons
    .visibility_outlined
    : Icons
    .visibility_off_outlined,
),
),
border:
OutlineInputBorder(
borderRadius:
BorderRadius.circular(
15,
),
),
enabledBorder:
OutlineInputBorder(
borderRadius:
BorderRadius.circular(
15,
),
borderSide:
BorderSide(
color: Colors
    .grey.shade300,
),
),
focusedBorder:
OutlineInputBorder(
borderRadius:
BorderRadius.circular(
15,
),
borderSide:
BorderSide(
color:
AppColors.primary,
width: 1.5,
),
),
),
),

const SizedBox(
height: 24,
),

// ==================================================
// LOGIN BUTTON
// ==================================================

SizedBox(
width:
double.infinity,
height: 54,
child:
ElevatedButton(
onPressed:
_isLoading
? null
    : _login,
style:
ElevatedButton.styleFrom(
backgroundColor:
AppColors.primary,
foregroundColor:
Colors.white,
disabledBackgroundColor:
AppColors.primary
    .withValues(
alpha: 0.55,
),
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(
15,
),
),
elevation: 0,
),
child: _isLoading
? const SizedBox(
width: 23,
height: 23,
child:
CircularProgressIndicator(
strokeWidth:
2.5,
color:
Colors.white,
),
)
    : const Row(
mainAxisAlignment:
MainAxisAlignment
    .center,
children: [
Icon(
Icons
    .login_rounded,
size: 21,
),
SizedBox(
width: 9,
),
Text(
'Admin Login',
style:
TextStyle(
fontSize:
15,
fontWeight:
FontWeight
    .w700,
),
),
],
),
),
),

const SizedBox(
height: 22,
),

// ==================================================
// SECURITY INFO
// ==================================================

Container(
width:
double.infinity,
padding:
const EdgeInsets.all(
15,
),
decoration:
BoxDecoration(
color:
AppColors.accentLight,
borderRadius:
BorderRadius.circular(
15,
),
),
child: Row(
crossAxisAlignment:
CrossAxisAlignment
    .start,
children: [
const Icon(
Icons
    .security_outlined,
size: 21,
color:
AppColors.primary,
),
const SizedBox(
width: 10,
),
Expanded(
child: Text(
'Admin access is restricted '
'to authorized CyberSafe '
'administrators only.',
style:
TextStyle(
fontSize: 12,
height: 1.45,
color: AppColors
    .textSecondary,
),
),
),
],
),
),

const SizedBox(
height: 20,
),

// ==================================================
// BACK TO USER LOGIN
// ==================================================

Center(
child:
TextButton.icon(
onPressed:
_isLoading
? null
    : () {
Navigator
    .pushNamedAndRemoveUntil(
context,
AppRoutes
    .login,
(route) =>
false,
);
},
icon: const Icon(
Icons
    .arrow_back_rounded,
size: 18,
),
label:
const Text(
'Back to User Login',
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
