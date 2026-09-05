import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguageType {
english,
urdu,
romanUrdu,
}

class AppLanguage extends ChangeNotifier {
AppLanguage._();

static final AppLanguage instance = AppLanguage._();

static const String _languageKey = 'app_language';

AppLanguageType _language = AppLanguageType.english;

AppLanguageType get language => _language;

Locale get locale {
switch (_language) {
case AppLanguageType.english:
return const Locale('en');

case AppLanguageType.urdu:
return const Locale('ur');

case AppLanguageType.romanUrdu:
return const Locale('ro');
}
}

String get languageName {
switch (_language) {
case AppLanguageType.english:
return 'English';

case AppLanguageType.urdu:
return 'اردو';

case AppLanguageType.romanUrdu:
return 'Roman Urdu';
}
}

Future<void> initialize() async {
final preferences =
await SharedPreferences.getInstance();

final savedLanguage =
preferences.getString(_languageKey);

switch (savedLanguage) {
case 'urdu':
_language = AppLanguageType.urdu;
break;

case 'romanUrdu':
_language = AppLanguageType.romanUrdu;
break;

case 'english':
default:
_language = AppLanguageType.english;
break;
}

notifyListeners();
}

Future<void> changeLanguage(
AppLanguageType language,
) async {
if (_language == language) {
return;
}

_language = language;

final preferences =
await SharedPreferences.getInstance();

await preferences.setString(
_languageKey,
_languageToString(language),
);

notifyListeners();
}

String _languageToString(
AppLanguageType language,
) {
switch (language) {
case AppLanguageType.english:
return 'english';

case AppLanguageType.urdu:
return 'urdu';

case AppLanguageType.romanUrdu:
return 'romanUrdu';
}
}

bool get isEnglish =>
_language == AppLanguageType.english;

bool get isUrdu =>
_language == AppLanguageType.urdu;

bool get isRomanUrdu =>
_language == AppLanguageType.romanUrdu;
}

