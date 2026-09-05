
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class AboutScreen extends StatelessWidget {
const AboutScreen({super.key});

void _showFeedbackDialog(BuildContext context) {
int selectedRating = 0;
final feedbackController = TextEditingController();

showDialog(
context: context,
builder: (dialogContext) {
return StatefulBuilder(
builder: (context, setState) {
return AlertDialog(
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(22),
),
title: const Text(
'Give Feedback',
style: TextStyle(
fontWeight: FontWeight.w800,
),
),
content: SingleChildScrollView(
child: Column(
mainAxisSize: MainAxisSize.min,
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'How was your experience with CyberSafe?',
style: TextStyle(
color: AppColors.textSecondary,
height: 1.4,
),
),

const SizedBox(height: 18),

// Rating
Row(
mainAxisAlignment: MainAxisAlignment.center,
children: List.generate(
5,
(index) {
final rating = index + 1;

return IconButton(
onPressed: () {
setState(() {
selectedRating = rating;
});
},
icon: Icon(
rating <= selectedRating
? Icons.star_rounded
    : Icons.star_border_rounded,
size: 32,
color: rating <= selectedRating
? Colors.amber
    : AppColors.textMuted,
),
);
},
),
),

const SizedBox(height: 10),

// Feedback Text
TextField(
controller: feedbackController,
maxLines: 4,
decoration: InputDecoration(
hintText: 'Write your feedback...',
filled: true,
fillColor: AppColors.background,
border: OutlineInputBorder(
borderRadius:
BorderRadius.circular(14),
borderSide: const BorderSide(
color: AppColors.border,
),
),
enabledBorder: OutlineInputBorder(
borderRadius:
BorderRadius.circular(14),
borderSide: const BorderSide(
color: AppColors.border,
),
),
focusedBorder: OutlineInputBorder(
borderRadius:
BorderRadius.circular(14),
borderSide: const BorderSide(
color: AppColors.primary,
width: 1.5,
),
),
),
),
],
),
),
actions: [
TextButton(
onPressed: () {
Navigator.pop(dialogContext);
},
child: const Text('Cancel'),
),

ElevatedButton(
onPressed: () {
if (selectedRating == 0) {
ScaffoldMessenger.of(context)
    .showSnackBar(
const SnackBar(
content: Text(
'Please select a rating first.',
),
),
);
return;
}

Navigator.pop(dialogContext);

ScaffoldMessenger.of(context)
    .showSnackBar(
const SnackBar(
content: Text(
'Thank you for your feedback!',
),
behavior:
SnackBarBehavior.floating,
),
);
},
style: ElevatedButton.styleFrom(
backgroundColor:
AppColors.primary,
foregroundColor: Colors.white,
shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(12),
),
),
child: const Text('Submit'),
),
],
);
},
);
},
);
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: AppColors.background,

appBar: AppBar(
title: const Text(
'About CyberSafe',
style: TextStyle(
fontWeight: FontWeight.w800,
),
),
),

body: ListView(
padding: const EdgeInsets.all(20),
children: [
// ==================================================
// HERO
// ==================================================

_buildHero(),

const SizedBox(height: 22),

// ==================================================
// WHAT IS CYBERSAFE?
// ==================================================

_section(
icon: Icons.info_outline_rounded,
title: 'What is CyberSafe?',
child: const Text(
'CyberSafe is a mobile application designed '
'to help users report cybercrime, track their '
'complaints and learn about online safety.',
style: TextStyle(
color: AppColors.textSecondary,
height: 1.6,
),
),
),

const SizedBox(height: 16),

// ==================================================
// OUR MISSION
// ==================================================

_section(
icon: Icons.flag_outlined,
title: 'Our Mission',
child: const Text(
'Our mission is to make cybercrime reporting '
'simple and improve cybersecurity awareness '
'among users.',
style: TextStyle(
color: AppColors.textSecondary,
height: 1.6,
),
),
),

const SizedBox(height: 16),

// ==================================================
// KEY FEATURES
// ==================================================

_section(
icon: Icons.security_outlined,
title: 'Key Features',
child: Column(
children: [
_feature(
Icons.report_outlined,
'Cybercrime Reporting',
),

_feature(
Icons.track_changes_rounded,
'Complaint Tracking',
),

_feature(
Icons.school_outlined,
'Cyber Awareness',
),

_feature(
Icons.notifications_none_rounded,
'Status Notifications',
),

_feature(
Icons.feedback_outlined,
'User Feedback',
),
],
),
),

const SizedBox(height: 16),

// ==================================================
// PRIVACY
// ==================================================

_section(
icon: Icons.verified_user_outlined,
title: 'Privacy',
child: const Text(
'CyberSafe is designed with user privacy '
'in mind. Users should only submit information '
'that is relevant to their complaint and avoid '
'sharing unnecessary sensitive information.',
style: TextStyle(
color: AppColors.textSecondary,
height: 1.6,
),
),
),

const SizedBox(height: 16),

// ==================================================
// FEEDBACK
// ==================================================

_section(
icon: Icons.feedback_outlined,
title: 'User Feedback',
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'Your feedback helps us understand '
'the user experience and improve '
'CyberSafe in the future.',
style: TextStyle(
color: AppColors.textSecondary,
height: 1.6,
),
),

const SizedBox(height: 14),

SizedBox(
width: double.infinity,
child: ElevatedButton.icon(
onPressed: () {
_showFeedbackDialog(context);
},
icon: const Icon(
Icons.rate_review_outlined,
),
label: const Text(
'Give Feedback',
),
style:
ElevatedButton.styleFrom(
backgroundColor:
AppColors.primary,
foregroundColor:
Colors.white,
padding:
const EdgeInsets.symmetric(
vertical: 14,
),
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(14),
),
),
),
),
],
),
),

const SizedBox(height: 30),

// ==================================================
// VERSION
// ==================================================

const Center(
child: Column(
children: [
Icon(
Icons.shield_rounded,
color: AppColors.primary,
size: 32,
),

SizedBox(height: 8),

Text(
'CyberSafe',
style: TextStyle(
fontWeight: FontWeight.w800,
fontSize: 15,
),
),

SizedBox(height: 4),

Text(
'Cyber Crime Complaint & Awareness System',
textAlign: TextAlign.center,
style: TextStyle(
color: AppColors.textMuted,
fontSize: 11,
),
),

SizedBox(height: 5),

Text(
'Version 1.0.0',
style: TextStyle(
color: AppColors.textMuted,
fontSize: 10,
fontWeight: FontWeight.w600,
),
),
],
),
),

const SizedBox(height: 20),
],
),
);
}

// ==========================================================
// HERO
// ==========================================================

Widget _buildHero() {
return Container(
padding: const EdgeInsets.all(25),
decoration: BoxDecoration(
gradient: const LinearGradient(
colors: [
AppColors.primary,
AppColors.primaryLight,
],
),
borderRadius: BorderRadius.circular(25),
),
child: const Column(
children: [
Icon(
Icons.shield_rounded,
color: Colors.white,
size: 60,
),

SizedBox(height: 14),

Text(
'CyberSafe',
style: TextStyle(
color: Colors.white,
fontSize: 28,
fontWeight: FontWeight.w900,
),
),

SizedBox(height: 6),

Text(
'Cyber Crime Complaint & Awareness System',
textAlign: TextAlign.center,
style: TextStyle(
color: Colors.white70,
height: 1.4,
),
),
],
),
);
}

// ==========================================================
// SECTION
// ==========================================================

Widget _section({
required IconData icon,
required String title,
required Widget child,
}) {
return Container(
padding: const EdgeInsets.all(19),
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(20),
border: Border.all(
color: AppColors.border,
),
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
children: [
Icon(
icon,
color: AppColors.primary,
),

const SizedBox(width: 9),

Expanded(
child: Text(
title,
style: const TextStyle(
fontSize: 17,
fontWeight:
FontWeight.w800,
),
),
),
],
),

const SizedBox(height: 14),

child,
],
),
);
}

// ==========================================================
// FEATURE
// ==========================================================

Widget _feature(
IconData icon,
String title,
) {
return Padding(
padding:
const EdgeInsets.only(bottom: 12),
child: Row(
children: [
Icon(
icon,
color: AppColors.primary,
size: 21,
),

const SizedBox(width: 10),

Expanded(
child: Text(
title,
style: const TextStyle(
fontWeight: FontWeight.w600,
),
),
),
],
),
);
}
}

