import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/complaint.dart';
import '../../../models/complaint_status.dart';

class ComplaintStatusScreen extends StatefulWidget {
final Complaint complaint;

const ComplaintStatusScreen({
super.key,
required this.complaint,
});

@override
State<ComplaintStatusScreen> createState() =>
_ComplaintStatusScreenState();
}

class _ComplaintStatusScreenState
extends State<ComplaintStatusScreen>
with SingleTickerProviderStateMixin {
late AnimationController _controller;

late Animation<double> _fadeAnimation;
late Animation<Offset> _slideAnimation;
late Animation<double> _scaleAnimation;

Complaint? _complaint;
bool _isLoading = true;
String? _errorMessage;

StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
_complaintSubscription;

// ==========================================================
// INIT
// ==========================================================

@override
void initState() {
super.initState();

_controller = AnimationController(
vsync: this,
duration: const Duration(
milliseconds: 800,
),
);

_fadeAnimation = CurvedAnimation(
parent: _controller,
curve: Curves.easeOut,
);

_slideAnimation = Tween<Offset>(
begin: const Offset(0, 0.08),
end: Offset.zero,
).animate(
CurvedAnimation(
parent: _controller,
curve: Curves.easeOutCubic,
),
);

_scaleAnimation = Tween<double>(
begin: 0.94,
end: 1.0,
).animate(
CurvedAnimation(
parent: _controller,
curve: Curves.easeOutBack,
),
);

_complaint = widget.complaint;

_controller.forward();

_listenToComplaint();
}

// ==========================================================
// FIRESTORE LIVE LISTENER
// ==========================================================

void _listenToComplaint() {
_complaintSubscription = FirebaseFirestore.instance
    .collection('complaints')
    .doc(widget.complaint.id)
    .snapshots()
    .listen(
(snapshot) {
if (!mounted) {
return;
}

if (!snapshot.exists) {
setState(() {
_isLoading = false;
_errorMessage = 'Complaint could not be found.';
});

return;
}

try {
final updatedComplaint =
Complaint.fromFirestore(snapshot);

setState(() {
_complaint = updatedComplaint;
_isLoading = false;
_errorMessage = null;
});
} catch (e) {
setState(() {
_isLoading = false;
_errorMessage =
'Unable to read complaint information.';
});
}
},
onError: (error) {
if (!mounted) {
return;
}

setState(() {
_isLoading = false;
_errorMessage =
'Unable to load complaint status.';
});
},
);
}

// ==========================================================
// DISPOSE
// ==========================================================

@override
void dispose() {
_complaintSubscription?.cancel();
_controller.dispose();

super.dispose();
}

// ==========================================================
// STATUS NAME
// ==========================================================

String _statusName(
ComplaintStatus status,
) {
return status.label;
}

// ==========================================================
// STATUS DESCRIPTION
// ==========================================================

String _statusDescription(
ComplaintStatus status,
) {
return status.description;
}

// ==========================================================
// BUILD
// ==========================================================

@override
Widget build(BuildContext context) {
final complaint = _complaint ?? widget.complaint;

return Scaffold(
backgroundColor: AppColors.background,

appBar: AppBar(
title: const Text(
'Track Complaint',
),
centerTitle: true,
elevation: 0,
backgroundColor: Colors.transparent,
foregroundColor: AppColors.textPrimary,
),

body: _isLoading
? const Center(
child: CircularProgressIndicator(),
)
    : _errorMessage != null
? _buildErrorState()
    : FadeTransition(
opacity: _fadeAnimation,
child: SlideTransition(
position: _slideAnimation,
child: ScaleTransition(
scale: _scaleAnimation,
child: SingleChildScrollView(
physics:
const BouncingScrollPhysics(),
padding:
const EdgeInsets.fromLTRB(
20,
10,
20,
32,
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
_buildComplaintHeader(
complaint,
),

const SizedBox(
height: 20,
),

_buildCurrentStatus(
complaint,
),

const SizedBox(
height: 20,
),

_buildProgressTimeline(
complaint,
),

const SizedBox(
height: 20,
),

_buildInformationCard(
complaint,
),

const SizedBox(
height: 20,
),

_buildHelpCard(),
],
),
),
),
),
),
);
}

// ==========================================================
// ERROR STATE
// ==========================================================

Widget _buildErrorState() {
return Center(
child: Padding(
padding: const EdgeInsets.all(24),
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
Container(
width: 80,
height: 80,
decoration: BoxDecoration(
color: Colors.red.withValues(
alpha: 0.08,
),
shape: BoxShape.circle,
),
child: const Icon(
Icons.error_outline_rounded,
color: Colors.red,
size: 40,
),
),

const SizedBox(height: 20),

Text(
_errorMessage ??
'Something went wrong.',
textAlign: TextAlign.center,
style: const TextStyle(
fontSize: 16,
fontWeight: FontWeight.w700,
),
),

const SizedBox(height: 18),

ElevatedButton.icon(
onPressed: () {
setState(() {
_isLoading = true;
_errorMessage = null;
});

_complaintSubscription?.cancel();

_listenToComplaint();
},
icon: const Icon(
Icons.refresh_rounded,
),
label: const Text(
'Try Again',
),
),
],
),
),
);
}

// ==========================================================
// COMPLAINT HEADER
// ==========================================================

Widget _buildComplaintHeader(
Complaint complaint,
) {
return Container(
width: double.infinity,
padding: const EdgeInsets.all(22),
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
borderRadius:
BorderRadius.circular(24),
boxShadow: [
BoxShadow(
color: AppColors.primary.withValues(
alpha: 0.18,
),
blurRadius: 20,
offset: const Offset(0, 9),
),
],
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
children: [
Container(
height: 52,
width: 52,
decoration: BoxDecoration(
color: Colors.white.withValues(
alpha: 0.14,
),
borderRadius:
BorderRadius.circular(16),
),
child: const Icon(
Icons.shield_outlined,
color: Colors.white,
size: 29,
),
),

const Spacer(),

_buildIdBadge(
complaint.id,
),
],
),

const SizedBox(height: 20),

Text(
complaint.title,
maxLines: 2,
overflow: TextOverflow.ellipsis,
style: const TextStyle(
color: Colors.white,
fontSize: 20,
fontWeight: FontWeight.w700,
),
),

const SizedBox(height: 7),

Text(
'Complaint tracking',
style: TextStyle(
color: Colors.white.withValues(
alpha: 0.72,
),
fontSize: 13,
),
),
],
),
);
}

// ==========================================================
// ID BADGE
// ==========================================================

Widget _buildIdBadge(
String id,
) {
return Container(
padding: const EdgeInsets.symmetric(
horizontal: 11,
vertical: 7,
),
decoration: BoxDecoration(
color: Colors.white.withValues(
alpha: 0.12,
),
borderRadius:
BorderRadius.circular(10),
border: Border.all(
color: Colors.white.withValues(
alpha: 0.20,
),
),
),
child: Text(
id,
style: const TextStyle(
color: Colors.white,
fontSize: 11,
fontWeight: FontWeight.w700,
),
),
);
}

// ==========================================================
// CURRENT STATUS
// ==========================================================

Widget _buildCurrentStatus(
Complaint complaint,
) {
final color =
_statusColor(complaint.status);

return Container(
width: double.infinity,
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: AppColors.surface,
borderRadius:
BorderRadius.circular(20),
border: Border.all(
color: AppColors.border,
),
boxShadow: [
BoxShadow(
color: Colors.black.withValues(
alpha: 0.035,
),
blurRadius: 14,
offset: const Offset(0, 5),
),
],
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
_sectionTitle(
Icons.radio_button_checked_rounded,
'Current Status',
),

const SizedBox(height: 18),

Row(
children: [
TweenAnimationBuilder<double>(
tween: Tween(
begin: 0.75,
end: 1.0,
),
duration:
const Duration(
milliseconds: 700,
),
curve: Curves.easeOutBack,
builder: (
context,
value,
child,
) {
return Transform.scale(
scale: value,
child: Container(
height: 62,
width: 62,
decoration:
BoxDecoration(
color:
color.withValues(
alpha: 0.10,
),
shape:
BoxShape.circle,
),
child: Icon(
_statusIcon(
complaint.status,
),
color: color,
size: 30,
),
),
);
},
),

const SizedBox(width: 15),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
_statusName(
complaint.status,
),
style: TextStyle(
color: color,
fontSize: 18,
fontWeight:
FontWeight.w800,
),
),

const SizedBox(
height: 6,
),

Text(
_statusDescription(
complaint.status,
),
style: TextStyle(
color:
AppColors
    .textSecondary,
fontSize: 13,
height: 1.4,
),
),
],
),
),
],
),
],
),
);
}

// ==========================================================
// TIMELINE
// ==========================================================

Widget _buildProgressTimeline(
Complaint complaint,
) {
final statuses = [
ComplaintStatus.submitted,
ComplaintStatus.underReview,
ComplaintStatus.inProgress,
ComplaintStatus.resolved,
ComplaintStatus.closed,
];

final currentIndex =
_statusIndex(complaint.status);

return Container(
width: double.infinity,
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: AppColors.surface,
borderRadius:
BorderRadius.circular(20),
border: Border.all(
color: AppColors.border,
),
boxShadow: [
BoxShadow(
color: Colors.black.withValues(
alpha: 0.035,
),
blurRadius: 14,
offset: const Offset(0, 5),
),
],
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
_sectionTitle(
Icons.timeline_rounded,
'Complaint Progress',
),

const SizedBox(height: 24),

...List.generate(
statuses.length,
(index) {
final status =
statuses[index];

return _AnimatedTimelineItem(
index: index,
status: status,
isCompleted:
index <= currentIndex,
isCurrent:
index == currentIndex,
isLast:
index ==
statuses.length - 1,
statusName:
_statusName(status),
statusDescription:
_statusDescription(
status,
),
);
},
),
],
),
);
}

// ==========================================================
// INFORMATION CARD
// ==========================================================

Widget _buildInformationCard(
Complaint complaint,
) {
return Container(
width: double.infinity,
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: AppColors.surface,
borderRadius:
BorderRadius.circular(20),
border: Border.all(
color: AppColors.border,
),
boxShadow: [
BoxShadow(
color: Colors.black.withValues(
alpha: 0.035,
),
blurRadius: 14,
offset: const Offset(0, 5),
),
],
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
_sectionTitle(
Icons.info_outline_rounded,
'Complaint Information',
),

const SizedBox(height: 18),

_infoRow(
Icons.category_outlined,
'Category',
complaint.category,
),

_divider(),

_infoRow(
Icons.public_outlined,
'Platform',
complaint.platform,
),

_divider(),

_infoRow(
Icons.calendar_today_outlined,
'Incident Date',
_formatDate(
complaint.date,
),
),

_divider(),

_infoRow(
Icons.location_on_outlined,
'Location',
complaint.location.isEmpty
? 'Not provided'
    : complaint.location,
),

_divider(),

_infoRow(
Icons.access_time_rounded,
'Submitted',
_formatDate(
complaint.submittedDate,
),
),
],
),
);
}

// ==========================================================
// HELP CARD
// ==========================================================

Widget _buildHelpCard() {
return Container(
width: double.infinity,
padding: const EdgeInsets.all(18),
decoration: BoxDecoration(
color: AppColors.primary
    .withValues(
alpha: 0.06,
),
borderRadius:
BorderRadius.circular(18),
border: Border.all(
color: AppColors.primary
    .withValues(
alpha: 0.12,
),
),
),
child: Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Icon(
Icons.security_rounded,
color: AppColors.primary,
size: 25,
),

const SizedBox(width: 13),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
'Keep your complaint ID safe',
style: TextStyle(
color:
AppColors.textPrimary,
fontSize: 14,
fontWeight:
FontWeight.w700,
),
),

const SizedBox(height: 6),

Text(
'You can use your complaint ID to identify '
'your report when checking its status.',
style: TextStyle(
color:
AppColors.textSecondary,
fontSize: 12.5,
height: 1.45,
),
),
],
),
),
],
),
);
}

// ==========================================================
// SECTION TITLE
// ==========================================================

Widget _sectionTitle(
IconData icon,
String title,
) {
return Row(
children: [
Icon(
icon,
color: AppColors.primary,
size: 21,
),

const SizedBox(width: 9),

Text(
title,
style: TextStyle(
color:
AppColors.textPrimary,
fontSize: 16,
fontWeight:
FontWeight.w700,
),
),
],
);
}

// ==========================================================
// INFORMATION ROW
// ==========================================================

Widget _infoRow(
IconData icon,
String title,
String value,
) {
return Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Icon(
icon,
color:
AppColors.textSecondary,
size: 19,
),

const SizedBox(width: 12),

Expanded(
child: Text(
title,
style: TextStyle(
color:
AppColors.textSecondary,
fontSize: 13,
),
),
),

const SizedBox(width: 10),

Flexible(
child: Text(
value,
textAlign:
TextAlign.right,
style: TextStyle(
color:
AppColors.textPrimary,
fontSize: 13,
fontWeight:
FontWeight.w600,
),
),
),
],
);
}

// ==========================================================
// DIVIDER
// ==========================================================

Widget _divider() {
return Padding(
padding:
const EdgeInsets.symmetric(
vertical: 13,
),
child: Divider(
height: 1,
color: AppColors.border,
),
);
}

// ==========================================================
// STATUS INDEX
// ==========================================================

int _statusIndex(
ComplaintStatus status,
) {
switch (status) {
case ComplaintStatus.submitted:
return 0;

case ComplaintStatus.underReview:
return 1;

case ComplaintStatus.inProgress:
return 2;

case ComplaintStatus.resolved:
return 3;

case ComplaintStatus.closed:
return 4;
}
}

// ==========================================================
// STATUS COLOR
// ==========================================================

Color _statusColor(
ComplaintStatus status,
) {
switch (status) {
case ComplaintStatus.submitted:
return Colors.blue;

case ComplaintStatus.underReview:
return Colors.orange;

case ComplaintStatus.inProgress:
return Colors.deepPurple;

case ComplaintStatus.resolved:
return Colors.green;

case ComplaintStatus.closed:
return Colors.grey;
}
}

// ==========================================================
// STATUS ICON
// ==========================================================

IconData _statusIcon(
ComplaintStatus status,
) {
switch (status) {
case ComplaintStatus.submitted:
return Icons.send_outlined;

case ComplaintStatus.underReview:
return Icons.visibility_outlined;

case ComplaintStatus.inProgress:
return Icons.manage_search_rounded;

case ComplaintStatus.resolved:
return Icons.check_circle_outline_rounded;

case ComplaintStatus.closed:
return Icons.lock_outline_rounded;
}
}

// ==========================================================
// DATE FORMAT
// ==========================================================

String _formatDate(
DateTime date,
) {
return '${date.day.toString().padLeft(2, '0')}/'
'${date.month.toString().padLeft(2, '0')}/'
'${date.year}';
}
}

// ============================================================
// ANIMATED TIMELINE ITEM
// ============================================================

class _AnimatedTimelineItem
extends StatefulWidget {
final int index;
final ComplaintStatus status;
final bool isCompleted;
final bool isCurrent;
final bool isLast;

final String statusName;
final String statusDescription;

const _AnimatedTimelineItem({
required this.index,
required this.status,
required this.isCompleted,
required this.isCurrent,
required this.isLast,
required this.statusName,
required this.statusDescription,
});

@override
State<_AnimatedTimelineItem> createState() =>
_AnimatedTimelineItemState();
}

class _AnimatedTimelineItemState
extends State<_AnimatedTimelineItem>
with SingleTickerProviderStateMixin {
late AnimationController _controller;

late Animation<double> _fade;
late Animation<Offset> _slide;

@override
void initState() {
super.initState();

_controller =
AnimationController(
vsync: this,
duration:
const Duration(
milliseconds: 450,
),
);

_fade = CurvedAnimation(
parent: _controller,
curve: Curves.easeOut,
);

_slide = Tween<Offset>(
begin: const Offset(0.06, 0),
end: Offset.zero,
).animate(
CurvedAnimation(
parent: _controller,
curve: Curves.easeOutCubic,
),
);

Future.delayed(
Duration(
milliseconds:
120 + (widget.index * 90),
),
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

// ==========================================================
// BUILD TIMELINE ITEM
// ==========================================================

@override
Widget build(
BuildContext context,
) {
final color = widget.isCompleted
? AppColors.primary
    : AppColors.textSecondary
    .withValues(
alpha: 0.30,
);

return FadeTransition(
opacity: _fade,
child: SlideTransition(
position: _slide,
child: Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
// ==================================================
// TIMELINE ICON + LINE
// ==================================================

Column(
children: [
AnimatedContainer(
duration:
const Duration(
milliseconds: 350,
),
height: 38,
width: 38,
decoration:
BoxDecoration(
color:
color.withValues(
alpha: 0.10,
),
shape:
BoxShape.circle,
border: Border.all(
color: color,
width:
widget.isCurrent
? 2
    : 1.3,
),
),
child: Icon(
widget.isCompleted
? Icons.check_rounded
    : Icons.circle_outlined,
color: color,
size: 19,
),
),

if (!widget.isLast)
AnimatedContainer(
duration:
const Duration(
milliseconds: 400,
),
height: 48,
width: 2,
color:
color.withValues(
alpha: 0.30,
),
),
],
),

const SizedBox(width: 14),

// ==================================================
// STATUS INFORMATION
// ==================================================

Expanded(
child: Padding(
padding:
const EdgeInsets.only(
top: 3,
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
widget.statusName,
style:
TextStyle(
color: widget
    .isCurrent
? AppColors
    .primary
    : AppColors
    .textPrimary,
fontSize: 15,
fontWeight: widget
    .isCurrent
? FontWeight
    .w800
    : FontWeight
    .w600,
),
),
),

if (widget.isCurrent)
Container(
padding:
const EdgeInsets
    .symmetric(
horizontal: 8,
vertical: 4,
),
decoration:
BoxDecoration(
color: AppColors
    .primary
    .withValues(
alpha: 0.08,
),
borderRadius:
BorderRadius
    .circular(
8,
),
),
child: Text(
'CURRENT',
style:
TextStyle(
color: AppColors
    .primary,
fontSize: 9,
fontWeight:
FontWeight
    .w800,
),
),
),
],
),

const SizedBox(height: 5),

Text(
widget.statusDescription,
style: TextStyle(
color: AppColors
    .textSecondary,
fontSize: 12.5,
height: 1.4,
),
),

const SizedBox(height: 17),
],
),
),
),
],
),
),
);
}
}
