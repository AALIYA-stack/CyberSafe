import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/quiz_result.dart';
import 'cyber_safety_quiz_screen.dart';

class QuizResultScreen extends StatelessWidget {
final QuizResult result;

const QuizResultScreen({
super.key,
required this.result,
});

// ==========================================================
// RESULT TITLE
// ==========================================================

String get _resultTitle {
final percentage = result.percentage;

if (percentage >= 80) {
return 'Excellent!';
}

if (percentage >= 60) {
return 'Good Job!';
}

return 'Keep Learning!';
}

// ==========================================================
// RESULT MESSAGE
// ==========================================================

String get _resultMessage {
final percentage = result.percentage;

if (percentage >= 80) {
return 'Great work! You have a strong understanding of cyber safety.';
}

if (percentage >= 60) {
return 'Good effort! Review the awareness topics to improve further.';
}

return 'Keep learning about cyber safety and try the quiz again.';
}

// ==========================================================
// PERFORMANCE LABEL
// ==========================================================

String _performanceLabel(double accuracy) {
if (accuracy >= 80) {
return 'Strong';
}

if (accuracy >= 60) {
return 'Good';
}

return 'Needs Improvement';
}

// ==========================================================
// PERFORMANCE COLOR
// ==========================================================

Color _performanceColor(double accuracy) {
if (accuracy >= 80) {
return Colors.green;
}

if (accuracy >= 60) {
return Colors.orange;
}

return Colors.red;
}

// ==========================================================
// WRONG ANSWERS
// ==========================================================

int _wrongAnswers() {
final wrong = result.totalQuestions - result.score;

if (wrong < 0) {
return 0;
}

return wrong;
}

// ==========================================================
// TRY AGAIN
// ==========================================================

void _tryAgain(BuildContext context) {
Navigator.pushReplacement(
context,
MaterialPageRoute(
builder: (_) => const CyberSafetyQuizScreen(),
),
);
}

// ==========================================================
// BACK TO AWARENESS
// ==========================================================

void _backToAwareness(BuildContext context) {
Navigator.pop(context);
}

// ==========================================================
// BUILD
// ==========================================================

@override
Widget build(BuildContext context) {
final int percentage = result.percentage.round();

return Scaffold(
appBar: AppBar(
automaticallyImplyLeading: false,
title: const Text(
'Quiz Result',
style: TextStyle(
fontWeight: FontWeight.w800,
),
),
),
body: SafeArea(
child: SingleChildScrollView(
padding: const EdgeInsets.fromLTRB(
20,
20,
20,
30,
),
child: Column(
children: [
// ==================================================
// RESULT ICON
// ==================================================

Container(
width: 100,
height: 100,
decoration: BoxDecoration(
color: AppColors.primary.withValues(
alpha: 0.10,
),
shape: BoxShape.circle,
),
child: Icon(
percentage >= 60
? Icons.emoji_events_rounded
    : Icons.school_rounded,
size: 52,
color: AppColors.primary,
),
),

const SizedBox(height: 22),

// ==================================================
// TITLE
// ==================================================

Text(
_resultTitle,
textAlign: TextAlign.center,
style: const TextStyle(
fontSize: 28,
fontWeight: FontWeight.w900,
),
),

const SizedBox(height: 8),

// ==================================================
// MESSAGE
// ==================================================

Text(
_resultMessage,
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 14,
height: 1.5,
color: Colors.grey.shade600,
),
),

const SizedBox(height: 30),

// ==================================================
// OVERALL SCORE CARD
// ==================================================

Container(
width: double.infinity,
padding: const EdgeInsets.all(24),
decoration: BoxDecoration(
color: Theme.of(context)
    .colorScheme
    .surface,
borderRadius: BorderRadius.circular(24),
border: Border.all(
color: Colors.grey.withValues(
alpha: 0.15,
),
),
boxShadow: [
BoxShadow(
blurRadius: 16,
offset: const Offset(0, 5),
color: Colors.black.withValues(
alpha: 0.035,
),
),
],
),
child: Column(
children: [
// ==========================================
// PERCENTAGE
// ==========================================

Text(
'$percentage%',
style: TextStyle(
fontSize: 48,
fontWeight: FontWeight.w900,
color: AppColors.primary,
),
),

const SizedBox(height: 5),

const Text(
'Your Score',
style: TextStyle(
fontSize: 14,
fontWeight: FontWeight.w700,
),
),

const SizedBox(height: 24),

// ==========================================
// CORRECT + QUESTIONS
// ==========================================

Row(
children: [
Expanded(
child: _ResultStat(
icon: Icons.check_circle_rounded,
title: 'Correct',
value: '${result.score}',
iconColor: Colors.green,
),
),
const SizedBox(width: 12),
Expanded(
child: _ResultStat(
icon: Icons.quiz_rounded,
title: 'Questions',
value: '${result.totalQuestions}',
iconColor: AppColors.primary,
),
),
],
),

const SizedBox(height: 12),

// ==========================================
// WRONG ANSWERS
// ==========================================

_ResultStatWide(
icon: Icons.cancel_rounded,
title: 'Wrong Answers',
value: '${_wrongAnswers()}',
iconColor: Colors.red,
),
],
),
),

// ==================================================
// CATEGORY ANALYTICS
// ==================================================

if (result.categoryTotal.isNotEmpty) ...[
const SizedBox(height: 20),
_buildCategoryAnalytics(context),
],

const SizedBox(height: 24),

// ==================================================
// TRY AGAIN
// ==================================================

SizedBox(
width: double.infinity,
height: 54,
child: FilledButton.icon(
onPressed: () {
_tryAgain(context);
},
icon: const Icon(
Icons.refresh_rounded,
),
label: const Text(
'Try Again',
style: TextStyle(
fontWeight: FontWeight.w800,
),
),
style: FilledButton.styleFrom(
backgroundColor: AppColors.primary,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(16),
),
),
),
),

const SizedBox(height: 12),

// ==================================================
// BACK TO AWARENESS
// ==================================================

SizedBox(
width: double.infinity,
height: 54,
child: OutlinedButton.icon(
onPressed: () {
_backToAwareness(context);
},
icon: const Icon(
Icons.arrow_back_rounded,
),
label: const Text(
'Back to Awareness',
style: TextStyle(
fontWeight: FontWeight.w800,
),
),
style: OutlinedButton.styleFrom(
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(16),
),
),
),
),

const SizedBox(height: 12),

// ==================================================
// DONE
// ==================================================

SizedBox(
width: double.infinity,
height: 54,
child: TextButton.icon(
onPressed: () {
Navigator.pop(context);
},
icon: const Icon(
Icons.done_rounded,
),
label: const Text(
'Done',
style: TextStyle(
fontWeight: FontWeight.w800,
),
),
),
),
],
),
),
),
);
}

// ==========================================================
// CATEGORY ANALYTICS
// ==========================================================

Widget _buildCategoryAnalytics(
BuildContext context,
) {
final categoryAccuracy = result.categoryAccuracy;

final sortedCategories =
result.categoryTotal.keys.toList()
..sort(
(a, b) {
final accuracyA =
categoryAccuracy[a] ?? 0;

final accuracyB =
categoryAccuracy[b] ?? 0;

return accuracyA.compareTo(
accuracyB,
);
},
);

return Container(
width: double.infinity,
padding: const EdgeInsets.all(18),
decoration: BoxDecoration(
color: Theme.of(context)
    .colorScheme
    .surface,
borderRadius: BorderRadius.circular(22),
border: Border.all(
color: Colors.grey.withValues(
alpha: 0.15,
),
),
boxShadow: [
BoxShadow(
blurRadius: 16,
offset: const Offset(0, 5),
color: Colors.black.withValues(
alpha: 0.035,
),
),
],
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
// ======================================================
// CATEGORY HEADER
// ======================================================

const Row(
children: [
Icon(
Icons.analytics_rounded,
size: 22,
),
SizedBox(width: 8),
Text(
'Topic Performance',
style: TextStyle(
fontSize: 17,
fontWeight: FontWeight.w800,
),
),
],
),

const SizedBox(height: 6),

Text(
'Your performance by cyber safety topic.',
style: TextStyle(
fontSize: 12,
color: Colors.grey.shade600,
),
),

const SizedBox(height: 18),

// ======================================================
// CATEGORY ROWS
// ======================================================

...sortedCategories.map(
(category) {
return _buildCategoryRow(
context,
category,
categoryAccuracy[category] ?? 0,
);
},
),
],
),
);
}

// ==========================================================
// CATEGORY ROW
// ==========================================================

Widget _buildCategoryRow(
BuildContext context,
String category,
double accuracy,
) {
final total =
result.categoryTotal[category] ?? 0;

final correct =
result.categoryCorrect[category] ?? 0;

final wrong = total - correct;

final safeWrong =
wrong < 0 ? 0 : wrong;

final progress =
(accuracy / 100).clamp(0.0, 1.0);

final performanceColor =
_performanceColor(accuracy);

return Container(
margin: const EdgeInsets.only(
bottom: 12,
),
padding: const EdgeInsets.all(14),
decoration: BoxDecoration(
color: Colors.grey.withValues(
alpha: 0.045,
),
borderRadius:
BorderRadius.circular(16),
border: Border.all(
color: Colors.grey.withValues(
alpha: 0.10,
),
),
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
// ====================================================
// CATEGORY NAME + ACCURACY
// ====================================================

Row(
children: [
Expanded(
child: Text(
category,
style: const TextStyle(
fontSize: 14,
fontWeight: FontWeight.w800,
),
),
),
Container(
padding:
const EdgeInsets.symmetric(
horizontal: 9,
vertical: 5,
),
decoration: BoxDecoration(
color:
performanceColor.withValues(
alpha: 0.09,
),
borderRadius:
BorderRadius.circular(10),
),
child: Text(
'${accuracy.round()}%',
style: TextStyle(
fontSize: 12,
fontWeight: FontWeight.w900,
color: performanceColor,
),
),
),
],
),

const SizedBox(height: 10),

// ====================================================
// PROGRESS BAR
// ====================================================

ClipRRect(
borderRadius:
BorderRadius.circular(20),
child: LinearProgressIndicator(
value: progress,
minHeight: 8,
backgroundColor:
Colors.grey.withValues(
alpha: 0.12,
),
valueColor:
AlwaysStoppedAnimation<Color>(
performanceColor,
),
),
),

const SizedBox(height: 10),

// ====================================================
// CORRECT / WRONG / TOTAL
// ====================================================

Row(
children: [
Expanded(
child: Text(
'Correct: $correct',
style: TextStyle(
fontSize: 11,
color:
Colors.green.shade700,
fontWeight:
FontWeight.w600,
),
),
),
Expanded(
child: Text(
'Wrong: $safeWrong',
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
color:
Colors.grey.shade600,
fontWeight:
FontWeight.w600,
),
),
),
],
),

const SizedBox(height: 6),

// ====================================================
// PERFORMANCE LABEL
// ====================================================

Text(
_performanceLabel(accuracy),
style: TextStyle(
fontSize: 11,
fontWeight: FontWeight.w700,
color: performanceColor,
),
),
],
),
);
}
}

// ============================================================
// RESULT STAT
// ============================================================

class _ResultStat extends StatelessWidget {
final IconData icon;
final String title;
final String value;
final Color iconColor;

const _ResultStat({
required this.icon,
required this.title,
required this.value,
required this.iconColor,
});

@override
Widget build(BuildContext context) {
return Container(
padding: const EdgeInsets.all(14),
decoration: BoxDecoration(
color: iconColor.withValues(
alpha: 0.07,
),
borderRadius:
BorderRadius.circular(16),
),
child: Column(
children: [
Icon(
icon,
color: iconColor,
size: 24,
),
const SizedBox(height: 8),
Text(
value,
style: const TextStyle(
fontSize: 20,
fontWeight: FontWeight.w900,
),
),
const SizedBox(height: 2),
Text(
title,
style: TextStyle(
fontSize: 11,
color: Colors.grey.shade600,
fontWeight: FontWeight.w600,
),
),
],
),
);
}
}

// ============================================================
// WIDE RESULT STAT
// ============================================================

class _ResultStatWide extends StatelessWidget {
final IconData icon;
final String title;
final String value;
final Color iconColor;

const _ResultStatWide({
required this.icon,
required this.title,
required this.value,
required this.iconColor,
});

@override
Widget build(BuildContext context) {
return Container(
width: double.infinity,
padding: const EdgeInsets.all(14),
decoration: BoxDecoration(
color: iconColor.withValues(
alpha: 0.07,
),
borderRadius:
BorderRadius.circular(16),
),
child: Row(
children: [
Container(
width: 38,
height: 38,
decoration: BoxDecoration(
color: iconColor.withValues(
alpha: 0.10,
),
shape: BoxShape.circle,
),
child: Icon(
icon,
color: iconColor,
size: 21,
),
),
const SizedBox(width: 12),
Expanded(
child: Text(
title,
style: const TextStyle(
fontSize: 13,
fontWeight: FontWeight.w700,
),
),
),
Text(
value,
style: const TextStyle(
fontSize: 18,
fontWeight: FontWeight.w900,
),
),
],
),
);
}
}
