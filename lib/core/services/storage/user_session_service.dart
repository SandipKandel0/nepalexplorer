import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final userSessionServiceProvider =
    Provider<UserSessionService>((ref) => UserSessionService());

class UserSessionService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _userIdKey = "user_id";
  static const _emailKey = "email";
  static const _roleKey = "role";
  static const _fullNameKey = "full_name";
  static const _tokenKey = "auth_token";

  // ================= STORE SESSION =================

  Future<void> storeUserSession({
    required String userId,
    required String email,
    required String role,
    required String fullName,
    String? token,
  }) async {
    await _storage.write(key: _userIdKey, value: userId);
    await _storage.write(key: _emailKey, value: email);
    await _storage.write(key: _roleKey, value: role);
    await _storage.write(key: _fullNameKey, value: fullName);
    if (token != null && token.isNotEmpty) {
      await _storage.write(key: _tokenKey, value: token);
    }
  }

  // ================= GET STORED TOKEN =================

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // ================= GET SESSION DATA =================

  Future<String?> getCurrentUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  Future<String?> getEmail() async {
    return await _storage.read(key: _emailKey);
  }

  Future<String?> getRole() async {
    return await _storage.read(key: _roleKey);
  }

  Future<String?> getFullName() async {
    return await _storage.read(key: _fullNameKey);
  }

  /// Check if session exists
  Future<bool> isLoggedIn() async {
    final userId = await _storage.read(key: _userIdKey);
    return userId != null;
  }

  // ================= CLEAR SESSION =================

  Future<void> clearUserSession() async {
    await _storage.deleteAll();
  }
}
