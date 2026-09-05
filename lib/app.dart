import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'screens/settings/settings_screen.dart';
import 'services/app_settings.dart';

class CyberSafeApp extends StatefulWidget {
const CyberSafeApp({
super.key,
});

@override
State<CyberSafeApp> createState() => _CyberSafeAppState();
}

class _CyberSafeAppState extends State<CyberSafeApp> {
// ==========================================================
// APP SETTINGS
// ==========================================================

final AppSettings _appSettings = AppSettings.instance;

// ==========================================================
// INIT
// ==========================================================

@override
void initState() {
super.initState();

_appSettings.addListener(_onSettingsChanged);
}

// ==========================================================
// SETTINGS CHANGE LISTENER
// ==========================================================

void _onSettingsChanged() {
if (!mounted) return;

setState(() {});
}

// ==========================================================
// DISPOSE
// ==========================================================

@override
void dispose() {
_appSettings.removeListener(_onSettingsChanged);

super.dispose();
}

// ==========================================================
// CURRENT DARK MODE
// ==========================================================

bool get _isDarkMode {
return _appSettings.isDarkMode;
}

// ==========================================================
// CURRENT LANGUAGE
// ==========================================================

String get _language {
return _appSettings.language;
}

// ==========================================================
// CHANGE THEME
// ==========================================================

Future<void> changeTheme(bool value) async {
await _appSettings.setDarkMode(value);
}

// ==========================================================
// CHANGE LANGUAGE
// ==========================================================

Future<void> changeLanguage(String language) async {
await _appSettings.setLanguage(language);
}

// ==========================================================
// BUILD
// ==========================================================

@override
Widget build(BuildContext context) {
return MaterialApp(
debugShowCheckedModeBanner: false,

// ======================================================
// APP TITLE
// ======================================================

title: 'CyberSafe',

// ======================================================
// LIGHT THEME
// ======================================================

theme: AppTheme.lightTheme,

// ======================================================
// DARK THEME
// ======================================================

darkTheme: AppTheme.darkTheme,

// ======================================================
// GLOBAL THEME MODE
// ======================================================

themeMode: _isDarkMode
? ThemeMode.dark
    : ThemeMode.light,

// ======================================================
// INITIAL ROUTE
// ======================================================

initialRoute: AppRoutes.splash,

// ======================================================
// ROUTING
// ======================================================

onGenerateRoute: (settings) {
// ----------------------------------------------------
// SETTINGS ROUTE
// ----------------------------------------------------

if (settings.name == AppRoutes.settings) {
return MaterialPageRoute(
builder: (_) => SettingsScreen(
isDarkMode: _isDarkMode,
selectedLanguage: _language,
onThemeChanged: changeTheme,
onLanguageChanged: changeLanguage,
),
settings: settings,
);
}

// ----------------------------------------------------
// ALL OTHER ROUTES
// ----------------------------------------------------

return AppRoutes.generateRoute(settings);
},

// ======================================================
// APP BUILDER
// ======================================================

builder: (
BuildContext context,
Widget? child,
) {
final mediaQuery = MediaQuery.of(context);

return MediaQuery(
data: mediaQuery.copyWith(
textScaler: const TextScaler.linear(1.0),
),
child: child ?? const SizedBox.shrink(),
);
},
);
}
}
