import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/quiz_data.dart';
import '../../../data/quiz_store.dart';
import '../../../models/quiz_question.dart';
import '../../../models/quiz_result.dart';
import 'quiz_result_screen.dart';

class CyberSafetyQuizScreen extends StatefulWidget {
const CyberSafetyQuizScreen({
super.key,
});

@override
State<CyberSafetyQuizScreen> createState() =>
_CyberSafetyQuizScreenState();
}

class _CyberSafetyQuizScreenState
extends State<CyberSafetyQuizScreen> {
// ==========================================================
// QUIZ QUESTIONS
// ==========================================================

/// QuizData contains the complete question bank.
///
/// Every time a NEW quiz screen is opened:
/// - All questions are copied.
/// - All questions are shuffled.
/// - ALL questions are used.
///
/// IMPORTANT:
/// Options are NOT shuffled.
/// Therefore each question's correctAnswerIndex
/// remains connected to its own options.
late final List<QuizQuestion> _quizQuestions;

// ==========================================================
// QUIZ STATE
// ==========================================================

int _currentQuestionIndex = 0;
int _score = 0;

int? _selectedAnswer;
bool _answerSubmitted = false;

// Prevent duplicate Firebase submission.
bool _isFinishingQuiz = false;

// ==========================================================
// CATEGORY ANALYTICS
// ==========================================================

/// Total attempted questions for each category.
final Map<String, int> _categoryTotal = {};

/// Correct answers for each category.
final Map<String, int> _categoryCorrect = {};

// ==========================================================
// INITIALIZE QUIZ
// ==========================================================

@override
void initState() {
super.initState();

// Create a separate mutable copy of ALL questions.
final shuffledQuestions =
List<QuizQuestion>.from(
QuizData.questions,
);

// Shuffle ALL questions.
//
// This changes the question order every time
// a new CyberSafetyQuizScreen is created.
shuffledQuestions.shuffle();

// IMPORTANT:
// Do NOT use take(20).
//
// ALL questions will be included.
_quizQuestions = shuffledQuestions;
}

// ==========================================================
// QUESTIONS
// ==========================================================

List<QuizQuestion> get _questions {
return _quizQuestions;
}

// ==========================================================
// CURRENT QUESTION
// ==========================================================

QuizQuestion get _currentQuestion {
return _questions[_currentQuestionIndex];
}

// ==========================================================
// PROGRESS
// ==========================================================

double get _progress {
if (_questions.isEmpty) {
return 0;
}

return (_currentQuestionIndex + 1) /
_questions.length;
}

// ==========================================================
// SELECT ANSWER
// ==========================================================

void _selectAnswer(int index) {
// User cannot change answer after checking it.
if (_answerSubmitted || _isFinishingQuiz) {
return;
}

setState(() {
_selectedAnswer = index;
});
}

// ==========================================================
// CHECK ANSWER
// ==========================================================

void _checkAnswer() {
if (_selectedAnswer == null) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Please select an answer first.',
),
),
);

return;
}

final question = _currentQuestion;

// If category is empty, use Other.
final category =
question.category.trim().isEmpty
? 'Other'
    : question.category.trim();

// Compare selected option with the question's
// own correct answer index.
final bool isCorrect =
_selectedAnswer ==
question.correctAnswerIndex;

setState(() {
_answerSubmitted = true;

// ======================================================
// CATEGORY TOTAL
// ======================================================

_categoryTotal[category] =
(_categoryTotal[category] ?? 0) + 1;

// ======================================================
// CATEGORY CORRECT
// ======================================================

if (isCorrect) {
_score++;

_categoryCorrect[category] =
(_categoryCorrect[category] ?? 0) + 1;
}
});
}

// ==========================================================
// FINISH QUIZ
// ==========================================================

Future<void> _finishQuiz() async {
// Prevent duplicate Firebase submission.
if (_isFinishingQuiz) {
return;
}

setState(() {
_isFinishingQuiz = true;
});

// ========================================================
// CREATE RESULT
// ========================================================

final result = QuizResult(
score: _score,

// ALL questions are used.
//
// If QuizData contains 40 questions,
// this value will be 40.
totalQuestions: _questions.length,

completed: true,

completedAt: DateTime.now(),

// ======================================================
// CATEGORY ANALYTICS
// ======================================================

categoryCorrect:
Map<String, int>.from(
_categoryCorrect,
),

categoryTotal:
Map<String, int>.from(
_categoryTotal,
),
);

try {
// ======================================================
// SAVE RESULT TO FIREBASE
// ======================================================
//
// QuizStore already handles Firestore.
//
// It saves:
// - userId
// - score
// - totalQuestions
// - percentage
// - completed
// - completedAt
// - categoryCorrect
// - categoryTotal
//
// No direct Firebase code is required here.

await QuizStore.addResult(result);

if (!mounted) {
return;
}

// ======================================================
// OPEN RESULT SCREEN
// ======================================================

Navigator.pushReplacement(
context,
MaterialPageRoute(
builder: (_) => QuizResultScreen(
result: result,
),
),
);
} catch (e) {
if (!mounted) {
return;
}

setState(() {
_isFinishingQuiz = false;
});

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Quiz result save nahi ho saka. '
'Internet/Firebase connection check karein.',
),
),
);
}
}

// ==========================================================
// NEXT QUESTION
// ==========================================================

void _nextQuestion() {
// First tap:
// Check the selected answer.
if (!_answerSubmitted) {
_checkAnswer();
return;
}

// Last question:
// Finish and save the quiz.
if (_currentQuestionIndex ==
_questions.length - 1) {
_finishQuiz();
return;
}

// Move to next question.
setState(() {
_currentQuestionIndex++;
_selectedAnswer = null;
_answerSubmitted = false;
});
}

// ==========================================================
// OPTION BORDER COLOR
// ==========================================================

Color _optionBorderColor(int index) {
// Before answer is checked.
if (!_answerSubmitted) {
if (_selectedAnswer == index) {
return AppColors.primary;
}

return Colors.grey.withValues(
alpha: 0.20,
);
}

// Correct answer.
if (index ==
_currentQuestion.correctAnswerIndex) {
return Colors.green;
}

// User selected wrong answer.
if (index == _selectedAnswer) {
return Colors.red;
}

return Colors.grey.withValues(
alpha: 0.20,
);
}

// ==========================================================
// OPTION ICON
// ==========================================================

IconData? _optionIcon(int index) {
if (!_answerSubmitted) {
return null;
}

// Correct answer.
if (index ==
_currentQuestion.correctAnswerIndex) {
return Icons.check_circle_rounded;
}

// Selected wrong answer.
if (index == _selectedAnswer) {
return Icons.cancel_rounded;
}

return null;
}

// ==========================================================
// BUILD
// ==========================================================

@override
Widget build(BuildContext context) {
// ========================================================
// EMPTY QUESTIONS
// ========================================================

if (_questions.isEmpty) {
return Scaffold(
appBar: AppBar(
title: const Text(
'Cyber Safety Quiz',
style: TextStyle(
fontWeight: FontWeight.w800,
),
),
),
body: const Center(
child: Text(
'No quiz questions available.',
),
),
);
}

// ========================================================
// MAIN SCREEN
// ========================================================

return Scaffold(
appBar: AppBar(
title: const Text(
'Cyber Safety Quiz',
style: TextStyle(
fontWeight: FontWeight.w800,
),
),
),
body: SafeArea(
child: SingleChildScrollView(
padding: const EdgeInsets.fromLTRB(
20,
12,
20,
24,
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
// ==================================================
// QUESTION NUMBER
// ==================================================

Row(
mainAxisAlignment:
MainAxisAlignment.spaceBetween,
children: [
Text(
'Question ${_currentQuestionIndex + 1}',
style: const TextStyle(
fontSize: 16,
fontWeight: FontWeight.w700,
),
),
Text(
'${_questions.length}',
style: TextStyle(
color: Colors.grey.shade600,
fontWeight: FontWeight.w600,
),
),
],
),

const SizedBox(height: 10),

// ==================================================
// PROGRESS BAR
// ==================================================

ClipRRect(
borderRadius:
BorderRadius.circular(20),
child: LinearProgressIndicator(
value: _progress,
minHeight: 8,
backgroundColor:
Colors.grey.withValues(
alpha: 0.15,
),
valueColor:
AlwaysStoppedAnimation<Color>(
AppColors.primary,
),
),
),

const SizedBox(height: 24),

// ==================================================
// CATEGORY
// ==================================================

Container(
padding:
const EdgeInsets.symmetric(
horizontal: 12,
vertical: 7,
),
decoration: BoxDecoration(
color: AppColors.primary
    .withValues(
alpha: 0.08,
),
borderRadius:
BorderRadius.circular(30),
),
child: Text(
_currentQuestion.category
    .trim()
    .isEmpty
? 'Other'
    : _currentQuestion.category
    .trim(),
style: TextStyle(
color: AppColors.primary,
fontWeight: FontWeight.w700,
fontSize: 13,
),
),
),

const SizedBox(height: 18),

// ==================================================
// QUESTION
// ==================================================

Text(
_currentQuestion.question,
style: const TextStyle(
fontSize: 22,
height: 1.35,
fontWeight: FontWeight.w800,
),
),

const SizedBox(height: 24),

// ==================================================
// OPTIONS
// ==================================================

...List.generate(
_currentQuestion.options.length,
(index) {
final bool selected =
_selectedAnswer == index;

final IconData? optionIcon =
_optionIcon(index);

return Padding(
padding:
const EdgeInsets.only(
bottom: 12,
),
child: InkWell(
onTap: _answerSubmitted ||
_isFinishingQuiz
? null
    : () =>
_selectAnswer(index),
borderRadius:
BorderRadius.circular(16),
child: AnimatedContainer(
duration:
const Duration(
milliseconds: 200,
),
padding:
const EdgeInsets.all(
16,
),
decoration: BoxDecoration(
color:
selected &&
!_answerSubmitted
? AppColors
    .primary
    .withValues(
alpha: 0.08,
)
    : Theme.of(context)
    .colorScheme
    .surface,
borderRadius:
BorderRadius.circular(
16,
),
border: Border.all(
color:
_optionBorderColor(
index,
),
width:
selected ||
(_answerSubmitted &&
index ==
_currentQuestion
    .correctAnswerIndex)
? 1.8
    : 1,
),
),
child: Row(
children: [
// ==================================
// OPTION LETTER
// ==================================

Container(
width: 34,
height: 34,
alignment:
Alignment.center,
decoration:
BoxDecoration(
shape:
BoxShape.circle,
color: selected &&
!_answerSubmitted
? AppColors
    .primary
    : Colors.grey
    .withValues(
alpha: 0.10,
),
),
child: Text(
String.fromCharCode(
65 + index,
),
style: TextStyle(
fontWeight:
FontWeight.w800,
color: selected &&
!_answerSubmitted
? Colors.white
    : null,
),
),
),

const SizedBox(
width: 14,
),

// ==================================
// OPTION TEXT
// ==================================

Expanded(
child: Text(
_currentQuestion
    .options[index],
style:
const TextStyle(
fontSize: 15,
height: 1.35,
fontWeight:
FontWeight.w600,
),
),
),

// ==================================
// RESULT ICON
// ==================================

if (optionIcon != null)
Icon(
optionIcon,
color: index ==
_currentQuestion
    .correctAnswerIndex
? Colors.green
    : Colors.red,
),
],
),
),
),
);
},
),

// ==================================================
// EXPLANATION
// ==================================================

if (_answerSubmitted) ...[
const SizedBox(height: 8),
Container(
width: double.infinity,
padding:
const EdgeInsets.all(16),
decoration: BoxDecoration(
color: Colors.blue
    .withValues(
alpha: 0.06,
),
borderRadius:
BorderRadius.circular(16),
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'Why?',
style: TextStyle(
fontSize: 16,
fontWeight:
FontWeight.w800,
),
),
const SizedBox(height: 6),
Text(
_currentQuestion
    .explanation,
style:
const TextStyle(
height: 1.4,
),
),
],
),
),
],

const SizedBox(height: 24),

// ==================================================
// ACTION BUTTON
// ==================================================

SizedBox(
width: double.infinity,
height: 54,
child: FilledButton(
onPressed:
_isFinishingQuiz
? null
    : _nextQuestion,
style:
FilledButton.styleFrom(
backgroundColor:
AppColors.primary,
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(
16,
),
),
),
child: _isFinishingQuiz
? const SizedBox(
width: 22,
height: 22,
child:
CircularProgressIndicator(
strokeWidth: 2.5,
color: Colors.white,
),
)
    : Text(
_answerSubmitted
? _currentQuestionIndex ==
_questions.length -
1
? 'View Result'
    : 'Next Question'
    : 'Check Answer',
style:
const TextStyle(
fontWeight:
FontWeight.w800,
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
}

