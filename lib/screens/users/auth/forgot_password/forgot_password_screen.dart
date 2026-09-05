import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../../../../services/auth_service.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../../widgets/primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
const ForgotPasswordScreen({
super.key,
});

@override
State<ForgotPasswordScreen> createState() =>
_ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
extends State<ForgotPasswordScreen> {
// ==========================================================
// CONTROLLER
// ==========================================================

final TextEditingController _emailController =
TextEditingController();

// ==========================================================
// FORM
// ==========================================================

final GlobalKey<FormState> _formKey =
GlobalKey<FormState>();

// ==========================================================
// STATE
// ==========================================================

bool _isLoading = false;

// ==========================================================
// SEND RESET EMAIL
// ==========================================================

Future<void> _sendResetEmail() async {
FocusScope.of(context).unfocus();

if (!_formKey.currentState!.validate()) {
return;
}

setState(() {
_isLoading = true;
});

try {
final email =
_emailController.text.trim().toLowerCase();

// ======================================================
// FIREBASE PASSWORD RESET
// ======================================================

final success =
await AuthService.instance.sendPasswordResetEmail(
email: email,
);

if (!mounted) return;

setState(() {
_isLoading = false;
});

// ======================================================
// FAILED
// ======================================================

if (!success) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Unable to send reset email. '
'Please check the email address and try again.',
),
behavior: SnackBarBehavior.floating,
),
);

return;
}

// ======================================================
// SUCCESS DIALOG
// ======================================================

await showDialog<void>(
context: context,
barrierDismissible: false,
builder: (dialogContext) {
return AlertDialog(
title: const Text(
'Reset Email Sent',
style: TextStyle(
fontWeight: FontWeight.w700,
),
),
content: Text(
'A password reset link has been sent to '
'$email.\n\n'
'Please check your inbox and follow the '
'link to create your new password.',
),
actions: [
TextButton(
onPressed: () {
Navigator.pop(dialogContext);
},
child: const Text(
'Continue',
),
),
],
);
},
);

if (!mounted) return;

// ======================================================
// GO BACK TO LOGIN
// ======================================================

Navigator.pushNamedAndRemoveUntil(
context,
AppRoutes.login,
(route) => false,
);
} catch (e) {
if (!mounted) return;

setState(() {
_isLoading = false;
});

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Something went wrong. Please try again.',
),
behavior: SnackBarBehavior.floating,
),
);
}
}

// ==========================================================
// EMAIL VALIDATOR
// ==========================================================

String? _validateEmail(String? value) {
final email = value?.trim() ?? '';

if (email.isEmpty) {
return 'Email is required';
}

final RegExp regex = RegExp(
r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
);

if (!regex.hasMatch(email)) {
return 'Enter a valid email address';
}

return null;
}

// ==========================================================
// DISPOSE
// ==========================================================

@override
void dispose() {
_emailController.dispose();

super.dispose();
}

// ==========================================================
// BUILD
// ==========================================================

@override
Widget build(BuildContext context) {
return Scaffold(
body: SafeArea(
child: SingleChildScrollView(
padding: const EdgeInsets.fromLTRB(
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
// BACK BUTTON
// ==================================================

IconButton(
onPressed: _isLoading
? null
    : () {
Navigator.pop(context);
},
icon: const Icon(
Icons.arrow_back_rounded,
),
),

const SizedBox(height: 24),

// ==================================================
// ICON
// ==================================================

Center(
child: Container(
width: 76,
height: 76,
decoration: BoxDecoration(
color: AppColors.primary,
borderRadius:
BorderRadius.circular(22),
boxShadow: [
BoxShadow(
color: AppColors.primary
    .withValues(alpha: 0.18),
blurRadius: 24,
offset: const Offset(0, 10),
),
],
),
child: const Icon(
Icons.lock_reset_rounded,
color: Colors.white,
size: 42,
),
),
),

const SizedBox(height: 28),

// ==================================================
// TITLE
// ==================================================

const Text(
'Forgot Password?',
style: TextStyle(
fontSize: 30,
fontWeight: FontWeight.w800,
),
),

const SizedBox(height: 8),

Text(
'Enter your registered email address '
'and we will send you a secure password '
'reset link.',
style: TextStyle(
fontSize: 14,
height: 1.5,
color: Colors.grey.shade600,
),
),

const SizedBox(height: 32),

// ==================================================
// EMAIL
// ==================================================

CustomTextField(
controller: _emailController,
label: 'Email',
hint: 'Enter your registered email',
prefixIcon: Icons.email_outlined,
keyboardType:
TextInputType.emailAddress,
textInputAction:
TextInputAction.done,
validator: _validateEmail,
),

const SizedBox(height: 24),

// ==================================================
// SEND RESET EMAIL BUTTON
// ==================================================

PrimaryButton(
text: 'Send Reset Link',
icon: Icons.mark_email_read_outlined,
isLoading: _isLoading,
onPressed: _sendResetEmail,
),

const SizedBox(height: 20),

// ==================================================
// BACK TO LOGIN
// ==================================================

Center(
child: TextButton.icon(
onPressed: _isLoading
? null
    : () {
Navigator
    .pushNamedAndRemoveUntil(
context,
AppRoutes.login,
(route) => false,
);
},
icon: const Icon(
Icons.arrow_back_rounded,
size: 18,
),
label: const Text(
'Back to Login',
),
),
),

const SizedBox(height: 18),

// ==================================================
// SECURITY INFO
// ==================================================

Container(
width: double.infinity,
padding: const EdgeInsets.all(14),
decoration: BoxDecoration(
color: AppColors.accentLight,
borderRadius:
BorderRadius.circular(14),
),
child: Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Icon(
Icons.security_outlined,
size: 20,
color: AppColors.primary,
),
const SizedBox(width: 10),
Expanded(
child: Text(
'For your security, CyberSafe '
'never asks you to share your '
'password or OTP with anyone.',
style: TextStyle(
fontSize: 11.5,
height: 1.45,
color:
AppColors.textSecondary,
),
),
),
],
),
),

const SizedBox(height: 18),

// ==================================================
// RESET INSTRUCTIONS
// ==================================================

Container(
width: double.infinity,
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
borderRadius:
BorderRadius.circular(16),
border: Border.all(
color: Colors.grey.shade200,
),
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Row(
children: [
Icon(
Icons.info_outline_rounded,
size: 20,
color:
AppColors.primary,
),
SizedBox(width: 8),
Text(
'How it works',
style: TextStyle(
fontWeight:
FontWeight.w700,
),
),
],
),

const SizedBox(height: 12),

const _InstructionRow(
number: '1',
text:
'Enter your registered email.',
),

const _InstructionRow(
number: '2',
text:
'Tap Send Reset Link.',
),

const _InstructionRow(
number: '3',
text:
'Open the password reset email.',
),

const _InstructionRow(
number: '4',
text:
'Create your new password.',
),
],
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

// ============================================================
// INSTRUCTION ROW
// ============================================================

class _InstructionRow extends StatelessWidget {
final String number;
final String text;

const _InstructionRow({
required this.number,
required this.text,
});

@override
Widget build(BuildContext context) {
return Padding(
padding:
const EdgeInsets.only(bottom: 10),
child: Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Container(
width: 24,
height: 24,
alignment: Alignment.center,
decoration: BoxDecoration(
color: AppColors.accentLight,
shape: BoxShape.circle,
),
child: Text(
number,
style: const TextStyle(
fontSize: 12,
fontWeight: FontWeight.w700,
color: AppColors.primary,
),
),
),

const SizedBox(width: 10),

Expanded(
child: Text(
text,
style: TextStyle(
fontSize: 13,
height: 1.4,
color: Colors.grey.shade700,
),
),
),
],
),
);
}
}
