import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import 'awareness_article_screen.dart';
import 'quiz/cyber_safety_quiz_screen.dart';
class AwarenessScreen extends StatefulWidget {
  const AwarenessScreen({super.key});

  @override
  State<AwarenessScreen> createState() => _AwarenessScreenState();
}

class _AwarenessScreenState extends State<AwarenessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  final TextEditingController _searchController =
  TextEditingController();

  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Phishing',
    'Online Fraud',
    'Password',
    'Social Media',
    'Privacy',
    'Malware',
    'Identity Theft',
  ];

  final List<_AwarenessArticle> _articles = [
    _AwarenessArticle(
      id: '1',
      title: 'How to Stay Safe from Phishing',
      description:
      'Learn how to identify suspicious messages, fake websites and phishing attempts.',
      category: 'Phishing',
      icon: Icons.phishing_outlined,
      readTime: '4 min read',
      content: [
        'Phishing is a common cyber threat where attackers try to trick people into sharing sensitive information.',
        'Always check the sender before opening links or responding to unexpected messages.',
        'Do not enter passwords or financial information on websites reached through suspicious links.',
        'When in doubt, open the official website or application directly instead of using a message link.',
      ],
      tips: [
        'Check the sender carefully.',
        'Avoid suspicious links.',
        'Never share passwords or verification codes.',
        'Use official websites and applications.',
      ],
    ),
    _AwarenessArticle(
      id: '2',
      title: 'Protect Yourself from Online Fraud',
      description:
      'Understand common online scams and learn how to protect your money and personal information.',
      category: 'Online Fraud',
      icon: Icons.account_balance_wallet_outlined,
      readTime: '5 min read',
      content: [
        'Online fraud can happen through fake stores, impersonation, fraudulent offers and deceptive payment requests.',
        'Before making an online payment, verify the seller and carefully review the website or account.',
        'Do not send money simply because someone creates urgency or threatens consequences.',
        'Keep transaction records and report suspicious activity through appropriate channels.',
      ],
      tips: [
        'Verify sellers before paying.',
        'Avoid pressure-based payment requests.',
        'Keep transaction records.',
        'Report suspicious activity.',
      ],
    ),
    _AwarenessArticle(
      id: '3',
      title: 'Create Strong Passwords',
      description:
      'Simple password security practices can significantly improve the safety of your online accounts.',
      category: 'Password',
      icon: Icons.lock_outline_rounded,
      readTime: '3 min read',
      content: [
        'A strong password should be difficult for others to guess and should not be reused across important accounts.',
        'Avoid using easily available personal information such as names, birthdays or simple patterns.',
        'Where available, use a password manager and enable multi-factor authentication.',
      ],
      tips: [
        'Use unique passwords.',
        'Avoid predictable information.',
        'Enable multi-factor authentication.',
        'Never share your password.',
      ],
    ),
    _AwarenessArticle(
      id: '4',
      title: 'Social Media Safety',
      description:
      'Protect your social media accounts and personal information from unauthorized access.',
      category: 'Social Media',
      icon: Icons.people_outline_rounded,
      readTime: '4 min read',
      content: [
        'Social media accounts can contain a large amount of personal information.',
        'Review your privacy settings regularly and be careful about accepting unknown requests.',
        'Avoid publicly sharing sensitive information that could be used to impersonate you.',
      ],
      tips: [
        'Review privacy settings.',
        'Be careful with unknown accounts.',
        'Limit sensitive information.',
        'Secure your account with additional protection.',
      ],
    ),
    _AwarenessArticle(
      id: '5',
      title: 'Protect Your Digital Privacy',
      description:
      'Learn practical ways to reduce unnecessary exposure of your personal information online.',
      category: 'Privacy',
      icon: Icons.privacy_tip_outlined,
      readTime: '4 min read',
      content: [
        'Digital privacy means understanding what information you share and who can access it.',
        'Review application permissions and remove permissions that are no longer necessary.',
        'Be careful when connecting to unknown networks or sharing personal documents online.',
      ],
      tips: [
        'Review app permissions.',
        'Limit unnecessary information sharing.',
        'Keep devices updated.',
        'Use secure connections whenever possible.',
      ],
    ),
    _AwarenessArticle(
      id: '6',
      title: 'Understanding Malware',
      description:
      'Learn what malware is and how basic security practices can reduce your risk.',
      category: 'Malware',
      icon: Icons.bug_report_outlined,
      readTime: '5 min read',
      content: [
        'Malware is malicious software designed to disrupt systems, steal information or perform unauthorized actions.',
        'Avoid downloading files from unknown sources and be cautious with unexpected attachments.',
        'Keep your operating system and security software updated.',
      ],
      tips: [
        'Download from trusted sources.',
        'Avoid unknown attachments.',
        'Keep software updated.',
        'Use reliable security protection.',
      ],
    ),
    _AwarenessArticle(
      id: '7',
      title: 'Identity Theft Awareness',
      description:
      'Understand how personal information can be misused and how to protect it.',
      category: 'Identity Theft',
      icon: Icons.badge_outlined,
      readTime: '4 min read',
      content: [
    'Identity theft can occur when someone obtains and misuses another person personal information.',
      'Avoid unnecessarily sharing identification documents and sensitive account information.',
      'Monitor important accounts for unusual activity and secure accounts with strong authentication.',
      ],
    tips: [
    'Protect identification documents.',
    'Monitor important accounts.',
    'Use strong authentication.',
    'Report suspicious activity.',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animationController.forward();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<_AwarenessArticle> get _filteredArticles {
    return _articles.where((article) {
      final matchesCategory = _selectedCategory == 'All' ||
          article.category == _selectedCategory;

      final matchesSearch = _searchQuery.isEmpty ||
          article.title.toLowerCase().contains(_searchQuery) ||
          article.description.toLowerCase().contains(_searchQuery) ||
          article.category.toLowerCase().contains(_searchQuery);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _openArticle(_AwarenessArticle article) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: AwarenessArticleScreen(
              article: article,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final articles = _filteredArticles;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cyber Awareness',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(
            const Duration(milliseconds: 700),
          );

          if (mounted) {
            setState(() {});
          }
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: _buildQuizCard(),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: _buildHero(),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: _buildSearch(),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.only(
                top: 18,
              ),
              sliver: SliverToBoxAdapter(
                child: _buildCategories(),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                20,
                24,
                20,
                30,
              ),
              sliver: articles.isEmpty
                  ? SliverToBoxAdapter(
                child: _buildEmptyState(),
              )
                  : SliverList.builder(
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  return _animatedArticleCard(
                    articles[index],
                    index,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final value = Curves.easeOutCubic.transform(
          _animationController.value,
        );

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
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.82),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.18),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: Colors.white,
                size: 34,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stay Cyber Safe',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Learn how to protect yourself from common online threats.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildQuizCard() {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CyberSafetyQuizScreen(),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.quiz_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),

              const SizedBox(width: 14),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cyber Safety Quiz',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Test your cybersecurity knowledge',
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 17,
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildSearch() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search cybersecurity topics...',
        prefixIcon: const Icon(
          Icons.search_rounded,
        ),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
          onPressed: () {
            _searchController.clear();
          },
          icon: const Icon(
            Icons.clear_rounded,
          ),
        )
            : null,
        filled: true,
        fillColor: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.45),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) =>
        const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final selected =
              _selectedCategory == category;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: ChoiceChip(
              label: Text(category),
              selected: selected,
              onSelected: (_) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: selected
                    ? Colors.white
                    : Theme.of(context)
                    .colorScheme
                    .onSurface,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.5),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(14),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _animatedArticleCard(
      _AwarenessArticle article,
      int index,
      ) {
    final start =
    (index * 0.08).clamp(0.0, 0.65);

    final animation = CurvedAnimation(
      parent: _animationController,
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
              30 * (1 - value),
            ),
            child: child,
          ),
        );
      },
      child: _articleCard(article),
    );
  }

  Widget _articleCard(_AwarenessArticle article) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _openArticle(article),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  color: AppColors.primary
                      .withValues(alpha: 0.08),
                  borderRadius:
                  BorderRadius.circular(16),
                ),
                child: Icon(
                  article.icon,
                  color: AppColors.primary,
                  size: 29,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            article.category,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight:
                              FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          article.readTime,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      article.description,
                      maxLines: 2,
                      overflow:
                      TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'Read Article',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight:
                            FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons
                              .arrow_forward_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
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


  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 50,
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 60,
          ),
          const SizedBox(height: 15),
          const Text(
            'No articles found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Try another keyword or category.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AwarenessArticle {
  final String id;
  final String title;
  final String description;
  final String category;
  final IconData icon;
  final String readTime;
  final List<String> content;
  final List<String> tips;

  const _AwarenessArticle({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.readTime,
    required this.content,
    required this.tips,
  });
}