import 'package:cloud_firestore/cloud_firestore.dart';

/// A single safety tip shown on the Safety Tips screen.
class SafetyTip {
  const SafetyTip({
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
  });

  final String title;

  /// Detailed explanation of the safety tip.
  final String description;

  /// One of:
  /// Account Security,
  /// Social Media Safety,
  /// Financial Safety,
  /// Device Security,
  /// Privacy.
  final String category;

  /// Material icon name.
  final String icon;

  /// Creates a SafetyTip from a Firebase Firestore document.
  factory SafetyTip.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    final data = document.data() ?? {};
    return SafetyTip(
    title: (data['title'] ?? '').toString(),
    description: (data['description'] ?? '').toString(),
    category: (data['category'] ?? '').toString(),
    icon: (data['icon'] ?? 'security_outlined').toString(),
    );
  }

  /// Converts the SafetyTip into Firestore data.
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'icon': icon,
    };
  }
}
