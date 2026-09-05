import 'package:cloud_firestore/cloud_firestore.dart';

class AboutService {
  AboutService._();

  static final AboutService instance = AboutService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _aboutDocument =>
      _firestore.collection('app_content').doc('about');

  /// Loads About screen content from Firebase.
  Future<Map<String, dynamic>> getAboutContent() async {
    final snapshot = await _aboutDocument.get();

    if (!snapshot.exists) {
    return {};
    }

    return snapshot.data() ?? {};


  }

  /// Real-time About screen content.
  Stream<Map<String, dynamic>> watchAboutContent() {
    return _aboutDocument.snapshots().map(
          (snapshot) => snapshot.data() ?? {},
    );
  }
}
