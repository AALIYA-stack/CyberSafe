import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/complaint.dart';
import '../../../models/complaint_status.dart';
import '../../../widgets/status_badge.dart';

class ComplaintDetailScreen extends StatelessWidget {
final Complaint complaint;

const ComplaintDetailScreen({
super.key,
required this.complaint,
});

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: AppColors.background,
appBar: AppBar(
title: const Text(
'Complaint Details',
style: TextStyle(
fontWeight: FontWeight.w700,
),
),
centerTitle: true,
backgroundColor: AppColors.primary,
foregroundColor: Colors.white,
elevation: 0,
),
body: SafeArea(
child: SingleChildScrollView(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
_buildHeaderCard(),

const SizedBox(height: 16),

_buildSectionCard(
title: 'Complaint Information',
icon: Icons.description_outlined,
children: [
_buildInfoRow(
icon: Icons.confirmation_number_outlined,
label: 'Complaint ID',
value: _value(complaint.id),
),
_buildInfoRow(
icon: Icons.title_outlined,
label: 'Title',
value: _value(complaint.title),
),
_buildInfoRow(
icon: Icons.category_outlined,
label: 'Category',
value: _formatValue(complaint.category),
),
_buildInfoRow(
icon: Icons.devices_outlined,
label: 'Platform',
value: _value(complaint.platform),
),
_buildInfoRow(
icon: Icons.location_on_outlined,
label: 'Location',
value: _value(complaint.location),
),
],
),

const SizedBox(height: 16),

_buildSectionCard(
title: 'Incident Details',
icon: Icons.report_problem_outlined,
children: [
_buildInfoRow(
icon: Icons.calendar_today_outlined,
label: 'Incident Date',
value: _formatDate(complaint.date),
),
_buildDescription(
title: 'Description',
value: _value(complaint.description),
),
],
),

const SizedBox(height: 16),

_buildSectionCard(
title: 'Personal Information',
icon: Icons.person_outline,
children: [
_buildInfoRow(
icon: Icons.person_outline,
label: 'Name',
value: _value(complaint.user),
),
_buildInfoRow(
icon: Icons.email_outlined,
label: 'Email',
value: _value(complaint.userEmail),
),
_buildInfoRow(
icon: Icons.phone_outlined,
label: 'Phone',
value: _value(complaint.phone),
),
],
),

const SizedBox(height: 16),

_buildSectionCard(
title: 'Suspect Information',
icon: Icons.person_search_outlined,
children: [
_buildInfoRow(
icon: Icons.person_search_outlined,
label: 'Suspect',
value: _value(complaint.suspect),
),
_buildInfoRow(
icon: Icons.contact_phone_outlined,
label: 'Suspect Contact',
value: _value(complaint.suspectContact),
),
],
),

const SizedBox(height: 16),

_buildEvidenceCard(),

const SizedBox(height: 16),

_buildSectionCard(
title: 'Submission Information',
icon: Icons.access_time_outlined,
children: [
_buildInfoRow(
icon: Icons.calendar_month_outlined,
label: 'Submitted Date',
value: _formatDateTime(
complaint.submittedDate,
),
),
_buildInfoRow(
icon: Icons.info_outline,
label: 'Current Status',
value: _formatStatus(
complaint.status,
),
),
],
),

const SizedBox(height: 16),

_buildTimelineCard(),

const SizedBox(height: 24),
],
),
),
),
);
}

// ============================================================
// HEADER
// ============================================================

Widget _buildHeaderCard() {
return Container(
width: double.infinity,
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
gradient: LinearGradient(
colors: [
AppColors.primary,
AppColors.secondary,
],
begin: Alignment.topLeft,
end: Alignment.bottomRight,
),
borderRadius: BorderRadius.circular(18),
boxShadow: [
BoxShadow(
color: AppColors.primary.withOpacity(0.18),
blurRadius: 14,
offset: const Offset(0, 6),
),
],
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
Container(
width: 48,
height: 48,
decoration: BoxDecoration(
color: Colors.white.withOpacity(0.16),
borderRadius: BorderRadius.circular(14),
),
child: const Icon(
Icons.assignment_outlined,
color: Colors.white,
size: 26,
),
),
const SizedBox(width: 14),
const Expanded(
child: Text(
'Complaint Status',
style: TextStyle(
color: Colors.white,
fontSize: 19,
fontWeight: FontWeight.w700,
),
),
),
],
),

const SizedBox(height: 18),

Text(
_value(complaint.title),
style: const TextStyle(
color: Colors.white,
fontSize: 20,
fontWeight: FontWeight.w800,
),
),

const SizedBox(height: 8),

Text(
'ID: ${_value(complaint.id)}',
style: TextStyle(
color: Colors.white.withOpacity(0.82),
fontSize: 13,
fontWeight: FontWeight.w500,
),
),

const SizedBox(height: 16),

StatusBadge(
status: complaint.status,
),
],
),
);
}

// ============================================================
// SECTION CARD
// ============================================================

Widget _buildSectionCard({
required String title,
required IconData icon,
required List<Widget> children,
}) {
return Container(
width: double.infinity,
padding: const EdgeInsets.all(18),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(16),
border: Border.all(
color: AppColors.border,
),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.04),
blurRadius: 10,
offset: const Offset(0, 4),
),
],
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
Container(
width: 38,
height: 38,
decoration: BoxDecoration(
color: AppColors.primary.withOpacity(0.08),
borderRadius: BorderRadius.circular(10),
),
child: Icon(
icon,
color: AppColors.primary,
size: 21,
),
),
const SizedBox(width: 11),
Expanded(
child: Text(
title,
style: TextStyle(
color: AppColors.primary,
fontSize: 17,
fontWeight: FontWeight.w700,
),
),
),
],
),

const SizedBox(height: 16),

...children,
],
),
);
}

// ============================================================
// INFO ROW
// ============================================================

Widget _buildInfoRow({
required IconData icon,
required String label,
required String value,
}) {
return Padding(
padding: const EdgeInsets.only(bottom: 15),
child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Icon(
icon,
size: 20,
color: AppColors.secondary,
),
const SizedBox(width: 11),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
label,
style: TextStyle(
color: Colors.grey.shade600,
fontSize: 12,
fontWeight: FontWeight.w500,
),
),
const SizedBox(height: 4),
Text(
value,
style: const TextStyle(
color: Colors.black87,
fontSize: 14,
fontWeight: FontWeight.w600,
),
),
],
),
),
],
),
);
}

// ============================================================
// DESCRIPTION
// ============================================================

Widget _buildDescription({
required String title,
required String value,
}) {
return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
title,
style: TextStyle(
color: Colors.grey.shade600,
fontSize: 12,
fontWeight: FontWeight.w500,
),
),
const SizedBox(height: 7),
Container(
width: double.infinity,
padding: const EdgeInsets.all(13),
decoration: BoxDecoration(
color: AppColors.background,
borderRadius: BorderRadius.circular(10),
),
child: Text(
value,
style: const TextStyle(
color: Colors.black87,
fontSize: 14,
height: 1.5,
),
),
),
],
);
}

// ============================================================
// EVIDENCE
// ============================================================

Widget _buildEvidenceCard() {
final hasSimpleEvidence = complaint.evidence.isNotEmpty;
final hasDetailedEvidence = complaint.evidenceFiles.isNotEmpty;

if (!hasSimpleEvidence && !hasDetailedEvidence) {
return _buildSectionCard(
title: 'Evidence',
icon: Icons.attach_file_outlined,
children: [
Row(
children: [
Icon(
Icons.info_outline,
color: Colors.grey.shade500,
size: 20,
),
const SizedBox(width: 10),
Expanded(
child: Text(
'No evidence was attached to this complaint.',
style: TextStyle(
color: Colors.grey.shade600,
fontSize: 13,
),
),
),
],
),
],
);
}

return Container(
width: double.infinity,
padding: const EdgeInsets.all(18),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(16),
border: Border.all(
color: AppColors.border,
),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.04),
blurRadius: 10,
offset: const Offset(0, 4),
),
],
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
Container(
width: 38,
height: 38,
decoration: BoxDecoration(
color: AppColors.primary.withOpacity(0.08),
borderRadius: BorderRadius.circular(10),
),
child: Icon(
Icons.attach_file_outlined,
color: AppColors.primary,
size: 21,
),
),
const SizedBox(width: 11),
Text(
'Evidence',
style: TextStyle(
color: AppColors.primary,
fontSize: 17,
fontWeight: FontWeight.w700,
),
),
],
),

const SizedBox(height: 16),

if (hasSimpleEvidence)
...complaint.evidence.map(
(fileName) => _buildEvidenceItem(
name: fileName,
type: 'Evidence file',
),
),

if (hasDetailedEvidence)
...complaint.evidenceFiles.map(
(file) => _buildEvidenceItem(
name: file['name']?.toString() ?? 'Unknown file',
type: file['type']?.toString() ?? 'File',
),
),
],
),
);
}

Widget _buildEvidenceItem({
required String name,
required String type,
}) {
final isImage = type.toLowerCase().startsWith('image');

return Container(
width: double.infinity,
margin: const EdgeInsets.only(bottom: 10),
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(
color: AppColors.background,
borderRadius: BorderRadius.circular(12),
),
child: Row(
children: [
Container(
width: 40,
height: 40,
decoration: BoxDecoration(
color: AppColors.primary.withOpacity(0.08),
borderRadius: BorderRadius.circular(10),
),
child: Icon(
isImage
? Icons.image_outlined
    : Icons.insert_drive_file_outlined,
color: AppColors.primary,
size: 21,
),
),
const SizedBox(width: 11),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
name.isEmpty ? 'Unnamed file' : name,
maxLines: 2,
overflow: TextOverflow.ellipsis,
style: const TextStyle(
fontSize: 13,
fontWeight: FontWeight.w600,
color: Colors.black87,
),
),
const SizedBox(height: 3),
Text(
type.isEmpty ? 'File' : type,
style: TextStyle(
fontSize: 11,
color: Colors.grey.shade600,
),
),
],
),
),
],
),
);
}

// ============================================================
// TIMELINE
// ============================================================

Widget _buildTimelineCard() {
return Container(
width: double.infinity,
padding: const EdgeInsets.all(18),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(16),
border: Border.all(
color: AppColors.border,
),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.04),
blurRadius: 10,
offset: const Offset(0, 4),
),
],
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
Icon(
Icons.timeline_outlined,
color: AppColors.primary,
),
const SizedBox(width: 10),
Text(
'Complaint Progress',
style: TextStyle(
color: AppColors.primary,
fontSize: 17,
fontWeight: FontWeight.w700,
),
),
],
),

const SizedBox(height: 20),

_timelineItem(
title: 'Complaint Submitted',
subtitle:
'Your complaint has been submitted successfully.',
icon: Icons.check_circle,
active: true,
isLast: false,
),

_timelineItem(
title: 'Under Review',
subtitle:
'Your complaint is being reviewed by the administrator.',
icon: Icons.search,
active: _isAtLeastUnderReview(),
isLast: false,
),

_timelineItem(
title: 'Resolved',
subtitle:
'The complaint has been resolved.',
icon: Icons.task_alt,
active: _isResolved(),
isLast: true,
),
],
),
);
}

Widget _timelineItem({
required String title,
required String subtitle,
required IconData icon,
required bool active,
required bool isLast,
}) {
return Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Column(
children: [
Container(
width: 34,
height: 34,
decoration: BoxDecoration(
color: active
? AppColors.primary.withOpacity(0.12)
    : Colors.grey.withOpacity(0.10),
shape: BoxShape.circle,
),
child: Icon(
icon,
size: 18,
color: active
? AppColors.primary
    : Colors.grey.shade400,
),
),

if (!isLast)
Container(
width: 2,
height: 48,
color: active
? AppColors.primary.withOpacity(0.25)
    : Colors.grey.withOpacity(0.18),
),
],
),

const SizedBox(width: 13),

Expanded(
child: Padding(
padding: const EdgeInsets.only(bottom: 20),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
title,
style: TextStyle(
color: active
? Colors.black87
    : Colors.grey.shade500,
fontSize: 14,
fontWeight: FontWeight.w700,
),
),
const SizedBox(height: 4),
Text(
subtitle,
style: TextStyle(
color: active
? Colors.grey.shade600
    : Colors.grey.shade400,
fontSize: 12,
height: 1.4,
),
),
],
),
),
),
],
);
}

// ============================================================
// STATUS HELPERS
// ============================================================

bool _isAtLeastUnderReview() {
final status =
complaint.status.firestoreValue.toLowerCase();

return status == 'under_review' ||
status == 'underreview' ||
status == 'resolved';
}

bool _isResolved() {
final status =
complaint.status.firestoreValue.toLowerCase();

return status == 'resolved';
}

String _formatStatus(ComplaintStatus status) {
final value = status.firestoreValue;

if (value.isEmpty) {
return 'Unknown';
}

return value
    .replaceAll('_', ' ')
    .replaceAll('-', ' ')
    .split(' ')
    .map(
(word) => word.isEmpty
? word
    : '${word[0].toUpperCase()}${word.substring(1)}',
)
    .join(' ');
}

// ============================================================
// VALUE HELPERS
// ============================================================

String _value(dynamic value) {
if (value == null) {
return 'Not provided';
}

final text = value.toString().trim();

if (text.isEmpty || text == 'null') {
return 'Not provided';
}

return text;
}

String _formatValue(dynamic value) {
final text = _value(value);

if (text == 'Not provided') {
return text;
}

return text
    .replaceAll('_', ' ')
    .replaceAll('-', ' ')
    .split(' ')
    .map(
(word) => word.isEmpty
? word
    : '${word[0].toUpperCase()}${word.substring(1)}',
)
    .join(' ');
}

String _formatDate(DateTime date) {
final day = date.day.toString().padLeft(2, '0');
final month = date.month.toString().padLeft(2, '0');

return '$day/$month/${date.year}';
}

String _formatDateTime(DateTime date) {
final day = date.day.toString().padLeft(2, '0');
final month = date.month.toString().padLeft(2, '0');

final hour = date.hour % 12 == 0
? 12
    : date.hour % 12;

final minute =
date.minute.toString().padLeft(2, '0');

final period = date.hour >= 12 ? 'PM' : 'AM';

return '$day/$month/${date.year} • '
'$hour:$minute $period';
}
}

