import 'package:nepalexplorer/features/auth/domain/entities/auth_entity.dart';
class UserApiModel {
  final String? id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String username;
  final String? password;
  final String role; // ✅ role is required

  UserApiModel({
    this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.username,
    this.password,
    required this.role, // ✅ required
  });

  // From JSON (API response)
  factory UserApiModel.fromJson(Map<String, dynamic> json) {
    return UserApiModel(
      id: json['_id'] as String?,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      username: json['username'] as String,
      password: json['password'] as String?,
      role: json['role'] as String? ?? 'user', // default to 'user' if null
    );
  }

  // To JSON (for API request)
  Map<String, dynamic> toJson() {
    return {
      "fullName": fullName,
      "email": email,
      "phoneNumber": phoneNumber,
      "username": username,
      "password": password,
      "role": role,
    };
  }

  // Convert API model to entity
  AuthEntity toEntity() {
    return AuthEntity(
      authId: id,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      username: username,
      password: password,
      role: role, // ✅ include role
    );
  }

  // Create API model from entity
  factory UserApiModel.fromEntity(AuthEntity entity) {
    return UserApiModel(
      id: entity.authId,
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      username: entity.username,
      password: entity.password,
      role: entity.role, // ✅ include role
    );
  }

  // Convert list of API models to list of entities
  static List<AuthEntity> toEntityList(List<UserApiModel> models) {
    return models.map((e) => e.toEntity()).toList();
  }

  // Convert list of entities to list of API models
  static List<UserApiModel> fromEntityList(List<AuthEntity> entities) {
    return entities.map((e) => UserApiModel.fromEntity(e)).toList();
  }
}