import 'package:flutter/material.dart';

import '../../../data/quiz_store.dart';

class AdminQuizAnalyticsScreen extends StatefulWidget {
  const AdminQuizAnalyticsScreen({
    super.key,
  });

  @override
  State<AdminQuizAnalyticsScreen> createState() =>
      _AdminQuizAnalyticsScreenState();
}

class _AdminQuizAnalyticsScreenState
    extends State<AdminQuizAnalyticsScreen> {
  bool _isLoading = true;
  String _errorMessage = '';

  int _totalAttempts = 0;
  int _completedAttempts = 0;

  double _averageScore = 0;
  double _completionRate = 0;
  double _highestScore = 0;
  double _lowestScore = 0;

  List<_TopicAnalytics> _topics = [];

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  // ==========================================================
  // LOAD ANALYTICS
  // ==========================================================

  Future<void> _loadAnalytics() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // --------------------------------------------------------
      // Overall Analytics
      // --------------------------------------------------------

      final analytics =
      await QuizStore.getAdminAnalytics();

      // --------------------------------------------------------
      // Topic Analytics
      // --------------------------------------------------------

      final topicAnalytics =
      await QuizStore.getTopicAnalytics();

      if (!mounted) return;

      final topics = <_TopicAnalytics>[];

      // getTopicAnalytics() returns:
      // List<Map<String, dynamic>>
      //
      // So .entries is NOT used here.

      for (final data in topicAnalytics) {
        final name =
            data['category']?.toString().trim() ?? 'Other';

        final total =
        _toInt(data['totalQuestions']);

        final correct =
        _toInt(data['correctAnswers']);

        final accuracy =
        _toDouble(data['accuracy']);

        topics.add(
          _TopicAnalytics(
            name: name.isEmpty ? 'Other' : name,
            total: total,
            correct: correct,
            accuracy: accuracy,
          ),
        );
      }

      // Lowest accuracy = most difficult topic
      topics.sort(
            (a, b) =>
            a.accuracy.compareTo(b.accuracy),
      );

      setState(() {
        _totalAttempts =
            _toInt(analytics['totalAttempts']);

        _completedAttempts =
            _toInt(analytics['completedQuizzes']);

        _averageScore =
            _toDouble(analytics['averageScore']);

        _completionRate =
            _toDouble(analytics['completionRate']);

        _highestScore =
            _toDouble(analytics['highestScore']);

        _lowestScore =
            _toDouble(analytics['lowestScore']);

        _topics = topics;

        _isLoading = false;
        _errorMessage = '';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
        'Unable to load quiz analytics. '
            'Please try again.';
      });
    }
  }

  // ==========================================================
  // SAFE INT
  // ==========================================================

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

  // ==========================================================
  // SAFE DOUBLE
  // ==========================================================

  double _toDouble(dynamic value) {
    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quiz Analytics',
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

  // ==========================================================
  // BODY
  // ==========================================================

  Widget _buildBody(ThemeData theme) {
    // --------------------------------------------------------
    // ERROR
    // --------------------------------------------------------

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
            style:
            theme.textTheme.titleLarge?.copyWith(
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
              label: const Text(
                'Try Again',
              ),
            ),
          ),
        ],
      );
    }

    // --------------------------------------------------------
    // NO DATA
    // --------------------------------------------------------

    if (_totalAttempts == 0) {
      return ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 100),

          Icon(
            Icons.quiz_outlined,
            size: 72,
            color: theme.colorScheme.primary,
          ),

          const SizedBox(height: 18),

          Text(
            'No Quiz Data',
            textAlign: TextAlign.center,
            style:
            theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'There are no quiz attempts available '
                'for analytics yet.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      );
    }

    // --------------------------------------------------------
    // ANALYTICS
    // --------------------------------------------------------

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
        _buildHeader(theme),

        const SizedBox(height: 16),

        _buildSummaryCards(theme),

        const SizedBox(height: 20),

        _buildPerformanceCard(theme),

        const SizedBox(height: 20),

        _buildDifficultTopics(theme),

        const SizedBox(height: 20),

        _buildTopicDistribution(theme),
      ],
    );
  }

  // ==========================================================
  // HEADER
  // ==========================================================

  Widget _buildHeader(ThemeData theme) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary
                    .withValues(alpha: 0.10),
                borderRadius:
                BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.analytics_rounded,
                color:
                theme.colorScheme.primary,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quiz Performance',
                    style: theme
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Firebase-based quiz analytics',
                    style:
                    theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // SUMMARY CARDS
  // ==========================================================

  Widget _buildSummaryCards(
      ThemeData theme,
      ) {
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
          title: 'Total Attempts',
          value:
          _totalAttempts.toString(),
          icon: Icons.quiz_outlined,
        ),

        _summaryCard(
          theme: theme,
          title: 'Completed',
          value:
          _completedAttempts.toString(),
          icon:
          Icons.check_circle_outline_rounded,
        ),

        _summaryCard(
          theme: theme,
          title: 'Average Score',
          value:
          '${_averageScore.toStringAsFixed(1)}%',
          icon: Icons.score_outlined,
        ),

        _summaryCard(
          theme: theme,
          title: 'Completion Rate',
          value:
          '${_completionRate.toStringAsFixed(1)}%',
          icon: Icons.percent_rounded,
        ),
      ],
    );
  }

  // ==========================================================
  // SUMMARY CARD
  // ==========================================================

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
              color:
              theme.colorScheme.primary,
            ),

            const Spacer(),

            Text(
              value,
              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,
              style: theme
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              title,
              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,
              style:
              theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // PERFORMANCE
  // ==========================================================

  Widget _buildPerformanceCard(
      ThemeData theme,
      ) {
    return _sectionCard(
      theme: theme,
      title: 'Score Performance',
      icon: Icons.insights_outlined,
      child: Column(
        children: [
          _statRow(
            theme: theme,
            title: 'Average Score',
            value:
            '${_averageScore.toStringAsFixed(1)}%',
          ),

          _statRow(
            theme: theme,
            title: 'Highest Score',
            value:
            '${_highestScore.toStringAsFixed(1)}%',
          ),

          _statRow(
            theme: theme,
            title: 'Lowest Score',
            value:
            '${_lowestScore.toStringAsFixed(1)}%',
          ),

          _statRow(
            theme: theme,
            title: 'Completed Attempts',
            value:
            _completedAttempts.toString(),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // DIFFICULT TOPICS
  // ==========================================================

  Widget _buildDifficultTopics(
      ThemeData theme,
      ) {
    final difficultTopics =
    _topics.take(5).toList();

    if (difficultTopics.isEmpty) {
      return _sectionCard(
        theme: theme,
        title: 'Difficult Topics',
        icon:
        Icons.warning_amber_rounded,
        child: const Text(
          'No topic analytics available yet.',
        ),
      );
    }

    return _sectionCard(
      theme: theme,
      title: 'Difficult Topics',
      icon:
      Icons.warning_amber_rounded,
      child: Column(
        children: difficultTopics
            .asMap()
            .entries
            .map(
              (entry) {
            final index = entry.key;
            final topic = entry.value;

            return Padding(
              padding:
              const EdgeInsets.only(
                bottom: 14,
              ),
              child: _topicRow(
                theme: theme,
                rank: index + 1,
                topic: topic,
              ),
            );
          },
        )
            .toList(),
      ),
    );
  }

  // ==========================================================
  // TOPIC DISTRIBUTION
  // ==========================================================

  Widget _buildTopicDistribution(
      ThemeData theme,
      ) {
    if (_topics.isEmpty) {
      return _sectionCard(
        theme: theme,
        title: 'Topic Performance',
        icon: Icons.category_outlined,
        child: const Text(
          'No topic performance data available.',
        ),
      );
    }

    return _sectionCard(
      theme: theme,
      title: 'Topic Performance',
      icon: Icons.category_outlined,
      child: Column(
        children: _topics.map(
              (topic) {
            return Padding(
              padding:
              const EdgeInsets.only(
                bottom: 14,
              ),
              child: _topicPerformanceRow(
                theme: theme,
                topic: topic,
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  // ==========================================================
  // DIFFICULT TOPIC ROW
  // ==========================================================

  Widget _topicRow({
    required ThemeData theme,
    required int rank,
    required _TopicAnalytics topic,
  }) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary
                .withValues(alpha: 0.10),
            borderRadius:
            BorderRadius.circular(10),
          ),
          child: Text(
            rank.toString(),
            style: theme
                .textTheme
                .bodyMedium
                ?.copyWith(
              fontWeight: FontWeight.bold,
              color:
              theme.colorScheme.primary,
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            topic.name,
            maxLines: 2,
            overflow:
            TextOverflow.ellipsis,
            style: theme
                .textTheme
                .bodyMedium
                ?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(width: 8),

        Text(
          '${topic.accuracy.toStringAsFixed(0)}%',
          style: theme
              .textTheme
              .bodyMedium
              ?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // TOPIC PERFORMANCE ROW
  // ==========================================================

  Widget _topicPerformanceRow({
    required ThemeData theme,
    required _TopicAnalytics topic,
  }) {
    final progress =
    (topic.accuracy / 100)
        .clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                topic.name,
                maxLines: 2,
                overflow:
                TextOverflow.ellipsis,
                style: theme
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(width: 8),

            Text(
              '${topic.correct}/${topic.total}',
              style: theme
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(width: 8),

            SizedBox(
              width: 48,
              child: Text(
                '${topic.accuracy.toStringAsFixed(0)}%',
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
          child:
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: theme
                .colorScheme
                .surfaceContainerHighest,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // STAT ROW
  // ==========================================================

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
            style: theme
                .textTheme
                .bodyMedium
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

  // ==========================================================
  // SECTION CARD
  // ==========================================================

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
                    style: theme
                        .textTheme
                        .titleMedium
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

// ============================================================
// TOPIC ANALYTICS MODEL
// ============================================================

class _TopicAnalytics {
  final String name;
  final int total;
  final int correct;
  final double accuracy;

  const _TopicAnalytics({
    required this.name,
    required this.total,
    required this.correct,
    required this.accuracy,
  });
}