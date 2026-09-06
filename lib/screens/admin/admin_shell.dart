import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'complaints/admin_complaints_screen.dart';
import 'dashboard/admin_dashboard_screen.dart';
import 'notifications/admin_notifications_screen.dart';
import 'profile/admin_profile_screen.dart';
import 'reports/admin_reports_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({
    super.key,
  });

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = const [
      AdminDashboardScreen(),
      AdminComplaintsScreen(),
      AdminNotificationsScreen(),

      // REAL FIREBASE REPORTS SCREEN
      AdminReportsScreen(),

      AdminProfileScreen(),
    ];
  }

  void _onNavigationTap(int index) {
    if (_currentIndex == index) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onNavigationTap,
        height: 72,
        elevation: 0,
        backgroundColor:
        Theme.of(context).scaffoldBackgroundColor,

        indicatorColor: AppColors.primary.withValues(
          alpha: 0.10,
        ),

        destinations: const [
          // ==================================================
          // DASHBOARD
          // ==================================================

          NavigationDestination(
            icon: Icon(
              Icons.dashboard_outlined,
            ),
            selectedIcon: Icon(
              Icons.dashboard_rounded,
            ),
            label: 'Dashboard',
          ),

          // ==================================================
          // COMPLAINTS
          // ==================================================

          NavigationDestination(
            icon: Icon(
              Icons.description_outlined,
            ),
            selectedIcon: Icon(
              Icons.description_rounded,
            ),
            label: 'Complaints',
          ),

          // ==================================================
          // NOTIFICATIONS
          // ==================================================

          NavigationDestination(
            icon: Icon(
              Icons.notifications_none_rounded,
            ),
            selectedIcon: Icon(
              Icons.notifications_rounded,
            ),
            label: 'Alerts',
          ),

          // ==================================================
          // REPORTS
          // ==================================================

          NavigationDestination(
            icon: Icon(
              Icons.bar_chart_outlined,
            ),
            selectedIcon: Icon(
              Icons.bar_chart_rounded,
            ),
            label: 'Reports',
          ),

          // ==================================================
          // PROFILE
          // ==================================================

          NavigationDestination(
            icon: Icon(
              Icons.person_outline_rounded,
            ),
            selectedIcon: Icon(
              Icons.person_rounded,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}