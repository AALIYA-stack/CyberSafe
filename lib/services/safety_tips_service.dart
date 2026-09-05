import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/safety_tips.dart';

class SafetyTipsService {
  SafetyTipsService._();

  static final SafetyTipsService instance =
  SafetyTipsService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>>
  get _tipsCollection =>
      _firestore.collection('safety_tips');

  /// Get all safety tips as a real-time Firebase stream.
  Stream<List<SafetyTip>> watchSafetyTips() {
    return _tipsCollection.snapshots().map(
          (snapshot) {
        final tips = snapshot.docs
            .map(
              (document) =>
              SafetyTip.fromFirestore(document),
        )
            .where(
              (tip) =>
          tip.title.trim().isNotEmpty &&
              tip.description.trim().isNotEmpty,
        )
            .toList();


        return tips;
      },
    );

  }

  /// Get all safety tips once.
  Future<List<SafetyTip>> getSafetyTips() async {
    final snapshot = await _tipsCollection.get();


    return snapshot.docs
        .map(
    (document) =>
    SafetyTip.fromFirestore(document),
    )
        .where(
    (tip) =>
    tip.title.trim().isNotEmpty &&
    tip.description.trim().isNotEmpty,
    )
        .toList();


  }

  /// Add a new safety tip.
  ///
  /// This method should only be called from an admin-controlled
  /// part of the application because Firestore rules protect
  /// the collection from normal users/guests.
  Future<String> addSafetyTip(
      SafetyTip tip,
      ) async {
    final document =
    await _tipsCollection.add(
      tip.toFirestore(),
    );
    return document.id;


  }

  /// Update an existing safety tip.
  Future<void> updateSafetyTip(
      String tipId,
      SafetyTip tip,
      ) async {
    if (tipId.trim().isEmpty) {
      throw ArgumentError(
        'Safety tip ID cannot be empty.',
      );
    }
    await _tipsCollection
        .doc(tipId)
        .update(
    tip.toFirestore(),
    );


  }

  /// Delete an existing safety tip.
  Future<void> deleteSafetyTip(
      String tipId,
      ) async {
    if (tipId.trim().isEmpty) {
      throw ArgumentError(
        'Safety tip ID cannot be empty.',
      );
    }
    await _tipsCollection
        .doc(tipId)
        .delete();

  }

  /// Get one safety tip by its document ID.
  Future<SafetyTip?> getSafetyTip(
      String tipId,
      ) async {
    if (tipId.trim().isEmpty) {
      return null;
    }
    final document =
    await _tipsCollection
        .doc(tipId)
        .get();

    if (!document.exists) {
    return null;
    }

    return SafetyTip.fromFirestore(
    document,
    );


  }
}
