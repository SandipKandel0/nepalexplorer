import 'package:dio/dio.dart';
import 'package:nepalexplorer/features/auth/data/models/auth_api_model.dart';
import 'package:nepalexplorer/features/auth/data/models/auth_hive_model.dart';

class AuthRemoteDatasource {
  final Dio _dio;

  AuthRemoteDatasource({required Dio dio}) : _dio = dio;

  Future<bool> register(AuthHiveModel model) async {
    final response = await _dio.post(
      '/auth/register',
      data: {
        'fullName': model.fullName,
        'email': model.email,
        'username': model.username,
        'phoneNumber': model.phoneNumber,
        'password': model.password,
        'role': 'user',
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data['success'] == true;
    }
    return false;
  }

  Future<AuthHiveModel?> login(String email, String password) async {
    final response = await _dio.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = response.data;
    if (data is! Map<String, dynamic> || data['success'] != true) {
      return null;
    }

    final body = data['data'];
    if (body is! Map<String, dynamic>) return null;

    final rawUser = body['user'] is Map<String, dynamic>
        ? body['user'] as Map<String, dynamic>
        : body;

    final apiModel = AuthApiModel.fromJson(rawUser);
    return AuthHiveModel(
      authId: apiModel.id,
      fullName: apiModel.fullName,
      email: apiModel.email,
      phoneNumber: apiModel.phoneNumber,
      username: apiModel.username,
      password: password,
    );
  }

  Future<bool> forgotPassword({
    required String email,
    required String role,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await _dio.post(
      '/auth/forgot-password',
      data: {
        'email': email,
        'role': role,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data['success'] == true;
    }
    return false;
  }
}
