import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';

class LoginRequiredScreen extends StatefulWidget {
final String featureName;

const LoginRequiredScreen({
super.key,
this.featureName = 'this feature',
});

@override
State<LoginRequiredScreen> createState() =>
_LoginRequiredScreenState();
}

class _LoginRequiredScreenState
extends State<LoginRequiredScreen>
with SingleTickerProviderStateMixin {
late AnimationController _controller;

late Animation<double> _fadeAnimation;
late Animation<double> _scaleAnimation;
late Animation<Offset> _slideAnimation;

@override
void initState() {
super.initState();

_controller = AnimationController(
vsync: this,
duration: const Duration(milliseconds: 750),
);

_fadeAnimation = CurvedAnimation(
parent: _controller,
curve: Curves.easeOut,
);

_scaleAnimation = Tween<double>(
begin: 0.75,
end: 1.0,
).animate(
CurvedAnimation(
parent: _controller,
curve: Curves.easeOutBack,
),
);

_slideAnimation = Tween<Offset>(
begin: const Offset(0, 0.12),
end: Offset.zero,
).animate(
CurvedAnimation(
parent: _controller,
curve: Curves.easeOutCubic,
),
);

_controller.forward();
}

@override
void dispose() {
_controller.dispose();
super.dispose();
}

// ==========================================================
// LOGIN
// ==========================================================

void _goToLogin() {
Navigator.pushNamed(
context,
AppRoutes.login,
);
}

// ==========================================================
// SIGNUP
// ==========================================================

void _goToSignup() {
Navigator.pushNamed(
context,
AppRoutes.signup,
);
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: AppColors.background,
appBar: AppBar(
title: const Text(
'Login Required',
style: TextStyle(
fontWeight: FontWeight.w800,
),
),
),
body: SafeArea(
child: Center(
child: SingleChildScrollView(
padding: const EdgeInsets.all(24),
child: FadeTransition(
opacity: _fadeAnimation,
child: SlideTransition(
position: _slideAnimation,
child: Column(
children: [
// ==================================================
// LOCK ICON
// ==================================================

ScaleTransition(
scale: _scaleAnimation,
child: Container(
height: 120,
width: 120,
decoration: BoxDecoration(
color: AppColors.primary.withValues(
alpha: 0.08,
),
shape: BoxShape.circle,
),
child: Container(
margin: const EdgeInsets.all(15),
decoration: BoxDecoration(
color: AppColors.primary,
shape: BoxShape.circle,
boxShadow: [
BoxShadow(
color: AppColors.primary
    .withValues(alpha: 0.20),
blurRadius: 20,
spreadRadius: 2,
),
],
),
child: const Icon(
Icons.lock_outline_rounded,
color: Colors.white,
size: 48,
),
),
),
),

const SizedBox(height: 30),

// ==================================================
// TITLE
// ==================================================

const Text(
'Login Required',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 26,
fontWeight: FontWeight.w900,
),
),

const SizedBox(height: 10),

// ==================================================
// DESCRIPTION
// ==================================================

Text(
'Please login or create an account '
'to access ${widget.featureName}.',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 14,
height: 1.6,
color: Colors.grey.shade600,
),
),

const SizedBox(height: 28),

// ==================================================
// BENEFITS CARD
// ==================================================

Container(
width: double.infinity,
padding: const EdgeInsets.all(18),
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(20),
border: Border.all(
color: Colors.grey.shade200,
),
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'With an account you can:',
style: TextStyle(
fontSize: 15,
fontWeight: FontWeight.w800,
),
),

const SizedBox(height: 15),

_benefit(
Icons.report_outlined,
'Submit cybercrime complaints',
),

_benefit(
Icons.track_changes_rounded,
'Track your own complaints',
),

_benefit(
Icons.timeline_rounded,
'View complaint status updates',
),

_benefit(
Icons.notifications_none_rounded,
'Receive complaint notifications',
),

_benefit(
Icons.person_outline_rounded,
'Manage your profile',
),
],
),
),

const SizedBox(height: 28),

// ==================================================
// LOGIN BUTTON
// ==================================================

SizedBox(
width: double.infinity,
height: 54,
child: ElevatedButton.icon(
onPressed: _goToLogin,
icon: const Icon(
Icons.login_rounded,
),
label: const Text(
'Login',
style: TextStyle(
fontSize: 15,
fontWeight: FontWeight.w800,
),
),
),
),

const SizedBox(height: 12),

// ==================================================
// SIGNUP BUTTON
// ==================================================

SizedBox(
width: double.infinity,
height: 54,
child: OutlinedButton.icon(
onPressed: _goToSignup,
icon: const Icon(
Icons.person_add_alt_1_rounded,
),
label: const Text(
'Create New Account',
style: TextStyle(
fontSize: 15,
fontWeight: FontWeight.w800,
),
),
),
),

const SizedBox(height: 18),

// ==================================================
// CONTINUE AS GUEST
// ==================================================

TextButton(
onPressed: () {
Navigator.pop(context);
},
child: const Text(
'Continue as Guest',
style: TextStyle(
fontWeight: FontWeight.w700,
),
),
),
],
),
),
),
),
),
),
);
}

// ==========================================================
// BENEFIT ITEM
// ==========================================================

Widget _benefit(
IconData icon,
String text,
) {
return Padding(
padding: const EdgeInsets.only(
bottom: 12,
),
child: Row(
children: [
Container(
height: 34,
width: 34,
decoration: BoxDecoration(
color: AppColors.primary.withValues(
alpha: 0.08,
),
borderRadius:
BorderRadius.circular(10),
),
child: Icon(
icon,
size: 19,
color: AppColors.primary,
),
),

const SizedBox(width: 11),

Expanded(
child: Text(
text,
style: const TextStyle(
fontSize: 13,
fontWeight: FontWeight.w600,
),
),
),

const Icon(
Icons.check_circle_outline_rounded,
size: 18,
color: AppColors.primary,
),
],
),
);
}
}
