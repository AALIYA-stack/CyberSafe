import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/auth_required_dialog.dart';
import '../animations/guest_fade_animation.dart';
import '../animations/guest_slide_animation.dart';

class GuestDashboardScreen extends StatelessWidget {
  const GuestDashboardScreen({
    super.key,
  });

  void _showLoginRequired(
      BuildContext context,
      ) {
    AuthRequiredDialog.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CyberSafe',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          GuestFadeAnimation(
            child: IconButton(
              tooltip: 'Login',
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.login,
                );
              },
              icon: const Icon(
                Icons.login_rounded,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            30,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              // ==================================================
              // WELCOME CARD
              // ==================================================

              GuestSlideAnimation(
                delay: 80,
                child: Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius:
                    BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration:
                        BoxDecoration(
                          color: Colors.white
                              .withValues(
                            alpha: 0.12,
                          ),
                          borderRadius:
                          BorderRadius
                              .circular(16),
                        ),
                        child: const Icon(
                          Icons
                              .shield_outlined,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      const Text(
                        'Stay Safe Online',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight:
                          FontWeight.w800,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        'Learn how to protect yourself '
                            'from cyber threats and online scams.',
                        style: TextStyle(
                          color: Colors.white
                              .withValues(
                            alpha: 0.82,
                          ),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.awareness,
                          );
                        },
                        icon: const Icon(
                          Icons
                              .auto_awesome_outlined,
                        ),
                        label: const Text(
                          'Explore Awareness',
                        ),
                        style:
                        FilledButton.styleFrom(
                          backgroundColor:
                          Colors.white,
                          foregroundColor:
                          AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ==================================================
              // PUBLIC FEATURES
              // ==================================================

              GuestSlideAnimation(
                delay: 180,
                child: const Text(
                  'Explore CyberSafe',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              GuestFadeAnimation(
                delay: 220,
                child: Text(
                  'Access public cybersecurity resources '
                      'without creating an account.',
                  style: TextStyle(
                    fontSize: 13,
                    color:
                    Colors.grey.shade600,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ==================================================
              // AWARENESS
              // ==================================================

              GuestSlideAnimation(
                delay: 260,
                child: _GuestFeatureCard(
                  icon: Icons.menu_book_outlined,
                  title: 'Cyber Awareness',
                  description:
                  'Learn about common cyber threats and '
                      'how to stay protected.',
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.awareness,
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // ==================================================
              // SAFETY TIPS
              // ==================================================

              GuestSlideAnimation(
                delay: 320,
                child: _GuestFeatureCard(
                  icon: Icons.security_outlined,
                  title: 'Safety Tips',
                  description:
                  'Practical recommendations for safer '
                      'digital activities.',
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.safetyTips,
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // ==================================================
              // EMERGENCY
              // ==================================================

              GuestSlideAnimation(
                delay: 380,
                child: _GuestFeatureCard(
                  icon:
                  Icons.warning_amber_outlined,
                  title: 'Emergency Guidance',
                  description:
                  'General guidance for common cyber '
                      'security incidents.',
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.emergency,
                    );
                  },
                ),
              ),

              const SizedBox(height: 28),

              // ==================================================
              // LOGIN REQUIRED SECTION
              // ==================================================

              GuestSlideAnimation(
                delay: 440,
                child: const Text(
                  'Account Features',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              GuestFadeAnimation(
                delay: 480,
                child: Text(
                  'Login to access personalized and '
                      'private features.',
                  style: TextStyle(
                    fontSize: 13,
                    color:
                    Colors.grey.shade600,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ==================================================
              // REPORT INCIDENT — LOCKED
              // ==================================================

              GuestSlideAnimation(
                delay: 520,
                child: _GuestFeatureCard(
                  icon:
                  Icons.report_problem_outlined,
                  title: 'Report an Incident',
                  description:
                  'Submit and manage your cyber crime complaint.',
                  locked: true,
                  onTap: () {
                    _showLoginRequired(
                      context,
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // ==================================================
              // MY COMPLAINTS — LOCKED
              // ==================================================

              GuestSlideAnimation(
                delay: 580,
                child: _GuestFeatureCard(
                  icon:
                  Icons.receipt_long_outlined,
                  title: 'My Complaints',
                  description:
                  'Track your submitted complaints and their status.',
                  locked: true,
                  onTap: () {
                    _showLoginRequired(
                      context,
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // ==================================================
              // NOTIFICATIONS — LOCKED
              // ==================================================

              GuestSlideAnimation(
                delay: 640,
                child: _GuestFeatureCard(
                  icon:
                  Icons.notifications_none_rounded,
                  title: 'Notifications',
                  description:
                  'View updates related to your account and complaints.',
                  locked: true,
                  onTap: () {
                    _showLoginRequired(
                      context,
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // ==================================================
              // AI ASSISTANT — LOCKED
              // ==================================================

              GuestSlideAnimation(
                delay: 700,
                child: _GuestFeatureCard(
                  icon:
                  Icons.smart_toy_outlined,
                  title: 'AI Assistant',
                  description:
                  'Get personalized cybersecurity assistance.',
                  locked: true,
                  onTap: () {
                    _showLoginRequired(
                      context,
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // ==================================================
              // LOGIN CTA
              // ==================================================

              GuestFadeAnimation(
                delay: 760,
                child: Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color:
                    AppColors.accentLight,
                    borderRadius:
                    BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons
                            .account_circle_outlined,
                        size: 34,
                        color:
                        AppColors.primary,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        'Want to report a cyber crime?',
                        textAlign:
                        TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Text(
                        'Create a free account to submit '
                            'and track your complaints.',
                        textAlign:
                        TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: Colors
                              .grey.shade700,
                        ),
                      ),
                      const SizedBox(
                        height: 14,
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.login,
                          );
                        },
                        child: const Text(
                          'Login to Continue',
                        ),
                      ),
                    ],
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

// ============================================================
// GUEST FEATURE CARD
// ============================================================

class _GuestFeatureCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool locked;
  final VoidCallback onTap;

  const _GuestFeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context)
          .colorScheme
          .surface,
      borderRadius:
      BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding:
          const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(18),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: locked
                      ? Colors.grey.shade100
                      : AppColors.accentLight,
                  borderRadius:
                  BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: locked
                      ? Colors.grey.shade600
                      : AppColors.primary,
                  size: 26,
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
                            title,
                            style:
                            const TextStyle(
                              fontSize: 15,
                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),
                        ),
                        if (locked)
                          Icon(
                            Icons
                                .lock_outline_rounded,
                            size: 18,
                            color: Colors
                                .grey.shade500,
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color:
                        Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons
                    .arrow_forward_ios_rounded,
                size: 15,
                color:
                Colors.grey.shade500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}