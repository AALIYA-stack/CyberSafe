import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class AwarenessArticleScreen extends StatefulWidget {
  final dynamic article;

  const AwarenessArticleScreen({
    super.key,
    required this.article,
  });

  @override
  State<AwarenessArticleScreen> createState() =>
      _AwarenessArticleScreenState();
}

class _AwarenessArticleScreenState
    extends State<AwarenessArticleScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool _isRead = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 900,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Article',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          30,
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            _animated(
              0,
              _buildHero(article),
            ),

            const SizedBox(height: 25),

            _animated(
              1,
              _buildIntroduction(article),
            ),

            const SizedBox(height: 25),

            _animated(
              2,
              _buildContent(article),
            ),

            const SizedBox(height: 25),

            _animated(
              3,
              _buildTips(article),
            ),

            const SizedBox(height: 30),

            _animated(
              4,
              _buildReadButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _animated(
      int index,
      Widget child,
      ) {
    final start =
    (index * 0.12).clamp(0.0, 0.55);

    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        start,
        1,
        curve: Curves.easeOutCubic,
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final value = animation.value;

        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(
              0,
              25 * (1 - value),
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildHero(dynamic article) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.primary
            .withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary
              .withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 82,
            width: 82,
            decoration: BoxDecoration(
              color: AppColors.primary
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              article.icon,
              color: AppColors.primary,
              size: 42,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            article.category,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            article.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            article.readTime,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroduction(dynamic article) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          article.description,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 14,
            height: 1.65,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(dynamic article) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Text(
          'Learn More',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 14),
        ...List.generate(
          article.content.length,
              (index) {
            return Container(
              margin: const EdgeInsets.only(
                bottom: 13,
              ),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.4),
                borderRadius:
                BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 28,
                    width: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary
                          .withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight:
                        FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      article.content[index],
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTips(dynamic article) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: AppColors.primary
            .withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary
              .withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: AppColors.primary,
              ),
              SizedBox(width: 9),
              Text(
                'Safety Tips',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ...article.tips.map<Widget>(
                (tip) {
              return Padding(
                padding:
                const EdgeInsets.only(
                  bottom: 11,
                ),
                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 19,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        tip,
                        style: TextStyle(
                          color:
                          Colors.grey.shade700,
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReadButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            _isRead = !_isRead;
          });

          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content: Text(
                _isRead
                    ? 'Article marked as read.'
                    : 'Article marked as unread.',
              ),
              behavior:
              SnackBarBehavior.floating,
            ),
          );
        },
        icon: Icon(
          _isRead
              ? Icons.check_circle_rounded
              : Icons.done_all_rounded,
        ),
        label: Text(
          _isRead
              ? 'Article Read'
              : 'Mark as Read',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}