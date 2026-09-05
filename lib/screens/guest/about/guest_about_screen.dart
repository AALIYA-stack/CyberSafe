import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../services/about_service.dart';

class GuestAboutScreen extends StatefulWidget {
const GuestAboutScreen({super.key});

@override
State<GuestAboutScreen> createState() => _GuestAboutScreenState();
}

class _GuestAboutScreenState extends State<GuestAboutScreen>
with SingleTickerProviderStateMixin {
late AnimationController _controller;

late Animation<double> _fadeAnimation;
late Animation<double> _scaleAnimation;
late Animation<Offset> _slideAnimation;

final AboutService _aboutService = AboutService.instance;

@override
void initState() {
super.initState();

_controller = AnimationController(
vsync: this,
duration: const Duration(milliseconds: 800),
);

_fadeAnimation = CurvedAnimation(
parent: _controller,
curve: Curves.easeOut,
);

_scaleAnimation = Tween<double>(
begin: 0.85,
end: 1,
).animate(
CurvedAnimation(
parent: _controller,
curve: Curves.easeOutBack,
),
);

_slideAnimation = Tween<Offset>(
begin: const Offset(0, 0.10),
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

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text(
'About CyberSafe',
style: TextStyle(
fontWeight: FontWeight.w800,
),
),
),
body: StreamBuilder<Map<String, dynamic>>(
stream: _aboutService.watchAboutContent(),
builder: (context, snapshot) {
if (snapshot.connectionState == ConnectionState.waiting) {
return _buildLoadingState();
}

if (snapshot.hasError) {
return _buildErrorState();
}

final data = snapshot.data ?? {};

final description =
(data['description'] ?? '').toString().trim();

final mission =
(data['mission'] ?? '').toString().trim();

final version =
(data['version'] ?? '1.0.0').toString().trim();

return FadeTransition(
opacity: _fadeAnimation,
child: SlideTransition(
position: _slideAnimation,
child: ListView(
padding: const EdgeInsets.fromLTRB(
20,
15,
20,
35,
),
children: [
_buildHero(),

const SizedBox(height: 24),

_buildSectionTitle(
'What is CyberSafe?',
),

const SizedBox(height: 10),

_buildDescription(
description.isNotEmpty
? description
    : 'CyberSafe is a professional cybersecurity platform designed to help users understand cyber threats, learn online safety practices and submit cyber crime complaints through a structured reporting process.',
),

const SizedBox(height: 26),

_buildSectionTitle(
'Our Mission',
),

const SizedBox(height: 10),

_buildMissionCard(
mission.isNotEmpty
? mission
    : 'Our mission is to promote safer digital communities by increasing cybersecurity awareness and providing an organized way to report and track cyber crime complaints.',
),

const SizedBox(height: 26),

_buildSectionTitle(
'What CyberSafe Provides',
),

const SizedBox(height: 12),

_buildFeatureList(),

const SizedBox(height: 28),

_buildSectionTitle(
'How CyberSafe Works',
),

const SizedBox(height: 12),

_buildProcess(),

const SizedBox(height: 28),

_buildSecurityNote(),

const SizedBox(height: 30),

Center(
child: Text(
'CyberSafe • Version $version',
style: TextStyle(
color: Colors.grey.shade500,
fontSize: 12,
fontWeight: FontWeight.w600,
),
),
),
],
),
),
);
},
),
);
}

Widget _buildLoadingState() {
return const Center(
child: CircularProgressIndicator(),
);
}

Widget _buildErrorState() {
return Center(
child: Padding(
padding: const EdgeInsets.all(24),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Icon(
Icons.cloud_off_outlined,
size: 60,
color: AppColors.primary,
),

const SizedBox(height: 16),

const Text(
'Unable to load About information',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w800,
),
),

const SizedBox(height: 8),

Text(
'Please check your internet connection and try again.',
textAlign: TextAlign.center,
style: TextStyle(
color: Colors.grey.shade600,
height: 1.5,
),
),
],
),
),
);
}

// ==========================================================
// HERO
// ==========================================================

Widget _buildHero() {
return ScaleTransition(
scale: _scaleAnimation,
child: Container(
padding: const EdgeInsets.symmetric(
horizontal: 20,
vertical: 28,
),
decoration: BoxDecoration(
gradient: LinearGradient(
colors: [
AppColors.primary,
AppColors.primary.withValues(
alpha: 0.82,
),
],
begin: Alignment.topLeft,
end: Alignment.bottomRight,
),
borderRadius: BorderRadius.circular(26),
boxShadow: [
BoxShadow(
color: AppColors.primary.withValues(
alpha: 0.18,
),
blurRadius: 22,
offset: const Offset(0, 10),
),
],
),
child: Column(
children: [
Container(
height: 82,
width: 82,
decoration: BoxDecoration(
color: Colors.white.withValues(
alpha: 0.14,
),
shape: BoxShape.circle,
),
child: const Icon(
Icons.shield_rounded,
color: Colors.white,
size: 48,
),
),

const SizedBox(height: 18),

const Text(
'CyberSafe',
style: TextStyle(
color: Colors.white,
fontSize: 28,
fontWeight: FontWeight.w900,
),
),

const SizedBox(height: 8),

const Text(
'Cyber Crime Complaint & Awareness\nManagement System',
textAlign: TextAlign.center,
style: TextStyle(
color: Colors.white70,
fontSize: 13,
height: 1.5,
),
),
],
),
),
);
}

// ==========================================================
// SECTION TITLE
// ==========================================================

Widget _buildSectionTitle(String title) {
return Text(
title,
style: const TextStyle(
fontSize: 19,
fontWeight: FontWeight.w900,
),
);
}

// ==========================================================
// DESCRIPTION
// ==========================================================

Widget _buildDescription(String description) {
return Container(
padding: const EdgeInsets.all(18),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(18),
border: Border.all(
color: Colors.grey.shade200,
),
),
child: Text(
description,
style: TextStyle(
color: Colors.grey.shade700,
fontSize: 14,
height: 1.6,
),
),
);
}

// ==========================================================
// MISSION
// ==========================================================

Widget _buildMissionCard(String mission) {
return Container(
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: AppColors.primary.withValues(
alpha: 0.05,
),
borderRadius: BorderRadius.circular(20),
border: Border.all(
color: AppColors.primary.withValues(
alpha: 0.12,
),
),
),
child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Container(
height: 48,
width: 48,
decoration: BoxDecoration(
color: AppColors.primary.withValues(
alpha: 0.10,
),
borderRadius: BorderRadius.circular(14),
),
child: const Icon(
Icons.flag_outlined,
color: AppColors.primary,
),
),

const SizedBox(width: 14),

Expanded(
child: Text(
mission,
style: const TextStyle(
fontSize: 14,
height: 1.55,
fontWeight: FontWeight.w600,
),
),
),
],
),
);
}

// ==========================================================
// FEATURES
// ==========================================================

Widget _buildFeatureList() {
final features = [
(
Icons.report_problem_outlined,
'Cyber Crime Reporting',
'Users can submit structured cyber crime complaints.',
),
(
Icons.track_changes_outlined,
'Complaint Tracking',
'Logged-in users can track the status of their own complaints.',
),
(
Icons.menu_book_outlined,
'Cyber Awareness',
'Learn about common cyber threats and safety practices.',
),
(
Icons.notifications_none_rounded,
'Complaint Updates',
'Users can receive updates related to their complaints.',
),
(
Icons.security_outlined,
'Privacy Focused',
'Personal complaint information is separated between users.',
),
];

return Column(
children: List.generate(
features.length,
(index) {
final feature = features[index];

return _AnimatedFeatureCard(
index: index,
icon: feature.$1,
title: feature.$2,
description: feature.$3,
);
},
),
);
}

// ==========================================================
// PROCESS
// ==========================================================

Widget _buildProcess() {
final steps = [
(
'01',
Icons.login_rounded,
'Create an Account',
'Login or create an account to access complaint features.',
),
(
'02',
Icons.edit_document,
'Submit Complaint',
'Enter incident information and attach available evidence.',
),
(
'03',
Icons.fact_check_outlined,
'Review',
'Review your complaint information before submission.',
),
(
'04',
Icons.manage_search_outlined,
'Complaint Handling',
'The complaint can be reviewed and managed by authorized administrators.',
),
(
'05',
Icons.timeline_rounded,
'Track Status',
'The user can view the status of their own complaint.',
),
];

return Column(
children: List.generate(
steps.length,
(index) {
final step = steps[index];

return _AnimatedProcessStep(
index: index,
number: step.$1,
icon: step.$2,
title: step.$3,
description: step.$4,
isLast: index == steps.length - 1,
);
},
),
);
}

// ==========================================================
// SECURITY NOTE
// ==========================================================

Widget _buildSecurityNote() {
return Container(
padding: const EdgeInsets.all(18),
decoration: BoxDecoration(
color: Colors.green.withValues(
alpha: 0.06,
),
borderRadius: BorderRadius.circular(18),
border: Border.all(
color: Colors.green.withValues(
alpha: 0.16,
),
),
),
child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Icon(
Icons.verified_user_outlined,
color: Colors.green,
size: 26,
),

const SizedBox(width: 12),

Expanded(
child: Text(
'CyberSafe is designed around responsible complaint handling. Guests can explore public awareness information, while complaint submission and personal complaint tracking require an account.',
style: TextStyle(
color: Colors.grey.shade700,
fontSize: 13,
height: 1.5,
fontWeight: FontWeight.w600,
),
),
),
],
),
);
}
}

// ==========================================================
// ANIMATED FEATURE CARD
// ==========================================================

class _AnimatedFeatureCard extends StatefulWidget {
final int index;
final IconData icon;
final String title;
final String description;

const _AnimatedFeatureCard({
required this.index,
required this.icon,
required this.title,
required this.description,
});

@override
State<_AnimatedFeatureCard> createState() =>
_AnimatedFeatureCardState();
}

class _AnimatedFeatureCardState
extends State<_AnimatedFeatureCard>
with SingleTickerProviderStateMixin {
late AnimationController _controller;

late Animation<double> _fade;
late Animation<Offset> _slide;

@override
void initState() {
super.initState();

_controller = AnimationController(
vsync: this,
duration: const Duration(milliseconds: 500),
);

_fade = CurvedAnimation(
parent: _controller,
curve: Curves.easeOut,
);

_slide = Tween<Offset>(
begin: const Offset(0, 0.12),
end: Offset.zero,
).animate(
CurvedAnimation(
parent: _controller,
curve: Curves.easeOutCubic,
),
);

Future.delayed(
Duration(milliseconds: 100 * widget.index),
() {
if (mounted) {
_controller.forward();
}
},
);
}

@override
void dispose() {
_controller.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
return FadeTransition(
opacity: _fade,
child: SlideTransition(
position: _slide,
child: Container(
margin: const EdgeInsets.only(
bottom: 12,
),
padding: const EdgeInsets.all(15),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(17),
border: Border.all(
color: Colors.grey.shade200,
),
),
child: Row(
children: [
Container(
height: 48,
width: 48,
decoration: BoxDecoration(
color: AppColors.primary.withValues(
alpha: 0.08,
),
borderRadius: BorderRadius.circular(14),
),
child: Icon(
widget.icon,
color: AppColors.primary,
),
),

const SizedBox(width: 14),

Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
widget.title,
style: const TextStyle(
fontSize: 14,
fontWeight: FontWeight.w800,
),
),

const SizedBox(height: 4),

Text(
widget.description,
style: TextStyle(
fontSize: 12,
height: 1.4,
color: Colors.grey.shade600,
),
),
],
),
),
],
),
),
),
);
}
}

// ==========================================================
// ANIMATED PROCESS STEP
// ==========================================================

class _AnimatedProcessStep extends StatefulWidget {
final int index;
final String number;
final IconData icon;
final String title;
final String description;
final bool isLast;

const _AnimatedProcessStep({
required this.index,
required this.number,
required this.icon,
required this.title,
required this.description,
required this.isLast,
});

@override
State<_AnimatedProcessStep> createState() =>
_AnimatedProcessStepState();
}

class _AnimatedProcessStepState
extends State<_AnimatedProcessStep>
with SingleTickerProviderStateMixin {
late AnimationController _controller;

late Animation<double> _fade;
late Animation<double> _scale;

@override
void initState() {
super.initState();

_controller = AnimationController(
vsync: this,
duration: const Duration(milliseconds: 500),
);

_fade = CurvedAnimation(
parent: _controller,
curve: Curves.easeOut,
);

_scale = Tween<double>(
begin: 0.8,
end: 1,
).animate(
CurvedAnimation(
parent: _controller,
curve: Curves.easeOutBack,
),
);

Future.delayed(
Duration(milliseconds: 120 * widget.index),
() {
if (mounted) {
_controller.forward();
}
},
);
}

@override
void dispose() {
_controller.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
return FadeTransition(
opacity: _fade,
child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Column(
children: [
ScaleTransition(
scale: _scale,
child: Container(
height: 48,
width: 48,
decoration: BoxDecoration(
color: AppColors.primary,
shape: BoxShape.circle,
boxShadow: [
BoxShadow(
color: AppColors.primary.withValues(
alpha: 0.18,
),
blurRadius: 10,
offset: const Offset(0, 4),
),
],
),
child: Center(
child: Icon(
widget.icon,
color: Colors.white,
size: 22,
),
),
),
),

if (!widget.isLast)
Container(
width: 2,
height: 58,
color: AppColors.primary.withValues(
alpha: 0.15,
),
),
],
),

const SizedBox(width: 14),

Expanded(
child: Container(
margin: const EdgeInsets.only(
bottom: 14,
),
padding: const EdgeInsets.all(15),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(16),
border: Border.all(
color: Colors.grey.shade200,
),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'STEP ${widget.number}',
style: TextStyle(
color: AppColors.primary,
fontSize: 10,
fontWeight: FontWeight.w900,
),
),

const SizedBox(height: 4),

Text(
widget.title,
style: const TextStyle(
fontSize: 14,
fontWeight: FontWeight.w800,
),
),

const SizedBox(height: 5),

Text(
widget.description,
style: TextStyle(
fontSize: 12,
height: 1.4,
color: Colors.grey.shade600,
),
),
],
),
),
),
],
),
);
}
}

