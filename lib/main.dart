import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app.dart';
import 'data/quiz_store.dart';
import 'firebase_options.dart';
import 'localization/app_language.dart';
import 'services/app_settings.dart';

Future<void> main() async {
WidgetsFlutterBinding.ensureInitialized();

// ==========================================================
// FIREBASE
// ==========================================================

await Firebase.initializeApp(
options: DefaultFirebaseOptions.currentPlatform,
);

// ==========================================================
// QUIZ STORE
// ==========================================================

await QuizStore.initialize();

// ==========================================================
// APP SETTINGS
// ==========================================================

await AppSettings.instance.initialize();

// ==========================================================
// LANGUAGE
// ==========================================================

await AppLanguage.instance.initialize();

// ==========================================================
// RUN APP
// ==========================================================

runApp(
const CyberSafeApp(),
);
}

