

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepalexplorer/core/services/storage/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider to expose TokenService
final tokenServiceProvider = Provider<TokenService>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return TokenService(prefs: prefs);
});

/// Service to save, read, and remove JWT tokens
class TokenService {
  static const _tokenKey = "auth_token";

  final SharedPreferences _prefs;

  TokenService({required SharedPreferences prefs}) : _prefs = prefs;

  /// Save token
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  /// Get token
  Future<String?> getToken() async {
    return _prefs.getString(_tokenKey);
  }

  /// Remove token (logout)
  Future<void> removeToken() async {
    await _prefs.remove(_tokenKey);
  }

  /// Check if token exists
  bool hasToken() {
    return _prefs.containsKey(_tokenKey);
  }
}
