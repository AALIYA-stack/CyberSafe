class AdminProfile {
final String name;
final String email;
final String phone;
final String designation;
final String bio;

/// Can contain:
/// - local device image path before upload
/// - Firebase Storage download URL after upload
final String profileImagePath;

const AdminProfile({
required this.name,
required this.email,
required this.phone,
required this.designation,
required this.bio,
required this.profileImagePath,
});

// ==========================================================
// COPY WITH
// ==========================================================

AdminProfile copyWith({
String? name,
String? email,
String? phone,
String? designation,
String? bio,
String? profileImagePath,
}) {
return AdminProfile(
name: name ?? this.name,
email: email ?? this.email,
phone: phone ?? this.phone,
designation:
designation ?? this.designation,
bio: bio ?? this.bio,
profileImagePath:
profileImagePath ??
this.profileImagePath,
);
}

// ==========================================================
// TO MAP
// ==========================================================

Map<String, dynamic> toMap() {
return {
'name': name,
'email': email,
'phone': phone,
'designation': designation,
'bio': bio,

// Firebase Storage URL
'profileImageUrl':
profileImagePath,
};
}

// ==========================================================
// FROM MAP
// ==========================================================

factory AdminProfile.fromMap(
Map<String, dynamic> map,
) {
return AdminProfile(
name:
map['name']?.toString() ?? '',
email:
map['email']?.toString() ?? '',
phone:
map['phone']?.toString() ?? '',
designation:
map['designation']?.toString() ?? '',
bio:
map['bio']?.toString() ?? '',

// New field first.
// Old field supported for compatibility.
profileImagePath:
map['profileImageUrl']
    ?.toString() ??
map['profileImagePath']
    ?.toString() ??
'',
);
}

// ==========================================================
// DEFAULT ADMIN PROFILE
// ==========================================================

factory AdminProfile.defaultProfile() {
return const AdminProfile(
name: 'CyberSafe Admin',
email: 'admin@cybersafe.com',
phone: '',
designation:
'System Administrator',
bio:
'CyberSafe Complaint Management Administrator',
profileImagePath: '',
);
}
}
