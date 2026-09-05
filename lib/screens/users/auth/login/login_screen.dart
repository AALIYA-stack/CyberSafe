import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../../../../services/auth_service.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../../widgets/primary_button.dart';
import '../animations/auth_fade_animation.dart';
import '../animations/auth_slide_animation.dart';

class LoginScreen extends StatefulWidget {
const LoginScreen({super.key});

@override
State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
// ==========================================================
// FORM
// ==========================================================

final _formKey = GlobalKey<FormState>();

// ==========================================================
// CONTROLLERS
// ==========================================================

final _emailController = TextEditingController();
final _passwordController = TextEditingController();

// ==========================================================
// STATE
// ==========================================================

bool _obscurePassword = true;
bool _isLoading = false;

// ==========================================================
// USER LOGIN
// ==========================================================

Future<void> _login() async {
FocusScope.of(context).unfocus();

if (!_formKey.currentState!.validate()) {
return;
}

setState(() {
_isLoading = true;
});

try {
// ======================================================
// FIREBASE LOGIN
// ======================================================

final success = await AuthService.instance.login(
email: _emailController.text.trim(),
password: _passwordController.text,
);

if (!mounted) return;

setState(() {
_isLoading = false;
});

// ======================================================
// LOGIN FAILED
// ======================================================

if (!success) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Invalid email or password.',
),
behavior: SnackBarBehavior.floating,
),
);

return;
}

// ======================================================
// LOGIN SUCCESS
// ======================================================

Navigator.pushNamedAndRemoveUntil(
context,
AppRoutes.main,
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
'Unable to login. Please try again.',
),
behavior: SnackBarBehavior.floating,
),
);
}
}

// ==========================================================
// CONTINUE AS GUEST
// ==========================================================

void _continueAsGuest() {
FocusScope.of(context).unfocus();

Navigator.pushNamedAndRemoveUntil(
context,
AppRoutes.guest,
(route) => false,
);
}

// ==========================================================
// OPEN ADMIN LOGIN
// ==========================================================

void _openAdminLogin() {
FocusScope.of(context).unfocus();

Navigator.pushNamed(
context,
AppRoutes.adminLogin,
);
}

// ==========================================================
// EMAIL VALIDATOR
// ==========================================================

String? _validateEmail(String? value) {
final email = value?.trim() ?? '';

if (email.isEmpty) {
return 'Email is required';
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

String? _validatePassword(String? value) {
if (value == null || value.isEmpty) {
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
Widget build(BuildContext context) {
return Scaffold(
body: SafeArea(
child: SingleChildScrollView(
padding: const EdgeInsets.fromLTRB(
24,
30,
24,
30,
),
child: Form(
key: _formKey,
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// ==================================================
// BACK
// ==================================================

AuthFadeAnimation(
child: IconButton(
onPressed: _isLoading
? null
    : () {
Navigator.pop(context);
},
icon: const Icon(
Icons.arrow_back_rounded,
),
),
),

const SizedBox(height: 20),

// ==================================================
// LOGO
// ==================================================

AuthSlideAnimation(
delay: 100,
child: Center(
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
Icons.shield_outlined,
color: Colors.white,
size: 42,
),
),
),
),

const SizedBox(height: 28),

// ==================================================
// TITLE
// ==================================================

AuthSlideAnimation(
delay: 180,
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'Welcome Back',
style: TextStyle(
fontSize: 30,
fontWeight: FontWeight.w800,
),
),
const SizedBox(height: 8),
Text(
'Login to your CyberSafe account '
'to continue.',
style: TextStyle(
fontSize: 14,
height: 1.5,
color: Colors.grey.shade600,
),
),
],
),
),

const SizedBox(height: 32),

// ==================================================
// EMAIL
// ==================================================

AuthSlideAnimation(
delay: 260,
child: CustomTextField(
controller: _emailController,
label: 'Email',
hint: 'Enter your email',
prefixIcon:
Icons.email_outlined,
keyboardType:
TextInputType.emailAddress,
textInputAction:
TextInputAction.next,
validator:
_validateEmail,
),
),

const SizedBox(height: 18),

// ==================================================
// PASSWORD
// ==================================================

AuthSlideAnimation(
delay: 320,
child: CustomTextField(
controller: _passwordController,
label: 'Password',
hint: 'Enter your password',
prefixIcon:
Icons.lock_outline_rounded,
obscureText:
_obscurePassword,
textInputAction:
TextInputAction.done,
validator:
_validatePassword,
suffixIcon:
IconButton(
onPressed: () {
setState(() {
_obscurePassword =
!_obscurePassword;
});
},
icon: Icon(
_obscurePassword
? Icons.visibility_outlined
    : Icons.visibility_off_outlined,
),
),
),
),

const SizedBox(height: 8),

// ==================================================
// FORGOT PASSWORD
// ==================================================

AuthFadeAnimation(
delay: 380,
child: Align(
alignment:
Alignment.centerRight,
child: TextButton(
onPressed: _isLoading
? null
    : () {
Navigator.pushNamed(
context,
AppRoutes.forgotPassword,
);
},
child: const Text(
'Forgot Password?',
),
),
),
),

const SizedBox(height: 12),

// ==================================================
// USER LOGIN
// ==================================================

AuthSlideAnimation(
delay: 440,
child: PrimaryButton(
text: 'Login',
icon: Icons.login_rounded,
isLoading: _isLoading,
onPressed: _login,
),
),

const SizedBox(height: 14),

// ==================================================
// ADMIN LOGIN
// ==================================================

AuthFadeAnimation(
delay: 500,
child: SizedBox(
width: double.infinity,
height: 52,
child: OutlinedButton.icon(
onPressed: _isLoading
? null
    : _openAdminLogin,
icon: const Icon(
Icons.admin_panel_settings_outlined,
),
label: const Text(
'Admin Login',
style: TextStyle(
fontWeight:
FontWeight.w700,
),
),
style:
OutlinedButton.styleFrom(
foregroundColor:
AppColors.primary,
side: BorderSide(
color: AppColors.primary
    .withValues(alpha: 0.45),
),
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(15),
),
),
),
),
),

const SizedBox(height: 12),

// ==================================================
// CONTINUE AS GUEST
// ==================================================

AuthFadeAnimation(
delay: 540,
child: SizedBox(
width: double.infinity,
height: 52,
child: TextButton.icon(
onPressed: _isLoading
? null
    : _continueAsGuest,
icon: const Icon(
Icons.person_outline_rounded,
),
label: const Text(
'Continue as Guest',
style: TextStyle(
fontWeight:
FontWeight.w700,
),
),
style:
TextButton.styleFrom(
foregroundColor:
AppColors.primary,
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(15),
),
),
),
),
),

const SizedBox(height: 20),

// ==================================================
// DIVIDER
// ==================================================

AuthFadeAnimation(
delay: 580,
child: Row(
children: [
Expanded(
child: Divider(
color:
Colors.grey.shade300,
),
),
Padding(
padding:
const EdgeInsets.symmetric(
horizontal: 14,
),
child: Text(
'OR',
style: TextStyle(
fontSize: 12,
fontWeight:
FontWeight.w600,
color:
Colors.grey.shade500,
),
),
),
Expanded(
child: Divider(
color:
Colors.grey.shade300,
),
),
],
),
),

const SizedBox(height: 24),

// ==================================================
// SIGNUP
// ==================================================

AuthSlideAnimation(
delay: 620,
child: Row(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
Text(
"Don't have an account?",
style: TextStyle(
color:
Colors.grey.shade600,
),
),
TextButton(
onPressed: _isLoading
? null
    : () {
Navigator.pushNamed(
context,
AppRoutes.signup,
);
},
child:
const Text('Sign Up'),
),
],
),
),

const SizedBox(height: 20),

// ==================================================
// SECURITY MESSAGE
// ==================================================

AuthFadeAnimation(
delay: 680,
child: Container(
width: double.infinity,
padding:
const EdgeInsets.all(14),
decoration: BoxDecoration(
color:
AppColors.accentLight,
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
color:
AppColors.primary,
),
const SizedBox(width: 10),
Expanded(
child: Text(
'Never share your password, '
'OTP or account credentials '
'with anyone.',
style: TextStyle(
fontSize: 11.5,
height: 1.45,
color: AppColors
    .textSecondary,
),
),
),
],
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
