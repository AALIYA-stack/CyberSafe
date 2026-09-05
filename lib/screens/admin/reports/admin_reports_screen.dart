import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/quiz_store.dart';
import '../../../models/complaint.dart';
import '../../../models/complaint_status.dart';
import '../../../models/quiz_result.dart';
import '../../../services/complaint_services.dart';

class AdminReportsScreen extends StatefulWidget {
const AdminReportsScreen({super.key});

@override
State<AdminReportsScreen> createState() =>
_AdminReportsScreenState();
}

class _AdminReportsScreenState
extends State<AdminReportsScreen> {
final ComplaintService _complaintService =
ComplaintService.instance;

// ============================================================
// COMPLAINT ANALYTICS
// ============================================================

bool _isLoading = true;
String _errorMessage = '';

List<Complaint> _complaints = [];

int _weeklyComplaints = 0;
int _weeklyTotal = 0;
int _weeklyResolved = 0;

List<_DayComplaintData> _weeklyData = [];

int _maxDailyCount = 1;

Map<String, int> _statusCount = {};

String _topCategory = 'No data';
int _topCategoryCount = 0;

// ============================================================
// QUIZ ANALYTICS
// ============================================================

bool _isLoadingQuiz = true;
String _quizErrorMessage = '';

List<QuizResult> _allQuizResults = [];

int _totalQuizAttempts = 0;
int _completedQuizzes = 0;

double _averageQuizScore = 0;
double _completionRate = 0;

double _highestQuizScore = 0;
double _lowestQuizScore = 0;

// ============================================================
// TOPIC ANALYTICS
// ============================================================

List<Map<String, dynamic>> _topicAnalytics = [];

String _mostDifficultTopic = 'No data';
double _mostDifficultAccuracy = 0;

// ============================================================
// FIREBASE STREAM
// ============================================================

StreamSubscription<List<Complaint>>?
_complaintSubscription;

// ============================================================
// INIT
// ============================================================

@override
void initState() {
super.initState();

_startComplaintStream();
_loadQuizReports();
}

// ============================================================
// DISPOSE
// ============================================================

@override
void dispose() {
_complaintSubscription?.cancel();
super.dispose();
}

// ============================================================
// START LIVE COMPLAINT STREAM
// ============================================================

void _startComplaintStream() {
if (mounted) {
setState(() {
_isLoading = true;
_errorMessage = '';
});
}

_complaintSubscription?.cancel();

_complaintSubscription =
_complaintService.allComplaintsStream().listen(
(complaints) {
if (!mounted) return;

_calculateComplaintAnalytics(
complaints,
);

setState(() {
_complaints = complaints;
_isLoading = false;
_errorMessage = '';
});
},
onError: (Object error) {
if (!mounted) return;

setState(() {
_isLoading = false;
_errorMessage =
'Unable to load complaint reports.';
});
},
);
}

// ============================================================
// MAIN LOAD
// ============================================================

Future<void> _loadReports() async {
_startComplaintStream();

await _loadQuizReports();
}

// ============================================================
// MANUAL COMPLAINT REFRESH
// ============================================================

Future<void> _loadComplaintReports() async {
_startComplaintStream();
}

// ============================================================
// CALCULATE COMPLAINT ANALYTICS
// ============================================================

void _calculateComplaintAnalytics(
List<Complaint> complaints,
) {
final now = DateTime.now();

// ----------------------------------------------------------
// MONDAY OF CURRENT WEEK
// ----------------------------------------------------------

final monday = DateTime(
now.year,
now.month,
now.day,
).subtract(
Duration(
days: now.weekday - DateTime.monday,
),
);

final sunday =
monday.add(const Duration(days: 6));

int weeklyCount = 0;
int weeklyResolved = 0;

final List<_DayComplaintData> dailyData = [];

// ----------------------------------------------------------
// DAILY DATA
// ----------------------------------------------------------

for (int i = 0; i < 7; i++) {
final day = monday.add(
Duration(days: i),
);

int count = 0;

for (final complaint in complaints) {
final date = complaint.submittedDate;

final sameDay =
date.year == day.year &&
date.month == day.month &&
date.day == day.day;

if (sameDay) {
count++;
}
}

dailyData.add(
_DayComplaintData(
day: _dayName(i),
count: count,
),
);
}

// ----------------------------------------------------------
// WEEKLY TOTALS
// ----------------------------------------------------------

final startOnly = DateTime(
monday.year,
monday.month,
monday.day,
);

final endOnly = DateTime(
sunday.year,
sunday.month,
sunday.day,
);

for (final complaint in complaints) {
final date = complaint.submittedDate;

final dateOnly = DateTime(
date.year,
date.month,
date.day,
);

final isThisWeek =
!dateOnly.isBefore(startOnly) &&
!dateOnly.isAfter(endOnly);

if (isThisWeek) {
weeklyCount++;

if (complaint.status ==
ComplaintStatus.resolved) {
weeklyResolved++;
}
}
}

// ----------------------------------------------------------
// STATUS COUNT
// ----------------------------------------------------------

final statusCounts = <String, int>{};

for (final complaint in complaints) {
final status =
complaint.status.displayName;

statusCounts[status] =
(statusCounts[status] ?? 0) + 1;
}

// ----------------------------------------------------------
// CATEGORY COUNT
// ----------------------------------------------------------

final categoryCounts = <String, int>{};

for (final complaint in complaints) {
final category =
complaint.category.trim().isEmpty
? 'Other'
    : complaint.category.trim();

categoryCounts[category] =
(categoryCounts[category] ?? 0) + 1;
}

// ----------------------------------------------------------
// TOP CATEGORY
// ----------------------------------------------------------

String topCategory = 'No data';
int topCategoryCount = 0;

for (final entry in categoryCounts.entries) {
if (entry.value > topCategoryCount) {
topCategory = entry.key;
topCategoryCount = entry.value;
}
}

// ----------------------------------------------------------
// MAX DAILY COUNT
// ----------------------------------------------------------

int maxDaily = 1;

for (final item in dailyData) {
if (item.count > maxDaily) {
maxDaily = item.count;
}
}

if (!mounted) return;

setState(() {
_weeklyComplaints = weeklyCount;
_weeklyTotal = complaints.length;
_weeklyResolved = weeklyResolved;
_weeklyData = dailyData;
_maxDailyCount = maxDaily;
_statusCount = statusCounts;
_topCategory = topCategory;
_topCategoryCount = topCategoryCount;
});
}

// ============================================================
// DAY NAME
// ============================================================

String _dayName(int index) {
const days = [
'Mon',
'Tue',
'Wed',
'Thu',
'Fri',
'Sat',
'Sun',
];

return days[index];
}

// ============================================================
// QUIZ REPORTS
// ============================================================
//
// IMPORTANT:
//
// One Firebase query is used:
//
// quiz_results
//      ↓
// getAllResultsForAdmin()
//      ↓
// calculate everything locally
//
// This avoids:
//
// getAllResultsForAdmin()
// getAdminAnalytics()
// getTopicAnalytics()
//
// all making separate Firebase reads.
// ============================================================

Future<void> _loadQuizReports() async {
if (mounted) {
setState(() {
_isLoadingQuiz = true;
_quizErrorMessage = '';
});
}

try {
// --------------------------------------------------------
// ONE FIREBASE QUERY
// --------------------------------------------------------

final results =
await QuizStore.getAllResultsForAdmin();

// --------------------------------------------------------
// SORT NEWEST FIRST
// --------------------------------------------------------

results.sort(
(a, b) => b.completedAt.compareTo(
a.completedAt,
),
);

// --------------------------------------------------------
// BASIC ANALYTICS
// --------------------------------------------------------

final totalAttempts = results.length;

int completed = 0;

double totalScore = 0;

double highest = 0;

double lowest =
results.isEmpty ? 0 : 100;

for (final result in results) {
if (result.completed) {
completed++;
}

final percentage =
result.percentage;

totalScore += percentage;

if (percentage > highest) {
highest = percentage;
}

if (percentage < lowest) {
lowest = percentage;
}
}

final average = results.isEmpty
? 0.0
    : totalScore / results.length;

final completionRate =
results.isEmpty
? 0.0
    : (completed / results.length) *
100;

// --------------------------------------------------------
// TOPIC ANALYTICS
// --------------------------------------------------------

final topicAnalytics =
_calculateTopicAnalytics(results);

// --------------------------------------------------------
// MOST DIFFICULT TOPIC
// --------------------------------------------------------

String mostDifficult = 'No data';
double mostDifficultAccuracy = 0;

if (topicAnalytics.isNotEmpty) {
final first =
topicAnalytics.first;

mostDifficult =
first['category']?.toString() ??
'No data';

mostDifficultAccuracy =
_toDouble(first['accuracy']);
}

// --------------------------------------------------------
// UPDATE UI
// --------------------------------------------------------

if (!mounted) return;

setState(() {
_allQuizResults = results;

_totalQuizAttempts =
totalAttempts;

_completedQuizzes =
completed;

_averageQuizScore =
average;

_completionRate =
completionRate;

_highestQuizScore =
highest;

_lowestQuizScore =
lowest;

_topicAnalytics =
topicAnalytics;

_mostDifficultTopic =
mostDifficult;

_mostDifficultAccuracy =
mostDifficultAccuracy;

_isLoadingQuiz = false;
_quizErrorMessage = '';
});
} catch (e) {
if (!mounted) return;

setState(() {
_isLoadingQuiz = false;
_quizErrorMessage =
'Unable to load quiz analytics.';
});
}
}

// ============================================================
// CALCULATE TOPIC ANALYTICS
// ============================================================

List<Map<String, dynamic>>
_calculateTopicAnalytics(
List<QuizResult> results,
) {
final Map<String, int> categoryCorrect = {};
final Map<String, int> categoryTotal = {};

// ----------------------------------------------------------
// AGGREGATE ALL USER RESULTS
// ----------------------------------------------------------

for (final result in results) {
// --------------------------------------------------------
// CATEGORY TOTAL
// --------------------------------------------------------

for (final entry
in result.categoryTotal.entries) {
final category =
entry.key.trim().isEmpty
? 'Other'
    : entry.key.trim();

final total =
_toInt(entry.value);

categoryTotal[category] =
(categoryTotal[category] ?? 0) +
total;
}

// --------------------------------------------------------
// CATEGORY CORRECT
// --------------------------------------------------------

for (final entry
in result.categoryCorrect.entries) {
final category =
entry.key.trim().isEmpty
? 'Other'
    : entry.key.trim();

final correct =
_toInt(entry.value);

categoryCorrect[category] =
(categoryCorrect[category] ?? 0) +
correct;
}
}

// ----------------------------------------------------------
// BUILD ANALYTICS LIST
// ----------------------------------------------------------

final List<Map<String, dynamic>>
analytics = [];

for (final category
in categoryTotal.keys) {
final total =
categoryTotal[category] ?? 0;

final correct =
categoryCorrect[category] ?? 0;

final wrong =
total - correct;

final accuracy = total <= 0
? 0.0
    : (correct / total) * 100;

analytics.add({
'category': category,
'totalQuestions': total,
'correctAnswers': correct,
'wrongAnswers':
wrong < 0 ? 0 : wrong,
'accuracy': accuracy,
});
}

// ----------------------------------------------------------
// LOWEST ACCURACY FIRST
// ----------------------------------------------------------

analytics.sort(
(a, b) {
final accuracyA =
_toDouble(a['accuracy']);

final accuracyB =
_toDouble(b['accuracy']);

return accuracyA.compareTo(
accuracyB,
);
},
);

return analytics;
}

// ============================================================
// SAFE DOUBLE
// ============================================================

double _toDouble(dynamic value) {
if (value is num) {
return value.toDouble();
}

return double.tryParse(
value?.toString() ?? '',
) ??
0;
}

// ============================================================
// SAFE INT
// ============================================================

int _toInt(dynamic value) {
if (value is int) {
return value;
}

if (value is num) {
return value.toInt();
}

return int.tryParse(
value?.toString() ?? '',
) ??
0;
}

// ============================================================
// REFRESH
// ============================================================

Future<void> _refresh() async {
// ----------------------------------------------------------
// RESTART COMPLAINT STREAM
// ----------------------------------------------------------

_startComplaintStream();

// ----------------------------------------------------------
// RELOAD QUIZ DATA
// ----------------------------------------------------------

await _loadQuizReports();
}

// ============================================================
// BUILD
// ============================================================

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text(
'Reports & Analytics',
style: TextStyle(
fontWeight: FontWeight.w800,
),
),
actions: [
IconButton(
tooltip: 'Refresh',
onPressed: _refresh,
icon: const Icon(
Icons.refresh_rounded,
),
),
],
),
body: RefreshIndicator(
onRefresh: _refresh,
child: SingleChildScrollView(
physics:
const AlwaysScrollableScrollPhysics(),
padding:
const EdgeInsets.fromLTRB(
16,
16,
16,
30,
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
_buildHeader(),

const SizedBox(height: 20),

_buildComplaintSection(),

const SizedBox(height: 28),

_buildQuizSection(),
],
),
),
),
);
}

// ============================================================
// HEADER
// ============================================================

Widget _buildHeader() {
return Container(
width: double.infinity,
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
gradient: LinearGradient(
colors: [
AppColors.primary,
AppColors.primary.withValues(
alpha: 0.82,
),
],
),
borderRadius:
BorderRadius.circular(22),
),
child: const Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Icon(
Icons.analytics_rounded,
color: Colors.white,
size: 34,
),
SizedBox(height: 14),
Text(
'Reports & Analytics',
style: TextStyle(
color: Colors.white,
fontSize: 24,
fontWeight: FontWeight.w900,
),
),
SizedBox(height: 6),
Text(
'Monitor complaints, quiz performance and cyber safety trends.',
style: TextStyle(
color: Colors.white70,
fontSize: 13,
height: 1.45,
),
),
],
),
);
}

// ============================================================
// COMPLAINT SECTION
// ============================================================

Widget _buildComplaintSection() {
return Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'Complaint Analytics',
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.w900,
),
),
const SizedBox(height: 5),
Text(
'Weekly and overall complaint statistics',
style: TextStyle(
color: Colors.grey.shade600,
fontSize: 13,
),
),
const SizedBox(height: 16),
if (_isLoading)
const _ReportCardContainer(
child: SizedBox(
height: 180,
child: Center(
child:
CircularProgressIndicator(),
),
),
)
else if (_errorMessage.isNotEmpty)
_buildErrorCard(
_errorMessage,
_loadComplaintReports,
)
else ...[
_buildComplaintStats(),

const SizedBox(height: 16),

_buildWeeklyChart(),

const SizedBox(height: 16),

_buildStatusAnalytics(),

const SizedBox(height: 16),

_buildCategoryAnalytics(),
],
],
);
}

// ============================================================
// COMPLAINT STATS
// ============================================================

Widget _buildComplaintStats() {
return Row(
children: [
Expanded(
child: _StatCard(
title: 'This Week',
value:
_weeklyComplaints.toString(),
icon:
Icons.calendar_month_rounded,
iconColor:
AppColors.primary,
),
),
const SizedBox(width: 10),
Expanded(
child: _StatCard(
title: 'All Complaints',
value:
_weeklyTotal.toString(),
icon:
Icons.assignment_rounded,
iconColor: Colors.orange,
),
),
const SizedBox(width: 10),
Expanded(
child: _StatCard(
title: 'Resolved',
value:
_weeklyResolved.toString(),
icon:
Icons.check_circle_rounded,
iconColor: Colors.green,
),
),
],
);
}

// ============================================================
// WEEKLY CHART
// ============================================================

Widget _buildWeeklyChart() {
return _ReportCardContainer(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Row(
children: [
Icon(
Icons.bar_chart_rounded,
size: 22,
),
SizedBox(width: 8),
Text(
'Weekly Complaints',
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.w800,
),
),
],
),
const SizedBox(height: 22),
SizedBox(
height: 190,
child: Row(
crossAxisAlignment:
CrossAxisAlignment.end,
children: _weeklyData.map(
(item) {
final double height =
item.count <= 0
? 4
    : (item.count /
_maxDailyCount) *
125;

return Expanded(
child: Padding(
padding:
const EdgeInsets
    .symmetric(
horizontal: 4,
),
child: Column(
mainAxisAlignment:
MainAxisAlignment.end,
children: [
Text(
'${item.count}',
style:
const TextStyle(
fontSize: 11,
fontWeight:
FontWeight.w800,
),
),
const SizedBox(
height: 5,
),
AnimatedContainer(
duration:
const Duration(
milliseconds: 300,
),
width: 22,
height: height,
decoration:
BoxDecoration(
color:
AppColors.primary,
borderRadius:
BorderRadius
    .circular(
8,
),
),
),
const SizedBox(
height: 8,
),
Text(
item.day,
style: TextStyle(
fontSize: 10,
color: Colors
    .grey
    .shade600,
fontWeight:
FontWeight.w600,
),
),
],
),
),
);
},
).toList(),
),
),
],
),
);
}

// ============================================================
// STATUS ANALYTICS
// ============================================================

Widget _buildStatusAnalytics() {
final submitted =
_getStatusCount('Submitted');

final underReview =
_getStatusCount('Under Review');

final inProgress =
_getStatusCount('In Progress');

final resolved =
_getStatusCount('Resolved');

final closed =
_getStatusCount('Closed');

return _ReportCardContainer(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Row(
children: [
Icon(
Icons.track_changes_rounded,
size: 22,
),
SizedBox(width: 8),
Text(
'Complaint Status',
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.w800,
),
),
],
),
const SizedBox(height: 16),
_StatusDataRow(
title: 'Submitted',
value: submitted,
icon:
Icons.fiber_new_rounded,
iconColor: Colors.blue,
),
_StatusDataRow(
title: 'Under Review',
value: underReview,
icon:
Icons.visibility_rounded,
iconColor: Colors.orange,
),
_StatusDataRow(
title: 'In Progress',
value: inProgress,
icon:
Icons.pending_actions_rounded,
iconColor:
Colors.deepPurple,
),
_StatusDataRow(
title: 'Resolved',
value: resolved,
icon:
Icons.check_circle_rounded,
iconColor: Colors.green,
),
_StatusDataRow(
title: 'Closed',
value: closed,
icon:
Icons.lock_rounded,
iconColor: Colors.grey,
),
],
),
);
}

int _getStatusCount(String status) {
int count = 0;

for (final entry
in _statusCount.entries) {
if (entry.key.toLowerCase() ==
status.toLowerCase()) {
count += entry.value;
}
}

return count;
}

// ============================================================
// CATEGORY ANALYTICS
// ============================================================

Widget _buildCategoryAnalytics() {
return _ReportCardContainer(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Row(
children: [
Icon(
Icons.category_rounded,
size: 22,
),
SizedBox(width: 8),
Text(
'Top Complaint Category',
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.w800,
),
),
],
),
const SizedBox(height: 18),
Container(
width: double.infinity,
padding:
const EdgeInsets.all(16),
decoration: BoxDecoration(
color: AppColors.primary
    .withValues(alpha: 0.07),
borderRadius:
BorderRadius.circular(16),
),
child: Row(
children: [
Container(
width: 46,
height: 46,
decoration:
BoxDecoration(
color: AppColors.primary
    .withValues(
alpha: 0.12,
),
shape: BoxShape.circle,
),
child: Icon(
Icons.category_rounded,
color:
AppColors.primary,
),
),
const SizedBox(width: 14),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,
children: [
Text(
_topCategory,
style:
const TextStyle(
fontSize: 15,
fontWeight:
FontWeight.w800,
),
),
const SizedBox(
height: 4,
),
Text(
'$_topCategoryCount complaint(s)',
style: TextStyle(
fontSize: 12,
color: Colors
    .grey
    .shade600,
),
),
],
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
// QUIZ SECTION
// ============================================================

Widget _buildQuizSection() {
return Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'Quiz Analytics',
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.w900,
),
),
const SizedBox(height: 5),
Text(
'Cyber Safety Quiz performance from Firebase',
style: TextStyle(
color: Colors.grey.shade600,
fontSize: 13,
),
),
const SizedBox(height: 16),
if (_isLoadingQuiz)
const _ReportCardContainer(
child: SizedBox(
height: 180,
child: Center(
child:
CircularProgressIndicator(),
),
),
)
else if (_quizErrorMessage.isNotEmpty)
_buildErrorCard(
_quizErrorMessage,
_loadQuizReports,
)
else ...[
_buildQuizAnalytics(),

const SizedBox(height: 16),

_buildDifficultTopics(),

const SizedBox(height: 16),

_buildQuizResults(),
],
],
);
}

// ============================================================
// QUIZ ANALYTICS
// ============================================================

Widget _buildQuizAnalytics() {
return Column(
children: [
Row(
children: [
Expanded(
child: _StatCard(
title: 'Attempts',
value:
'$_totalQuizAttempts',
icon:
Icons.quiz_rounded,
iconColor:
AppColors.primary,
),
),
const SizedBox(width: 10),
Expanded(
child: _StatCard(
title: 'Completed',
value:
'$_completedQuizzes',
icon:
Icons.task_alt_rounded,
iconColor: Colors.green,
),
),
],
),
const SizedBox(height: 10),
Row(
children: [
Expanded(
child: _StatCard(
title: 'Average',
value:
'${_averageQuizScore.round()}%',
icon:
Icons.analytics_rounded,
iconColor:
Colors.orange,
),
),
const SizedBox(width: 10),
Expanded(
child: _StatCard(
title: 'Completion',
value:
'${_completionRate.round()}%',
icon:
Icons.pie_chart_rounded,
iconColor:
Colors.deepPurple,
),
),
],
),
const SizedBox(height: 10),
Row(
children: [
Expanded(
child: _StatCard(
title: 'Highest',
value:
'${_highestQuizScore.round()}%',
icon:
Icons.arrow_upward_rounded,
iconColor: Colors.green,
),
),
const SizedBox(width: 10),
Expanded(
child: _StatCard(
title: 'Lowest',
value:
'${_lowestQuizScore.round()}%',
icon:
Icons.arrow_downward_rounded,
iconColor: Colors.red,
),
),
],
),
],
);
}

// ============================================================
// DIFFICULT TOPICS
// ============================================================

Widget _buildDifficultTopics() {
return _ReportCardContainer(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Row(
children: [
Icon(
Icons.warning_amber_rounded,
size: 22,
),
SizedBox(width: 8),
Text(
'Difficult Topics',
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.w800,
),
),
],
),
const SizedBox(height: 8),
Text(
'Topics are calculated from real user answers.',
style: TextStyle(
fontSize: 12,
color: Colors.grey.shade600,
),
),
const SizedBox(height: 16),
if (_topicAnalytics.isEmpty)
_buildNoTopicData()
else ...[
Container(
width: double.infinity,
padding:
const EdgeInsets.all(14),
decoration: BoxDecoration(
color: Colors.red
    .withValues(alpha: 0.06),
borderRadius:
BorderRadius.circular(16),
),
child: Row(
children: [
Container(
width: 42,
height: 42,
decoration:
BoxDecoration(
color: Colors.red
    .withValues(
alpha: 0.10,
),
shape: BoxShape.circle,
),
child: const Icon(
Icons.warning_rounded,
color: Colors.red,
),
),
const SizedBox(width: 12),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,
children: [
const Text(
'Most Difficult Topic',
style: TextStyle(
fontSize: 11,
fontWeight:
FontWeight.w600,
),
),
const SizedBox(
height: 3,
),
Text(
_mostDifficultTopic,
style:
const TextStyle(
fontSize: 15,
fontWeight:
FontWeight.w900,
),
),
const SizedBox(
height: 3,
),
Text(
'${_mostDifficultAccuracy.round()}% accuracy',
style: TextStyle(
fontSize: 12,
color: Colors
    .grey
    .shade600,
),
),
],
),
),
],
),
),
const SizedBox(height: 16),
..._topicAnalytics.map(
(topic) {
return _buildTopicRow(
topic,
);
},
),
],
],
),
);
}

// ============================================================
// NO TOPIC DATA
// ============================================================

Widget _buildNoTopicData() {
return Container(
width: double.infinity,
padding:
const EdgeInsets.all(18),
decoration: BoxDecoration(
color: Colors.grey
    .withValues(alpha: 0.06),
borderRadius:
BorderRadius.circular(16),
),
child: Column(
children: [
Icon(
Icons.school_rounded,
size: 36,
color: Colors.grey.shade500,
),
const SizedBox(height: 10),
const Text(
'No topic analytics yet',
style: TextStyle(
fontWeight: FontWeight.w800,
),
),
const SizedBox(height: 5),
Text(
'Complete a new quiz attempt to generate topic-wise analytics.',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 12,
color: Colors.grey.shade600,
height: 1.4,
),
),
],
),
);
}

// ============================================================
// TOPIC ROW
// ============================================================

Widget _buildTopicRow(
Map<String, dynamic> topic,
) {
final category =
topic['category']?.toString() ??
'Other';

final total =
_toInt(topic['totalQuestions']);

final correct =
_toInt(topic['correctAnswers']);

final wrong =
_toInt(topic['wrongAnswers']);

final accuracy =
_toDouble(topic['accuracy']);

final progress =
(accuracy / 100).clamp(0.0, 1.0);

final bool difficult =
accuracy < 60;

return Padding(
padding:
const EdgeInsets.only(
bottom: 14,
),
child: Container(
padding:
const EdgeInsets.all(14),
decoration: BoxDecoration(
border: Border.all(
color: Colors.grey
    .withValues(alpha: 0.12),
),
borderRadius:
BorderRadius.circular(16),
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
children: [
Expanded(
child: Text(
category,
style:
const TextStyle(
fontSize: 14,
fontWeight:
FontWeight.w800,
),
),
),
Container(
padding:
const EdgeInsets
    .symmetric(
horizontal: 9,
vertical: 5,
),
decoration:
BoxDecoration(
color: difficult
? Colors.red
    .withValues(
alpha: 0.09,
)
    : Colors.green
    .withValues(
alpha: 0.09,
),
borderRadius:
BorderRadius.circular(
10,
),
),
child: Text(
'${accuracy.round()}%',
style: TextStyle(
fontSize: 12,
fontWeight:
FontWeight.w900,
color: difficult
? Colors.red
    : Colors.green,
),
),
),
],
),
const SizedBox(height: 10),
ClipRRect(
borderRadius:
BorderRadius.circular(20),
child:
LinearProgressIndicator(
value: progress,
minHeight: 8,
backgroundColor:
Colors.grey.withValues(
alpha: 0.12,
),
valueColor:
AlwaysStoppedAnimation<
Color>(
difficult
? Colors.red
    : AppColors.primary,
),
),
),
const SizedBox(height: 9),
Row(
children: [
Expanded(
child: Text(
'Correct: $correct',
style: TextStyle(
fontSize: 11,
color: Colors
    .green
    .shade700,
fontWeight:
FontWeight.w600,
),
),
),
Expanded(
child: Text(
'Wrong: $wrong',
textAlign:
TextAlign.center,
style: TextStyle(
fontSize: 11,
color:
Colors.red.shade700,
fontWeight:
FontWeight.w600,
),
),
),
Expanded(
child: Text(
'Total: $total',
textAlign:
TextAlign.end,
style: TextStyle(
fontSize: 11,
color: Colors
    .grey
    .shade600,
fontWeight:
FontWeight.w600,
),
),
),
],
),
],
),
),
);
}

// ============================================================
// RECENT QUIZ RESULTS
// ============================================================

Widget _buildQuizResults() {
return _ReportCardContainer(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Row(
children: [
Icon(
Icons.history_rounded,
size: 22,
),
SizedBox(width: 8),
Text(
'Recent Quiz Results',
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.w800,
),
),
],
),
const SizedBox(height: 16),
if (_allQuizResults.isEmpty)
_buildEmptyResults()
else
..._allQuizResults
    .take(10)
    .map(
(result) =>
_buildQuizResultRow(
result,
),
),
],
),
);
}

// ============================================================
// QUIZ RESULT ROW
// ============================================================

Widget _buildQuizResultRow(
QuizResult result,
) {
final percentage =
result.percentage.round();

final scoreText =
'${result.score}/${result.totalQuestions}';

return Container(
margin:
const EdgeInsets.only(bottom: 10),
padding:
const EdgeInsets.all(13),
decoration: BoxDecoration(
color: Colors.grey
    .withValues(alpha: 0.05),
borderRadius:
BorderRadius.circular(14),
),
child: Row(
children: [
Container(
width: 42,
height: 42,
decoration:
BoxDecoration(
color: AppColors.primary
    .withValues(alpha: 0.08),
shape: BoxShape.circle,
),
child: Icon(
percentage >= 60
? Icons.check_rounded
    : Icons.school_rounded,
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
children: [
Text(
scoreText,
style:
const TextStyle(
fontSize: 14,
fontWeight:
FontWeight.w800,
),
),
const SizedBox(height: 3),
Text(
_formatDate(
result.completedAt,
),
style: TextStyle(
fontSize: 11,
color: Colors
    .grey
    .shade600,
),
),
],
),
),
Container(
padding:
const EdgeInsets.symmetric(
horizontal: 10,
vertical: 6,
),
decoration: BoxDecoration(
color: percentage >= 60
? Colors.green
    .withValues(
alpha: 0.08,
)
    : Colors.red
    .withValues(
alpha: 0.08,
),
borderRadius:
BorderRadius.circular(10),
),
child: Text(
'$percentage%',
style: TextStyle(
fontSize: 12,
fontWeight:
FontWeight.w900,
color: percentage >= 60
? Colors.green
    : Colors.red,
),
),
),
],
),
);
}

// ============================================================
// EMPTY RESULTS
// ============================================================

Widget _buildEmptyResults() {
return Container(
width: double.infinity,
padding:
const EdgeInsets.all(18),
child: Column(
children: [
Icon(
Icons.quiz_outlined,
size: 40,
color: Colors.grey.shade500,
),
const SizedBox(height: 10),
const Text(
'No quiz results yet',
style: TextStyle(
fontWeight: FontWeight.w800,
),
),
const SizedBox(height: 4),
Text(
'Quiz results will appear here after users complete the quiz.',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 12,
color: Colors.grey.shade600,
),
),
],
),
);
}

// ============================================================
// ERROR CARD
// ============================================================

Widget _buildErrorCard(
String message,
VoidCallback onRetry,
) {
return _ReportCardContainer(
child: Column(
children: [
const Icon(
Icons.error_outline_rounded,
size: 42,
color: Colors.red,
),
const SizedBox(height: 10),
Text(
message,
textAlign: TextAlign.center,
style: const TextStyle(
fontWeight: FontWeight.w700,
),
),
const SizedBox(height: 14),
OutlinedButton.icon(
onPressed: onRetry,
icon: const Icon(
Icons.refresh_rounded,
),
label:
const Text('Try Again'),
),
],
),
);
}

// ============================================================
// FORMAT DATE
// ============================================================

String _formatDate(DateTime date) {
final hour =
date.hour.toString().padLeft(2, '0');

final minute =
date.minute.toString().padLeft(2, '0');

return '${date.day}/${date.month}/${date.year} '
'$hour:$minute';
}
}

// ============================================================================
// REPORT CARD CONTAINER
// ============================================================================

class _ReportCardContainer
extends StatelessWidget {
final Widget child;

const _ReportCardContainer({
required this.child,
});

@override
Widget build(BuildContext context) {
return Container(
width: double.infinity,
padding:
const EdgeInsets.all(16),
decoration: BoxDecoration(
color: Theme.of(context)
    .colorScheme
    .surface,
borderRadius:
BorderRadius.circular(20),
border: Border.all(
color: Colors.grey
    .withValues(alpha: 0.12),
),
boxShadow: [
BoxShadow(
blurRadius: 16,
offset: const Offset(0, 5),
color: Colors.black
    .withValues(alpha: 0.035),
),
],
),
child: child,
);
}
}

// ============================================================================
// STAT CARD
// ============================================================================

class _StatCard
extends StatelessWidget {
final String title;
final String value;
final IconData icon;
final Color iconColor;

const _StatCard({
required this.title,
required this.value,
required this.icon,
required this.iconColor,
});

@override
Widget build(BuildContext context) {
return Container(
padding:
const EdgeInsets.all(14),
decoration: BoxDecoration(
color: Theme.of(context)
    .colorScheme
    .surface,
borderRadius:
BorderRadius.circular(18),
border: Border.all(
color: Colors.grey
    .withValues(alpha: 0.12),
),
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Container(
width: 38,
height: 38,
decoration: BoxDecoration(
color: iconColor.withValues(
alpha: 0.10,
),
borderRadius:
BorderRadius.circular(12),
),
child: Icon(
icon,
size: 20,
color: iconColor,
),
),
const SizedBox(height: 12),
Text(
value,
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style: const TextStyle(
fontSize: 21,
fontWeight: FontWeight.w900,
),
),
const SizedBox(height: 3),
Text(
title,
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style: TextStyle(
fontSize: 10,
color: Colors.grey.shade600,
fontWeight:
FontWeight.w600,
),
),
],
),
);
}
}

// ============================================================================
// WEEKLY DATA
// ============================================================================

class _DayComplaintData {
final String day;
final int count;

const _DayComplaintData({
required this.day,
required this.count,
});
}

// ============================================================================
// STATUS ROW
// ============================================================================

class _StatusDataRow
extends StatelessWidget {
final String title;
final int value;
final IconData icon;
final Color iconColor;

const _StatusDataRow({
required this.title,
required this.value,
required this.icon,
required this.iconColor,
});

@override
Widget build(BuildContext context) {
return Padding(
padding:
const EdgeInsets.only(
bottom: 10,
),
child: Row(
children: [
Container(
width: 38,
height: 38,
decoration:
BoxDecoration(
color: iconColor.withValues(
alpha: 0.09,
),
borderRadius:
BorderRadius.circular(11),
),
child: Icon(
icon,
color: iconColor,
size: 20,
),
),
const SizedBox(width: 12),
Expanded(
child: Text(
title,
style:
const TextStyle(
fontSize: 13,
fontWeight:
FontWeight.w700,
),
),
),
Text(
'$value',
style:
const TextStyle(
fontSize: 15,
fontWeight: FontWeight.w900,
),
),
],
),
);
}
}

