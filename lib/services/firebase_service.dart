import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  FirebaseService._();

  static final FirebaseService instance = FirebaseService._();

  bool _initialized = false;
  Object? _lastError;

  bool get isInitialized => _initialized;
  Object? get lastError => _lastError;

  Future<bool> initialize() async {
    if (_initialized) return true;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      _initialized = true;
      _lastError = null;
      return true;
    } catch (e) {
      _lastError = e;
      return false;
    }
  }

  void requireInitialized() {
    if (!_initialized) {
      throw StateError(
        'Firebase is not initialized. '
            'Run flutterfire configure first.',
      );
    }
  }
}