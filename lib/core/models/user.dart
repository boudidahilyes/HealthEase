import 'package:intl/intl.dart';

enum UserRole { admin, patient, doctor }

extension UserRoleExtension on UserRole {
  String get name {
    switch (this) {
      case UserRole.admin:
        return 'ADMIN';
      case UserRole.patient:
        return 'PATIENT';
      case UserRole.doctor:
        return 'DOCTOR';
    }
  }

  static UserRole fromString(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return UserRole.admin;
      case 'DOCTOR':
        return UserRole.doctor;
      case 'PATIENT':
      default:
        return UserRole.patient;
    }
  }
}

class User {
  final int? id;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String? userImage;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserRole role;

  User({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    this.userImage,
    this.active = true,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.role = UserRole.patient,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      firstName: map['first_name'] ?? '',
      lastName: map['last_name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      userImage: map['user_image'],
      active: (map['active'] == 1 || map['active'] == true),
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] ?? '') ?? DateTime.now(),
      role: UserRoleExtension.fromString(map['role'] ?? 'PATIENT'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
      'user_image': userImage,
      'active': active ? 1 : 0,
      'created_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt),
      'updated_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(updatedAt),
      'role': role.name,
    };
  }

  @override
  String toString() {
    return 'User(id: $id, name: $firstName $lastName, email: $email, role: ${role.name})';
  }
}
