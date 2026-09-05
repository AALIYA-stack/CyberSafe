import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() =>
      _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  late AnimationController _iconController;
  late AnimationController _contentController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      icon: Icons.shield_outlined,
      title: 'Stay Cyber Safe',
      description:
      'Learn how to protect your accounts, personal information and digital identity from online threats.',
    ),
    _OnboardingData(
      icon: Icons.report_problem_outlined,
      title: 'Report Cyber Crime',
      description:
      'Submit your cyber crime complaint through a simple, secure and organized reporting process.',
    ),
    _OnboardingData(
      icon: Icons.track_changes_outlined,
      title: 'Track Your Complaint',
      description:
      'Track the progress of your submitted complaint and stay informed about important status updates.',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.75,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeOutCubic,
      ),
    );

    _startAnimations();
  }

  void _startAnimations() {
    _iconController.forward(from: 0);
    _contentController.forward(from: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _iconController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // ==========================================================
  // MARK ONBOARDING AS COMPLETED
  // ==========================================================

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      'onboarding_completed',
      true,
    );

    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed('/login');
  }

  // ==========================================================
  // SKIP
  // ==========================================================

  Future<void> _skip() async {
    await _completeOnboarding();
  }

  // ==========================================================
  // NEXT
  // ==========================================================

  Future<void> _nextPage() async {
    if (_currentPage < _pages.length - 1) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    } else {
      await _completeOnboarding();
    }
  }

  // ==========================================================
  // PAGE CHANGE
  // ==========================================================

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });

    _iconController.forward(from: 0);
    _contentController.forward(from: 0);
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // TOP BAR
            // ==================================================

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 18,
              ),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  // LOGO
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.shield_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Text(
                        'CyberSafe',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),

                  // SKIP
                  TextButton(
                    onPressed: _skip,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // PAGE VIEW
            // ==================================================

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final page = _pages[index];

                  return AnimatedBuilder(
                    animation: Listenable.merge([
                      _iconController,
                      _contentController,
                    ]),
                    builder: (context, child) {
                      return Padding(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 28,
                        ),
                        child: Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            // ==================================
                            // ANIMATED ICON
                            // ==================================

                            ScaleTransition(
                              scale: _scaleAnimation,
                              child: Container(
                                width: size.width * 0.48,
                                height: size.width * 0.48,
                                constraints:
                                const BoxConstraints(
                                  maxWidth: 210,
                                  maxHeight: 210,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Container(
                                    width:
                                    size.width * 0.32,
                                    height:
                                    size.width * 0.32,
                                    constraints:
                                    const BoxConstraints(
                                      maxWidth: 140,
                                      maxHeight: 140,
                                    ),
                                    decoration:
                                    BoxDecoration(
                                      color:
                                      AppColors.primary,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors
                                              .primary
                                              .withValues(
                                            alpha: 0.20,
                                          ),
                                          blurRadius: 25,
                                          spreadRadius: 3,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      page.icon,
                                      color: Colors.white,
                                      size: 65,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 45),

                            // ==================================
                            // TITLE + DESCRIPTION
                            // ==================================

                            SlideTransition(
                              position: _slideAnimation,
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: Column(
                                  children: [
                                    Text(
                                      page.title,
                                      textAlign:
                                      TextAlign.center,
                                      style: TextStyle(
                                        color:
                                        AppColors.primary,
                                        fontSize: 29,
                                        fontWeight:
                                        FontWeight.w800,
                                        height: 1.2,
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    Text(
                                      page.description,
                                      textAlign:
                                      TextAlign.center,
                                      style: TextStyle(
                                        color: AppColors
                                            .textSecondary,
                                        fontSize: 15.5,
                                        height: 1.65,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // ==================================================
            // PAGE INDICATORS
            // ==================================================

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                    (index) {
                  final selected =
                      index == _currentPage;

                  return AnimatedContainer(
                    duration:
                    const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    margin:
                    const EdgeInsets.symmetric(
                      horizontal: 4,
                    ),
                    width: selected ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary
                          : AppColors.border,
                      borderRadius:
                      BorderRadius.circular(20),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            // ==================================================
            // BOTTOM BUTTON
            // ==================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                24,
                0,
                24,
                24,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(16),
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration:
                    const Duration(milliseconds: 250),
                    child: Text(
                      _currentPage ==
                          _pages.length - 1
                          ? 'Get Started'
                          : 'Next',
                      key: ValueKey(_currentPage),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ONBOARDING MODEL
// ============================================================

class _OnboardingData {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
  });
}