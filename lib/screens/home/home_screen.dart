import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../routes/app_routes.dart';

class GuestHomeScreen extends StatefulWidget {
  const GuestHomeScreen({super.key});

  @override
  State<GuestHomeScreen> createState() => _GuestHomeScreenState();
}

class _GuestHomeScreenState extends State<GuestHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;


  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ==========================================================
  // LOGIN REQUIRED
  // ==========================================================

  void _showLoginRequired() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            24,
            24,
            24,
            30,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 24),

              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: 0.08,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  size: 34,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Login Required',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Please login or create an account '
                    'to submit and track your cyber crime complaint.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  height: 1.5,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);

                    Navigator.pushNamed(
                      context,
                      AppRoutes.login,
                    );
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);

                    Navigator.pushNamed(
                      context,
                      AppRoutes.signup,
                    );
                  },
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================
  // NAVIGATION
  // ==========================================================

  void _onBottomNavigationTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;

      case 1:
        Navigator.pushNamed(
          context,
          AppRoutes.awareness,
        );
        break;

      case 2:
        Navigator.pushNamed(
          context,
          AppRoutes.about,
        );
        break;

      case 3:
        Navigator.pushNamed(
          context,
          AppRoutes.login,
        );
        break;
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),

      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.shield_rounded,
                color: Colors.white,
                size: 23,
              ),
            ),

            const SizedBox(width: 11),

            const Text(
              'CyberSafe',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 16,
            ),
            child: OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.login,
                );
              },
              child: const Text(
                'Login',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
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
                  _buildWelcomeSection(),

                  const SizedBox(height: 24),

                  _buildReportCard(),

                  const SizedBox(height: 24),

                  _buildQuickActions(),

                  const SizedBox(height: 28),

                  _buildAwarenessSection(),

                  const SizedBox(height: 28),

                  _buildHowItWorks(),

                  const SizedBox(height: 25),

                  _buildSignupBanner(),
                ],
              ),
            ),
          ),
        ),
      ),

      bottomNavigationBar:
      _buildBottomNavigation(),
    );
  }

  // ==========================================================
  // WELCOME
  // ==========================================================

  Widget _buildWelcomeSection() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Stay Safe Online',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Learn about cyber threats and '
                        'protect yourself from online crime.',
                    style: TextStyle(
                      color: Colors.white.withValues(
                        alpha: 0.82,
                      ),
                      height: 1.5,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 17),

                  SizedBox(
                    height: 42,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.awareness,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor:
                        AppColors.primary,
                      ),
                      child: const Text(
                        'Explore Safety Tips',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: 0.12,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.security_rounded,
                color: Colors.white,
                size: 42,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // REPORT CARD
  // ==========================================================

  Widget _buildReportCard() {
    return GestureDetector(
      onTap: _showLoginRequired,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.04,
              ),
              blurRadius: 15,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(
                  alpha: 0.08,
                ),
                borderRadius: BorderRadius.circular(17),
              ),
              child: const Icon(
                Icons.report_problem_outlined,
                color: AppColors.primary,
                size: 29,
              ),
            ),

            const SizedBox(width: 15),

            const Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'Report Cyber Crime',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Login required to submit a complaint.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.lock_outline_rounded,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // QUICK ACTIONS
  // ==========================================================

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Text(
          'Explore CyberSafe',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: _quickAction(
                icon: Icons.security_outlined,
                title: 'Awareness',
                subtitle: 'Learn & protect',
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.awareness,
                  );
                },
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _quickAction(
                icon: Icons.info_outline_rounded,
                title: 'About',
                subtitle: 'Learn about us',
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.about,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(
                  alpha: 0.08,
                ),
                borderRadius:
                BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 13),

            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // AWARENESS
  // ==========================================================

  Widget _buildAwarenessSection() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Cyber Safety Tips',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.awareness,
                );
              },
              child: const Text('View All'),
            ),
          ],
        ),

        const SizedBox(height: 10),

        SizedBox(
          height: 155,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _tipCard(
                icon: Icons.phishing_outlined,
                title: 'Avoid Phishing',
                text:
                'Do not open suspicious links or messages.',
              ),
              _tipCard(
                icon: Icons.lock_outline_rounded,
                title: 'Secure Passwords',
                text:
                'Use strong and unique passwords.',
              ),
              _tipCard(
                icon: Icons.privacy_tip_outlined,
                title: 'Protect Privacy',
                text:
                'Be careful when sharing personal information.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tipCard({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      width: 235,
      margin: const EdgeInsets.only(
        right: 12,
      ),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 28,
          ),

          const SizedBox(height: 10),

          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // HOW IT WORKS
  // ==========================================================

  Widget _buildHowItWorks() {
    final steps = [
      (
      Icons.login_rounded,
      'Create Account',
      'Login or create your CyberSafe account.',
      ),
      (
      Icons.description_outlined,
      'Submit Complaint',
      'Provide incident details and evidence.',
      ),
      (
      Icons.rate_review_outlined,
      'Review',
      'Review your complaint before submission.',
      ),
      (
      Icons.track_changes_rounded,
      'Track Status',
      'Track your complaint after submission.',
      ),
    ];

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Text(
          'How CyberSafe Works',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 15),

        ...List.generate(
          steps.length,
              (index) {
            final step = steps[index];

            return Padding(
              padding: const EdgeInsets.only(
                bottom: 12,
              ),
              child: Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color:
                      AppColors.primary.withValues(
                        alpha: 0.08,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      step.$1,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),

                  const SizedBox(width: 13),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.$2,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          step.$3,
                          style: TextStyle(
                            color:
                            Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
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

  // ==========================================================
  // SIGNUP BANNER
  // ==========================================================

  Widget _buildSignupBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(
          alpha: 0.07,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(
            alpha: 0.12,
          ),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.person_add_alt_1_rounded,
            color: AppColors.primary,
            size: 32,
          ),

          const SizedBox(height: 10),

          const Text(
            'Ready to report a cyber crime?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Create an account to submit and track '
                'your complaints securely.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 15),

          SizedBox(
            height: 46,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.signup,
                );
              },
              child: const Text(
                'Create Free Account',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // BOTTOM NAVIGATION
  // ==========================================================

  Widget _buildBottomNavigation() {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected:
      _onBottomNavigationTap,
      destinations: const [
        NavigationDestination(
          icon: Icon(
            Icons.home_outlined,
          ),
          selectedIcon: Icon(
            Icons.home_rounded,
          ),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.security_outlined,
          ),
          selectedIcon: Icon(
            Icons.security_rounded,
          ),
          label: 'Awareness',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.info_outline_rounded,
          ),
          selectedIcon: Icon(
            Icons.info_rounded,
          ),
          label: 'About',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.login_outlined,
          ),
          selectedIcon: Icon(
            Icons.login_rounded,
          ),
          label: 'Login',
        ),
      ],
    );
  }
}