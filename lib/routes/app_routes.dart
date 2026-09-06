import 'package:flutter/material.dart';

// ==========================================================
// GENERAL SCREENS
// ==========================================================

import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/main/main_shell.dart';

// ==========================================================
// GUEST
// ==========================================================

import '../screens/guest/dashboard/guest_dashboard_screen.dart';
import '../screens/guest/awareness/guest_awareness_screen.dart';

// ==========================================================
// USER HOME
// ==========================================================

import '../screens/users/home/user_home_screen.dart';

// ==========================================================
// AWARENESS
// ==========================================================

import '../screens/awareness/awareness_screen.dart';
import '../screens/awareness/awareness_article_screen.dart';

// ==========================================================
// AUTH
// ==========================================================

import '../screens/users/auth/login/login_screen.dart';
import '../screens/users/auth/signup/signup_screen.dart';
import '../screens/users/auth/forgot_password/forgot_password_screen.dart';

// ==========================================================
// USER
// ==========================================================

import '../screens/notification/notifications_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/ai_chat/ai_chat_screen.dart';

// ==========================================================
// PUBLIC / SAFETY
// ==========================================================

import '../screens/about/about_screen.dart';
import '../screens/safety/safety_tips_screen.dart';
import '../screens/safety/emergency_screen.dart';

// ==========================================================
// COMPLAINTS
// ==========================================================
import '../screens/users/complaints/my_complaints_screen.dart';
import '../screens/users/complaints/complaint_form_screen.dart';
import '../screens/users/complaints/complaint_status_screen.dart';
import '../screens/users/complaints/complaint_details_screen.dart';

// ==========================================================
// ADMIN
// ==========================================================
import '../screens/admin/login/admin_login_screen.dart';
import '../screens/admin/dashboard/admin_dashboard_screen.dart';
import '../screens/admin/complaints/admin_complaints_screen.dart';
import '../screens/admin/complaints/admin_complaint_details_screen.dart';
import '../screens/admin/notifications/admin_notifications_screen.dart';
import '../screens/admin/settings/admin_settings_screen.dart';
import '../screens/admin/admin_shell.dart';
import '../screens/admin/reports/admin_reports_screen.dart';
// ==========================================================
// MODELS
// ==========================================================

import '../models/complaint.dart';

// ==========================================================
// APP ROUTES
// ==========================================================

class AppRoutes {
AppRoutes._();

// ==========================================================
// GENERAL
// ==========================================================

static const String splash = '/';

static const String onboarding = '/onboarding';

static const String guest = '/guest';

static const String main = '/main';

static const String home = '/home';

// ==========================================================
// AUTH
// ==========================================================

static const String login = '/login';

static const String signup = '/signup';

static const String forgotPassword = '/forgot-password';

// ==========================================================
// PUBLIC
// ==========================================================

static const String awareness = '/awareness';

static const String awarenessArticle = '/awareness-article';

static const String guestAwareness = '/guest-awareness';

static const String about = '/about';

static const String safetyTips = '/safety-tips';

static const String emergency = '/emergency';

// ==========================================================
// USER
// ==========================================================

static const String notifications = '/notifications';

static const String profile = '/profile';

static const String settings = '/settings';

static const String aiChat = '/ai-chat';

// ==========================================================
// COMPLAINT
// ==========================================================

static const String complaintForm = '/complaint-form';

static const String complaintStatus = '/complaint-status';

static const String complaintDetails = '/complaint-details';

  static const String myComplaints = '/my-complaints';
// ==========================================================
// ADMIN
// ==========================================================

  static const String adminLogin = '/admin-login';
  static const String adminComplaints = '/admin-complaints';
   static const String adminReports = '/admin-reports';
static const String adminComplaintDetails =
'/admin-complaint-details';
  static const String adminDashboard = '/admin-dashboard';
  static const String adminShell = '/admin-shell';

static const String adminNotifications =
'/admin-notifications';


static const String adminSettings = '/admin-settings';

// ==========================================================
// GENERATE ROUTE
// ==========================================================

static Route<dynamic> generateRoute(
RouteSettings routeSettings,
) {
switch (routeSettings.name) {

// ======================================================
// SPLASH
// ======================================================

case splash:
return MaterialPageRoute(
builder: (_) => const SplashScreen(),
settings: routeSettings,
);

// ======================================================
// ONBOARDING
// ======================================================

case onboarding:
return MaterialPageRoute(
builder: (_) => const OnboardingScreen(),
settings: routeSettings,
);

// ======================================================
// GUEST DASHBOARD
// ======================================================

case guest:
return MaterialPageRoute(
builder: (_) => const GuestDashboardScreen(),
settings: routeSettings,
);

// ======================================================
// GUEST AWARENESS
// ======================================================

case guestAwareness:
return MaterialPageRoute(
builder: (_) => const GuestAwarenessScreen(),
settings: routeSettings,
);

// ======================================================
// LOGIN
// ======================================================

case login:
return MaterialPageRoute(
builder: (_) => const LoginScreen(),
settings: routeSettings,
);

// ======================================================
// SIGNUP
// ======================================================

case signup:
return MaterialPageRoute(
builder: (_) => const SignupScreen(),
settings: routeSettings,
);

// ======================================================
// FORGOT PASSWORD
// ======================================================

case forgotPassword:
return MaterialPageRoute(
builder: (_) => const ForgotPasswordScreen(),
settings: routeSettings,
);

// ======================================================
// MAIN SHELL
// ======================================================

case main:
return MaterialPageRoute(
builder: (_) => const MainShell(),
settings: routeSettings,
);

// ======================================================
// HOME
// ======================================================

case home:
return MaterialPageRoute(
builder: (_) => const UserHomeScreen(),
settings: routeSettings,
);

// ======================================================
// AWARENESS
// ======================================================

case awareness:
return MaterialPageRoute(
builder: (_) => const AwarenessScreen(),
settings: routeSettings,
);

// ======================================================
// AWARENESS ARTICLE
// ======================================================

case awarenessArticle:
final article = routeSettings.arguments;

if (article != null) {
return MaterialPageRoute(
builder: (_) => AwarenessArticleScreen(
article: article,
),
settings: routeSettings,
);
}

return _errorRoute(
'Article not found.',
);

// ======================================================
// ABOUT
// ======================================================

case about:
return MaterialPageRoute(
builder: (_) => const AboutScreen(),
settings: routeSettings,
);

// ======================================================
// SAFETY TIPS
// ======================================================

case safetyTips:
return MaterialPageRoute(
builder: (_) => const SafetyTipsScreen(),
settings: routeSettings,
);

// ======================================================
// EMERGENCY
// ======================================================

case emergency:
return MaterialPageRoute(
builder: (_) => const EmergencyScreen(),
settings: routeSettings,
);

// ======================================================
// AI CHAT
// ======================================================

case aiChat:
return MaterialPageRoute(
builder: (_) => const AiChatScreen(),
settings: routeSettings,
);

// ======================================================
// COMPLAINT FORM
// ======================================================

case complaintForm:
return MaterialPageRoute(
builder: (_) => const ComplaintFormScreen(),
settings: routeSettings,
);

// ======================================================
// COMPLAINT STATUS
// ======================================================

case complaintStatus:
final argument = routeSettings.arguments;

if (argument is Complaint) {
return MaterialPageRoute(
builder: (_) => ComplaintStatusScreen(
complaint: argument,
),
settings: routeSettings,
);
}

return _errorRoute(
'Complaint information not found.',
);

// ======================================================
// COMPLAINT DETAILS
// ======================================================

case complaintDetails:
final argument = routeSettings.arguments;

if (argument is Complaint) {
return MaterialPageRoute(
builder: (_) => ComplaintDetailScreen(
complaint: argument,
),
settings: routeSettings,
);
}

return _errorRoute(
'Complaint information not found.',
);


// ======================================================
//MY Complaints
// ======================================================
    case myComplaints:
      return MaterialPageRoute(
        builder: (_) => const MyComplaintsScreen(),
        settings: routeSettings,
      );
// ======================================================
// USER NOTIFICATIONS
// ======================================================

case notifications:
return MaterialPageRoute(
builder: (_) => const NotificationsScreen(),
settings: routeSettings,
);

// ======================================================
// PROFILE
// ======================================================

case profile:
return MaterialPageRoute(
builder: (_) => const ProfileScreen(),
settings: routeSettings,
);

// ======================================================
// ADMIN login
// ======================================================

    case adminLogin:
      return MaterialPageRoute(
        builder: (_) => const AdminLoginScreen(),
        settings: routeSettings,
      );

// ======================================================
// ADMIN Shell
// ======================================================
    case adminShell:
      return MaterialPageRoute(
        builder: (_) => const AdminShell(),
        settings: routeSettings,
      );

// ======================================================
// ADMIN DASHBOARD
// ======================================================

case adminDashboard:
return MaterialPageRoute(
builder: (_) => const AdminDashboardScreen(),
settings: routeSettings,
);

// ======================================================
// ADMIN COMPLAINTS
// ======================================================

case adminComplaints:
return MaterialPageRoute(
builder: (_) => const AdminComplaintsScreen(),
settings: routeSettings,
);

// ======================================================
// ADMIN COMPLAINT DETAILS
// ======================================================

case adminComplaintDetails:
final argument = routeSettings.arguments;

if (argument is Complaint) {
return MaterialPageRoute(
builder: (_) => AdminComplaintDetailsScreen(
complaint: argument,
),
settings: routeSettings,
);
}

return _errorRoute(
'Admin complaint information not found.',
);

// ======================================================
// ADMIN NOTIFICATIONS
// ======================================================

case adminNotifications:
return MaterialPageRoute(
builder: (_) => const AdminNotificationsScreen(),
settings: routeSettings,
);

// ======================================================
// ADMIN SETTINGS
// ======================================================

case adminSettings:
return MaterialPageRoute(
builder: (_) => const AdminSettingsScreen(),
settings: routeSettings,
);

// ======================================================
// ADMIN REPORTS
// ======================================================

    case adminReports:
      return MaterialPageRoute(
        builder: (_) => const AdminReportsScreen(),
        settings: routeSettings,
      );
// ======================================================
// UNKNOWN ROUTE
// ======================================================

default:
return _errorRoute(
'Route not found: ${routeSettings.name}',
);
}
}

// ==========================================================
// ERROR ROUTE
// ==========================================================

static Route<dynamic> _errorRoute(
String message,
) {
return MaterialPageRoute(
builder: (context) {
return Scaffold(
appBar: AppBar(
title: const Text(
'CyberSafe',
style: TextStyle(
fontWeight: FontWeight.w800,
),
),
),
body: Center(
child: Padding(
padding: const EdgeInsets.all(24),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
const Icon(
Icons.error_outline_rounded,
size: 60,
color: Colors.red,
),

const SizedBox(height: 16),

Text(
message,
textAlign: TextAlign.center,
style: const TextStyle(
fontSize: 16,
fontWeight: FontWeight.w600,
),
),

const SizedBox(height: 20),

ElevatedButton.icon(
onPressed: () {
Navigator.pushNamedAndRemoveUntil(
context,
splash,
(route) => false,
);
},
icon: const Icon(
Icons.home_rounded,
),
label: const Text(
'Go Home',
),
),
],
),
),
),
);
},
);
}
}
