import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../models/complaint.dart';
import '../../../../routes/app_routes.dart';

class ComplaintSuccessScreen extends StatefulWidget {
final Complaint complaint;

const ComplaintSuccessScreen({
super.key,
required this.complaint,
});

@override
State<ComplaintSuccessScreen> createState() =>
_ComplaintSuccessScreenState();
}

class _ComplaintSuccessScreenState
extends State<ComplaintSuccessScreen>
with SingleTickerProviderStateMixin {
// ==========================================================
// ANIMATION
// ==========================================================

late AnimationController _controller;

late Animation<double> _scaleAnimation;
late Animation<double> _fadeAnimation;
late Animation<Offset> _slideAnimation;

// ==========================================================
// INIT
// ==========================================================

@override
void initState() {
super.initState();

_controller = AnimationController(
vsync: this,
duration: const Duration(
milliseconds: 900,
),
);

_scaleAnimation = CurvedAnimation(
parent: _controller,
curve: Curves.elasticOut,
);

_fadeAnimation = CurvedAnimation(
parent: _controller,
curve: Curves.easeIn,
);

_slideAnimation = Tween<Offset>(
begin: const Offset(0, 0.15),
end: Offset.zero,
).animate(
CurvedAnimation(
parent: _controller,
curve: Curves.easeOutCubic,
),
);

_controller.forward();
}

// ==========================================================
// DISPOSE
// ==========================================================

@override
void dispose() {
_controller.dispose();
super.dispose();
}

// ==========================================================
// TRACK COMPLAINT
// ==========================================================

void _trackComplaint() {
Navigator.pushNamedAndRemoveUntil(
context,
AppRoutes.complaintStatus,
(route) => false,
arguments: widget.complaint,
);
}

// ==========================================================
// GO HOME
// ==========================================================

void _goHome() {
Navigator.pushNamedAndRemoveUntil(
context,
AppRoutes.home,
(route) => false,
);
}

// ==========================================================
// BUILD
// ==========================================================

@override
Widget build(BuildContext context) {
final complaint = widget.complaint;

return Scaffold(
backgroundColor: Theme.of(context)
    .scaffoldBackgroundColor,

body: SafeArea(
child: Center(
child: SingleChildScrollView(
padding: const EdgeInsets.all(24),

child: Column(
children: [
const SizedBox(height: 30),

// ==================================================
// SUCCESS ICON
// ==================================================

ScaleTransition(
scale: _scaleAnimation,

child: Container(
width: 110,
height: 110,

decoration: BoxDecoration(
color: AppColors.primary
    .withValues(alpha: 0.08),
shape: BoxShape.circle,
),

child: Container(
margin:
const EdgeInsets.all(12),

decoration: BoxDecoration(
color:
AppColors.primary,
shape: BoxShape.circle,

boxShadow: [
BoxShadow(
color: AppColors.primary
    .withValues(
alpha: 0.20,
),
blurRadius: 24,
spreadRadius: 2,
),
],
),

child: const Icon(
Icons.check_rounded,
color: Colors.white,
size: 52,
),
),
),
),

const SizedBox(height: 30),

// ==================================================
// SUCCESS TEXT
// ==================================================

FadeTransition(
opacity: _fadeAnimation,

child: SlideTransition(
position: _slideAnimation,

child: Column(
children: [
const Text(
'Complaint Submitted!',
textAlign:
TextAlign.center,

style: TextStyle(
fontSize: 28,
fontWeight:
FontWeight.w900,
),
),

const SizedBox(height: 10),

Text(
'Your cyber crime complaint has '
'been submitted successfully.',
textAlign:
TextAlign.center,

style: TextStyle(
fontSize: 15,
height: 1.5,
color:
Colors.grey.shade600,
),
),
],
),
),
),

const SizedBox(height: 30),

// ==================================================
// COMPLAINT ID CARD
// ==================================================

FadeTransition(
opacity: _fadeAnimation,

child: Container(
width: double.infinity,
padding:
const EdgeInsets.all(20),

decoration: BoxDecoration(
color: AppColors.primary
    .withValues(
alpha: 0.05,
),

borderRadius:
BorderRadius.circular(20),

border: Border.all(
color:
AppColors.primary
    .withValues(
alpha: 0.15,
),
),
),

child: Column(
children: [
const Icon(
Icons
    .confirmation_number_outlined,
color:
AppColors.primary,
size: 30,
),

const SizedBox(height: 12),

Text(
'Complaint ID',
style: TextStyle(
fontSize: 12,
color:
Colors.grey.shade600,
fontWeight:
FontWeight.w600,
),
),

const SizedBox(height: 6),

Text(
complaint.id,
textAlign:
TextAlign.center,

style: const TextStyle(
fontSize: 21,
fontWeight:
FontWeight.w900,
letterSpacing: 0.5,
),
),

const SizedBox(height: 12),

Text(
'Please keep this ID safe. '
'You can use it to track '
'your complaint.',
textAlign:
TextAlign.center,

style: TextStyle(
fontSize: 12,
height: 1.4,
color:
Colors.grey.shade600,
),
),
],
),
),
),

const SizedBox(height: 22),

// ==================================================
// STATUS CARD
// ==================================================

FadeTransition(
opacity: _fadeAnimation,

child: Container(
width: double.infinity,
padding:
const EdgeInsets.all(18),

decoration: BoxDecoration(
color: Theme.of(context)
    .cardColor,

borderRadius:
BorderRadius.circular(18),

border: Border.all(
color:
Theme.of(context)
    .dividerColor
    .withValues(
alpha: 0.30,
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
color: AppColors.primary
    .withValues(
alpha: 0.10,
),

borderRadius:
BorderRadius
    .circular(
14,
),
),

child: const Icon(
Icons
    .pending_actions_outlined,
color:
AppColors.primary,
),
),

const SizedBox(width: 14),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,

children: [
Text(
'Current Status',
style: TextStyle(
fontSize: 12,
fontWeight:
FontWeight
    .w600,
color:
Theme.of(
context,
)
    .textTheme
    .bodySmall
    ?.color,
),
),

const SizedBox(height: 4),

Text(
complaint.status.label,

style: const TextStyle(
fontSize: 16,
fontWeight:
FontWeight
    .w800,
),
),

const SizedBox(height: 3),

Text(
complaint.status
    .description,

maxLines: 2,
overflow:
TextOverflow
    .ellipsis,

style: TextStyle(
fontSize: 11.5,
color:
Colors.grey
    .shade600,
),
),
],
),
),
],
),
),
),

const SizedBox(height: 30),

// ==================================================
// TRACK BUTTON
// ==================================================

SizedBox(
width: double.infinity,
height: 54,

child: ElevatedButton.icon(
onPressed:
_trackComplaint,

icon: const Icon(
Icons
    .track_changes_rounded,
),

label: const Text(
'Track Complaint',
style: TextStyle(
fontWeight:
FontWeight.w800,
),
),

style:
ElevatedButton.styleFrom(
backgroundColor:
AppColors.primary,
foregroundColor:
Colors.white,

shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(
15,
),
),
),
),
),

const SizedBox(height: 12),

// ==================================================
// HOME BUTTON
// ==================================================

SizedBox(
width: double.infinity,
height: 52,

child: OutlinedButton.icon(
onPressed: _goHome,

icon: const Icon(
Icons.home_outlined,
),

label: const Text(
'Back to Home',
style: TextStyle(
fontWeight:
FontWeight.w700,
),
),

style:
OutlinedButton.styleFrom(
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(
15,
),
),
),
),
),

const SizedBox(height: 25),

// ==================================================
// INFORMATION
// ==================================================

Text(
'You can view your complaint and '
'its status anytime from My Complaints.',

textAlign:
TextAlign.center,

style: TextStyle(
fontSize: 12,
height: 1.4,
color:
Colors.grey.shade500,
),
),

const SizedBox(height: 20),
],
),
),
),
),
);
}
}
