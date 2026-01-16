import 'package:nepalexplorer/features/auth/data/models/auth_hive_model.dart';

class UserApiModel {
  final String? id; // nullable
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String username;
  final String? role; // nullable
  final String? password;

  UserApiModel({
    this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.username,
    this.role,
    this.password,
  });

  factory UserApiModel.fromJson(Map<String, dynamic> json) {
    return UserApiModel(
      id: json['id'] as String?,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      username: json['username'] as String,
      role: json['role'] as String?,
      password: json['password'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "fullName": fullName,
      "email": email,
      "phoneNumber": phoneNumber,
      "username": username,
      "role": role,
      "password": password,
    };
  }
}

