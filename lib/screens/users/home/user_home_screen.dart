import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../localization/app_localizations.dart';
import '../../../models/complaint_status.dart';
import '../../../services/auth_service.dart';
import '../../../services/complaint_services.dart';

class UserHomeScreen extends StatefulWidget {
const UserHomeScreen({
super.key,
});

@override
State<UserHomeScreen> createState() =>
_UserHomeScreenState();
}

class _UserHomeScreenState
extends State<UserHomeScreen> {
final AuthService _authService =
AuthService.instance;

final ComplaintService _complaintService =
ComplaintService.instance;

String _userName = 'User';

int _totalComplaints = 0;
int _underReview = 0;
int _inProgress = 0;
int _resolved = 0;

bool _loading = true;

@override
void initState() {
super.initState();

_loadDashboard();
}

// ==========================================================
// LOAD DASHBOARD DATA
// ==========================================================

Future<void> _loadDashboard() async {
try {
final name =
await _authService.getUserName();

final counts =
await _complaintService
    .getMyComplaintStatusCounts();

final total =
await _complaintService
    .getMyComplaintCount();

if (!mounted) return;

setState(() {
_userName =
name.trim().isEmpty
? 'User'
    : name;

_totalComplaints = total;

_underReview =
counts[
ComplaintStatus
    .underReview] ??
0;

_inProgress =
counts[
ComplaintStatus
    .inProgress] ??
0;

_resolved =
counts[
ComplaintStatus
    .resolved] ??
0;

_loading = false;
});
} catch (e) {
if (!mounted) return;

setState(() {
_loading = false;
});

debugPrint(
'USER HOME LOAD ERROR: $e',
);
}
}

// ==========================================================
// REFRESH
// ==========================================================

Future<void> _refresh() async {
if (mounted) {
setState(() {
_loading = true;
});
}

await _loadDashboard();
}

// ==========================================================
// BUILD
// ==========================================================

@override
Widget build(BuildContext context) {
final l10n =
AppLocalizations.of(context);

return Scaffold(
backgroundColor:
AppColors.background,
body: SafeArea(
child: RefreshIndicator(
onRefresh: _refresh,
color: AppColors.primary,
child: ListView(
physics:
const AlwaysScrollableScrollPhysics(),
padding:
const EdgeInsets.fromLTRB(
20,
16,
20,
30,
),
children: [
_buildTopBar(l10n),
const SizedBox(height: 22),
_buildWelcomeCard(l10n),
const SizedBox(height: 22),
_buildQuickActions(l10n),
const SizedBox(height: 24),
_buildStatistics(l10n),
const SizedBox(height: 24),
_buildSafetyCard(l10n),
const SizedBox(height: 20),
_buildInfoCard(l10n),
],
),
),
),
);
}

// ==========================================================
// TOP BAR
// ==========================================================

Widget _buildTopBar(
AppLocalizations l10n,
) {
return Row(
children: [
Container(
width: 48,
height: 48,
decoration: BoxDecoration(
color: AppColors.primary,
borderRadius:
BorderRadius.circular(15),
),
child: const Icon(
Icons.shield_rounded,
color: Colors.white,
size: 27,
),
),
const SizedBox(width: 12),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
l10n.appName,
style: const TextStyle(
fontSize: 19,
fontWeight:
FontWeight.w900,
),
),
const SizedBox(height: 2),
Text(
l10n.cyberCrimeProtection,
style: const TextStyle(
fontSize: 12,
color:
AppColors.textSecondary,
),
),
],
),
),
IconButton(
onPressed: () {
Navigator.pushNamed(
context,
'/notifications',
);
},
icon: const Icon(
Icons.notifications_none_rounded,
),
),
],
);
}

// ==========================================================
// WELCOME CARD
// ==========================================================

Widget _buildWelcomeCard(
AppLocalizations l10n,
) {
return Container(
width: double.infinity,
padding:
const EdgeInsets.all(22),
decoration: BoxDecoration(
gradient: LinearGradient(
colors: [
AppColors.primary,
AppColors.primaryLight,
],
begin: Alignment.topLeft,
end: Alignment.bottomRight,
),
borderRadius:
BorderRadius.circular(24),
boxShadow: [
BoxShadow(
color: AppColors.primary
    .withValues(alpha: 0.18),
blurRadius: 20,
offset:
const Offset(0, 8),
),
],
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
children: [
Expanded(
child: Text(
l10n.welcomeBack,
style:
const TextStyle(
color:
Colors.white70,
fontSize: 14,
fontWeight:
FontWeight.w600,
),
),
),
Container(
padding:
const EdgeInsets.symmetric(
horizontal: 10,
vertical: 6,
),
decoration:
BoxDecoration(
color: Colors.white
    .withValues(
alpha: 0.12,
),
borderRadius:
BorderRadius.circular(
20,
),
),
child: Row(
mainAxisSize:
MainAxisSize.min,
children: [
const Icon(
Icons
    .verified_user_outlined,
color: Colors.white,
size: 14,
),
const SizedBox(width: 5),
Text(
l10n.protected,
style:
const TextStyle(
color:
Colors.white,
fontSize: 11,
fontWeight:
FontWeight.w700,
),
),
],
),
),
],
),
const SizedBox(height: 7),
Text(
_userName,
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style: const TextStyle(
color: Colors.white,
fontSize: 25,
fontWeight:
FontWeight.w900,
),
),
const SizedBox(height: 9),
Text(
_welcomeDescription(l10n),
style: const TextStyle(
color: Colors.white70,
height: 1.45,
),
),
],
),
);
}

// ==========================================================
// WELCOME DESCRIPTION
// ==========================================================

String _welcomeDescription(
AppLocalizations l10n,
) {
switch (l10n.language) {
case 'اردو':
return 'باخبر رہیں، سائبر کرائم کی رپورٹ کریں اور اپنی ڈیجیٹل زندگی کو محفوظ رکھیں۔';

case 'Roman Urdu':
return 'Ba-khabar rahein, cybercrime report karein aur apni digital life ko safe rakhein.';

case 'English':
default:
return 'Stay informed, report cybercrime and keep your digital life safe.';
}
}

// ==========================================================
// QUICK ACTIONS
// ==========================================================

Widget _buildQuickActions(
AppLocalizations l10n,
) {
return Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
l10n.quickActions,
style: const TextStyle(
fontSize: 20,
fontWeight:
FontWeight.w900,
),
),
const SizedBox(height: 13),
Row(
children: [
Expanded(
child: _ActionCard(
icon: Icons
    .add_circle_outline_rounded,
title: l10n.report,
subtitle:
l10n.submitComplaint,
onTap: () {
Navigator.pushNamed(
context,
'/complaint-form',
);
},
),
),
const SizedBox(width: 12),
Expanded(
child: _ActionCard(
icon: Icons
    .track_changes_rounded,
title: l10n.track,
subtitle:
l10n.checkStatus,
onTap: () {
Navigator.pushNamed(
context,
'/complaint-status',
);
},
),
),
],
),
const SizedBox(height: 12),
Row(
children: [
Expanded(
child: _ActionCard(
icon:
Icons.menu_book_outlined,
title: l10n.awareness,
subtitle:
l10n.learnAndStaySafe,
onTap: () {
Navigator.pushNamed(
context,
'/awareness',
);
},
),
),
const SizedBox(width: 12),
Expanded(
child: _ActionCard(
icon: Icons
    .support_agent_outlined,
title: l10n.aiAssistant,
subtitle:
l10n.getGuidance,
onTap: () {
Navigator.pushNamed(
context,
'/ai-chat',
);
},
),
),
],
),
],
);
}

// ==========================================================
// STATISTICS
// ==========================================================

Widget _buildStatistics(
AppLocalizations l10n,
) {
return Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
l10n.myComplaints,
style: const TextStyle(
fontSize: 20,
fontWeight:
FontWeight.w900,
),
),
const SizedBox(height: 13),
Row(
children: [
Expanded(
child: _StatCard(
title: l10n.total,
value: _loading
? '—'
    : '$_totalComplaints',
icon:
Icons.description_outlined,
color:
AppColors.submitted,
),
),
const SizedBox(width: 10),
Expanded(
child: _StatCard(
title: l10n.review,
value: _loading
? '—'
    : '$_underReview',
icon:
Icons.search_rounded,
color:
AppColors.underReview,
),
),
],
),
const SizedBox(height: 10),
Row(
children: [
Expanded(
child: _StatCard(
title: l10n.progress,
value: _loading
? '—'
    : '$_inProgress',
icon:
Icons.sync_rounded,
color:
AppColors.inProgress,
),
),
const SizedBox(width: 10),
Expanded(
child: _StatCard(
title: l10n.resolved,
value: _loading
? '—'
    : '$_resolved',
icon:
Icons.check_circle_outline,
color:
AppColors.resolved,
),
),
],
),
],
);
}

// ==========================================================
// SAFETY CARD
// ==========================================================

Widget _buildSafetyCard(
AppLocalizations l10n,
) {
return InkWell(
borderRadius:
BorderRadius.circular(20),
onTap: () {
Navigator.pushNamed(
context,
'/safety-tips',
);
},
child: Container(
padding:
const EdgeInsets.all(18),
decoration: BoxDecoration(
color:
AppColors.accentLight,
borderRadius:
BorderRadius.circular(20),
border: Border.all(
color: AppColors.accent
    .withValues(
alpha: 0.16,
),
),
),
child: Row(
children: [
Container(
width: 50,
height: 50,
decoration:
BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(
15,
),
),
child: const Icon(
Icons.security_rounded,
color:
AppColors.primary,
),
),
const SizedBox(width: 14),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
l10n.stayCyberSafe,
style:
const TextStyle(
fontSize: 16,
fontWeight:
FontWeight.w800,
),
),
const SizedBox(height: 4),
Text(
l10n.exploreSafetyTips,
style:
const TextStyle(
fontSize: 12,
color: AppColors
    .textSecondary,
height: 1.4,
),
),
],
),
),
const Icon(
Icons
    .arrow_forward_ios_rounded,
size: 16,
color:
AppColors.primary,
),
],
),
),
);
}

// ==========================================================
// INFO CARD
// ==========================================================

Widget _buildInfoCard(
AppLocalizations l10n,
) {
return Container(
padding:
const EdgeInsets.all(18),
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
const Icon(
Icons.info_outline_rounded,
color:
AppColors.primary,
),
const SizedBox(width: 9),
Text(
l10n.remember,
style:
const TextStyle(
fontSize: 16,
fontWeight:
FontWeight.w800,
),
),
],
),
const SizedBox(height: 10),
Text(
l10n.neverShareSensitiveInfo,
style: const TextStyle(
color:
AppColors.textSecondary,
height: 1.5,
),
),
],
),
);
}
}

// ============================================================
// ACTION CARD
// ============================================================

class _ActionCard
extends StatelessWidget {
final IconData icon;
final String title;
final String subtitle;
final VoidCallback onTap;

const _ActionCard({
required this.icon,
required this.title,
required this.subtitle,
required this.onTap,
});

@override
Widget build(
BuildContext context,
) {
return Material(
color: Colors.white,
borderRadius:
BorderRadius.circular(18),
child: InkWell(
borderRadius:
BorderRadius.circular(18),
onTap: onTap,
child: Container(
padding:
const EdgeInsets.all(16),
decoration:
BoxDecoration(
borderRadius:
BorderRadius.circular(18),
border: Border.all(
color: AppColors.border,
),
),
child: Row(
children: [
Container(
width: 44,
height: 44,
decoration:
BoxDecoration(
color: AppColors.primary
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
AppColors.primary,
size: 23,
),
),
const SizedBox(width: 10),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
title,
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style:
const TextStyle(
fontWeight:
FontWeight.w800,
fontSize: 14,
),
),
const SizedBox(height: 3),
Text(
subtitle,
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style:
const TextStyle(
fontSize: 10,
color: AppColors
    .textSecondary,
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

// ============================================================
// STAT CARD
// ============================================================

class _StatCard
extends StatelessWidget {
final String title;
final String value;
final IconData icon;
final Color color;

const _StatCard({
required this.title,
required this.value,
required this.icon,
required this.color,
});

@override
Widget build(
BuildContext context,
) {
return Container(
padding:
const EdgeInsets.all(15),
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(18),
border: Border.all(
color: AppColors.border,
),
),
child: Row(
children: [
Container(
width: 40,
height: 40,
decoration:
BoxDecoration(
color: color.withValues(
alpha: 0.10,
),
borderRadius:
BorderRadius.circular(
12,
),
),
child: Icon(
icon,
color: color,
size: 21,
),
),
const SizedBox(width: 10),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
title,
style:
const TextStyle(
fontSize: 11,
color: AppColors
    .textSecondary,
),
),
const SizedBox(height: 2),
Text(
value,
style:
const TextStyle(
fontSize: 20,
fontWeight:
FontWeight.w900,
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
