import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../../../../services/auth_service.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../../widgets/primary_button.dart';
import '../animations/auth_fade_animation.dart';
import '../animations/auth_slide_animation.dart';

class SignupScreen extends StatefulWidget {
const SignupScreen({super.key});

@override
State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
// ==========================================================
// FORM
// ==========================================================

final _formKey = GlobalKey<FormState>();

// ==========================================================
// CONTROLLERS
// ==========================================================

final _nameController = TextEditingController();
final _emailController = TextEditingController();
final _phoneController = TextEditingController();
final _passwordController = TextEditingController();
final _confirmPasswordController = TextEditingController();

// ==========================================================
// STATE
// ==========================================================

bool _obscurePassword = true;
bool _obscureConfirmPassword = true;
bool _acceptTerms = false;
bool _isLoading = false;

// ==========================================================
// SIGN UP
// ==========================================================

Future<void> _signup() async {
FocusScope.of(context).unfocus();

if (!_formKey.currentState!.validate()) {
return;
}

if (!_acceptTerms) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Please accept the Terms & Conditions.',
),
behavior: SnackBarBehavior.floating,
),
);

return;
}

setState(() {
_isLoading = true;
});

try {
final success = await AuthService.instance.signUp(
name: _nameController.text.trim(),
email: _emailController.text.trim(),
password: _passwordController.text,
phone: _phoneController.text.trim(),
);

if (!mounted) return;

setState(() {
_isLoading = false;
});

if (!success) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Unable to create account. Email may already be registered.',
),
behavior: SnackBarBehavior.floating,
),
);

return;
}

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Account created successfully.',
),
behavior: SnackBarBehavior.floating,
),
);

Navigator.pushNamedAndRemoveUntil(
context,
AppRoutes.main,
(route) => false,
);
} catch (_) {
if (!mounted) return;

setState(() {
_isLoading = false;
});

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Unable to create account. Please try again.',
),
behavior: SnackBarBehavior.floating,
),
);
}
}

// ==========================================================
// NAME VALIDATOR
// ==========================================================

String? _validateName(String? value) {
final name = value?.trim() ?? '';

if (name.isEmpty) {
return 'Name is required';
}

if (name.length < 3) {
return 'Name must contain at least 3 characters';
}

return null;
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
// PHONE VALIDATOR
// ==========================================================

String? _validatePhone(String? value) {
final phone = value?.trim() ?? '';

if (phone.isEmpty) {
return 'Phone number is required';
}

final digits = phone.replaceAll(
RegExp(r'\D'),
'',
);

if (digits.length < 10 ||
digits.length > 15) {
return 'Enter a valid phone number';
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
// CONFIRM PASSWORD VALIDATOR
// ==========================================================

String? _validateConfirmPassword(String? value) {
if (value == null || value.isEmpty) {
return 'Please confirm your password';
}

if (value != _passwordController.text) {
return 'Passwords do not match';
}

return null;
}

// ==========================================================
// DISPOSE
// ==========================================================

@override
void dispose() {
_nameController.dispose();
_emailController.dispose();
_phoneController.dispose();
_passwordController.dispose();
_confirmPasswordController.dispose();

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
crossAxisAlignment:
CrossAxisAlignment.start,
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
'Create Account',
style: TextStyle(
fontSize: 30,
fontWeight: FontWeight.w800,
),
),
const SizedBox(height: 8),
Text(
'Create your CyberSafe account '
'to protect and manage your digital safety.',
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
// NAME
// ==================================================

AuthSlideAnimation(
delay: 240,
child: CustomTextField(
controller: _nameController,
label: 'Full Name',
hint: 'Enter your full name',
prefixIcon:
Icons.person_outline_rounded,
textInputAction:
TextInputAction.next,
validator: _validateName,
),
),

const SizedBox(height: 18),

// ==================================================
// EMAIL
// ==================================================

AuthSlideAnimation(
delay: 280,
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
validator: _validateEmail,
),
),

const SizedBox(height: 18),

// ==================================================
// PHONE
// ==================================================

AuthSlideAnimation(
delay: 320,
child: CustomTextField(
controller: _phoneController,
label: 'Phone Number',
hint: 'Enter your phone number',
prefixIcon:
Icons.phone_outlined,
keyboardType:
TextInputType.phone,
textInputAction:
TextInputAction.next,
validator: _validatePhone,
),
),

const SizedBox(height: 18),

// ==================================================
// PASSWORD
// ==================================================

AuthSlideAnimation(
delay: 360,
child: CustomTextField(
controller: _passwordController,
label: 'Password',
hint: 'Create a password',
prefixIcon:
Icons.lock_outline_rounded,
obscureText:
_obscurePassword,
textInputAction:
TextInputAction.next,
validator:
_validatePassword,
suffixIcon: IconButton(
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

const SizedBox(height: 18),

// ==================================================
// CONFIRM PASSWORD
// ==================================================

AuthSlideAnimation(
delay: 400,
child: CustomTextField(
controller:
_confirmPasswordController,
label: 'Confirm Password',
hint: 'Re-enter your password',
prefixIcon:
Icons.lock_outline_rounded,
obscureText:
_obscureConfirmPassword,
textInputAction:
TextInputAction.done,
validator:
_validateConfirmPassword,
suffixIcon: IconButton(
onPressed: () {
setState(() {
_obscureConfirmPassword =
!_obscureConfirmPassword;
});
},
icon: Icon(
_obscureConfirmPassword
? Icons.visibility_outlined
    : Icons.visibility_off_outlined,
),
),
),
),

const SizedBox(height: 16),

// ==================================================
// TERMS & CONDITIONS
// ==================================================

AuthFadeAnimation(
delay: 440,
child: Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Checkbox(
value: _acceptTerms,
activeColor:
AppColors.primary,
onChanged: _isLoading
? null
    : (value) {
setState(() {
_acceptTerms =
value ?? false;
});
},
),
Expanded(
child: Padding(
padding:
const EdgeInsets.only(
top: 12,
),
child: Text(
'I agree to the Terms & Conditions '
'and Privacy Policy.',
style: TextStyle(
fontSize: 12.5,
height: 1.4,
color:
Colors.grey.shade600,
),
),
),
),
],
),
),

const SizedBox(height: 14),

// ==================================================
// CREATE ACCOUNT
// ==================================================

AuthSlideAnimation(
delay: 480,
child: PrimaryButton(
text: 'Create Account',
icon: Icons.person_add_alt_1_rounded,
isLoading: _isLoading,
onPressed: _signup,
),
),

const SizedBox(height: 22),

// ==================================================
// DIVIDER
// ==================================================

AuthFadeAnimation(
delay: 520,
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

const SizedBox(height: 22),

// ==================================================
// LOGIN
// ==================================================

AuthSlideAnimation(
delay: 560,
child: Row(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
Text(
'Already have an account?',
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
AppRoutes.login,
);
},
child:
const Text('Login'),
),
],
),
),

const SizedBox(height: 20),

// ==================================================
// SECURITY MESSAGE
// ==================================================

AuthFadeAnimation(
delay: 600,
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
'Your password is securely '
'handled by Firebase Authentication. '
'Never share your password or OTP.',
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

