class AdminModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;

  const AdminModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
  });

  AdminModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
  }) {
    return AdminModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
    };
  }

  factory AdminModel.fromMap(
      Map<String, dynamic> map,
      ) {
    return AdminModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      role: map['role']?.toString() ?? 'Administrator',
    );
  }
}