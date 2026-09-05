import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/complaint.dart';
import '../../../models/complaint_status.dart';
import '../../../services/complaint_services.dart';

class AdminComplaintAnalyticsScreen extends StatefulWidget {
const AdminComplaintAnalyticsScreen({
super.key,
});

@override
State<AdminComplaintAnalyticsScreen> createState() =>
_AdminComplaintAnalyticsScreenState();
}

class _AdminComplaintAnalyticsScreenState
extends State<AdminComplaintAnalyticsScreen> {
final ComplaintService _complaintService =
ComplaintService.instance;

bool _isLoading = true;
String _errorMessage = '';
List<Complaint> _complaints = [];

@override
void initState() {
super.initState();
_loadAnalytics();
}

Future<void> _loadAnalytics() async {
if (!mounted) return;

setState(() {
_isLoading = true;
_errorMessage = '';
});

try {
final complaints =
await _complaintService.getAllComplaints();

if (!mounted) return;

final error = _complaintService.lastError;

if (error.isNotEmpty && complaints.isEmpty) {
setState(() {
_isLoading = false;
_errorMessage = error;
_complaints = [];
});
return;
}

setState(() {
_complaints = complaints;
_isLoading = false;
_errorMessage = '';
});
} catch (_) {
if (!mounted) return;

setState(() {
_isLoading = false;
_errorMessage =
'Unable to load complaint analytics. '
'Please try again.';
});
}
}

DateTime _startOfCurrentWeek() {
final now = DateTime.now();

final today = DateTime(
now.year,
now.month,
now.day,
);

return today.subtract(
Duration(days: today.weekday - 1),
);
}

DateTime _startOfNextWeek() {
return _startOfCurrentWeek().add(
const Duration(days: 7),
);
}

List<Complaint> get _currentWeekComplaints {
final monday = _startOfCurrentWeek();
final nextMonday = _startOfNextWeek();

return _complaints.where((complaint) {
final date = complaint.submittedDate;

final day = DateTime(
date.year,
date.month,
date.day,
);

return !day.isBefore(monday) &&
day.isBefore(nextMonday);
}).toList();
}

int _countStatus(
ComplaintStatus status, {
List<Complaint>? source,
}) {
final list = source ?? _currentWeekComplaints;

return list
    .where(
(complaint) => complaint.status == status,
)
    .length;
}

int get _weeklyTotal =>
_currentWeekComplaints.length;

int get _weeklyPending =>
_countStatus(
ComplaintStatus.submitted,
) +
_countStatus(
ComplaintStatus.underReview,
);

int get _weeklyResolved =>
_countStatus(
ComplaintStatus.resolved,
);

double get _resolutionRate {
if (_weeklyTotal == 0) {
return 0;
}

return (_weeklyResolved / _weeklyTotal) * 100;
}

Map<String, int> get _categoryCounts {
final counts = <String, int>{};

for (final complaint in _currentWeekComplaints) {
final category =
complaint.category.trim().isEmpty
? 'Other'
    : complaint.category.trim();

counts[category] =
(counts[category] ?? 0) + 1;
}

final entries = counts.entries.toList()
..sort(
(a, b) => b.value.compareTo(a.value),
);

return Map.fromEntries(entries);
}

List<int> get _dailyCounts {
final monday = _startOfCurrentWeek();

final counts = List<int>.filled(7, 0);

for (final complaint in _currentWeekComplaints) {
final date = complaint.submittedDate;

final day = DateTime(
date.year,
date.month,
date.day,
);

final difference =
day.difference(monday).inDays;

if (difference >= 0 &&
difference < 7) {
counts[difference]++;
}
}

return counts;
}

String _formatDate(DateTime date) {
const months = [
'Jan',
'Feb',
'Mar',
'Apr',
'May',
'Jun',
'Jul',
'Aug',
'Sep',
'Oct',
'Nov',
'Dec',
];

return '${months[date.month - 1]} '
'${date.day}, ${date.year}';
}

@override
Widget build(BuildContext context) {
final theme = Theme.of(context);

return Scaffold(
appBar: AppBar(
title: const Text(
'Complaint Analytics',
),
actions: [
IconButton(
tooltip: 'Refresh',
onPressed:
_isLoading ? null : _loadAnalytics,
icon: const Icon(
Icons.refresh_rounded,
),
),
],
),
body: _isLoading
? const Center(
child: CircularProgressIndicator(),
)
    : RefreshIndicator(
onRefresh: _loadAnalytics,
child: _buildBody(theme),
),
);
}

Widget _buildBody(ThemeData theme) {
if (_errorMessage.isNotEmpty) {
return ListView(
physics:
const AlwaysScrollableScrollPhysics(),
padding: const EdgeInsets.all(24),
children: [
const SizedBox(height: 100),
Icon(
Icons.error_outline_rounded,
size: 64,
color: theme.colorScheme.error,
),
const SizedBox(height: 16),
Text(
'Unable to Load Analytics',
textAlign: TextAlign.center,
style: theme.textTheme.titleLarge?.copyWith(
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 8),
Text(
_errorMessage,
textAlign: TextAlign.center,
style: theme.textTheme.bodyMedium,
),
const SizedBox(height: 20),
Center(
child: FilledButton.icon(
onPressed: _loadAnalytics,
icon: const Icon(
Icons.refresh_rounded,
),
label: const Text('Try Again'),
),
),
],
);
}

if (_complaints.isEmpty) {
return ListView(
physics:
const AlwaysScrollableScrollPhysics(),
padding: const EdgeInsets.all(24),
children: [
const SizedBox(height: 100),
Icon(
Icons.analytics_outlined,
size: 72,
color: theme.colorScheme.primary,
),
const SizedBox(height: 18),
Text(
'No Complaint Data',
textAlign: TextAlign.center,
style: theme.textTheme.titleLarge?.copyWith(
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 8),
Text(
'There are no complaints available '
'for analytics yet.',
textAlign: TextAlign.center,
style: theme.textTheme.bodyMedium,
),
],
);
}

return ListView(
physics:
const AlwaysScrollableScrollPhysics(),
padding: const EdgeInsets.fromLTRB(
16,
16,
16,
32,
),
children: [
_buildWeekHeader(theme),
const SizedBox(height: 16),
_buildSummaryCards(theme),
const SizedBox(height: 20),
_buildDailyChart(theme),
const SizedBox(height: 20),
_buildStatusDistribution(theme),
const SizedBox(height: 20),
_buildCategoryDistribution(theme),
const SizedBox(height: 20),
_buildOverallStats(theme),
],
);
}

Widget _buildWeekHeader(ThemeData theme) {
final monday = _startOfCurrentWeek();
final sunday = monday.add(
const Duration(days: 6),
);

return Card(
elevation: 0,
child: Padding(
padding: const EdgeInsets.all(18),
child: Row(
children: [
Container(
width: 48,
height: 48,
decoration: BoxDecoration(
color: theme.colorScheme.primary
    .withValues(alpha: 0.10),
borderRadius:
BorderRadius.circular(14),
),
child: Icon(
Icons.date_range_rounded,
color: theme.colorScheme.primary,
),
),
const SizedBox(width: 14),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
'Current Week',
style: theme.textTheme.titleMedium
    ?.copyWith(
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 4),
Text(
'${_formatDate(monday)} - '
'${_formatDate(sunday)}',
style: theme.textTheme.bodyMedium,
),
],
),
),
],
),
),
);
}

Widget _buildSummaryCards(ThemeData theme) {
return GridView.count(
crossAxisCount: 2,
crossAxisSpacing: 12,
mainAxisSpacing: 12,
childAspectRatio: 1.55,
shrinkWrap: true,
physics:
const NeverScrollableScrollPhysics(),
children: [
_summaryCard(
theme: theme,
title: 'Weekly Total',
value: _weeklyTotal.toString(),
icon: Icons.description_outlined,
),
_summaryCard(
theme: theme,
title: 'Pending',
value: _weeklyPending.toString(),
icon: Icons.pending_actions_rounded,
),
_summaryCard(
theme: theme,
title: 'Resolved',
value: _weeklyResolved.toString(),
icon: Icons.check_circle_outline_rounded,
),
_summaryCard(
theme: theme,
title: 'Resolution Rate',
value:
'${_resolutionRate.toStringAsFixed(1)}%',
icon: Icons.percent_rounded,
),
],
);
}

Widget _summaryCard({
required ThemeData theme,
required String title,
required String value,
required IconData icon,
}) {
return Card(
elevation: 0,
child: Padding(
padding: const EdgeInsets.all(14),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Icon(
icon,
color: theme.colorScheme.primary,
),
const Spacer(),
Text(
value,
maxLines: 1,
overflow: TextOverflow.ellipsis,
style: theme.textTheme.headlineSmall
    ?.copyWith(
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 2),
Text(
title,
maxLines: 1,
overflow: TextOverflow.ellipsis,
style: theme.textTheme.bodySmall,
),
],
),
),
);
}

Widget _buildDailyChart(ThemeData theme) {
final counts = _dailyCounts;

const days = [
'Mon',
'Tue',
'Wed',
'Thu',
'Fri',
'Sat',
'Sun',
];

final maxCount = counts.fold<int>(
0,
(max, value) => value > max ? value : max,
);

return _sectionCard(
theme: theme,
title: 'Weekly Complaints',
icon: Icons.bar_chart_rounded,
child: SizedBox(
height: 240,
child: Row(
crossAxisAlignment:
CrossAxisAlignment.end,
children: List.generate(
7,
(index) {
final count = counts[index];

final height = maxCount == 0
? 8.0
    : 130 *
(count / maxCount);

return Expanded(
child: Padding(
padding:
const EdgeInsets.symmetric(
horizontal: 4,
),
child: Column(
mainAxisAlignment:
MainAxisAlignment.end,
children: [
Text(
count.toString(),
style: theme.textTheme.bodySmall
    ?.copyWith(
fontWeight:
FontWeight.bold,
),
),
const SizedBox(height: 6),
Container(
width: double.infinity,
height: height,
constraints:
const BoxConstraints(
minHeight: 8,
),
decoration: BoxDecoration(
color:
theme.colorScheme.primary,
borderRadius:
const BorderRadius
    .vertical(
top: Radius.circular(8),
),
),
),
const SizedBox(height: 8),
Text(
days[index],
style:
theme.textTheme.bodySmall,
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

Widget _buildStatusDistribution(
ThemeData theme,
) {
final statuses = [
ComplaintStatus.submitted,
ComplaintStatus.underReview,
ComplaintStatus.inProgress,
ComplaintStatus.resolved,
ComplaintStatus.closed,
];

return _sectionCard(
theme: theme,
title: 'Status Distribution',
icon: Icons.pie_chart_outline_rounded,
child: Column(
children: statuses.map((status) {
final count = _countStatus(status);

final percentage = _weeklyTotal == 0
? 0.0
    : count / _weeklyTotal;

return Padding(
padding:
const EdgeInsets.only(bottom: 14),
child: _distributionRow(
theme: theme,
title: status.label,
count: count,
percentage: percentage,
),
);
}).toList(),
),
);
}

Widget _buildCategoryDistribution(
ThemeData theme,
) {
final categories = _categoryCounts;

if (categories.isEmpty) {
return _sectionCard(
theme: theme,
title: 'Category Distribution',
icon: Icons.category_outlined,
child: const Padding(
padding: EdgeInsets.symmetric(
vertical: 12,
),
child: Text(
'No complaints were submitted '
'this week.',
),
),
);
}

return _sectionCard(
theme: theme,
title: 'Category Distribution',
icon: Icons.category_outlined,
child: Column(
children: categories.entries.map((entry) {
final percentage = _weeklyTotal == 0
? 0.0
    : entry.value / _weeklyTotal;

return Padding(
padding:
const EdgeInsets.only(bottom: 14),
child: _distributionRow(
theme: theme,
title: entry.key,
count: entry.value,
percentage: percentage,
),
);
}).toList(),
),
);
}

Widget _distributionRow({
required ThemeData theme,
required String title,
required int count,
required double percentage,
}) {
return Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
children: [
Expanded(
child: Text(
title,
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style:
theme.textTheme.bodyMedium
    ?.copyWith(
fontWeight: FontWeight.w600,
),
),
),
Text(
'$count',
style:
theme.textTheme.bodyMedium
    ?.copyWith(
fontWeight: FontWeight.bold,
),
),
const SizedBox(width: 8),
SizedBox(
width: 48,
child: Text(
'${(percentage * 100).toStringAsFixed(0)}%',
textAlign: TextAlign.end,
style:
theme.textTheme.bodySmall,
),
),
],
),
const SizedBox(height: 7),
ClipRRect(
borderRadius:
BorderRadius.circular(10),
child: LinearProgressIndicator(
value: percentage,
minHeight: 8,
backgroundColor:
theme.colorScheme.surfaceContainerHighest,
),
),
],
);
}

Widget _buildOverallStats(ThemeData theme) {
final total = _complaints.length;

final submitted = _countStatus(
ComplaintStatus.submitted,
source: _complaints,
);

final underReview = _countStatus(
ComplaintStatus.underReview,
source: _complaints,
);

final inProgress = _countStatus(
ComplaintStatus.inProgress,
source: _complaints,
);

final resolved = _countStatus(
ComplaintStatus.resolved,
source: _complaints,
);

final closed = _countStatus(
ComplaintStatus.closed,
source: _complaints,
);

return _sectionCard(
theme: theme,
title: 'Overall Complaint Statistics',
icon: Icons.insights_outlined,
child: Column(
children: [
_statRow(
theme: theme,
title: 'Total Complaints',
value: total.toString(),
),
_statRow(
theme: theme,
title: 'Submitted',
value: submitted.toString(),
),
_statRow(
theme: theme,
title: 'Under Review',
value: underReview.toString(),
),
_statRow(
theme: theme,
title: 'In Progress',
value: inProgress.toString(),
),
_statRow(
theme: theme,
title: 'Resolved',
value: resolved.toString(),
),
_statRow(
theme: theme,
title: 'Closed',
value: closed.toString(),
),
],
),
);
}

Widget _statRow({
required ThemeData theme,
required String title,
required String value,
}) {
return Padding(
padding:
const EdgeInsets.symmetric(
vertical: 8,
),
child: Row(
children: [
Expanded(
child: Text(
title,
style:
theme.textTheme.bodyMedium,
),
),
Text(
value,
style:
theme.textTheme.bodyMedium
    ?.copyWith(
fontWeight: FontWeight.bold,
color:
theme.colorScheme.primary,
),
),
],
),
);
}

Widget _sectionCard({
required ThemeData theme,
required String title,
required IconData icon,
required Widget child,
}) {
return Card(
elevation: 0,
child: Padding(
padding: const EdgeInsets.all(18),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
children: [
Icon(
icon,
color:
theme.colorScheme.primary,
),
const SizedBox(width: 10),
Expanded(
child: Text(
title,
style: theme.textTheme.titleMedium
    ?.copyWith(
fontWeight:
FontWeight.bold,
),
),
),
],
),
const SizedBox(height: 18),
child,
],
),
),
);
}
}

