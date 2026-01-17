import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:nepalexplorer/features/auth/data/models/auth_hive_model.dart';

class HiveAuthService {
  static const String _authBoxName = 'authBox';
  late Box<AuthHiveModel> _authBox;

  // Initialize box 
  Future<void> init() async {
    _authBox = await Hive.openBox<AuthHiveModel>(_authBoxName);
  }

  // Register a user
  Future<bool> registerUser(AuthHiveModel user) async {
    if (_authBox.values.any((u) => u.email == user.email)) {
      return false;
    }
    await _authBox.put(user.authId, user);
    return true;
  }

  // Login user
  Future<AuthHiveModel?> login(String email, String password) async {
    final user = _authBox.values.cast<AuthHiveModel?>().firstWhere(
      (u) => u?.email == email && u?.password == password,
      orElse: () => null,
    );

    if (user != null) {
      await _authBox.put('currentUser', user);
    }

    return user;
  }

  // Logout user
  Future<void> logout() async => await _authBox.delete('currentUser');

  // Get currently logged-in user
  AuthHiveModel? getCurrentUser() => _authBox.get('currentUser');

  // Check if email exists
  bool isEmailExists(String email) {
    return _authBox.values.any((u) => u.email == email);
  }

  FutureOr<bool>? isPhoneExists(String phoneNumber) {
    return null;
  }

  FutureOr<bool>? isUsernameExists(String username) {
    return null;
  }
}
