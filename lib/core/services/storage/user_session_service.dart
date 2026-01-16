import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final userSessionServiceProvider =
    Provider<UserSessionService>((ref) => UserSessionService());

class UserSessionService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> storeUserSession({
    required String userId,
    required String email,
    required String role,
    required String fullName,
  }) async {
    await _storage.write(key: "user_id", value: userId);
    await _storage.write(key: "email", value: email);
    await _storage.write(key: "role", value: role);
    await _storage.write(key: "full_name", value: fullName);
  }

  Future<void> clearUserSession() async {
    await _storage.deleteAll();
  }
}
