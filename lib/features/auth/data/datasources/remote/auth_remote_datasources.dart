// lib/features/auth/data/datasources/auth_remote_datasource.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepalexplorer/core/api/api_client.dart';
import 'package:nepalexplorer/core/services/storage/user_session_service.dart';
import 'package:nepalexplorer/core/api/api_endpoints.dart';
import 'package:nepalexplorer/features/auth/data/datasources/auth_datasource.dart';
import 'package:nepalexplorer/features/auth/data/models/auth_api_model.dart';

/// Provider for AuthRemoteDatasource
final authRemoteDatasourceProvider = Provider<IAuthRemoteDatasource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final userSessionService = ref.read(userSessionServiceProvider);

  return AuthRemoteDatasource(
    apiClient: apiClient,
    userSessionService: userSessionService,
  );
});

class AuthRemoteDatasource implements IAuthRemoteDatasource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
  })  : _apiClient = apiClient,
        _userSessionService = userSessionService;

  // ================= REGISTER =================
  @override
  Future<UserApiModel> register(UserApiModel user) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: user.toJson(),
    );

    if (response.data['success'] == true && response.data['data'] != null) {
      final userData = UserApiModel.fromJson(response.data['data']);
      final token = response.data['token']; // Extract token from response

      // Save user session and token after registration
      if (userData.id != null) {
        await _userSessionService.storeUserSession(
          userId: userData.id!,
          email: userData.email,
          role: userData.role,
          fullName: userData.fullName,
          token: token,
        );
      }

      return userData;
    } else {
      throw Exception(response.data['message'] ?? "Registration failed");
    }
  }

  // ================= LOGIN =================
  @override
  Future<UserApiModel> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {
        "email": email.trim(),
        "password": password,
      },
    );

    if (response.data["success"] == true && response.data["data"] != null) {
      final user = UserApiModel.fromJson(response.data["data"]);
      final token = response.data["token"]; // Extract token from response

      if (user.id == null) {
        throw Exception("User ID missing in response");
      }

      await _userSessionService.storeUserSession(
        userId: user.id!,
        email: user.email,
        role: user.role,
        fullName: user.fullName,
        token: token, // Save token
      );

      return user;
    } else {
      throw Exception(response.data["message"] ?? "Login failed");
    }
  }

  // ================= LOGOUT =================
  @override
  Future<bool> logout() async {
    final response = await _apiClient.get(ApiEndpoints.logout);

    if (response.data["success"] == true) {
      await _userSessionService.clearUserSession();
      return true;
    } else {
      throw Exception(response.data["message"] ?? "Logout failed");
    }
  }

  // ================= GET CURRENT USER =================
  @override
  Future<UserApiModel> getCurrentUser(String userId) async {
    final response = await _apiClient.get(ApiEndpoints.userById(userId));

    if (response.data["success"] == true && response.data["data"] != null) {
      return UserApiModel.fromJson(response.data["data"]);
    } else {
      throw Exception("Failed to fetch user");
    }
  }

  // ================= CHECKS =================
  @override
  Future<bool> isEmailExists(String email) async {
    final response = await _apiClient.get(ApiEndpoints.checkEmailExists(email));
    return response.data["exists"] == true;
  }

  @override
  Future<bool> isUsernameExists(String username) async {
    final response =
        await _apiClient.get(ApiEndpoints.checkUsernameExists(username));
    return response.data["exists"] == true;
  }

  @override
  Future<bool> isPhoneExists(String phoneNumber) async {
    final response =
        await _apiClient.get(ApiEndpoints.checkPhoneExists(phoneNumber));
    return response.data["exists"] == true;
  }
}
