import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../animations/fade_slide_animation.dart';
import '../../animations/scale_fade_animation.dart';
import '../../core/constants/app_colors.dart';
import '../../localization/app_localizations.dart';
import '../../models/safety_tips.dart';

class SafetyTipsScreen extends StatelessWidget {
const SafetyTipsScreen({super.key});

// ==========================================================
// LOCALIZATION HELPER
// ==========================================================

String _text({
required String english,
required String urdu,
required String romanUrdu,
required String language,
}) {
switch (language) {
case 'اردو':
return urdu;

case 'Roman Urdu':
return romanUrdu;

case 'English':
default:
return english;
}
}

// ==========================================================
// FIREBASE ICON → FLUTTER ICON
// ==========================================================

static IconData _getIcon(String iconName) {
switch (iconName) {
case 'lock_outline_rounded':
return Icons.lock_outline_rounded;

case 'verified_user_outlined':
return Icons.verified_user_outlined;

case 'link_off_rounded':
return Icons.link_off_rounded;

case 'privacy_tip_outlined':
return Icons.privacy_tip_outlined;

case 'download_for_offline_outlined':
return Icons.download_for_offline_outlined;

case 'system_update_outlined':
return Icons.system_update_outlined;

case 'public_outlined':
return Icons.public_outlined;

case 'payment_outlined':
return Icons.payment_outlined;

case 'report_outlined':
return Icons.report_outlined;

case 'security_outlined':
return Icons.security_outlined;

case 'shield_outlined':
return Icons.shield_outlined;

case 'warning_outlined':
return Icons.warning_outlined;

case 'vpn_key_outlined':
return Icons.vpn_key_outlined;

case 'phone_android_outlined':
return Icons.phone_android_outlined;

default:
return Icons.security_outlined;
}
}

// ==========================================================
// BUILD
// ==========================================================

@override
Widget build(BuildContext context) {
final l10n = AppLocalizations.of(context);
final language = l10n.language;

return Scaffold(
appBar: AppBar(
title: Text(
l10n.safetyTips,
style: const TextStyle(
fontWeight: FontWeight.w800,
),
),
),

body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
stream: FirebaseFirestore.instance
    .collection('safety_tips')
    .snapshots(),

builder: (context, snapshot) {
// ====================================================
// LOADING
// ====================================================

if (snapshot.connectionState ==
ConnectionState.waiting) {
return const Center(
child: CircularProgressIndicator(),
);
}

// ====================================================
// FIREBASE ERROR
// ====================================================

if (snapshot.hasError) {
return _buildErrorState(
context,
snapshot.error.toString(),
language,
);
}

// ====================================================
// NO DOCUMENTS
// ====================================================

if (!snapshot.hasData ||
snapshot.data!.docs.isEmpty) {
return _buildEmptyState(
context,
language,
);
}

final tips = snapshot.data!.docs
    .map(
(document) =>
SafetyTip.fromFirestore(document),
)
    .where(
(tip) =>
tip.title.trim().isNotEmpty &&
tip.description.trim().isNotEmpty,
)
    .toList();

// ====================================================
// NO VALID TIPS
// ====================================================

if (tips.isEmpty) {
return _buildEmptyState(
context,
language,
);
}

// ====================================================
// CONTENT
// ====================================================

return ListView(
padding: const EdgeInsets.fromLTRB(
20,
12,
20,
30,
),
children: [
FadeSlideAnimation(
child: _buildHeader(
context,
language,
),
),

const SizedBox(height: 22),

FadeSlideAnimation(
delay: 100,
child: Text(
_text(
english: 'Protect Yourself Online',
urdu: 'آن لائن خود کو محفوظ رکھیں',
romanUrdu:
'Online Khud Ko Mehfooz Rakhein',
language: language,
),
style: const TextStyle(
fontSize: 22,
fontWeight: FontWeight.w900,
),
),
),

const SizedBox(height: 6),

FadeSlideAnimation(
delay: 150,
child: Text(
_text(
english:
'Simple cybersecurity practices can help you stay safer online.',
urdu:
'سائبر سیکیورٹی کے آسان اصول آپ کو آن لائن زیادہ محفوظ رہنے میں مدد دے سکتے ہیں۔',
romanUrdu:
'Cybersecurity ke aasaan usool aap ko online zyada mehfooz rehne mein madad de sakte hain.',
language: language,
),
style: const TextStyle(
color: AppColors.textSecondary,
height: 1.45,
),
),
),

const SizedBox(height: 18),

...List.generate(
tips.length,
(index) {
final tip = tips[index];

return FadeSlideAnimation(
delay:
200 + (index * 60).toDouble(),
child: _SafetyTipCard(
title: tip.title,
description: tip.description,
icon: _getIcon(tip.icon),
index: index + 1,
),
);
},
),

const SizedBox(height: 10),

ScaleFadeAnimation(
delay: 700,
child: _buildReminderCard(
context,
language,
),
),
],
);
},
),
);
}

// ==========================================================
// HEADER
// ==========================================================

Widget _buildHeader(
BuildContext context,
String language,
) {
return Container(
padding: const EdgeInsets.all(22),
decoration: BoxDecoration(
gradient: LinearGradient(
colors: [
AppColors.primary,
AppColors.primaryLight,
],
begin: Alignment.topLeft,
end: Alignment.bottomRight,
),
borderRadius: BorderRadius.circular(24),
boxShadow: [
BoxShadow(
color: AppColors.primary.withValues(
alpha: 0.18,
),
blurRadius: 20,
offset: const Offset(0, 8),
),
],
),
child: Row(
children: [
Container(
width: 62,
height: 62,
decoration: BoxDecoration(
color: Colors.white.withValues(
alpha: 0.14,
),
borderRadius:
BorderRadius.circular(19),
),
child: const Icon(
Icons.shield_outlined,
color: Colors.white,
size: 34,
),
),

const SizedBox(width: 16),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
_text(
english: 'Stay Cyber Safe',
urdu: 'سائبر دنیا میں محفوظ رہیں',
romanUrdu:
'Cyber Duniya Mein Mehfooz Rahein',
language: language,
),
style: const TextStyle(
color: Colors.white,
fontSize: 21,
fontWeight: FontWeight.w900,
),
),

const SizedBox(height: 6),

Text(
_text(
english:
'Follow these simple tips to reduce common online risks.',
urdu:
'عام آن لائن خطرات کو کم کرنے کے لیے ان آسان تجاویز پر عمل کریں۔',
romanUrdu:
'Aam online khatron ko kam karne ke liye in aasaan tips par amal karein.',
language: language,
),
style: const TextStyle(
color: Colors.white70,
height: 1.4,
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
// REMINDER CARD
// ==========================================================

Widget _buildReminderCard(
BuildContext context,
String language,
) {
return Container(
padding: const EdgeInsets.all(18),
decoration: BoxDecoration(
color: AppColors.accentLight,
borderRadius: BorderRadius.circular(20),
border: Border.all(
color: AppColors.accent.withValues(
alpha: 0.25,
),
),
),
child: Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Icon(
Icons.lightbulb_outline_rounded,
color: AppColors.primary,
size: 26,
),

const SizedBox(width: 12),

Expanded(
child: Text(
_text(
english:
'Remember: Never share passwords, OTPs or verification codes with anyone.',
urdu:
'یاد رکھیں: پاس ورڈ، OTP یا تصدیقی کوڈ کسی کے ساتھ بھی شیئر نہ کریں۔',
romanUrdu:
'Yaad rakhein: Password, OTP ya verification codes kisi ke sath bhi share na karein.',
language: language,
),
style: const TextStyle(
color: AppColors.textPrimary,
fontWeight: FontWeight.w700,
height: 1.45,
),
),
),
],
),
);
}

// ==========================================================
// LOADING STATE
// ==========================================================

Widget _buildLoadingState() {
return const Center(
child: CircularProgressIndicator(),
);
}

// ==========================================================
// EMPTY STATE
// ==========================================================

Widget _buildEmptyState(
BuildContext context,
String language,
) {
return ListView(
padding: const EdgeInsets.fromLTRB(
20,
12,
20,
30,
),
children: [
FadeSlideAnimation(
child: _buildHeader(
context,
language,
),
),

const SizedBox(height: 40),

const Icon(
Icons.info_outline_rounded,
size: 60,
color: AppColors.primary,
),

const SizedBox(height: 16),

Center(
child: Text(
_text(
english: 'No safety tips available',
urdu: 'کوئی حفاظتی تجاویز دستیاب نہیں ہیں',
romanUrdu:
'Koi safety tips dastiyab nahi hain',
language: language,
),
textAlign: TextAlign.center,
style: const TextStyle(
fontSize: 18,
fontWeight: FontWeight.w800,
),
),
),

const SizedBox(height: 8),

Center(
child: Text(
_text(
english:
'Safety tips will appear here when they are added.',
urdu:
'جب حفاظتی تجاویز شامل کی جائیں گی تو وہ یہاں ظاہر ہوں گی۔',
romanUrdu:
'Jab safety tips shamil ki jayengi to woh yahan nazar aayengi.',
language: language,
),
textAlign: TextAlign.center,
style: const TextStyle(
color: AppColors.textSecondary,
height: 1.4,
),
),
),
],
);
}

// ==========================================================
// ERROR STATE
// ==========================================================

Widget _buildErrorState(
BuildContext context,
String error,
String language,
) {
return ListView(
padding: const EdgeInsets.fromLTRB(
20,
12,
20,
30,
),
children: [
FadeSlideAnimation(
child: _buildHeader(
context,
language,
),
),

const SizedBox(height: 40),

const Icon(
Icons.cloud_off_outlined,
size: 60,
color: AppColors.primary,
),

const SizedBox(height: 16),

Center(
child: Text(
_text(
english: 'Unable to load safety tips',
urdu: 'حفاظتی تجاویز لوڈ نہیں ہو سکیں',
romanUrdu:
'Safety tips load nahi ho sakeen',
language: language,
),
textAlign: TextAlign.center,
style: const TextStyle(
fontSize: 18,
fontWeight: FontWeight.w800,
),
),
),

const SizedBox(height: 8),

Center(
child: Text(
_text(
english:
'Please check your internet connection and try again.',
urdu:
'براہ کرم اپنا انٹرنیٹ کنکشن چیک کریں اور دوبارہ کوشش کریں۔',
romanUrdu:
'Barah-e-karam apna internet connection check karein aur dobara koshish karein.',
language: language,
),
textAlign: TextAlign.center,
style: const TextStyle(
color: AppColors.textSecondary,
height: 1.4,
),
),
),
],
);
}
}

// ============================================================
// SAFETY TIP CARD
// ============================================================

class _SafetyTipCard extends StatelessWidget {
final String title;
final String description;
final IconData icon;
final int index;

const _SafetyTipCard({
required this.title,
required this.description,
required this.icon,
required this.index,
});

@override
Widget build(BuildContext context) {
return Container(
margin: const EdgeInsets.only(
bottom: 14,
),
padding: const EdgeInsets.all(17),
decoration: BoxDecoration(
color: Theme.of(context)
    .colorScheme
    .surface,
borderRadius:
BorderRadius.circular(20),
border: Border.all(
color: AppColors.border,
),
boxShadow: const [
BoxShadow(
color: AppColors.shadow,
blurRadius: 12,
offset: Offset(0, 5),
),
],
),
child: Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Container(
width: 52,
height: 52,
decoration: BoxDecoration(
color: AppColors.primary
    .withValues(
alpha: 0.08,
),
borderRadius:
BorderRadius.circular(16),
),
child: Icon(
icon,
color: AppColors.primary,
size: 26,
),
),

const SizedBox(width: 14),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
children: [
Expanded(
child: Text(
title,
style:
const TextStyle(
fontSize: 16,
fontWeight:
FontWeight.w800,
),
),
),

Text(
'$index',
style: TextStyle(
color: AppColors.primary
    .withValues(
alpha: 0.45,
),
fontSize: 12,
fontWeight:
FontWeight.w900,
),
),
],
),

const SizedBox(height: 7),

Text(
description,
style: const TextStyle(
color:
AppColors.textSecondary,
fontSize: 13,
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
}

