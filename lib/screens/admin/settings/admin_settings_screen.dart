import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../localization/app_localizations.dart';
import '../../../services/app_settings.dart';
import '../../../services/auth_service.dart';

class AdminSettingsScreen extends StatefulWidget {
const AdminSettingsScreen({
super.key,
});

@override
State<AdminSettingsScreen> createState() =>
_AdminSettingsScreenState();
}

class _AdminSettingsScreenState
extends State<AdminSettingsScreen> {
// ==========================================================
// SERVICES
// ==========================================================

final AuthService _auth =
AuthService.instance;

final FirebaseAuth _firebaseAuth =
FirebaseAuth.instance;

final FirebaseFirestore _firestore =
FirebaseFirestore.instance;

final AppSettings _appSettings =
AppSettings.instance;

// ==========================================================
// SETTINGS
// ==========================================================

bool _notifications = true;

bool _darkMode = false;

bool _isLoading = true;

bool _isSavingNotifications = false;

String _adminName =
'CyberSafe Administrator';

String _adminEmail = '';

// ==========================================================
// ADMIN DOCUMENT
// ==========================================================

DocumentReference<Map<String, dynamic>>?
get _adminDocument {
final user =
_firebaseAuth.currentUser;

if (user == null) {
return null;
}

return _firestore
    .collection('users')
    .doc(user.uid);
}

// ==========================================================
// LOCALIZATION
// ==========================================================

AppLocalizations get _l10n {
return AppLocalizations.of(context);
}

// ==========================================================
// INIT
// ==========================================================

@override
void initState() {
super.initState();

_darkMode =
_appSettings.isDarkMode;

_appSettings.addListener(
_onAppSettingsChanged,
);

_loadAdminSettings();
}

// ==========================================================
// APP SETTINGS LISTENER
// ==========================================================

void _onAppSettingsChanged() {
if (!mounted) {
return;
}

setState(() {
_darkMode =
_appSettings.isDarkMode;
});
}

// ==========================================================
// DISPOSE
// ==========================================================

@override
void dispose() {
_appSettings.removeListener(
_onAppSettingsChanged,
);

super.dispose();
}

// ==========================================================
// LOAD ADMIN SETTINGS
// ==========================================================

Future<void> _loadAdminSettings() async {
try {
final user =
_firebaseAuth.currentUser;

if (user == null) {
if (!mounted) {
return;
}

setState(() {
_isLoading = false;
});

return;
}

// ------------------------------------------------------
// EMAIL
// ------------------------------------------------------

_adminEmail =
user.email ?? '';

// ------------------------------------------------------
// LOAD ADMIN DOCUMENT
// ------------------------------------------------------

final document =
await _firestore
    .collection('users')
    .doc(user.uid)
    .get();

final data =
document.data();

if (data != null) {
// ----------------------------------------------------
// ROLE CHECK
// ----------------------------------------------------

final role = data['role']
    ?.toString()
    .trim()
    .toLowerCase();

if (role != 'admin') {
if (!mounted) {
return;
}

_showError(
_l10n.administratorAccessDenied,
);

Navigator.pop(context);

return;
}

// ----------------------------------------------------
// ADMIN NAME
// ----------------------------------------------------

final firebaseName =
data['name']
    ?.toString()
    .trim();

if (firebaseName != null &&
firebaseName.isNotEmpty) {
_adminName =
firebaseName;
}

// ----------------------------------------------------
// NOTIFICATIONS
// ----------------------------------------------------

final notificationValue =
data['notificationsEnabled'];

if (notificationValue is bool) {
_notifications =
notificationValue;
}
}

// ------------------------------------------------------
// DARK MODE
// ------------------------------------------------------

_darkMode =
_appSettings.isDarkMode;

// ------------------------------------------------------
// AUTH SERVICE FALLBACK
// ------------------------------------------------------

if (_adminName ==
'CyberSafe Administrator') {
try {
final authName =
await _auth.getUserName();

if (authName.trim().isNotEmpty) {
_adminName =
authName.trim();
}
} catch (_) {
// Keep default administrator name.
}
}
} on FirebaseException catch (e) {
if (mounted) {
_showError(
_friendlyFirebaseError(e),
);
}
} catch (_) {
if (mounted) {
_showError(
_l10n.unableToLoadAdminSettings,
);
}
} finally {
if (mounted) {
setState(() {
_isLoading = false;
});
}
}
}

// ==========================================================
// SAVE NOTIFICATION SETTING
// ==========================================================

Future<void> _changeNotifications(
bool value,
) async {
if (_isSavingNotifications) {
return;
}

final document =
_adminDocument;

if (document == null) {
_showError(
_l10n.administratorSessionNotFound,
);

return;
}

// --------------------------------------------------------
// UPDATE UI IMMEDIATELY
// --------------------------------------------------------

setState(() {
_notifications = value;
_isSavingNotifications = true;
});

try {
await document.set(
{
'notificationsEnabled': value,
'updatedAt':
FieldValue.serverTimestamp(),
},
SetOptions(
merge: true,
),
);

if (!mounted) {
return;
}

ScaffoldMessenger.of(context)
    .showSnackBar(
SnackBar(
content: Text(
_l10n.notificationSettingsSaved,
),
),
);
} on FirebaseException catch (e) {
if (!mounted) {
return;
}

// Roll UI value back if Firebase update fails.
setState(() {
_notifications = !value;
});

_showError(
_friendlyFirebaseError(e),
);
} catch (_) {
if (!mounted) {
return;
}

setState(() {
_notifications = !value;
});

_showError(
_l10n.unableToSaveNotificationSettings,
);
} finally {
if (mounted) {
setState(() {
_isSavingNotifications = false;
});
}
}
}

// ==========================================================
// CHANGE DARK MODE
// ==========================================================

Future<void> _changeDarkMode(
bool value,
) async {
if (!mounted) {
return;
}

await _appSettings.setDarkMode(
value,
);

if (!mounted) {
return;
}

setState(() {
_darkMode =
_appSettings.isDarkMode;
});

ScaffoldMessenger.of(context)
    .showSnackBar(
SnackBar(
content: Text(
value
? _l10n.darkModeEnabled
    : _l10n.darkModeDisabled,
),
),
);
}

// ==========================================================
// LOGOUT
// ==========================================================

Future<void> _logout() async {
if (_isSavingNotifications) {
return;
}

final shouldLogout =
await showDialog<bool>(
context: context,
builder: (dialogContext) {
return AlertDialog(
title: Text(
_l10n.logoutConfirmationTitle,
style: const TextStyle(
fontWeight: FontWeight.w800,
),
),
content: Text(
_l10n.logoutConfirmationMessage,
),
actions: [
TextButton(
onPressed: () {
Navigator.pop(
dialogContext,
false,
);
},
child: Text(
_l10n.cancel,
),
),
FilledButton(
onPressed: () {
Navigator.pop(
dialogContext,
true,
);
},
child: Text(
_l10n.logout,
),
),
],
);
},
);

if (shouldLogout != true) {
return;
}

try {
await _auth.logout();

if (!mounted) {
return;
}

Navigator.pushNamedAndRemoveUntil(
context,
'/login',
(route) => false,
);
} catch (_) {
if (!mounted) {
return;
}

_showError(
_l10n.logoutFailed,
);
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
Theme.of(context)
    .scaffoldBackgroundColor,

appBar: AppBar(
title: Text(
_l10n.adminSettings,
style: const TextStyle(
fontWeight: FontWeight.w800,
),
),
actions: [
if (_isSavingNotifications)
const Padding(
padding: EdgeInsets.only(
right: 16,
),
child: Center(
child: SizedBox(
width: 20,
height: 20,
child:
CircularProgressIndicator(
strokeWidth: 2,
),
),
),
),
],
),

body: _isLoading
? const Center(
child:
CircularProgressIndicator(),
)
    : RefreshIndicator(
onRefresh:
_loadAdminSettings,
child: ListView(
physics:
const AlwaysScrollableScrollPhysics(),
padding:
const EdgeInsets.all(18),
children: [
_buildAdminCard(),

const SizedBox(
height: 18,
),

_buildSectionTitle(
_l10n.general,
),

// ------------------------------------------------
// NOTIFICATIONS
// ------------------------------------------------

_settingTile(
icon:
Icons.notifications_outlined,
title:
_l10n.notifications,
subtitle:
_l10n
    .receiveAdminComplaintAlerts,
trailing:
Switch(
value:
_notifications,
onChanged:
_changeNotifications,
),
),

// ------------------------------------------------
// DARK MODE
// ------------------------------------------------

_settingTile(
icon:
Icons.dark_mode_outlined,
title:
_l10n.darkMode,
subtitle:
_l10n
    .useDarkAppearanceThroughoutApp,
trailing:
Switch(
value:
_darkMode,
onChanged:
_changeDarkMode,
),
),

const SizedBox(
height: 20,
),

_buildSectionTitle(
_l10n.administration,
),

// ------------------------------------------------
// SECURITY
// ------------------------------------------------

_settingTile(
icon:
Icons.security_outlined,
title:
_l10n.security,
subtitle:
_l10n
    .manageAdministratorSecurity,
trailing:
const Icon(
Icons
    .chevron_right_rounded,
),
onTap:
_showSecurityInfo,
),

// ------------------------------------------------
// ABOUT
// ------------------------------------------------

_settingTile(
icon:
Icons.info_outline_rounded,
title:
_l10n.aboutCyberSafe,
subtitle:
_l10n
    .applicationInformation,
trailing:
const Icon(
Icons
    .chevron_right_rounded,
),
onTap:
_showAboutInfo,
),

const SizedBox(
height: 20,
),

_buildSectionTitle(
_l10n.account,
),

// ------------------------------------------------
// LOGOUT
// ------------------------------------------------

_settingTile(
icon:
Icons.logout_rounded,
title:
_l10n.logout,
subtitle:
_l10n
    .signOutFromAdministratorAccount,
iconColor:
AppColors.error,
titleColor:
AppColors.error,
trailing:
const Icon(
Icons
    .chevron_right_rounded,
color:
AppColors.error,
),
onTap:
_logout,
),

const SizedBox(
height: 30,
),

Center(
child: Text(
_l10n
    .cybersafeAdminVersion,
style: TextStyle(
color:
Theme.of(context)
    .colorScheme
    .onSurface
    .withValues(
alpha: 0.5,
),
fontSize: 12,
),
),
),

const SizedBox(
height: 20,
),
],
),
),
);
}

// ==========================================================
// ADMIN CARD
// ==========================================================

Widget _buildAdminCard() {
return Container(
padding:
const EdgeInsets.all(20),
decoration:
BoxDecoration(
gradient:
const LinearGradient(
colors: [
AppColors.primary,
AppColors.primaryLight,
],
),
borderRadius:
BorderRadius.circular(22),
),
child: Row(
children: [
Container(
width: 58,
height: 58,
decoration:
BoxDecoration(
color: Colors.white
    .withValues(
alpha: 0.14,
),
borderRadius:
BorderRadius.circular(
18,
),
),
child: const Icon(
Icons
    .admin_panel_settings_outlined,
color: Colors.white,
size: 30,
),
),

const SizedBox(
width: 15,
),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
_l10n.administrator,
style: const TextStyle(
color:
Colors.white70,
fontSize: 12,
),
),

const SizedBox(
height: 4,
),

Text(
_adminName,
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style:
const TextStyle(
color:
Colors.white,
fontSize: 17,
fontWeight:
FontWeight.w800,
),
),

if (_adminEmail
    .trim()
    .isNotEmpty) ...[
const SizedBox(
height: 3,
),
Text(
_adminEmail,
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style:
const TextStyle(
color:
Colors.white70,
fontSize: 11,
),
),
],
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
String title,
) {
return Padding(
padding:
const EdgeInsets.only(
left: 4,
bottom: 9,
),
child: Text(
title,
style: const TextStyle(
fontSize: 14,
fontWeight:
FontWeight.w800,
color:
AppColors.primary,
),
),
);
}

// ==========================================================
// SETTING TILE
// ==========================================================

Widget _settingTile({
required IconData icon,
required String title,
required String subtitle,
required Widget trailing,
Color? iconColor,
Color? titleColor,
VoidCallback? onTap,
}) {
final theme =
Theme.of(context);

final Color effectiveIconColor =
iconColor ??
AppColors.primary;

return Container(
margin:
const EdgeInsets.only(
bottom: 8,
),
decoration:
BoxDecoration(
color:
theme.colorScheme.surface,
borderRadius:
BorderRadius.circular(17),
border: Border.all(
color:
theme.dividerColor,
),
),
child: ListTile(
onTap: onTap,
contentPadding:
const EdgeInsets.symmetric(
horizontal: 15,
vertical: 5,
),
leading:
Container(
width: 43,
height: 43,
decoration:
BoxDecoration(
color:
effectiveIconColor
    .withValues(
alpha: 0.08,
),
borderRadius:
BorderRadius.circular(
13,
),
),
child: Icon(
icon,
color:
effectiveIconColor,
),
),
title:
Text(
title,
style:
TextStyle(
fontWeight:
FontWeight.w700,
color:
titleColor ??
theme
    .colorScheme
    .onSurface,
),
),
subtitle:
Text(
subtitle,
style:
TextStyle(
fontSize: 12,
color:
theme
    .colorScheme
    .onSurface
    .withValues(
alpha: 0.65,
),
),
),
trailing:
trailing,
),
);
}

// ==========================================================
// SECURITY INFO
// ==========================================================

void _showSecurityInfo() {
_showInfo(
_l10n.administratorSecurity,
_l10n
    .administratorSecurityMessage,
);
}

// ==========================================================
// ABOUT INFO
// ==========================================================

void _showAboutInfo() {
_showInfo(
_l10n.aboutCyberSafe,
_l10n.aboutCyberSafeMessage,
);
}

// ==========================================================
// INFO DIALOG
// ==========================================================

void _showInfo(
String title,
String message,
) {
showDialog<void>(
context: context,
builder: (dialogContext) {
return AlertDialog(
title: Text(
title,
style: const TextStyle(
fontWeight:
FontWeight.w800,
),
),
content:
Text(message),
actions: [
TextButton(
onPressed: () {
Navigator.pop(
dialogContext,
);
},
child:
Text(
_l10n.ok,
),
),
],
);
},
);
}

// ==========================================================
// ERROR
// ==========================================================

void _showError(
String message,
) {
if (!mounted) {
return;
}

ScaffoldMessenger.of(context)
    .showSnackBar(
SnackBar(
content:
Text(message),
backgroundColor:
AppColors.error,
),
);
}

// ==========================================================
// FIREBASE ERROR
// ==========================================================

String _friendlyFirebaseError(
FirebaseException error,
) {
switch (error.code) {
case 'permission-denied':
return _l10n
    .firebasePermissionDenied;

case 'unavailable':
return _l10n
    .firebaseTemporarilyUnavailable;

case 'network-request-failed':
return _l10n.networkError;

case 'unauthenticated':
return _l10n.sessionExpired;

default:
return _l10n
    .unableToProcessRequest;
}
}
}
