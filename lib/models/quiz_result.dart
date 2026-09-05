class QuizResult {
  final int score;
  final int totalQuestions;
  final bool completed;
  final DateTime completedAt;

  /// Category-wise correct answers.
  ///
  /// Example:
  /// {
  ///   "Phishing & Scams": 2,
  ///   "Privacy": 4,
  /// }
  final Map<String, int> categoryCorrect;

  /// Category-wise total questions.
  ///
  /// Example:
  /// {
  ///   "Phishing & Scams": 4,
  ///   "Privacy": 4,
  /// }
  final Map<String, int> categoryTotal;

  const QuizResult({
    required this.score,
    required this.totalQuestions,
    required this.completed,
    required this.completedAt,
    this.categoryCorrect = const {},
    this.categoryTotal = const {},
  });

// ==========================================================
// PERCENTAGE
// ==========================================================

  double get percentage {
    if (totalQuestions <= 0) {
      return 0;
    }


    return (score / totalQuestions) * 100;


  }

// ==========================================================
// CATEGORY ACCURACY
// ==========================================================

  Map<String, double> get categoryAccuracy {
    final Map<String, double> result = {};


    for (final category in categoryTotal.keys) {
    final total = categoryTotal[category] ?? 0;
    final correct = categoryCorrect[category] ?? 0;

    if (total <= 0) {
    result[category] = 0;
    } else {
    result[category] = (correct / total) * 100;
    }
    }

    return result;
      }

// ==========================================================
// FIRESTORE / MAP
// ==========================================================

  Map<String, dynamic> toMap() {
    return {
      'score': score,
      'totalQuestions': totalQuestions,
      'completed': completed,
      'percentage': percentage,
      'completedAt': completedAt,
      'categoryCorrect': categoryCorrect,
      'categoryTotal': categoryTotal,
    };
  }

// ==========================================================
// COPY WITH
// ==========================================================

  QuizResult copyWith({
    int? score,
    int? totalQuestions,
    bool? completed,
    DateTime? completedAt,
    Map<String, int>? categoryCorrect,
    Map<String, int>? categoryTotal,
  }) {
    return QuizResult(
      score: score ?? this.score,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      categoryCorrect:
      categoryCorrect ?? this.categoryCorrect,
      categoryTotal:
      categoryTotal ?? this.categoryTotal,
    );
  }
}
