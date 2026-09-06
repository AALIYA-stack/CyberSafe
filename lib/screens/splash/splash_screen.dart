import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1200,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.75,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();

    _startSplash();
  }

  // ==========================================================
  // SPLASH NAVIGATION
  // ==========================================================

  Future<void> _startSplash() async {
    await Future.delayed(
      const Duration(
        milliseconds: 2200,
      ),
    );

    if (!mounted) {
      return;
    }

    try {
      // ======================================================
      // CHECK CURRENT FIREBASE USER
      // ======================================================

      final currentUser =
          AuthService.instance.currentUser;

      // ======================================================
      // NO LOGGED-IN USER
      // ======================================================

      if (currentUser == null) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.onboarding,
              (route) => false,
        );

        return;
      }

      // ======================================================
      // GET USER ROLE FROM FIRESTORE
      // ======================================================

      final role =
      await AuthService.instance.getUserRole();

      if (!mounted) {
        return;
      }

      // ======================================================
      // ADMIN USER
      // IMPORTANT:
      // ADMIN GOES TO ADMIN SHELL
      // ======================================================

      if (role == 'admin') {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.adminShell,
              (route) => false,
        );

        return;
      }

      // ======================================================
      // NORMAL USER
      // ======================================================

      if (role == 'user') {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.main,
              (route) => false,
        );

        return;
      }

      // ======================================================
      // UNKNOWN / INVALID ROLE
      // ======================================================

      await AuthService.instance.logout();

      if (!mounted) {
        return;
      }

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.onboarding,
            (route) => false,
      );
    } catch (e) {
      debugPrint(
        'SPLASH NAVIGATION ERROR: $e',
      );

      if (!mounted) {
        return;
      }

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.onboarding,
            (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  // ==========================================================
  // UI
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (
                context,
                child,
                ) {
              return Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  // ==================================================
                  // LOGO
                  // ==================================================

                  Transform.scale(
                    scale: _scaleAnimation.value,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        width: 105,
                        height: 105,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                          BorderRadius.circular(30),
                        ),
                        child: Icon(
                          Icons.shield_rounded,
                          size: 62,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ==================================================
                  // APP NAME + DESCRIPTION
                  // ==================================================

                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Column(
                        children: [
                          Text(
                            'CyberSafe',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight:
                              FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),

                          SizedBox(height: 8),

                          Text(
                            'Cyber Crime Complaint &\n'
                                'Awareness Management System',
                            textAlign:
                            TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}