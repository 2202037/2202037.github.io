class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? profileImage;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.profileImage,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String? ?? 'patient',
      phone: json['phone'] as String?,
      profileImage: json['profile_image'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        if (phone != null) 'phone': phone,
        if (profileImage != null) 'profile_image': profileImage,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      };

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    String? phone,
    String? profileImage,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  bool get isDoctor => role == 'doctor';
  bool get isPatient => role == 'patient';
  bool get isAdmin => role == 'admin';
  bool get isClinic => role == 'clinic';
  bool get isPharmacy => role == 'pharmacy';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UserModel && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'UserModel(id: $id, name: $name, role: $role)';
}
