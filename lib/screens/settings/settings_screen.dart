import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../localization/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
final bool isDarkMode;
final String selectedLanguage;

final ValueChanged<bool> onThemeChanged;
final ValueChanged<String> onLanguageChanged;

const SettingsScreen({
super.key,
required this.isDarkMode,
required this.selectedLanguage,
required this.onThemeChanged,
required this.onLanguageChanged,
});

// ==========================================================
// LANGUAGE OPTIONS
// ==========================================================

static const List<String> languages = [
'English',
'اردو',
'Roman Urdu',
];

// ==========================================================
// LOCALIZATION
// ==========================================================

AppLocalizations _l10n(BuildContext context) {
return AppLocalizations.of(context);
}

// ==========================================================
// LOCALIZED SCREEN TEXT
// ==========================================================

String _text({
required BuildContext context,
required String english,
required String urdu,
required String romanUrdu,
}) {
switch (selectedLanguage) {
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
// BUILD
// ==========================================================

@override
Widget build(BuildContext context) {
final l10n = _l10n(context);

return Scaffold(
appBar: AppBar(
title: Text(
l10n.settings,
style: const TextStyle(
fontWeight: FontWeight.w800,
),
),
),
body: SafeArea(
child: ListView(
padding: const EdgeInsets.fromLTRB(
20,
12,
20,
30,
),
children: [
_buildHeader(context),

const SizedBox(height: 24),

// ==================================================
// APPEARANCE
// ==================================================

_buildSectionTitle(
context,
_text(
context: context,
english: 'Appearance',
urdu: 'ظاہری شکل',
romanUrdu: 'Appearance',
),
_text(
context: context,
english: 'Customize how CyberSafe looks.',
urdu: 'CyberSafe کی ظاہری شکل کو اپنی پسند کے مطابق بنائیں۔',
romanUrdu: 'CyberSafe ki appearance apni pasand ke mutabiq banayein.',
),
),

const SizedBox(height: 12),

_buildThemeCard(context),

const SizedBox(height: 28),

// ==================================================
// LANGUAGE
// ==================================================

_buildSectionTitle(
context,
l10n.languageLabel,
_text(
context: context,
english: 'Choose your preferred app language.',
urdu: 'اپنی پسندیدہ ایپ کی زبان منتخب کریں۔',
romanUrdu: 'Apni pasandeeda app language select karein.',
),
),

const SizedBox(height: 12),

_buildLanguageCard(context),

const SizedBox(height: 28),

// ==================================================
// APP INFORMATION
// ==================================================

_buildSectionTitle(
context,
_text(
context: context,
english: 'App Information',
urdu: 'ایپ کی معلومات',
romanUrdu: 'App Information',
),
_text(
context: context,
english: 'CyberSafe application details.',
urdu: 'CyberSafe ایپ کی تفصیلات۔',
romanUrdu: 'CyberSafe application ki details.',
),
),

const SizedBox(height: 12),

_buildInfoCard(context),

const SizedBox(height: 28),

// ==================================================
// PRIVACY
// ==================================================

_buildSectionTitle(
context,
_text(
context: context,
english: 'Privacy & Security',
urdu: 'رازداری اور سیکیورٹی',
romanUrdu: 'Privacy & Security',
),
_text(
context: context,
english: 'Manage your safety preferences.',
urdu: 'اپنی حفاظتی ترجیحات کا انتظام کریں۔',
romanUrdu: 'Apni safety preferences manage karein.',
),
),

const SizedBox(height: 12),

_buildPrivacyCard(context),

const SizedBox(height: 30),

Center(
child: Text(
'CyberSafe • Version 1.0.0',
style: TextStyle(
color: Colors.grey.shade600,
fontSize: 12,
fontWeight: FontWeight.w600,
),
),
),
],
),
),
);
}

// ==========================================================
// HEADER
// ==========================================================

Widget _buildHeader(BuildContext context) {
return Container(
width: double.infinity,
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
gradient: LinearGradient(
begin: Alignment.topLeft,
end: Alignment.bottomRight,
colors: [
AppColors.primary,
AppColors.primary.withValues(
alpha: 0.82,
),
],
),
borderRadius: BorderRadius.circular(24),
),
child: Row(
children: [
Container(
width: 56,
height: 56,
decoration: BoxDecoration(
color: Colors.white.withValues(
alpha: 0.15,
),
borderRadius: BorderRadius.circular(17),
),
child: const Icon(
Icons.settings_rounded,
color: Colors.white,
size: 30,
),
),

const SizedBox(width: 16),

Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
_text(
context: context,
english: 'App Settings',
urdu: 'ایپ کی ترتیبات',
romanUrdu: 'App Settings',
),
style: const TextStyle(
color: Colors.white,
fontSize: 21,
fontWeight: FontWeight.w900,
),
),

const SizedBox(height: 5),

Text(
_text(
context: context,
english:
'Personalize your CyberSafe experience',
urdu:
'اپنے CyberSafe کے تجربے کو اپنی پسند کے مطابق بنائیں',
romanUrdu:
'Apna CyberSafe experience apni pasand ke mutabiq banayein',
),
style: const TextStyle(
color: Colors.white70,
fontSize: 13,
fontWeight: FontWeight.w500,
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

Widget _buildSectionTitle(
BuildContext context,
String title,
String subtitle,
) {
return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
title,
style: const TextStyle(
fontSize: 19,
fontWeight: FontWeight.w900,
),
),

const SizedBox(height: 4),

Text(
subtitle,
style: TextStyle(
color: Colors.grey.shade600,
fontSize: 12,
height: 1.4,
),
),
],
);
}

// ==========================================================
// THEME CARD
// ==========================================================

Widget _buildThemeCard(BuildContext context) {
return Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: Theme.of(context).colorScheme.surface,
borderRadius: BorderRadius.circular(20),
border: Border.all(
color: Colors.grey.withValues(
alpha: 0.15,
),
),
),
child: Column(
children: [
Row(
children: [
_iconContainer(
context,
isDarkMode
? Icons.dark_mode_rounded
    : Icons.light_mode_rounded,
),

const SizedBox(width: 14),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
_l10n(context).darkMode,
style: const TextStyle(
fontSize: 15,
fontWeight: FontWeight.w800,
),
),

const SizedBox(height: 4),

Text(
isDarkMode
? _text(
context: context,
english:
'Dark theme is enabled',
urdu:
'ڈارک تھیم فعال ہے',
romanUrdu:
'Dark theme enabled hai',
)
    : _text(
context: context,
english:
'Light theme is enabled',
urdu:
'لائٹ تھیم فعال ہے',
romanUrdu:
'Light theme enabled hai',
),
style: TextStyle(
color: Colors.grey.shade600,
fontSize: 12,
),
),
],
),
),

Switch.adaptive(
value: isDarkMode,
onChanged: onThemeChanged,
),
],
),

const SizedBox(height: 14),

Container(
width: double.infinity,
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(
color: isDarkMode
? Colors.blue.withValues(
alpha: 0.08,
)
    : Colors.orange.withValues(
alpha: 0.08,
),
borderRadius:
BorderRadius.circular(14),
),
child: Row(
children: [
Icon(
isDarkMode
? Icons.nightlight_round
    : Icons.wb_sunny_rounded,
size: 19,
color: isDarkMode
? Colors.blue
    : Colors.orange,
),

const SizedBox(width: 9),

Expanded(
child: Text(
isDarkMode
? _text(
context: context,
english:
'Dark mode helps reduce brightness in low-light environments.',
urdu:
'ڈارک موڈ کم روشنی والے ماحول میں اسکرین کی چمک کم کرنے میں مدد کرتا ہے۔',
romanUrdu:
'Dark mode kam roshni wale environment mein brightness kam karne mein madad karta hai.',
)
    : _text(
context: context,
english:
'Light mode provides a bright and clean interface.',
urdu:
'لائٹ موڈ روشن اور صاف انٹرفیس فراہم کرتا ہے۔',
romanUrdu:
'Light mode bright aur clean interface provide karta hai.',
),
style: TextStyle(
fontSize: 11,
height: 1.4,
color: Colors.grey.shade700,
),
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
// LANGUAGE CARD
// ==========================================================

Widget _buildLanguageCard(BuildContext context) {
return Container(
decoration: BoxDecoration(
color: Theme.of(context).colorScheme.surface,
borderRadius: BorderRadius.circular(20),
border: Border.all(
color: Colors.grey.withValues(
alpha: 0.15,
),
),
),
child: Column(
children: [
for (int index = 0;
index < languages.length;
index++)
_buildLanguageTile(
context,
languages[index],
index == languages.length - 1,
),
],
),
);
}

// ==========================================================
// LANGUAGE TILE
// ==========================================================

Widget _buildLanguageTile(
BuildContext context,
String language,
bool isLast,
) {
final bool selected =
selectedLanguage == language;

return Column(
children: [
InkWell(
onTap: () async {
if (selected) {
return;
}

onLanguageChanged(language);

ScaffoldMessenger.of(context)
    .hideCurrentSnackBar();

ScaffoldMessenger.of(context)
    .showSnackBar(
SnackBar(
content: Text(
_selectedMessage(
context,
language,
),
),
duration:
const Duration(seconds: 1),
),
);
},
borderRadius: BorderRadius.vertical(
top: const Radius.circular(20),
bottom: Radius.circular(
isLast ? 20 : 0,
),
),
child: Padding(
padding:
const EdgeInsets.symmetric(
horizontal: 16,
vertical: 14,
),
child: Row(
children: [
_languageIcon(
context,
language,
selected,
),

const SizedBox(width: 14),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
language,
style: const TextStyle(
fontSize: 14,
fontWeight:
FontWeight.w700,
),
),

const SizedBox(height: 3),

Text(
_languageDescription(
context,
language,
),
style: TextStyle(
color:
Colors.grey.shade600,
fontSize: 11,
),
),
],
),
),

AnimatedContainer(
duration:
const Duration(
milliseconds: 200,
),
width: 24,
height: 24,
decoration: BoxDecoration(
shape: BoxShape.circle,
color: selected
? AppColors.primary
    : Colors.transparent,
border: Border.all(
color: selected
? AppColors.primary
    : Colors.grey.shade400,
width: selected
? 2
    : 1.5,
),
),
child: selected
? const Icon(
Icons.check_rounded,
color: Colors.white,
size: 16,
)
    : null,
),
],
),
),
),

if (!isLast)
Divider(
height: 1,
indent: 70,
endIndent: 16,
color: Colors.grey.withValues(
alpha: 0.12,
),
),
],
);
}

// ==========================================================
// LANGUAGE ICON
// ==========================================================

Widget _languageIcon(
BuildContext context,
String language,
bool selected,
) {
IconData icon;

switch (language) {
case 'اردو':
icon = Icons.translate_rounded;
break;

case 'Roman Urdu':
icon = Icons.text_fields_rounded;
break;

default:
icon = Icons.language_rounded;
}

return Container(
width: 42,
height: 42,
decoration: BoxDecoration(
color: selected
? AppColors.primary.withValues(
alpha: 0.10,
)
    : Colors.grey.withValues(
alpha: 0.08,
),
borderRadius:
BorderRadius.circular(13),
),
child: Icon(
icon,
color: selected
? AppColors.primary
    : Colors.grey.shade600,
size: 21,
),
);
}

// ==========================================================
// LANGUAGE DESCRIPTION
// ==========================================================

String _languageDescription(
BuildContext context,
String language,
) {
switch (language) {
case 'اردو':
return 'اردو میں ایپ استعمال کریں';

case 'Roman Urdu':
return 'App Roman Urdu mein use karein';

default:
return 'Use CyberSafe in English';
}
}

// ==========================================================
// LANGUAGE SELECTED MESSAGE
// ==========================================================

String _selectedMessage(
BuildContext context,
String language,
) {
switch (language) {
case 'اردو':
return 'اردو منتخب کر لی گئی ہے';

case 'Roman Urdu':
return 'Roman Urdu select kar li gayi hai';

default:
return 'English selected';
}
}

// ==========================================================
// APP INFORMATION
// ==========================================================

Widget _buildInfoCard(BuildContext context) {
return Container(
decoration: BoxDecoration(
color:
Theme.of(context).colorScheme.surface,
borderRadius:
BorderRadius.circular(20),
border: Border.all(
color: Colors.grey.withValues(
alpha: 0.15,
),
),
),
child: Column(
children: [
_infoTile(
context,
icon: Icons.info_outline_rounded,
title: _text(
context: context,
english: 'About CyberSafe',
urdu: 'CyberSafe کے بارے میں',
romanUrdu:
'CyberSafe ke Baare Mein',
),
subtitle: _text(
context: context,
english:
'Cyber crime complaint & awareness system',
urdu:
'سائبر کرائم شکایات اور آگاہی کا نظام',
romanUrdu:
'Cyber crime complaint aur awareness system',
),
onTap: () {
_showAboutDialog(context);
},
),

_divider(),

_infoTile(
context,
icon: Icons.verified_rounded,
title: _text(
context: context,
english: 'Version',
urdu: 'ورژن',
romanUrdu: 'Version',
),
subtitle: '1.0.0',
),
],
),
);
}

// ==========================================================
// PRIVACY CARD
// ==========================================================

Widget _buildPrivacyCard(BuildContext context) {
return Container(
decoration: BoxDecoration(
color:
Theme.of(context).colorScheme.surface,
borderRadius:
BorderRadius.circular(20),
border: Border.all(
color: Colors.grey.withValues(
alpha: 0.15,
),
),
),
child: Column(
children: [
_infoTile(
context,
icon: Icons.lock_outline_rounded,
title: _text(
context: context,
english: 'Privacy',
urdu: 'رازداری',
romanUrdu: 'Privacy',
),
subtitle: _text(
context: context,
english:
'Learn how CyberSafe handles your information',
urdu:
'جانیں کہ CyberSafe آپ کی معلومات کو کیسے سنبھالتا ہے',
romanUrdu:
'Jaaniye CyberSafe aapki information ko kaise handle karta hai',
),
onTap: () {
_showInfoDialog(
context,
title: _text(
context: context,
english: 'Privacy',
urdu: 'رازداری',
romanUrdu: 'Privacy',
),
message: _text(
context: context,
english:
'CyberSafe is designed to provide a secure and user-friendly environment for cyber safety awareness and complaint management.',
urdu:
'CyberSafe کو سائبر سیفٹی آگاہی اور شکایات کے انتظام کے لیے ایک محفوظ اور صارف دوست ماحول فراہم کرنے کے لیے بنایا گیا ہے۔',
romanUrdu:
'CyberSafe ko cyber safety awareness aur complaint management ke liye secure aur user-friendly environment provide karne ke liye design kiya gaya hai.',
),
);
},
),

_divider(),

_infoTile(
context,
icon: Icons.security_rounded,
title: _text(
context: context,
english: 'Security',
urdu: 'سیکیورٹی',
romanUrdu: 'Security',
),
subtitle: _text(
context: context,
english:
'Keep your account and information protected',
urdu:
'اپنے اکاؤنٹ اور معلومات کو محفوظ رکھیں',
romanUrdu:
'Apne account aur information ko mehfooz rakhein',
),
onTap: () {
_showInfoDialog(
context,
title: _text(
context: context,
english: 'Security',
urdu: 'سیکیورٹی',
romanUrdu: 'Security',
),
message: _text(
context: context,
english:
'Use a strong password, keep your account credentials private, and avoid sharing sensitive information with others.',
urdu:
'مضبوط پاس ورڈ استعمال کریں، اپنے اکاؤنٹ کی معلومات خفیہ رکھیں اور حساس معلومات دوسروں کے ساتھ شیئر کرنے سے گریز کریں۔',
romanUrdu:
'Strong password use karein, account credentials private rakhein aur sensitive information doosron ke sath share na karein.',
),
);
},
),
],
),
);
}

// ==========================================================
// INFO TILE
// ==========================================================

Widget _infoTile(
BuildContext context, {
required IconData icon,
required String title,
required String subtitle,
VoidCallback? onTap,
}) {
return ListTile(
onTap: onTap,
contentPadding:
const EdgeInsets.symmetric(
horizontal: 16,
vertical: 5,
),
leading: _iconContainer(
context,
icon,
),
title: Text(
title,
style: const TextStyle(
fontSize: 14,
fontWeight: FontWeight.w800,
),
),
subtitle: Padding(
padding:
const EdgeInsets.only(top: 3),
child: Text(
subtitle,
style: TextStyle(
fontSize: 11,
color: Colors.grey.shade600,
),
),
),
trailing: onTap != null
? const Icon(
Icons.arrow_forward_ios_rounded,
size: 15,
)
    : null,
);
}

// ==========================================================
// ICON CONTAINER
// ==========================================================

Widget _iconContainer(
BuildContext context,
IconData icon,
) {
return Container(
width: 44,
height: 44,
decoration: BoxDecoration(
color: AppColors.primary.withValues(
alpha: 0.08,
),
borderRadius:
BorderRadius.circular(13),
),
child: Icon(
icon,
color: AppColors.primary,
size: 21,
),
);
}

// ==========================================================
// DIVIDER
// ==========================================================

Widget _divider() {
return Divider(
height: 1,
indent: 72,
endIndent: 16,
color: Colors.grey.withValues(
alpha: 0.12,
),
);
}

// ==========================================================
// ABOUT DIALOG
// ==========================================================

void _showAboutDialog(
BuildContext context,
) {
showDialog(
context: context,
builder: (dialogContext) {
return AlertDialog(
title: Text(
_text(
context: context,
english: 'About CyberSafe',
urdu: 'CyberSafe کے بارے میں',
romanUrdu:
'CyberSafe ke Baare Mein',
),
style: const TextStyle(
fontWeight: FontWeight.w800,
),
),
content: Text(
_text(
context: context,
english:
'CyberSafe is a cyber crime complaint and awareness management system designed to help users learn about cyber safety and manage their complaints.',
urdu:
'CyberSafe ایک سائبر کرائم شکایات اور آگاہی کا انتظامی نظام ہے جو صارفین کو سائبر سیفٹی کے بارے میں سیکھنے اور اپنی شکایات کو منظم کرنے میں مدد فراہم کرتا ہے۔',
romanUrdu:
'CyberSafe aik cyber crime complaint aur awareness management system hai jo users ko cyber safety ke baare mein seekhne aur complaints manage karne mein madad karta hai.',
),
style: const TextStyle(
height: 1.5,
),
),
actions: [
TextButton(
onPressed: () {
Navigator.pop(dialogContext);
},
child: Text(
_text(
context: context,
english: 'Close',
urdu: 'بند کریں',
romanUrdu: 'Close',
),
),
),
],
);
},
);
}

// ==========================================================
// INFO DIALOG
// ==========================================================

void _showInfoDialog(
BuildContext context, {
required String title,
required String message,
}) {
showDialog(
context: context,
builder: (dialogContext) {
return AlertDialog(
title: Text(
title,
style: const TextStyle(
fontWeight: FontWeight.w800,
),
),
content: Text(
message,
style: const TextStyle(
height: 1.5,
),
),
actions: [
TextButton(
onPressed: () {
Navigator.pop(dialogContext);
},
child: Text(
_text(
context: context,
english: 'Close',
urdu: 'بند کریں',
romanUrdu: 'Close',
),
),
),
],
);
},
);
}
}

