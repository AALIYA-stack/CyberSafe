import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/complaint.dart';
import '../../../models/complaint_status.dart';
import '../../../services/auth_service.dart';
import '../../../services/complaint_services.dart';
import '../../../widgets/status_chip.dart';
import '../analytics/admin_complaint_analytics_screen.dart';
import '../analytics/admin_quiz_analytics_screen.dart';
import '../complaints/admin_complaints_screen.dart';
import '../notifications/admin_notifications_screen.dart';
import '../settings/admin_settings_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
const AdminDashboardScreen({
super.key,
});

@override
State<AdminDashboardScreen> createState() =>
_AdminDashboardScreenState();
}

class _AdminDashboardScreenState
extends State<AdminDashboardScreen> {
final ComplaintService _complaintService =
ComplaintService.instance;

final AuthService _auth =
AuthService.instance;

bool _isLoading = true;
String _errorMessage = '';

List<Complaint> _complaints = [];

int get _total => _complaints.length;

int get _submitted => _complaints
    .where(
(complaint) =>
complaint.status == ComplaintStatus.submitted,
)
    .length;

int get _underReview => _complaints
    .where(
(complaint) =>
complaint.status ==
ComplaintStatus.underReview,
)
    .length;

int get _inProgress => _complaints
    .where(
(complaint) =>
complaint.status ==
ComplaintStatus.inProgress,
)
    .length;

int get _resolved => _complaints
    .where(
(complaint) =>
complaint.status == ComplaintStatus.resolved,
)
    .length;

int get _closed => _complaints
    .where(
(complaint) =>
complaint.status == ComplaintStatus.closed,
)
    .length;

int get _pending => _submitted + _underReview;

@override
void initState() {
super.initState();
_loadDashboard();
}

// ==========================================================
// LOAD DASHBOARD
// ==========================================================

Future<void> _loadDashboard() async {
if (mounted) {
setState(() {
_isLoading = true;
_errorMessage = '';
});
}

try {
final complaints =
await _complaintService.getAllComplaints();

if (!mounted) return;

complaints.sort(
(a, b) => b.submittedDate.compareTo(
a.submittedDate,
),
);

setState(() {
_complaints = complaints;
_isLoading = false;
});
} catch (e) {
debugPrint(
'ADMIN DASHBOARD ERROR: $e',
);

if (!mounted) return;

setState(() {
_isLoading = false;
_errorMessage =
_complaintService.lastError.isNotEmpty
? _complaintService.lastError
    : 'Unable to load dashboard data.';
});
}
}

// ==========================================================
// NAVIGATION
// ==========================================================

Future<void> _openComplaints() async {
await Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
const AdminComplaintsScreen(),
),
);

if (mounted) {
await _loadDashboard();
}
}

Future<void> _openComplaintAnalytics() async {
await Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
const AdminComplaintAnalyticsScreen(),
),
);
}

Future<void> _openQuizAnalytics() async {
await Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
const AdminQuizAnalyticsScreen(),
),
);
}

Future<void> _openNotifications() async {
await Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
const AdminNotificationsScreen(),
),
);
}

Future<void> _openSettings() async {
await Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
const AdminSettingsScreen(),
),
);
}

// ==========================================================
// ADMIN NAME
// ==========================================================

String _adminName() {
final user = _auth.currentUser;

final displayName =
user?.displayName?.trim() ?? '';

if (displayName.isNotEmpty) {
return displayName;
}

final email =
user?.email?.trim() ?? '';

if (email.isNotEmpty) {
final name =
email.split('@').first.trim();

if (name.isNotEmpty) {
return name;
}
}

return 'Administrator';
}

// ==========================================================
// DATE
// ==========================================================

String _formatDate(DateTime date) {
final day =
date.day.toString().padLeft(2, '0');

final month =
date.month.toString().padLeft(2, '0');

return '$day/$month/${date.year}';
}

// ==========================================================
// BUILD
// ==========================================================

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text(
'Admin Dashboard',
),
actions: [
IconButton(
tooltip: 'Notifications',
onPressed:
_openNotifications,
icon: const Icon(
Icons.notifications_none_rounded,
),
),
IconButton(
tooltip: 'Settings',
onPressed:
_openSettings,
icon: const Icon(
Icons.settings_outlined,
),
),
],
),
body: RefreshIndicator(
onRefresh: _loadDashboard,
child: _isLoading
? ListView(
physics:
const AlwaysScrollableScrollPhysics(),
children: const [
SizedBox(height: 280),
Center(
child:
CircularProgressIndicator(),
),
],
)
    : _errorMessage.isNotEmpty
? ListView(
physics:
const AlwaysScrollableScrollPhysics(),
children: [
const SizedBox(height: 180),
_buildErrorState(),
],
)
    : ListView(
physics:
const AlwaysScrollableScrollPhysics(),
padding:
const EdgeInsets.fromLTRB(
16,
12,
16,
30,
),
children: [
_buildWelcomeCard(),

const SizedBox(height: 20),

_buildSectionTitle(
'Complaint Overview',
'Live complaint statistics',
),

const SizedBox(height: 12),

_buildStatisticsGrid(),

const SizedBox(height: 24),

_buildStatusOverview(),

const SizedBox(height: 24),

_buildSectionTitle(
'Recent Complaints',
'Latest complaints submitted',
),

const SizedBox(height: 12),

_buildRecentComplaints(),

const SizedBox(height: 24),

_buildSectionTitle(
'Quick Actions',
'Manage the CyberSafe system',
),

const SizedBox(height: 12),

_buildQuickActions(),

const SizedBox(height: 24),

_buildAdminInfo(),
],
),
),
);
}

// ==========================================================
// WELCOME
// ==========================================================

Widget _buildWelcomeCard() {
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
color:
AppColors.primary.withValues(
alpha: 0.20,
),
blurRadius: 20,
offset:
const Offset(0, 8),
),
],
),
child: Row(
children: [
Container(
width: 58,
height: 58,
decoration: BoxDecoration(
color: Colors.white.withValues(
alpha: 0.14,
),
borderRadius:
BorderRadius.circular(17),
),
child: const Icon(
Icons.admin_panel_settings_rounded,
color: Colors.white,
size: 31,
),
),
const SizedBox(width: 16),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'Welcome back',
style: TextStyle(
color: Colors.white70,
fontSize: 13,
),
),
const SizedBox(height: 3),
Text(
_adminName(),
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style: const TextStyle(
color: Colors.white,
fontSize: 21,
fontWeight:
FontWeight.w800,
),
),
const SizedBox(height: 5),
const Text(
'Manage CyberSafe complaints efficiently.',
maxLines: 2,
style: TextStyle(
color: Colors.white70,
fontSize: 12,
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
String title,
String subtitle,
) {
return Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
title,
style: const TextStyle(
fontSize: 19,
fontWeight:
FontWeight.w800,
),
),
const SizedBox(height: 3),
Text(
subtitle,
style: Theme.of(context)
    .textTheme
    .bodySmall,
),
],
);
}

// ==========================================================
// STATISTICS GRID
// ==========================================================

Widget _buildStatisticsGrid() {
return GridView.count(
crossAxisCount: 2,
crossAxisSpacing: 12,
mainAxisSpacing: 12,
childAspectRatio: 1.55,
shrinkWrap: true,
physics:
const NeverScrollableScrollPhysics(),
children: [
_statCard(
title: 'Total',
value: _total,
icon:
Icons.folder_copy_outlined,
),
_statCard(
title: 'Pending',
value: _pending,
icon:
Icons.pending_actions_rounded,
),
_statCard(
title: 'In Progress',
value: _inProgress,
icon:
Icons.sync_rounded,
),
_statCard(
title: 'Resolved',
value: _resolved,
icon:
Icons.check_circle_outline_rounded,
),
],
);
}

// ==========================================================
// STAT CARD
// ==========================================================

Widget _statCard({
required String title,
required int value,
required IconData icon,
}) {
return Container(
padding:
const EdgeInsets.all(16),
decoration: BoxDecoration(
color:
Theme.of(context).cardColor,
borderRadius:
BorderRadius.circular(18),
border: Border.all(
color: Theme.of(context)
    .dividerColor
    .withValues(
alpha: 0.25,
),
),
boxShadow: [
BoxShadow(
color:
Colors.black.withValues(
alpha: 0.025,
),
blurRadius: 10,
offset:
const Offset(0, 4),
),
],
),
child: Row(
children: [
Container(
width: 43,
height: 43,
decoration:
BoxDecoration(
color:
AppColors.primary
    .withValues(
alpha: 0.09,
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
size: 22,
),
),
const SizedBox(width: 12),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
mainAxisAlignment:
MainAxisAlignment.center,
children: [
Text(
value.toString(),
style:
const TextStyle(
fontSize: 23,
fontWeight:
FontWeight.w800,
),
),
const SizedBox(height: 2),
Text(
title,
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style: Theme.of(context)
    .textTheme
    .bodySmall
    ?.copyWith(
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
// STATUS OVERVIEW
// ==========================================================

Widget _buildStatusOverview() {
final statuses = [
_StatusData(
'Submitted',
_submitted,
Icons.send_rounded,
),
_StatusData(
'Under Review',
_underReview,
Icons.search_rounded,
),
_StatusData(
'In Progress',
_inProgress,
Icons.manage_search_rounded,
),
_StatusData(
'Resolved',
_resolved,
Icons.check_circle_outline_rounded,
),
_StatusData(
'Closed',
_closed,
Icons.lock_outline_rounded,
),
];

return _dashboardCard(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
children: [
Container(
width: 42,
height: 42,
decoration:
BoxDecoration(
color:
AppColors.primary
    .withValues(
alpha: 0.09,
),
borderRadius:
BorderRadius.circular(
13,
),
),
child: const Icon(
Icons.analytics_outlined,
color:
AppColors.primary,
),
),
const SizedBox(width: 12),
const Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
'Status Overview',
style: TextStyle(
fontSize: 16,
fontWeight:
FontWeight.w800,
),
),
SizedBox(height: 2),
Text(
'Current complaint distribution',
style: TextStyle(
fontSize: 12,
),
),
],
),
),
],
),
const SizedBox(height: 20),
...statuses.map(
(item) =>
_statusOverviewRow(item),
),
],
),
);
}

Widget _statusOverviewRow(
_StatusData item,
) {
final percentage =
_total == 0
? 0.0
    : item.count / _total;

return Padding(
padding:
const EdgeInsets.only(
bottom: 14,
),
child: Column(
children: [
Row(
children: [
Icon(
item.icon,
size: 18,
color:
AppColors.primary,
),
const SizedBox(width: 9),
Expanded(
child: Text(
item.title,
style:
const TextStyle(
fontWeight:
FontWeight.w600,
),
),
),
Text(
'${item.count}',
style:
const TextStyle(
fontWeight:
FontWeight.w800,
),
),
const SizedBox(width: 7),
Text(
'${(percentage * 100).round()}%',
style: Theme.of(context)
    .textTheme
    .bodySmall,
),
],
),
const SizedBox(height: 7),
ClipRRect(
borderRadius:
BorderRadius.circular(10),
child:
LinearProgressIndicator(
value: percentage,
minHeight: 7,
backgroundColor:
Theme.of(context)
    .dividerColor
    .withValues(
alpha: 0.18,
),
valueColor:
const AlwaysStoppedAnimation<
Color>(
AppColors.primary,
),
),
),
],
),
);
}

// ==========================================================
// RECENT COMPLAINTS
// ==========================================================

Widget _buildRecentComplaints() {
if (_complaints.isEmpty) {
return _dashboardCard(
child: Column(
children: [
Icon(
Icons.inbox_outlined,
size: 46,
color: Theme.of(context)
    .colorScheme
    .onSurface
    .withValues(
alpha: 0.40,
),
),
const SizedBox(height: 10),
const Text(
'No complaints yet',
style: TextStyle(
fontWeight:
FontWeight.w700,
),
),
const SizedBox(height: 4),
Text(
'New complaints will appear here.',
style: Theme.of(context)
    .textTheme
    .bodySmall,
),
],
),
);
}

final recent =
_complaints.take(5).toList();

return _dashboardCard(
padding: EdgeInsets.zero,
child: Column(
children: [
...List.generate(
recent.length,
(index) {
final complaint =
recent[index];

return Column(
children: [
_recentComplaintTile(
complaint,
),
if (index !=
recent.length - 1)
Divider(
height: 1,
indent: 16,
endIndent: 16,
color: Theme.of(
context,
)
    .dividerColor
    .withValues(
alpha: 0.20,
),
),
],
);
},
),
Padding(
padding:
const EdgeInsets.all(12),
child: SizedBox(
width: double.infinity,
child:
OutlinedButton.icon(
onPressed:
_openComplaints,
icon: const Icon(
Icons.list_alt_rounded,
),
label: const Text(
'View All Complaints',
),
),
),
),
],
),
);
}

// ==========================================================
// RECENT COMPLAINT TILE
// ==========================================================

Widget _recentComplaintTile(
Complaint complaint,
) {
return InkWell(
onTap: _openComplaints,
child: Padding(
padding:
const EdgeInsets.all(16),
child: Row(
children: [
Container(
width: 46,
height: 46,
decoration:
BoxDecoration(
color:
AppColors.primary
    .withValues(
alpha: 0.09,
),
borderRadius:
BorderRadius.circular(
13,
),
),
child: const Icon(
Icons.report_problem_outlined,
color:
AppColors.primary,
),
),
const SizedBox(width: 12),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
complaint.title
    .trim()
    .isEmpty
? 'Untitled Complaint'
    : complaint.title,
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style:
const TextStyle(
fontWeight:
FontWeight.w700,
),
),
const SizedBox(height: 5),
Text(
'${complaint.category} • '
'${_formatDate(complaint.submittedDate)}',
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style:
Theme.of(context)
    .textTheme
    .bodySmall,
),
],
),
),
const SizedBox(width: 8),
StatusChip(
status:
complaint.status,
),
],
),
),
);
}

// ==========================================================
// QUICK ACTIONS
// ==========================================================

Widget _buildQuickActions() {
return GridView.count(
crossAxisCount: 2,
crossAxisSpacing: 12,
mainAxisSpacing: 12,
childAspectRatio: 1.35,
shrinkWrap: true,
physics:
const NeverScrollableScrollPhysics(),
children: [
_actionCard(
icon:
Icons.list_alt_rounded,
title:
'Complaints',
subtitle:
'Manage reports',
onTap:
_openComplaints,
),
_actionCard(
icon:
Icons.analytics_outlined,
title:
'Analytics',
subtitle:
'Complaint reports',
onTap:
_openComplaintAnalytics,
),
_actionCard(
icon:
Icons.quiz_outlined,
title:
'Quiz Analytics',
subtitle:
'View quiz reports',
onTap:
_openQuizAnalytics,
),
_actionCard(
icon:
Icons.notifications_none_rounded,
title:
'Notifications',
subtitle:
'View alerts',
onTap:
_openNotifications,
),
_actionCard(
icon:
Icons.settings_outlined,
title:
'Settings',
subtitle:
'Admin settings',
onTap:
_openSettings,
),
],
);
}

// ==========================================================
// ACTION CARD
// ==========================================================

Widget _actionCard({
required IconData icon,
required String title,
required String subtitle,
required VoidCallback onTap,
}) {
return Material(
color: Colors.transparent,
child: InkWell(
onTap: onTap,
borderRadius:
BorderRadius.circular(18),
child: Ink(
padding:
const EdgeInsets.all(16),
decoration: BoxDecoration(
color: Theme.of(context)
    .cardColor,
borderRadius:
BorderRadius.circular(18),
border: Border.all(
color: Theme.of(context)
    .dividerColor
    .withValues(
alpha: 0.25,
),
),
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Container(
width: 44,
height: 44,
decoration:
BoxDecoration(
color:
AppColors.primary
    .withValues(
alpha: 0.09,
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
),
),
const SizedBox(height: 13),
Text(
title,
style:
const TextStyle(
fontWeight:
FontWeight.w800,
fontSize: 15,
),
),
const SizedBox(height: 3),
Text(
subtitle,
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style: Theme.of(context)
    .textTheme
    .bodySmall,
),
],
),
),
),
);
}

// ==========================================================
// ADMIN INFO
// ==========================================================

Widget _buildAdminInfo() {
final user =
_auth.currentUser;

return _dashboardCard(
child: Row(
children: [
CircleAvatar(
radius: 25,
backgroundColor:
AppColors.primary
    .withValues(
alpha: 0.10,
),
child: const Icon(
Icons.admin_panel_settings_rounded,
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
const Text(
'Administrator Account',
style: TextStyle(
fontWeight:
FontWeight.w700,
),
),
const SizedBox(height: 4),
Text(
user?.email ??
'Admin account',
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style: Theme.of(context)
    .textTheme
    .bodySmall,
),
],
),
),
const Icon(
Icons.verified_user_outlined,
color:
AppColors.primary,
),
],
),
);
}

// ==========================================================
// DASHBOARD CARD
// ==========================================================

Widget _dashboardCard({
required Widget child,
EdgeInsetsGeometry? padding,
}) {
return Container(
width: double.infinity,
padding:
padding ??
const EdgeInsets.all(18),
decoration: BoxDecoration(
color:
Theme.of(context).cardColor,
borderRadius:
BorderRadius.circular(20),
border: Border.all(
color: Theme.of(context)
    .dividerColor
    .withValues(
alpha: 0.25,
),
),
boxShadow: [
BoxShadow(
color:
Colors.black.withValues(
alpha: 0.025,
),
blurRadius: 12,
offset:
const Offset(0, 5),
),
],
),
child: child,
);
}

// ==========================================================
// ERROR STATE
// ==========================================================

Widget _buildErrorState() {
return Padding(
padding:
const EdgeInsets.all(24),
child: Column(
children: [
Icon(
Icons.cloud_off_rounded,
size: 65,
color:
AppColors.primary,
),
const SizedBox(height: 16),
const Text(
'Unable to load dashboard',
textAlign:
TextAlign.center,
style: TextStyle(
fontSize: 18,
fontWeight:
FontWeight.w700,
),
),
const SizedBox(height: 8),
Text(
_errorMessage,
textAlign:
TextAlign.center,
style: Theme.of(context)
    .textTheme
    .bodySmall,
),
const SizedBox(height: 18),
FilledButton.icon(
onPressed:
_loadDashboard,
icon: const Icon(
Icons.refresh_rounded,
),
label: const Text(
'Try Again',
),
),
],
),
);
}
}

// ============================================================
// STATUS DATA
// ============================================================

class _StatusData {
final String title;
final int count;
final IconData icon;

const _StatusData(
this.title,
this.count,
this.icon,
);
}
