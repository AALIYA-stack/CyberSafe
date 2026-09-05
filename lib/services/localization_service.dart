import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  english,
  urdu,
  romanUrdu,
}

class LocalizationService extends ChangeNotifier {
  LocalizationService._();

  static final LocalizationService instance =
  LocalizationService._();

  static const String _languageKey = 'app_language';

  AppLanguage _language = AppLanguage.english;

  AppLanguage get language => _language;

  // ==========================================================
  // LANGUAGE CODE
  // ==========================================================

  String get languageCode {
    switch (_language) {
      case AppLanguage.english:
        return 'en';

      case AppLanguage.urdu:
        return 'ur';

      case AppLanguage.romanUrdu:
        return 'ro';
    }
  }

  // ==========================================================
  // INITIALIZE
  // ==========================================================

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    final savedLanguage = prefs.getString(_languageKey);

    if (savedLanguage == null) {
      return;
    }

    switch (savedLanguage) {
      case 'ur':
        _language = AppLanguage.urdu;
        break;

      case 'ro':
        _language = AppLanguage.romanUrdu;
        break;

      case 'en':
      default:
        _language = AppLanguage.english;
        break;
    }
  }

  // ==========================================================
  // CHANGE LANGUAGE
  // ==========================================================

  Future<void> changeLanguage(AppLanguage language) async {
    _language = language;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _languageKey,
      _languageToString(language),
    );

    notifyListeners();
  }

  // ==========================================================
  // CONVERT ENUM TO STRING
  // ==========================================================

  String _languageToString(AppLanguage language) {
    switch (language) {
      case AppLanguage.english:
        return 'en';

      case AppLanguage.urdu:
        return 'ur';

      case AppLanguage.romanUrdu:
        return 'ro';
    }
  }

  // ==========================================================
  // COMMON TRANSLATIONS
  // ==========================================================

  String translate({
    required String english,
    String? urdu,
    String? romanUrdu,
  }) {
    switch (_language) {
      case AppLanguage.english:
        return english;

      case AppLanguage.urdu:
        return urdu ?? english;

      case AppLanguage.romanUrdu:
        return romanUrdu ?? english;
    }
  }
}