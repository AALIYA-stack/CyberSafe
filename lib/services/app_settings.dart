import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
// ==========================================================
// SINGLETON
// ==========================================================

AppSettings._();

static final AppSettings instance =
AppSettings._();

// ==========================================================
// SERVICES
// ==========================================================

final FirebaseAuth _auth =
FirebaseAuth.instance;

final FirebaseFirestore _firestore =
FirebaseFirestore.instance;

// ==========================================================
// STORAGE KEYS
// ==========================================================

static const String _darkModeKey =
'dark_mode';

static const String _languageKey =
'app_language';

// ==========================================================
// DEFAULT VALUES
// ==========================================================

bool _isDarkMode = false;

String _language = 'English';

// ==========================================================
// SUPPORTED LANGUAGES
// ==========================================================

static const List<String>
_supportedLanguages = [
'English',
'اردو',
'Roman Urdu',
];

List<String> get supportedLanguages =>
List.unmodifiable(
_supportedLanguages,
);

// ==========================================================
// GETTERS
// ==========================================================

bool get isDarkMode =>
_isDarkMode;

String get language =>
_language;

bool get isEnglish =>
_language == 'English';

bool get isUrdu =>
_language == 'اردو';

bool get isRomanUrdu =>
_language == 'Roman Urdu';

// ==========================================================
// LOCALE
// ==========================================================

Locale get locale {
switch (_language) {
case 'اردو':
return const Locale('ur');

case 'Roman Urdu':
return const Locale('ro');

case 'English':
default:
return const Locale('en');
}
}

// ==========================================================
// INITIALIZE
// ==========================================================

Future<void> initialize() async {
final preferences =
await SharedPreferences.getInstance();

// --------------------------------------------------------
// DARK MODE
// --------------------------------------------------------

_isDarkMode =
preferences.getBool(
_darkModeKey,
) ??
false;

// --------------------------------------------------------
// LOCAL LANGUAGE
// --------------------------------------------------------

final savedLanguage =
preferences.getString(
_languageKey,
);

if (savedLanguage != null &&
_supportedLanguages.contains(
savedLanguage,
)) {
_language =
savedLanguage;
} else {
_language = 'English';
}

// --------------------------------------------------------
// FIREBASE LANGUAGE
// --------------------------------------------------------

await _loadLanguageFromFirebase();

notifyListeners();
}

// ==========================================================
// DARK MODE
// ==========================================================

Future<void> setDarkMode(
bool value,
) async {
_isDarkMode = value;

final preferences =
await SharedPreferences.getInstance();

await preferences.setBool(
_darkModeKey,
value,
);

notifyListeners();
}

// ==========================================================
// LANGUAGE
// ==========================================================

Future<void> setLanguage(
String language,
) async {
final normalizedLanguage =
_normalizeLanguage(
language,
);

if (_language ==
normalizedLanguage) {
return;
}

// --------------------------------------------------------
// UPDATE MEMORY FIRST
// --------------------------------------------------------

_language =
normalizedLanguage;

notifyListeners();

// --------------------------------------------------------
// SAVE LOCALLY
// --------------------------------------------------------

final preferences =
await SharedPreferences.getInstance();

await preferences.setString(
_languageKey,
normalizedLanguage,
);

// --------------------------------------------------------
// SAVE TO FIREBASE
// --------------------------------------------------------

await _saveLanguageToFirebase(
normalizedLanguage,
);
}

// ==========================================================
// NORMALIZE LANGUAGE
// ==========================================================

String _normalizeLanguage(
String language,
) {
final value =
language.trim().toLowerCase();

switch (value) {
case 'urdu':
case 'اردو':
return 'اردو';

case 'roman urdu':
case 'romanurdu':
case 'roman_urdu':
return 'Roman Urdu';

case 'english':
default:
return 'English';
}
}

// ==========================================================
// CURRENT USER DOCUMENT
// ==========================================================

DocumentReference<
Map<String, dynamic>>?
get _currentUserDocument {
final user =
_auth.currentUser;

if (user == null) {
return null;
}

return _firestore
    .collection('users')
    .doc(user.uid);
}

// ==========================================================
// SAVE LANGUAGE TO FIREBASE
// ==========================================================

Future<void> _saveLanguageToFirebase(
String language,
) async {
final document =
_currentUserDocument;

if (document == null) {
return;
}

try {
await document.set(
{
'language': language,
},
SetOptions(
merge: true,
),
);
} on FirebaseException catch (e) {
debugPrint(
'LANGUAGE SAVE ERROR '
'[${e.code}]: ${e.message}',
);
} catch (e) {
debugPrint(
'LANGUAGE SAVE GENERAL ERROR: $e',
);
}
}

// ==========================================================
// LOAD LANGUAGE FROM FIREBASE
// ==========================================================

Future<void>
_loadLanguageFromFirebase() async {
final document =
_currentUserDocument;

if (document == null) {
return;
}

try {
final snapshot =
await document.get(
const GetOptions(
source: Source.server,
),
);

if (!snapshot.exists) {
return;
}

final data =
snapshot.data();

if (data == null) {
return;
}

final firebaseLanguage =
data['language']
    ?.toString()
    .trim();

if (firebaseLanguage ==
null ||
firebaseLanguage.isEmpty) {
return;
}

final normalizedLanguage =
_normalizeLanguage(
firebaseLanguage,
);

_language =
normalizedLanguage;

// Keep local storage synchronized.
final preferences =
await SharedPreferences
    .getInstance();

await preferences.setString(
_languageKey,
normalizedLanguage,
);
} on FirebaseException catch (e) {
debugPrint(
'LANGUAGE LOAD ERROR '
'[${e.code}]: ${e.message}',
);
} catch (e) {
debugPrint(
'LANGUAGE LOAD GENERAL ERROR: $e',
);
}
}

// ==========================================================
// REFRESH LANGUAGE FROM FIREBASE
// ==========================================================

Future<void>
refreshLanguageFromFirebase() async {
await _loadLanguageFromFirebase();

notifyListeners();
}

// ==========================================================
// LOGIN LANGUAGE SYNC
// ==========================================================

Future<void>
syncLanguageAfterLogin() async {
final user =
_auth.currentUser;

if (user == null) {
return;
}

try {
final document =
_firestore
    .collection('users')
    .doc(user.uid);

final snapshot =
await document.get();

final data =
snapshot.data();

final firebaseLanguage =
data?['language']
    ?.toString()
    .trim();

// ------------------------------------------------------
// USER ALREADY HAS LANGUAGE
// ------------------------------------------------------

if (firebaseLanguage != null &&
firebaseLanguage.isNotEmpty) {
final normalizedLanguage =
_normalizeLanguage(
firebaseLanguage,
);

_language =
normalizedLanguage;

final preferences =
await SharedPreferences
    .getInstance();

await preferences.setString(
_languageKey,
normalizedLanguage,
);
}

// ------------------------------------------------------
// FIRST LOGIN / NO LANGUAGE SAVED
// ------------------------------------------------------

else {
await document.set(
{
'language': _language,
},
SetOptions(
merge: true,
),
);
}

notifyListeners();
} on FirebaseException catch (e) {
debugPrint(
'LANGUAGE LOGIN SYNC ERROR '
'[${e.code}]: ${e.message}',
);
} catch (e) {
debugPrint(
'LANGUAGE LOGIN SYNC GENERAL ERROR: $e',
);
}
}

// ==========================================================
// RESET LANGUAGE
// ==========================================================

Future<void>
resetLanguage() async {
await setLanguage(
'English',
);
}
}
