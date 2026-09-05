import 'package:flutter/material.dart';

import '../../animations/fade_slide_animation.dart';
import '../../animations/scale_fade_animation.dart';
import '../../core/constants/app_colors.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Emergency Help',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          12,
          20,
          30,
        ),
        children: [
          FadeSlideAnimation(
            child: _buildEmergencyHeader(),
          ),

          const SizedBox(height: 22),

          const FadeSlideAnimation(
            delay: 100,
            child: Text(
              'What Should You Do?',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(height: 7),

          FadeSlideAnimation(
            delay: 150,
            child: Text(
              'If you believe you are experiencing cybercrime, stay calm and take the following steps.',
              style: TextStyle(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ),

          const SizedBox(height: 18),

          FadeSlideAnimation(
            delay: 200,
            child: _EmergencyStepCard(
              number: '01',
              icon: Icons.pause_circle_outline_rounded,
              title: 'Stop Communication',
              description:
              'Stop communicating with suspicious individuals and avoid sending additional information or money.',
            ),
          ),

          FadeSlideAnimation(
            delay: 260,
            child: _EmergencyStepCard(
              number: '02',
              icon: Icons.save_outlined,
              title: 'Preserve Evidence',
              description:
              'Keep relevant messages, emails, transaction information and other useful records.',
            ),
          ),

          FadeSlideAnimation(
            delay: 320,
            child: _EmergencyStepCard(
              number: '03',
              icon: Icons.lock_reset_rounded,
              title: 'Secure Your Accounts',
              description:
              'Change compromised passwords and enable additional security features where possible.',
            ),
          ),

          FadeSlideAnimation(
            delay: 380,
            child: _EmergencyStepCard(
              number: '04',
              icon: Icons.report_outlined,
              title: 'Report the Incident',
              description:
              'Use an appropriate official reporting channel to report the incident and provide accurate information.',
            ),
          ),

          const SizedBox(height: 20),

          ScaleFadeAnimation(
            delay: 450,
            child: _buildImportantCard(),
          ),

          const SizedBox(height: 18),

          FadeSlideAnimation(
            delay: 520,
            child: _buildCyberSafeCard(context),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyHeader() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryDark,
            AppColors.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(
              alpha: 0.20,
            ),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.13,
                  ),
                  borderRadius:
                  BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.emergency_outlined,
                  color: Colors.white,
                  size: 31,
                ),
              ),
              const SizedBox(width: 15),
              const Expanded(
                child: Text(
                  'Cyber Emergency',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'If something suspicious happens online, act carefully and protect your accounts and information.',
            style: TextStyle(
              color: Colors.white70,
              height: 1.5,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportantCard() {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(
          alpha: 0.09,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.warning.withValues(
            alpha: 0.25,
          ),
        ),
      ),
      child: const Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppColors.warning,
            size: 27,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Important',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'CyberSafe is a frontend demonstration application. For a real emergency, contact the appropriate official emergency or law-enforcement service in your area.',
                  style: TextStyle(
                    color:
                    AppColors.textSecondary,
                    height: 1.5,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCyberSafeCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary
                      .withValues(alpha: 0.08),
                  borderRadius:
                  BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Need to report cybercrime?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          const Text(
            'Create an account to submit a complaint and track its status inside CyberSafe.',
            style: TextStyle(
              color: AppColors.textSecondary,
              height: 1.5,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/complaint-form',
                );
              },
              icon: const Icon(
                Icons.add_circle_outline_rounded,
              ),
              label: const Text(
                'Report a Complaint',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyStepCard extends StatelessWidget {
  final String number;
  final IconData icon;
  final String title;
  final String description;

  const _EmergencyStepCard({
    required this.number,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 13,
      ),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: 0.08,
              ),
              borderRadius:
              BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 25,
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
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight:
                          FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      number,
                      style: TextStyle(
                        color: AppColors.primary
                            .withValues(
                          alpha: 0.45,
                        ),
                        fontSize: 11,
                        fontWeight:
                        FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  description,
                  style: const TextStyle(
                    color:
                    AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}