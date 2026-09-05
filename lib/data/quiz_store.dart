import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/quiz_result.dart';

class QuizStore {
  QuizStore._();

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static final FirebaseAuth _auth =
      FirebaseAuth.instance;

  static const String _collection = 'quiz_results';

  static final List<QuizResult> _results = [];

// ============================================================
// INITIALIZE
// ============================================================

  static Future<void> initialize() async {
    await loadResults();
  }

// ============================================================
// CURRENT USER RESULTS
// ============================================================

  static Future<void> loadResults() async {
    final user = _auth.currentUser;


    if (user == null) {
    _results.clear();
    return;
    }

    try {
    final snapshot = await _firestore
        .collection(_collection)
        .where(
    'userId',
    isEqualTo: user.uid,
    )
        .get();

    _results.clear();

    for (final document in snapshot.docs) {
    _results.add(
    _resultFromFirestore(
    document.data(),
    ),
    );
    }

    _sortResults(_results);
    } on FirebaseException catch (e) {
    throw Exception(
    'Quiz results load failed: '
    '${e.message ?? e.code}',
    );
    } catch (e) {
    throw Exception(
    'Quiz results load failed: $e',
    );
    }


  }

// ============================================================
// ADD RESULT
// ============================================================

  static Future<void> addResult(
      QuizResult result,
      ) async {
    final user = _auth.currentUser;

        if (user == null) {
    throw Exception(
    'User must be logged in before submitting quiz.',
    );
    }

    try {
    await _firestore
        .collection(_collection)
        .add({
    'userId': user.uid,
    'score': result.score,
    'totalQuestions': result.totalQuestions,
    'percentage': result.percentage,
    'completed': result.completed,
    'completedAt': Timestamp.fromDate(
    result.completedAt,
    ),
    'createdAt': FieldValue.serverTimestamp(),

    // ======================================================
    // CATEGORY ANALYTICS
    // ======================================================

    'categoryCorrect': result.categoryCorrect,
    'categoryTotal': result.categoryTotal,
    });

    _results.insert(
    0,
    result,
    );

    _sortResults(_results);
    } on FirebaseException catch (e) {
    throw Exception(
    'Quiz result save failed: '
    '${e.message ?? e.code}',
    );
    } catch (e) {
    throw Exception(
    'Quiz result save failed: $e',
    );
    }


  }

// ============================================================
// CURRENT USER RESULTS
// ============================================================

  static List<QuizResult> get results {
    return List.unmodifiable(_results);
  }

  static Future<List<QuizResult>> getCurrentUserResults() async {
    await loadResults();


    return List.unmodifiable(_results);


  }

// ============================================================
// ADMIN — ALL RESULTS
// ============================================================

  /// Loads all quiz results from Firebase.
  ///
  /// AdminReportsScreen should call this method once and
  /// calculate all analytics locally from the returned list.
  static Future<List<QuizResult>> getAllResultsForAdmin() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .get();


    final results = <QuizResult>[];

    for (final document in snapshot.docs) {
    results.add(
    _resultFromFirestore(
    document.data(),
    ),
    );
    }

    _sortResults(results);

    return results;
    } on FirebaseException catch (e) {
    throw Exception(
    'Admin quiz analytics load failed: '
    '${e.message ?? e.code}',
    );
    } catch (e) {
    throw Exception(
    'Admin quiz analytics load failed: $e',
    );
    }

  }

// ============================================================
// ADMIN ANALYTICS
// ============================================================

  /// Calculates overall quiz analytics.
  ///
  /// This method uses a single Firebase read through
  /// getAllResultsForAdmin().
  static Future<Map<String, dynamic>> getAdminAnalytics() async {
    final allResults = await getAllResultsForAdmin();

  return calculateAdminAnalytics(
    allResults,
    );


  }

  /// Calculates admin analytics from already-loaded results.
  ///
  /// Useful for AdminReportsScreen because Firebase data only
  /// needs to be loaded once.
  static Map<String, dynamic> calculateAdminAnalytics(
      List<QuizResult> allResults,
      ) {
    if (allResults.isEmpty) {
      return {
        'totalAttempts': 0,
        'completedQuizzes': 0,
        'averageScore': 0.0,
        'completionRate': 0.0,
        'highestScore': 0.0,
        'lowestScore': 0.0,
      };
    }
    int completedQuizzes = 0;
    double totalPercentage = 0;
    double highestScore = 0;
    double lowestScore = 100;

    for (final result in allResults) {
    final percentage = result.percentage;

    totalPercentage += percentage;

    if (result.completed) {
    completedQuizzes++;
    }

    if (percentage > highestScore) {
    highestScore = percentage;
    }

    if (percentage < lowestScore) {
    lowestScore = percentage;
    }
    }

    final totalAttempts = allResults.length;

    final averageScore =
    totalPercentage / totalAttempts;

    final completionRate =
    (completedQuizzes / totalAttempts) * 100;

    return {
    'totalAttempts': totalAttempts,
    'completedQuizzes': completedQuizzes,
    'averageScore': averageScore,
    'completionRate': completionRate,
    'highestScore': highestScore,
    'lowestScore': lowestScore,
    };


  }

// ============================================================
// PHASE 3 — TOPIC ANALYTICS
// ============================================================

  /// Loads topic analytics directly from Firebase.
  ///
  /// Kept for compatibility with existing code.
  /// New AdminReportsScreen should preferably use
  /// calculateTopicAnalytics() with the already-loaded results.
  static Future<List<Map<String, dynamic>>> getTopicAnalytics() async {
    final results = await getAllResultsForAdmin();


    return calculateTopicAnalytics(
    results,
    );


  }

  /// Calculates category/topic analytics from already-loaded
  /// Firebase results.
  static List<Map<String, dynamic>> calculateTopicAnalytics(
      List<QuizResult> results,
      ) {
    final Map<String, int> totalByCategory = {};
    final Map<String, int> correctByCategory = {};


    for (final result in results) {
    final categories = <String>{
    ...result.categoryTotal.keys,
    ...result.categoryCorrect.keys,
    };

    for (final rawCategory in categories) {
    final category = rawCategory.trim().isEmpty
    ? 'Other'
        : rawCategory.trim();

    final total =
    result.categoryTotal[rawCategory] ?? 0;

    final correct =
    result.categoryCorrect[rawCategory] ?? 0;

    totalByCategory[category] =
    (totalByCategory[category] ?? 0) + total;

    correctByCategory[category] =
    (correctByCategory[category] ?? 0) + correct;
    }
    }

    final analytics = <Map<String, dynamic>>[];

    for (final category in totalByCategory.keys) {
    final total =
    totalByCategory[category] ?? 0;

    final correct =
    correctByCategory[category] ?? 0;

    final safeCorrect =
    correct.clamp(0, total);

    final wrong =
    total > 0 ? total - safeCorrect : 0;

    final double accuracy =
    total <= 0
    ? 0
        : (safeCorrect / total) * 100;

    analytics.add({
    'category': category,
    'totalQuestions': total,
    'correctAnswers': safeCorrect,
    'wrongAnswers': wrong,
    'accuracy': accuracy,
    });
    }

// Lowest accuracy = most difficult topic.
    analytics.sort(
    (a, b) {
    final accuracyA =
    (a['accuracy'] as num).toDouble();

    final accuracyB =
    (b['accuracy'] as num).toDouble();

    final accuracyComparison =
    accuracyA.compareTo(accuracyB);

    if (accuracyComparison != 0) {
    return accuracyComparison;
    }

    final categoryA =
    a['category'].toString();

    final categoryB =
    b['category'].toString();

    return categoryA.compareTo(categoryB);
    },
    );

    return analytics;


    }

// ============================================================
// SINGLE USER RESULTS
// ============================================================

  static Future<List<QuizResult>> getResultsForUser(
      String userId,
      ) async {
    final cleanUserId = userId.trim();

   if (cleanUserId.isEmpty) {
    return [];
    }

    try {
    final snapshot = await _firestore
        .collection(_collection)
        .where(
    'userId',
    isEqualTo: cleanUserId,
    )
        .get();

    final results = <QuizResult>[];

    for (final document in snapshot.docs) {
    results.add(
    _resultFromFirestore(
    document.data(),
    ),
    );
    }

    _sortResults(results);

    return results;
    } on FirebaseException catch (e) {
    throw Exception(
    'User quiz results load failed: '
    '${e.message ?? e.code}',
    );
    } catch (e) {
    throw Exception(
    'User quiz results load failed: $e',
    );
    }
  }

// ============================================================
// DELETE CURRENT USER RESULTS
// ============================================================

  static Future<void> deleteCurrentUserResults() async {
    final user = _auth.currentUser;


    if (user == null) {
    return;
    }

    try {
    final snapshot = await _firestore
        .collection(_collection)
        .where(
    'userId',
    isEqualTo: user.uid,
    )
        .get();

    for (final document in snapshot.docs) {
    await document.reference.delete();
    }

    _results.clear();
    } on FirebaseException catch (e) {
    throw Exception(
    'Quiz results delete failed: '
    '${e.message ?? e.code}',
    );
    } catch (e) {
    throw Exception(
    'Quiz results delete failed: $e',
    );
    }


  }

// ============================================================
// LOCAL CLEAR
// ============================================================

  static void clearResults() {
    _results.clear();
  }

// ============================================================
// FIRESTORE → MODEL
// ============================================================

  static QuizResult _resultFromFirestore(
      Map<String, dynamic> data,
      ) {
    return QuizResult(
      score: _toInt(
        data['score'],
      ),
      totalQuestions: _toInt(
        data['totalQuestions'],
      ),
      completed: data['completed'] == true,
      completedAt: _toDateTime(
        data['completedAt'],
      ),
      categoryCorrect: _toIntMap(
        data['categoryCorrect'],
      ),
      categoryTotal: _toIntMap(
        data['categoryTotal'],
      ),
    );
  }

// ============================================================
// MAP CONVERSION
// ============================================================

  static Map<String, int> _toIntMap(
      dynamic value,
      ) {
    final result = <String, int>{};


    if (value is Map) {
    value.forEach(
    (key, val) {
    final category = key.toString();

    result[category] = _toInt(val);
    },
    );
    }

    return result;

  }

// ============================================================
// SAFE INT
// ============================================================

  static int _toInt(
      dynamic value,
      ) {
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
// SAFE DATETIME
// ============================================================

  static DateTime _toDateTime(
      dynamic value,
      ) {
    if (value is Timestamp) {
      return value.toDate();
    }

      if (value is DateTime) {
    return value;
    }

    if (value is String) {
    return DateTime.tryParse(
    value,
    ) ??
    DateTime.now();
    }

    return DateTime.now();


  }

// ============================================================
// SORT RESULTS
// ============================================================

  static void _sortResults(
      List<QuizResult> results,
      ) {
    results.sort(
          (a, b) => b.completedAt.compareTo(
        a.completedAt,
      ),
    );
  }

// ============================================================
// BASIC USER ANALYTICS
// ============================================================

  static int get totalAttempts {
    return _results.length;
  }

  static int get completedQuizzes {
    return _results
        .where(
          (result) => result.completed,
    )
        .length;
  }

  static double get averageScore {
    if (_results.isEmpty) {
      return 0;
    }


    double total = 0;

    for (final result in _results) {
    total += result.percentage;
    }

    return total / _results.length;

  }

  static double get completionRate {
    if (_results.isEmpty) {
      return 0;
    }
    return (completedQuizzes / totalAttempts) * 100;


  }
}
