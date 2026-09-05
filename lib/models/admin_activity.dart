class AdminActivity {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String type;

  const AdminActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.type,
  });

  AdminActivity copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? type,
  }) {
    return AdminActivity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      type: type ?? this.type,
    );
  }
}