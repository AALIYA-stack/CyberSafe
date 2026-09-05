import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'complaints/admin_complaints_screen.dart';
import 'dashboard/admin_dashboard_screen.dart';
import 'notifications/admin_notifications_screen.dart';
import 'profile/admin_profile_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

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
      _AdminReportsScreen(),
      AdminProfileScreen(),
    ];
  }

  void _onNavigationTap(int index) {
    if (_currentIndex == index) return;

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
          NavigationDestination(
            icon: Icon(
              Icons.dashboard_outlined,
            ),
            selectedIcon: Icon(
              Icons.dashboard_rounded,
            ),
            label: 'Dashboard',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.description_outlined,
            ),
            selectedIcon: Icon(
              Icons.description_rounded,
            ),
            label: 'Complaints',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.notifications_none_rounded,
            ),
            selectedIcon: Icon(
              Icons.notifications_rounded,
            ),
            label: 'Alerts',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.bar_chart_outlined,
            ),
            selectedIcon: Icon(
              Icons.bar_chart_rounded,
            ),
            label: 'Reports',
          ),

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


// ==========================================================
// ADMIN REPORTS SCREEN
// ==========================================================

class _AdminReportsScreen extends StatelessWidget {
  const _AdminReportsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reports',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            const Text(
              'Complaint Reports',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Monitor complaint statistics and resolution progress.',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _ReportCard(
                    title: 'Total',
                    value: '24',
                    icon: Icons.description_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ReportCard(
                    title: 'Pending',
                    value: '08',
                    icon: Icons.pending_actions_rounded,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _ReportCard(
                    title: 'In Progress',
                    value: '06',
                    icon: Icons.sync_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ReportCard(
                    title: 'Resolved',
                    value: '10',
                    icon: Icons.check_circle_outline_rounded,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surface,
                borderRadius:
                BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey.withValues(
                    alpha: 0.15,
                  ),
                ),
              ),
              child: const Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'Report Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Detailed analytics can be connected '
                        'to the complaint service when the backend '
                        'is implemented.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _ReportCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _ReportCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.withValues(
            alpha: 0.15,
          ),
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

          const SizedBox(height: 14),

          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}