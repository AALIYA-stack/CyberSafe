import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/complaint.dart';
import '../../../models/complaint_status.dart';
import '../../../services/complaint_services.dart';
import 'complaint_success_screen.dart';

class ComplaintReviewScreen extends StatefulWidget {
final String title;
final String category;
final String user;
final String userEmail;
final String phone;
final DateTime date;
final String platform;
final String location;
final String suspect;
final String suspectContact;
final String description;

// Evidence structure:
//
// {
//   'name': 'image.png',
//   'base64': '...',
//   'type': 'image/png',
// }
//
final List<Map<String, dynamic>> evidenceFiles;

// Kept for compatibility with existing navigation.
final List<String> adminIds;

const ComplaintReviewScreen({
super.key,
required this.title,
required this.category,
required this.user,
required this.userEmail,
required this.phone,
required this.date,
required this.platform,
required this.location,
required this.suspect,
required this.suspectContact,
required this.description,
this.evidenceFiles = const [],
this.adminIds = const [],
});

@override
State<ComplaintReviewScreen> createState() =>
_ComplaintReviewScreenState();
}

class _ComplaintReviewScreenState
extends State<ComplaintReviewScreen> {
bool _isSubmitting = false;

// ==========================================================
// SUBMIT COMPLAINT
// ==========================================================

Future<void> _submitComplaint() async {
if (_isSubmitting) {
return;
}

final firebaseUser =
FirebaseAuth.instance.currentUser;

// ========================================================
// CHECK LOGIN
// ========================================================

if (firebaseUser == null) {
_showMessage(
'Please login before submitting a complaint.',
isError: true,
);
return;
}

if (!mounted) {
return;
}

setState(() {
_isSubmitting = true;
});

try {
// ======================================================
// PREPARE EVIDENCE
// ======================================================

final evidence =
widget.evidenceFiles.map(
(item) {
return <String, dynamic>{
'name':
item['name']?.toString() ?? '',
'base64':
item['base64']?.toString() ?? '',
'type':
item['type']?.toString() ?? '',
};
},
).where(
(item) {
final name =
item['name']?.toString().trim() ?? '';

return name.isNotEmpty;
},
).toList();

// ======================================================
// CREATE COMPLAINT OBJECT
// ======================================================

final complaint = Complaint(
// Service will generate the actual ID.
id: '',

userId: firebaseUser.uid,

title:
widget.title.trim(),

category:
widget.category.trim(),

user:
widget.user.trim(),

userEmail: (
firebaseUser.email ??
widget.userEmail
).trim().toLowerCase(),

phone:
widget.phone.trim(),

date:
widget.date,

platform:
widget.platform.trim(),

location:
widget.location.trim(),

suspect:
widget.suspect.trim(),

suspectContact:
widget.suspectContact.trim(),

description:
widget.description.trim(),

// ==================================================
// SIMPLE EVIDENCE FILE NAMES
// ==================================================

evidence: evidence
    .map(
(item) =>
item['name']
    ?.toString()
    .trim() ??
'',
)
    .where(
(name) =>
name.isNotEmpty,
)
    .toList(),

// ==================================================
// DETAILED EVIDENCE
// ==================================================

evidenceFiles:
evidence,

status:
ComplaintStatus.submitted,

submittedDate:
DateTime.now(),
);

// ======================================================
// SAVE TO FIRESTORE
// ======================================================

  final complaintId =
  await ComplaintService
      .instance
      .saveComplaint(
    complaint,
  );

if (!mounted) {
return;
}

// ======================================================
// CHECK SAVE RESULT
// ======================================================

if (complaintId.trim().isEmpty) {
setState(() {
_isSubmitting = false;
});

final error =
ComplaintService
    .instance
    .lastError;

_showMessage(
error.isNotEmpty
? error
    : 'Complaint could not be submitted. Please try again.',
isError: true,
);

return;
}

// ======================================================
// LOAD SAVED COMPLAINT
// ======================================================

final savedComplaint =
await ComplaintService
    .instance
    .getMyComplaintById(
complaintId,
);

if (!mounted) {
return;
}

// ======================================================
// FINAL COMPLAINT
// ======================================================

final finalComplaint =
savedComplaint ??
complaint.copyWith(
id: complaintId,
);

// ======================================================
// SUCCESS SCREEN
// ======================================================

Navigator.pushAndRemoveUntil(
context,
MaterialPageRoute(
builder: (_) =>
ComplaintSuccessScreen(
complaint:
finalComplaint,
),
),
(route) => route.isFirst,
);
}

// ========================================================
// FIREBASE ERROR
// ========================================================

on FirebaseException catch (e) {
if (!mounted) {
return;
}

setState(() {
_isSubmitting = false;
});

_showMessage(
'Firebase error: ${e.message ?? e.code}',
isError: true,
);
}

// ========================================================
// GENERAL ERROR
// ========================================================

catch (e) {
if (!mounted) {
return;
}

setState(() {
_isSubmitting = false;
});

debugPrint(
'COMPLAINT SUBMISSION ERROR: $e',
);

final error =
ComplaintService
    .instance
    .lastError;

_showMessage(
error.isNotEmpty
? error
    : 'Submission failed. Please try again.',
isError: true,
);
}
}

// ==========================================================
// MESSAGE
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
content: Row(
children: [
Icon(
isError
? Icons.error_outline
    : Icons.check_circle_outline,
color: Colors.white,
),
const SizedBox(width: 10),
Expanded(
child: Text(
message,
),
),
],
),
backgroundColor:
isError
? Colors.red.shade700
    : Colors.green.shade700,
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
// INFO ROW
// ==========================================================

Widget _infoRow(
String label,
String value,
IconData icon,
) {
if (value.trim().isEmpty) {
return const SizedBox();
}

return Padding(
padding:
const EdgeInsets.only(
bottom: 15,
),
child: Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Container(
width: 38,
height: 38,
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
icon,
size: 20,
color:
AppColors.primary,
),
),

const SizedBox(width: 12),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,
children: [
Text(
label,
style: TextStyle(
color:
Colors.grey.shade600,
fontSize: 12,
),
),

const SizedBox(
height: 3,
),

Text(
value,
style:
const TextStyle(
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
// SECTION CARD
// ==========================================================

Widget _sectionCard({
required String title,
required Widget child,
}) {
return Container(
width: double.infinity,
margin:
const EdgeInsets.only(
bottom: 16,
),
padding:
const EdgeInsets.all(18),
decoration:
BoxDecoration(
color:
Theme.of(context)
    .cardColor,
borderRadius:
BorderRadius.circular(
20,
),
border: Border.all(
color:
Colors.grey.shade200,
),
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,
children: [
Text(
title,
style:
const TextStyle(
fontSize: 17,
fontWeight:
FontWeight.w800,
),
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
// EVIDENCE SECTION
// ==========================================================

Widget _evidenceSection() {
if (widget.evidenceFiles.isEmpty) {
return Row(
children: [
Icon(
Icons
    .attach_file_outlined,
color:
Colors.grey.shade500,
),

const SizedBox(
width: 8,
),

Text(
'No evidence attached.',
style: TextStyle(
color:
Colors.grey.shade600,
),
),
],
);
}

return Column(
children: List.generate(
widget.evidenceFiles.length,
(index) {
final item =
widget.evidenceFiles[
index];

// ==================================================
// FILE NAME
// ==================================================

final rawName =
item['name']
    ?.toString()
    .trim() ??
'';

final name =
rawName.isNotEmpty
? rawName
    : 'Evidence ${index + 1}';

// ==================================================
// EXTENSION
// ==================================================

final extension =
name.contains('.')
? name
    .split('.')
    .last
    .toUpperCase()
    : 'FILE';

// ==================================================
// IMAGE CHECK
// ==================================================

final isImage = [
'JPG',
'JPEG',
'PNG',
'WEBP',
'GIF',
].contains(
extension,
);

// ==================================================
// BASE64
// ==================================================

final base64String =
item['base64']
    ?.toString()
    .trim() ??
'';

Uint8List? imageBytes;

if (isImage &&
base64String.isNotEmpty) {
try {
imageBytes =
base64Decode(
base64String,
);
} catch (e) {
debugPrint(
'Evidence image decode error: $e',
);
}
}

// ==================================================
// EVIDENCE CARD
// ==================================================

return Container(
margin:
const EdgeInsets.only(
bottom: 10,
),
padding:
const EdgeInsets.all(
12,
),
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
// ==================================================
// IMAGE PREVIEW
// ==================================================

if (isImage &&
imageBytes != null)
ClipRRect(
borderRadius:
BorderRadius.circular(
10,
),
child:
Image.memory(
imageBytes,
width: 45,
height: 45,
fit:
BoxFit.cover,
errorBuilder:
(
_,
__,
___,
) {
return _fileIcon(
extension,
);
},
),
)
else
_fileIcon(
extension,
),

const SizedBox(
width: 12,
),

// ==================================================
// FILE INFORMATION
// ==================================================

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,
children: [
Text(
name,
maxLines: 1,
overflow:
TextOverflow
    .ellipsis,
style:
const TextStyle(
fontWeight:
FontWeight
    .w600,
),
),

const SizedBox(
height: 3,
),

Text(
'Evidence ${index + 1} • $extension',
style: TextStyle(
color:
Colors.grey.shade600,
fontSize: 11,
),
),
],
),
),
],
),
);
},
),
);
}

// ==========================================================
// FILE ICON
// ==========================================================

Widget _fileIcon(
String extension,
) {
return Container(
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
extension == 'PDF'
? Icons
    .picture_as_pdf_outlined
    : Icons
    .insert_drive_file_outlined,
color:
AppColors.primary,
),
);
}

// ==========================================================
// BUILD
// ==========================================================

@override
Widget build(
BuildContext context,
) {
final date =
'${widget.date.day.toString().padLeft(2, '0')}/'
'${widget.date.month.toString().padLeft(2, '0')}/'
'${widget.date.year}';

return Scaffold(
appBar: AppBar(
title:
const Text(
'Review Complaint',
),
),

body: SafeArea(
child: Column(
children: [
Expanded(
child:
SingleChildScrollView(
padding:
const EdgeInsets.all(
20,
),
child: Column(
children: [
// ==================================================
// REVIEW MESSAGE
// ==================================================

Container(
width:
double.infinity,
padding:
const EdgeInsets
    .all(18),
decoration:
BoxDecoration(
color:
AppColors
    .primary
    .withValues(
alpha: .06,
),
borderRadius:
BorderRadius
    .circular(
20,
),
),
child:
const Row(
children: [
Icon(
Icons
    .fact_check_outlined,
size: 40,
),

SizedBox(
width: 14,
),

Expanded(
child:
Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,
children: [
Text(
'Review carefully',
style:
TextStyle(
fontWeight:
FontWeight.w800,
fontSize:
16,
),
),

SizedBox(
height: 4,
),

Text(
'Make sure all information is correct before submitting.',
style:
TextStyle(
fontSize:
12,
),
),
],
),
),
],
),
),

const SizedBox(
height: 18,
),

// ==================================================
// PERSONAL INFORMATION
// ==================================================

_sectionCard(
title:
'Personal Information',
child:
Column(
children: [
_infoRow(
'Name',
widget.user,
Icons
    .person_outline,
),

_infoRow(
'Email',
widget.userEmail,
Icons
    .email_outlined,
),

_infoRow(
'Phone',
widget.phone,
Icons
    .phone_outlined,
),
],
),
),

// ==================================================
// INCIDENT INFORMATION
// ==================================================

_sectionCard(
title:
'Incident Information',
child:
Column(
children: [
_infoRow(
'Complaint Title',
widget.title,
Icons.title,
),

_infoRow(
'Category',
widget.category,
Icons
    .category_outlined,
),

_infoRow(
'Platform',
widget.platform,
Icons.language,
),

_infoRow(
'Incident Date',
date,
Icons
    .calendar_today_outlined,
),

_infoRow(
'Location',
widget.location,
Icons
    .location_on_outlined,
),

_infoRow(
'Suspect',
widget.suspect,
Icons
    .person_search_outlined,
),

_infoRow(
'Suspect Contact',
widget.suspectContact,
Icons
    .contact_phone_outlined,
),
],
),
),

// ==================================================
// DESCRIPTION
// ==================================================

_sectionCard(
title:
'Description',
child:
Text(
widget.description,
style:
TextStyle(
color:
Colors.grey.shade700,
height: 1.6,
),
),
),

// ==================================================
// EVIDENCE
// ==================================================

_sectionCard(
title:
'Evidence',
child:
_evidenceSection(),
),
],
),
),
),

// ========================================================
// SUBMIT BUTTON
// ========================================================

Container(
padding:
const EdgeInsets
    .fromLTRB(
20,
12,
20,
20,
),
decoration:
BoxDecoration(
color:
Theme.of(context)
    .scaffoldBackgroundColor,
boxShadow: [
BoxShadow(
blurRadius: 15,
color:
Colors.black
    .withValues(
alpha: .06,
),
),
],
),
child:
SizedBox(
width:
double.infinity,
height: 54,
child:
ElevatedButton(
onPressed:
_isSubmitting
? null
    : _submitComplaint,
style:
ElevatedButton
    .styleFrom(
backgroundColor:
AppColors
    .primary,
foregroundColor:
Colors.white,
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius
    .circular(
15,
),
),
),
child:
_isSubmitting
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
    : const Text(
'Submit Complaint',
style:
TextStyle(
fontWeight:
FontWeight
    .w700,
fontSize:
15,
),
),
),
),
),
],
),
),
);
}
}
