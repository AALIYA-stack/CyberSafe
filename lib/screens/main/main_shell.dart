import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

import '../awareness/awareness_screen.dart';
import '../notification/notifications_screen.dart';
import '../profile/profile_screen.dart';
import '../ai_chat/ai_chat_screen.dart';
import '../users/complaints/my_complaints_screen.dart';
import '../users/home/user_home_screen.dart';

class MainShell extends StatefulWidget {
final bool isGuest;

const MainShell({
super.key,
this.isGuest = false,
});

@override
State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
// ==========================================================
// CURRENT TAB
// ==========================================================

int _currentIndex = 0;

// ==========================================================
// USER SCREENS
// ==========================================================

late final List<Widget> _screens;

@override
void initState() {
super.initState();

_screens = [
// ------------------------------------------------------
// 0 — USER HOME
// ------------------------------------------------------

const UserHomeScreen(),

// ------------------------------------------------------
// 1 — MY COMPLAINTS
// ------------------------------------------------------

const MyComplaintsScreen(),

// ------------------------------------------------------
// 2 — AI CHAT
// ------------------------------------------------------

const AiChatScreen(),

// ------------------------------------------------------
// 3 — AWARENESS
// ------------------------------------------------------

const AwarenessScreen(),

// ------------------------------------------------------
// 4 — NOTIFICATIONS
// ------------------------------------------------------

const NotificationsScreen(),

// ------------------------------------------------------
// 5 — PROFILE
// ------------------------------------------------------

const ProfileScreen(),
];
}

// ==========================================================
// GUEST ACCESS
// ==========================================================

bool _isGuestAllowed(int index) {
return index == 0 || index == 3;
}

// ==========================================================
// NAVIGATION
// ==========================================================

void _onNavigationTap(int index) {
if (widget.isGuest && !_isGuestAllowed(index)) {
_showLoginRequired();
return;
}

setState(() {
_currentIndex = index;
});
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
28,
24,
24,
),
decoration: BoxDecoration(
color: Theme.of(context).scaffoldBackgroundColor,
borderRadius: const BorderRadius.vertical(
top: Radius.circular(28),
),
),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
// ------------------------------------------------
// LOCK ICON
// ------------------------------------------------

Container(
width: 64,
height: 64,
decoration: BoxDecoration(
color: AppColors.primary.withValues(
alpha: 0.08,
),
shape: BoxShape.circle,
),
child: const Icon(
Icons.lock_outline_rounded,
color: AppColors.primary,
size: 30,
),
),

const SizedBox(height: 18),

// ------------------------------------------------
// TITLE
// ------------------------------------------------

const Text(
'Login Required',
style: TextStyle(
fontSize: 21,
fontWeight: FontWeight.w800,
),
),

const SizedBox(height: 8),

const Text(
'Please login to access your personal CyberSafe features.',
textAlign: TextAlign.center,
style: TextStyle(
color: AppColors.textSecondary,
height: 1.5,
),
),

const SizedBox(height: 24),

// ------------------------------------------------
// LOGIN
// ------------------------------------------------

SizedBox(
width: double.infinity,
height: 52,
child: ElevatedButton(
onPressed: () {
Navigator.pop(context);

Navigator.pushNamed(
context,
'/login',
);
},
style: ElevatedButton.styleFrom(
backgroundColor: AppColors.primary,
foregroundColor: Colors.white,
elevation: 0,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(15),
),
),
child: const Text(
'Login',
style: TextStyle(
fontWeight: FontWeight.w700,
),
),
),
),

const SizedBox(height: 10),

// ------------------------------------------------
// CREATE ACCOUNT
// ------------------------------------------------

SizedBox(
width: double.infinity,
height: 48,
child: OutlinedButton(
onPressed: () {
Navigator.pop(context);

Navigator.pushNamed(
context,
'/signup',
);
},
style: OutlinedButton.styleFrom(
foregroundColor: AppColors.primary,
side: const BorderSide(
color: AppColors.primary,
),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(15),
),
),
child: const Text(
'Create Account',
style: TextStyle(
fontWeight: FontWeight.w700,
),
),
),
),

const SizedBox(height: 8),

// ------------------------------------------------
// CONTINUE AS GUEST
// ------------------------------------------------

TextButton(
onPressed: () {
Navigator.pop(context);
},
child: const Text(
'Continue as Guest',
style: TextStyle(
color: AppColors.textSecondary,
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
// LOCKED ICON
// ==========================================================

Widget _lockedIcon({
required IconData normalIcon,
required IconData selectedIcon,
required bool locked,
required bool selected,
}) {
if (locked) {
return const Icon(
Icons.lock_outline_rounded,
);
}

return Icon(
selected ? selectedIcon : normalIcon,
);
}

// ==========================================================
// BUILD
// ==========================================================

@override
Widget build(BuildContext context) {
return Scaffold(
// ======================================================
// BODY
// ======================================================

body: IndexedStack(
index: _currentIndex,
children: _screens,
),

// ======================================================
// BOTTOM NAVIGATION
// ======================================================

bottomNavigationBar: NavigationBar(
selectedIndex: _currentIndex,
onDestinationSelected: _onNavigationTap,

backgroundColor:
Theme.of(context).scaffoldBackgroundColor,

indicatorColor: AppColors.primary.withValues(
alpha: 0.10,
),

elevation: 0,

height: 72,

destinations: [
// ==================================================
// HOME
// ==================================================

const NavigationDestination(
icon: Icon(
Icons.home_outlined,
),
selectedIcon: Icon(
Icons.home_rounded,
),
label: 'Home',
),

// ==================================================
// COMPLAINTS
// ==================================================

NavigationDestination(
icon: _lockedIcon(
normalIcon: Icons.description_outlined,
selectedIcon: Icons.description_rounded,
locked: widget.isGuest,
selected: _currentIndex == 1,
),
selectedIcon: _lockedIcon(
normalIcon: Icons.description_outlined,
selectedIcon: Icons.description_rounded,
locked: widget.isGuest,
selected: true,
),
label: 'Complaints',
),

// ==================================================
// AI CHAT
// ==================================================

NavigationDestination(
icon: _lockedIcon(
normalIcon: Icons.smart_toy_outlined,
selectedIcon: Icons.smart_toy_rounded,
locked: widget.isGuest,
selected: _currentIndex == 2,
),
selectedIcon: _lockedIcon(
normalIcon: Icons.smart_toy_outlined,
selectedIcon: Icons.smart_toy_rounded,
locked: widget.isGuest,
selected: true,
),
label: 'AI Chat',
),

// ==================================================
// AWARENESS
// ==================================================

const NavigationDestination(
icon: Icon(
Icons.shield_outlined,
),
selectedIcon: Icon(
Icons.shield_rounded,
),
label: 'Awareness',
),

// ==================================================
// NOTIFICATIONS
// ==================================================

NavigationDestination(
icon: _lockedIcon(
normalIcon:
Icons.notifications_none_rounded,
selectedIcon:
Icons.notifications_rounded,
locked: widget.isGuest,
selected: _currentIndex == 4,
),
selectedIcon: _lockedIcon(
normalIcon:
Icons.notifications_none_rounded,
selectedIcon:
Icons.notifications_rounded,
locked: widget.isGuest,
selected: true,
),
label: 'Alerts',
),

// ==================================================
// PROFILE
// ==================================================

NavigationDestination(
icon: _lockedIcon(
normalIcon: Icons.person_outline_rounded,
selectedIcon: Icons.person_rounded,
locked: widget.isGuest,
selected: _currentIndex == 5,
),
selectedIcon: _lockedIcon(
normalIcon: Icons.person_outline_rounded,
selectedIcon: Icons.person_rounded,
locked: widget.isGuest,
selected: true,
),
label: 'Profile',
),
],
),
);
}
}

