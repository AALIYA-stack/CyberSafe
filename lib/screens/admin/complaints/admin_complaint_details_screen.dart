import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/complaint.dart';
import '../../../models/complaint_status.dart';
import '../../../services/complaint_services.dart';

class AdminComplaintDetailsScreen extends StatefulWidget {
final Complaint complaint;

const AdminComplaintDetailsScreen({
super.key,
required this.complaint,
});

@override
State<AdminComplaintDetailsScreen> createState() =>
_AdminComplaintDetailsScreenState();
}

class _AdminComplaintDetailsScreenState
extends State<AdminComplaintDetailsScreen> {
final ComplaintService _complaintService =
ComplaintService.instance;

late Complaint _complaint;

bool _isLoading = false;
bool _isDeleting = false;

@override
void initState() {
super.initState();

_complaint = widget.complaint;

_loadLatestComplaint();
}

// ==========================================================
// LOAD LATEST COMPLAINT
// ==========================================================

Future<void> _loadLatestComplaint() async {
try {
final latest =
await _complaintService.getComplaint(
_complaint.id,
);

if (!mounted) {
return;
}

if (latest != null) {
setState(() {
_complaint = latest;
});
}
} catch (e) {
debugPrint(
'LOAD COMPLAINT ERROR: $e',
);
}
}

// ==========================================================
// STATUS UPDATE
// ==========================================================

Future<void> _updateStatus(
ComplaintStatus status,
) async {
if (_isLoading) {
return;
}

if (_complaint.status == status) {
_showMessage(
'Complaint is already ${status.displayName}.',
);
return;
}

setState(() {
_isLoading = true;
});

try {
await _complaintService
    .updateComplaintStatus(
complaintId: _complaint.id,
status: status,
);

if (!mounted) {
return;
}

setState(() {
_complaint = _complaint.copyWith(
status: status,
);

_isLoading = false;
});

_showMessage(
'Complaint status updated to ${status.displayName}.',
);
} catch (e) {
if (!mounted) {
return;
}

setState(() {
_isLoading = false;
});

_showMessage(
'Unable to update complaint status.',
isError: true,
);

debugPrint(
'UPDATE STATUS ERROR: $e',
);
}
}

// ==========================================================
// DELETE COMPLAINT
// ==========================================================

Future<void> _deleteComplaint() async {
if (_isDeleting) {
return;
}

final confirmed =
await showDialog<bool>(
context: context,
builder: (context) {
return AlertDialog(
title: const Text(
'Delete Complaint',
),
content: const Text(
'Are you sure you want to delete this complaint? '
'This action cannot be undone.',
),
actions: [
TextButton(
onPressed: () {
Navigator.pop(
context,
false,
);
},
child: const Text(
'Cancel',
),
),
FilledButton(
onPressed: () {
Navigator.pop(
context,
true,
);
},
style:
FilledButton.styleFrom(
backgroundColor:
Colors.red,
),
child: const Text(
'Delete',
),
),
],
);
},
);

if (confirmed != true) {
return;
}

setState(() {
_isDeleting = true;
});

try {
await _complaintService
    .deleteComplaint(
_complaint.id,
);

if (!mounted) {
return;
}

setState(() {
_isDeleting = false;
});

_showMessage(
'Complaint deleted successfully.',
);

Navigator.pop(
context,
true,
);
} catch (e) {
if (!mounted) {
return;
}

setState(() {
_isDeleting = false;
});

_showMessage(
'Unable to delete complaint.',
isError: true,
);

debugPrint(
'DELETE COMPLAINT ERROR: $e',
);
}
}

// ==========================================================
// BASE64 → BYTES
// ==========================================================

Uint8List? _decodeBase64Image(
String source,
) {
try {
var value = source.trim();

if (value.isEmpty) {
return null;
}

if (value.startsWith('data:image/')) {
final commaIndex =
value.indexOf(',');

if (commaIndex == -1) {
return null;
}

value = value.substring(
commaIndex + 1,
);
}

value = value.trim();

if (value.isEmpty) {
return null;
}

return base64Decode(value);
} catch (e) {
debugPrint(
'BASE64 DECODE ERROR: $e',
);

return null;
}
}

// ==========================================================
// CHECK IMAGE TYPE
// ==========================================================

bool _isImageType(
String type,
String name,
) {
final cleanType =
type.trim().toLowerCase();

final cleanName =
name.trim().toLowerCase();

if (cleanType.startsWith('image/')) {
return true;
}

return cleanName.endsWith('.jpg') ||
cleanName.endsWith('.jpeg') ||
cleanName.endsWith('.png') ||
cleanName.endsWith('.webp') ||
cleanName.endsWith('.gif');
}

// ==========================================================
// OPEN FULL SCREEN IMAGE
// ==========================================================

Future<void> _openFullScreenImage(
Uint8List bytes,
String title,
) async {
if (!mounted) {
return;
}

await Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
_FullScreenEvidenceImage(
imageBytes: bytes,
title: title,
),
),
);
}

// ==========================================================
// GET FILE NAME
// ==========================================================

String _getFileName(
Map<String, dynamic> file,
int index,
) {
final name =
file['name']
    ?.toString()
    .trim() ??
'';

if (name.isNotEmpty) {
return name;
}

return 'Evidence ${index + 1}';
}

// ==========================================================
// SHOW MESSAGE
// ==========================================================

void _showMessage(
String message, {
bool isError = false,
}) {
if (!mounted) {
return;
}

ScaffoldMessenger.of(context)
..hideCurrentSnackBar()
..showSnackBar(
SnackBar(
content: Text(message),
backgroundColor:
isError ? Colors.red : null,
behavior:
SnackBarBehavior.floating,
margin:
const EdgeInsets.all(16),
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(14),
),
),
);
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
return Icons.rate_review_outlined;

case ComplaintStatus.inProgress:
return Icons.sync_outlined;

case ComplaintStatus.resolved:
return Icons.check_circle_outline;

case ComplaintStatus.closed:
return Icons.lock_outline;
}
}

// ==========================================================
// BUILD
// ==========================================================

@override
Widget build(
BuildContext context,
) {
return Scaffold(
backgroundColor:
Colors.grey.shade50,
appBar: AppBar(
title: const Text(
'Complaint Details',
),
centerTitle: false,
actions: [
IconButton(
tooltip:
'Delete Complaint',
onPressed: _isDeleting
? null
    : _deleteComplaint,
icon: const Icon(
Icons.delete_outline,
),
),
],
),
body: RefreshIndicator(
onRefresh:
_loadLatestComplaint,
child:
SingleChildScrollView(
physics:
const AlwaysScrollableScrollPhysics(),
padding:
const EdgeInsets.fromLTRB(
16,
16,
16,
120,
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
_buildComplaintHeader(),

const SizedBox(
height: 18,
),

_buildStatusSection(),

const SizedBox(
height: 18,
),

_buildTimeline(),

const SizedBox(
height: 18,
),

_buildUserInformation(),

const SizedBox(
height: 18,
),

_buildIncidentInformation(),

const SizedBox(
height: 18,
),

_buildDescription(),

const SizedBox(
height: 18,
),

_buildEvidence(),

const SizedBox(
height: 18,
),

_buildSubmissionInformation(),
],
),
),
),
bottomNavigationBar:
_buildBottomActions(),
);
}

// ==========================================================
// HEADER
// ==========================================================

Widget _buildComplaintHeader() {
return Container(
width: double.infinity,
padding:
const EdgeInsets.all(20),
decoration:
BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(20),
border: Border.all(
color: Colors.grey.shade200,
),
boxShadow: [
BoxShadow(
color:
Colors.black.withValues(
alpha: .04,
),
blurRadius: 12,
offset:
const Offset(0, 4),
),
],
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Container(
width: 52,
height: 52,
decoration:
BoxDecoration(
color:
AppColors.primary
    .withValues(
alpha: .10,
),
borderRadius:
BorderRadius.circular(
14,
),
),
child: Icon(
Icons
    .report_problem_outlined,
color:
AppColors.primary,
size: 28,
),
),
const SizedBox(
width: 14,
),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
_complaint.title
    .trim()
    .isEmpty
? 'Untitled Complaint'
    : _complaint.title,
style:
const TextStyle(
fontSize: 20,
fontWeight:
FontWeight.w700,
),
),
const SizedBox(
height: 6,
),
Text(
'Complaint ID: ${_complaint.id}',
style: TextStyle(
fontSize: 13,
color:
Colors.grey.shade600,
fontWeight:
FontWeight.w500,
),
),
],
),
),
],
),
const SizedBox(
height: 16,
),
_buildStatusChip(
_complaint.status,
),
],
),
);
}

// ==========================================================
// STATUS SECTION
// ==========================================================

Widget _buildStatusSection() {
return _sectionCard(
title: 'Complaint Status',
icon:
Icons.track_changes_outlined,
child: Column(
children: [
DropdownButtonFormField<
ComplaintStatus>(
value: _complaint.status,
decoration:
const InputDecoration(
labelText:
'Update Status',
border:
OutlineInputBorder(),
),
items:
ComplaintStatus.values
    .map(
(status) {
return DropdownMenuItem<
ComplaintStatus>(
value: status,
child: Text(
status.displayName,
),
);
},
).toList(),
onChanged: _isLoading
? null
    : (status) {
if (status != null) {
_updateStatus(
status,
);
}
},
),
if (_isLoading) ...[
const SizedBox(
height: 14,
),
const LinearProgressIndicator(),
],
],
),
);
}

// ==========================================================
// STATUS CHIP
// ==========================================================

Widget _buildStatusChip(
ComplaintStatus status,
) {
final color =
_statusColor(status);

return Container(
padding:
const EdgeInsets.symmetric(
horizontal: 12,
vertical: 8,
),
decoration:
BoxDecoration(
color:
color.withValues(
alpha: .10,
),
borderRadius:
BorderRadius.circular(30),
),
child: Row(
mainAxisSize:
MainAxisSize.min,
children: [
Icon(
_statusIcon(status),
size: 18,
color: color,
),
const SizedBox(
width: 7,
),
Text(
status.displayName,
style: TextStyle(
color: color,
fontWeight:
FontWeight.w700,
fontSize: 13,
),
),
],
),
);
}

// ==========================================================
// TIMELINE
// ==========================================================

Widget _buildTimeline() {
final statuses =
ComplaintStatus.values;

final currentIndex =
statuses.indexOf(
_complaint.status,
);

return _sectionCard(
title: 'Complaint Progress',
icon: Icons.timeline_outlined,
child: Column(
children:
List.generate(
statuses.length,
(index) {
final status =
statuses[index];

final completed =
index <= currentIndex;

final isLast =
index ==
statuses.length - 1;

final color = completed
? _statusColor(status)
    : Colors.grey.shade400;

return Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Column(
children: [
Container(
width: 34,
height: 34,
decoration:
BoxDecoration(
shape:
BoxShape.circle,
color: completed
? color
    : Colors.grey.shade200,
),
child: Icon(
completed
? Icons.check
    : _statusIcon(
status,
),
size: 18,
color: completed
? Colors.white
    : Colors.grey.shade500,
),
),
if (!isLast)
Container(
width: 2,
height: 36,
color:
index < currentIndex
? color
    : Colors.grey.shade300,
),
],
),
const SizedBox(
width: 14,
),
Expanded(
child: Padding(
padding:
const EdgeInsets.only(
top: 7,
),
child: Text(
status.displayName,
style: TextStyle(
fontWeight: completed
? FontWeight.w700
    : FontWeight.w500,
color: completed
? Colors.grey.shade900
    : Colors.grey.shade500,
),
),
),
),
],
);
},
),
),
);
}

// ==========================================================
// USER INFORMATION
// ==========================================================

Widget _buildUserInformation() {
return _sectionCard(
title: 'User Information',
icon: Icons.person_outline,
child: Column(
children: [
_infoRow(
icon: Icons.person_outline,
label: 'Name',
value: _complaint.user,
),
_infoRow(
icon: Icons.email_outlined,
label: 'Email',
value:
_complaint.userEmail,
),
_infoRow(
icon: Icons.phone_outlined,
label: 'Phone',
value: _complaint.phone,
),
],
),
);
}

// ==========================================================
// INCIDENT INFORMATION
// ==========================================================

Widget _buildIncidentInformation() {
return _sectionCard(
title: 'Incident Information',
icon: Icons.info_outline,
child: Column(
children: [
_infoRow(
icon:
Icons.category_outlined,
label: 'Category',
value:
_complaint.category,
),
_infoRow(
icon:
Icons.public_outlined,
label: 'Platform',
value:
_complaint.platform,
),
_infoRow(
icon:
Icons.location_on_outlined,
label: 'Location',
value:
_complaint.location,
),
_infoRow(
icon:
Icons.calendar_today_outlined,
label: 'Incident Date',
value:
_formatDate(
_complaint.date,
),
),
_infoRow(
icon:
Icons.person_search_outlined,
label: 'Suspect',
value:
_complaint.suspect,
),
_infoRow(
icon:
Icons.contact_phone_outlined,
label: 'Suspect Contact',
value:
_complaint
    .suspectContact,
),
],
),
);
}

// ==========================================================
// DESCRIPTION
// ==========================================================

Widget _buildDescription() {
return _sectionCard(
title:
'Complaint Description',
icon:
Icons.description_outlined,
child: Container(
width: double.infinity,
padding:
const EdgeInsets.all(14),
decoration:
BoxDecoration(
color: Colors.grey.shade50,
borderRadius:
BorderRadius.circular(12),
),
child: Text(
_complaint.description
    .trim()
    .isEmpty
? 'No description provided.'
    : _complaint.description,
style:
const TextStyle(
fontSize: 14,
height: 1.6,
),
),
),
);
}

// ==========================================================
// EVIDENCE
// ==========================================================

Widget _buildEvidence() {
final evidenceFiles =
_complaint.evidenceFiles;

final oldEvidence =
_complaint.evidence;

if (evidenceFiles.isEmpty &&
oldEvidence.isEmpty) {
return _sectionCard(
title: 'Evidence (0)',
icon:
Icons.attach_file_outlined,
child: Container(
width: double.infinity,
padding:
const EdgeInsets.all(20),
decoration:
BoxDecoration(
color:
Colors.grey.shade50,
borderRadius:
BorderRadius.circular(12),
),
child: Column(
children: [
Icon(
Icons
    .image_not_supported_outlined,
size: 42,
color:
Colors.grey.shade400,
),
const SizedBox(
height: 10,
),
Text(
'No evidence attached.',
style: TextStyle(
color:
Colors.grey.shade600,
),
),
],
),
),
);
}

if (evidenceFiles.isNotEmpty) {
return _sectionCard(
title:
'Evidence (${evidenceFiles.length})',
icon:
Icons.attach_file_outlined,
child:
GridView.builder(
shrinkWrap: true,
physics:
const NeverScrollableScrollPhysics(),
itemCount:
evidenceFiles.length,
gridDelegate:
const SliverGridDelegateWithFixedCrossAxisCount(
crossAxisCount: 2,
crossAxisSpacing: 12,
mainAxisSpacing: 12,
childAspectRatio: .90,
),
itemBuilder:
(context, index) {
return _base64EvidenceTile(
evidenceFiles[index],
index,
);
},
),
);
}

return _sectionCard(
title:
'Evidence (${oldEvidence.length})',
icon:
Icons.attach_file_outlined,
child: Column(
children:
List.generate(
oldEvidence.length,
(index) {
return Container(
width: double.infinity,
margin:
const EdgeInsets.only(
bottom: 10,
),
padding:
const EdgeInsets.all(14),
decoration:
BoxDecoration(
color:
Colors.grey.shade50,
borderRadius:
BorderRadius.circular(
14,
),
),
child: Row(
children: [
Container(
width: 45,
height: 45,
decoration:
BoxDecoration(
color:
AppColors.primary
    .withValues(
alpha: .08,
),
borderRadius:
BorderRadius.circular(
11,
),
),
child: Icon(
Icons
    .insert_drive_file_outlined,
color:
AppColors.primary,
),
),
const SizedBox(
width: 12,
),
Expanded(
child: Text(
oldEvidence[index],
maxLines: 2,
overflow:
TextOverflow.ellipsis,
style:
const TextStyle(
fontWeight:
FontWeight.w600,
),
),
),
],
),
);
},
),
),
);
}

// ==========================================================
// BASE64 EVIDENCE TILE
// ==========================================================

Widget _base64EvidenceTile(
Map<String, dynamic> file,
int index,
) {
final name =
_getFileName(
file,
index,
);

final type =
file['type']?.toString() ??
'';

final base64 =
file['base64']
    ?.toString()
    .trim() ??
'';

final isImage =
_isImageType(
type,
name,
);

Uint8List? imageBytes;

if (isImage &&
base64.isNotEmpty) {
imageBytes =
_decodeBase64Image(
base64,
);
}

return InkWell(
borderRadius:
BorderRadius.circular(16),
onTap: () {
if (imageBytes != null &&
imageBytes!.isNotEmpty) {
_openFullScreenImage(
imageBytes!,
name,
);
} else {
_showMessage(
'Unable to preview this evidence.',
isError: true,
);
}
},
child: Container(
decoration:
BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(16),
border: Border.all(
color:
Colors.grey.shade200,
),
boxShadow: [
BoxShadow(
color:
Colors.black.withValues(
alpha: .04,
),
blurRadius: 8,
offset:
const Offset(0, 3),
),
],
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Expanded(
child: ClipRRect(
borderRadius:
const BorderRadius.vertical(
top:
Radius.circular(16),
),
child: imageBytes != null &&
imageBytes!.isNotEmpty
? Image.memory(
imageBytes!,
width:
double.infinity,
fit:
BoxFit.cover,
gaplessPlayback:
true,
errorBuilder:
(
context,
error,
stackTrace,
) {
return const _BrokenEvidenceWidget();
},
)
    : const _BrokenEvidenceWidget(),
),
),
Padding(
padding:
const EdgeInsets.all(12),
child: Row(
children: [
Icon(
isImage
? Icons.image_outlined
    : Icons
    .insert_drive_file_outlined,
size: 20,
color:
AppColors.primary,
),
const SizedBox(
width: 8,
),
Expanded(
child: Text(
name,
maxLines: 2,
overflow:
TextOverflow.ellipsis,
style:
const TextStyle(
fontSize: 12,
fontWeight:
FontWeight.w600,
),
),
),
],
),
),
],
),
),
);
}

// ==========================================================
// SUBMISSION INFORMATION
// ==========================================================

Widget _buildSubmissionInformation() {
return _sectionCard(
title:
'Submission Information',
icon:
Icons.access_time_outlined,
child: Column(
children: [
_infoRow(
icon:
Icons.calendar_today_outlined,
label: 'Submitted Date',
value:
_formatDateTime(
_complaint.submittedDate,
),
),
_infoRow(
icon:
Icons.fingerprint_outlined,
label: 'User ID',
value:
_complaint.userId,
),
],
),
);
}

// ==========================================================
// BOTTOM ACTIONS
// ==========================================================

Widget _buildBottomActions() {
return SafeArea(
child: Container(
padding:
const EdgeInsets.fromLTRB(
16,
10,
16,
10,
),
decoration:
BoxDecoration(
color: Colors.white,
boxShadow: [
BoxShadow(
color:
Colors.black.withValues(
alpha: .08,
),
blurRadius: 12,
offset:
const Offset(0, -3),
),
],
),
child: Row(
children: [
Expanded(
child:
OutlinedButton.icon(
onPressed: _isDeleting
? null
    : _deleteComplaint,
icon: const Icon(
Icons.delete_outline,
),
label: const Text(
'Delete',
),
style:
OutlinedButton.styleFrom(
foregroundColor:
Colors.red,
side:
const BorderSide(
color: Colors.red,
),
padding:
const EdgeInsets.symmetric(
vertical: 14,
),
),
),
),
const SizedBox(
width: 12,
),
Expanded(
child:
FilledButton.icon(
onPressed: _isLoading
? null
    : _showStatusSelector,
icon: const Icon(
Icons.sync_outlined,
),
label: const Text(
'Update Status',
),
style:
FilledButton.styleFrom(
backgroundColor:
AppColors.primary,
padding:
const EdgeInsets.symmetric(
vertical: 14,
),
),
),
),
],
),
),
);
}

// ==========================================================
// STATUS SELECTOR
// ==========================================================

Future<void>
_showStatusSelector() async {
await showModalBottomSheet<
ComplaintStatus>(
context: context,
showDragHandle: true,
builder: (context) {
return SafeArea(
child: Padding(
padding:
const EdgeInsets.fromLTRB(
16,
8,
16,
20,
),
child: Column(
mainAxisSize:
MainAxisSize.min,
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Padding(
padding:
EdgeInsets.only(
bottom: 12,
),
child: Text(
'Select Complaint Status',
style:
TextStyle(
fontSize: 18,
fontWeight:
FontWeight.w700,
),
),
),
...ComplaintStatus.values
    .map(
(status) {
final selected =
status ==
_complaint.status;

return ListTile(
leading: Icon(
_statusIcon(
status,
),
color:
_statusColor(
status,
),
),
title: Text(
status.displayName,
),
trailing: selected
? Icon(
Icons
    .check_circle,
color:
_statusColor(
status,
),
)
    : null,
onTap: () {
Navigator.pop(
context,
status,
);
},
);
},
),
],
),
),
);
},
).then(
(status) {
if (status != null) {
_updateStatus(
status,
);
}
},
);
}

// ==========================================================
// SECTION CARD
// ==========================================================

Widget _sectionCard({
required String title,
required IconData icon,
required Widget child,
}) {
return Container(
width: double.infinity,
padding:
const EdgeInsets.all(18),
decoration:
BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(20),
border: Border.all(
color:
Colors.grey.shade200,
),
boxShadow: [
BoxShadow(
color:
Colors.black.withValues(
alpha: .03,
),
blurRadius: 10,
offset:
const Offset(0, 3),
),
],
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
children: [
Icon(
icon,
color:
AppColors.primary,
size: 22,
),
const SizedBox(
width: 9,
),
Expanded(
child: Text(
title,
style:
const TextStyle(
fontSize: 17,
fontWeight:
FontWeight.w700,
),
),
),
],
),
const SizedBox(
height: 16,
),
child,
],
),
);
}

// ==========================================================
// INFO ROW
// ==========================================================

Widget _infoRow({
required IconData icon,
required String label,
required String value,
}) {
final cleanValue =
value.trim();

return Padding(
padding:
const EdgeInsets.only(
bottom: 14,
),
child: Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Container(
width: 36,
height: 36,
decoration:
BoxDecoration(
color:
AppColors.primary
    .withValues(
alpha: .08,
),
borderRadius:
BorderRadius.circular(
10,
),
),
child: Icon(
icon,
size: 19,
color:
AppColors.primary,
),
),
const SizedBox(
width: 12,
),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
label,
style: TextStyle(
fontSize: 12,
color:
Colors.grey.shade600,
fontWeight:
FontWeight.w500,
),
),
const SizedBox(
height: 3,
),
Text(
cleanValue.isEmpty
? 'Not provided'
    : cleanValue,
style:
const TextStyle(
fontSize: 14,
fontWeight:
FontWeight.w600,
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
// DATE FORMAT
// ==========================================================

String _formatDate(
DateTime date,
) {
return '${date.day.toString().padLeft(2, '0')}/'
'${date.month.toString().padLeft(2, '0')}/'
'${date.year}';
}

// ==========================================================
// DATE TIME FORMAT
// ==========================================================

String _formatDateTime(
DateTime date,
) {
final hour =
date.hour % 12 == 0
? 12
    : date.hour % 12;

final minute =
date.minute
    .toString()
    .padLeft(
2,
'0',
);

final period =
date.hour >= 12
? 'PM'
    : 'AM';

return '${_formatDate(date)} '
'$hour:$minute $period';
}
}

// ============================================================
// BROKEN EVIDENCE
// ============================================================

class _BrokenEvidenceWidget
extends StatelessWidget {
const _BrokenEvidenceWidget();

@override
Widget build(
BuildContext context,
) {
return Container(
width: double.infinity,
height: double.infinity,
color: Colors.grey.shade100,
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
Icon(
Icons
    .broken_image_outlined,
size: 42,
color:
Colors.grey.shade500,
),
const SizedBox(
height: 8,
),
Text(
'Unable to preview',
style: TextStyle(
fontSize: 12,
color:
Colors.grey.shade600,
),
),
],
),
);
}
}

// ============================================================
// FULL SCREEN BASE64 IMAGE
// ============================================================

class _FullScreenEvidenceImage
extends StatelessWidget {
final Uint8List imageBytes;
final String title;

const _FullScreenEvidenceImage({
required this.imageBytes,
required this.title,
});

@override
Widget build(
BuildContext context,
) {
return Scaffold(
backgroundColor:
Colors.black,
appBar: AppBar(
backgroundColor:
Colors.black,
foregroundColor:
Colors.white,
title: Text(
title,
maxLines: 1,
overflow:
TextOverflow.ellipsis,
),
),
body: Center(
child:
InteractiveViewer(
minScale: .5,
maxScale: 5,
child: Image.memory(
imageBytes,
fit: BoxFit.contain,
gaplessPlayback: true,
errorBuilder:
(
context,
error,
stackTrace,
) {
return const Center(
child: Padding(
padding:
EdgeInsets.all(24),
child: Column(
mainAxisSize:
MainAxisSize.min,
children: [
Icon(
Icons
    .broken_image_outlined,
color:
Colors.white,
size: 60,
),
SizedBox(
height: 14,
),
Text(
'Unable to preview image',
textAlign:
TextAlign.center,
style:
TextStyle(
color:
Colors.white,
fontSize: 17,
fontWeight:
FontWeight.w600,
),
),
],
),
),
);
},
),
),
),
);
}
}

