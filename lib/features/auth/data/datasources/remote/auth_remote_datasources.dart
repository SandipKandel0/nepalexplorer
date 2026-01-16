
import 'package:nepalexplorer/core/api/api_client.dart';
import 'package:nepalexplorer/core/api/api_endpoints.dart';
import 'package:nepalexplorer/core/services/storage/user_session_service.dart';
import 'package:nepalexplorer/features/auth/data/datasources/auth_datasource.dart';
import 'package:nepalexplorer/features/auth/data/models/user_api_model.dart';

class AuthRemoteDatasource implements IAuthRemoteDatasource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
  })  : _apiClient = apiClient,
        _userSessionService = userSessionService;

  @override
  Future<UserApiModel?> register(UserApiModel user) async {
    final response = await _apiClient.post(ApiEndpoints.register, data: user.toJson());
    if (response.data["success"] != true) return null;

    return UserApiModel.fromJson(response.data["data"]);
  }

  @override
  Future<UserApiModel?> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {"email": email, "password": password},
    );
    if (response.data["success"] != true) return null;

    final user = UserApiModel.fromJson(response.data["data"]);

    // Store session
    await _userSessionService.storeUserSession(
      userId: user.id!,
      email: user.email,
      role: user.role!,
      fullName: user.fullName,
    );

    return user;
  }

  @override
  Future<bool> logout() async {
    final response = await _apiClient.get(ApiEndpoints.logout);
    if (response.data["success"] != true) return false;

    await _userSessionService.clearUserSession();
    return true;
  }

  @override
  Future<UserApiModel?> getCurrentUser(String userId) async {
    final response = await _apiClient.get(ApiEndpoints.userById(userId));
    if (response.data["success"] != true) return null;

    return UserApiModel.fromJson(response.data["data"]);
  }

  @override
  Future<bool> isEmailExists(String email) async {
    final response = await _apiClient.get(ApiEndpoints.checkEmailExists(email));
    return response.data["exists"] == true;
  }

  @override
  Future<bool> isUsernameExists(String username) async {
    final response = await _apiClient.get(ApiEndpoints.checkUsernameExists(username));
    return response.data["exists"] == true;
  }

  @override
  Future<bool> isPhoneExists(String phoneNumber) async {
    final response = await _apiClient.get(ApiEndpoints.checkPhoneExists(phoneNumber));
    return response.data["exists"] == true;
  }
}
