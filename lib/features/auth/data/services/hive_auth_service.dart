import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nepalexplorer/features/auth/data/models/auth_hive_model.dart';

class HiveAuthService {
  static const String authBoxName = 'authBox';

  Box<AuthHiveModel> get _authBox => Hive.box<AuthHiveModel>(authBoxName);

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<bool> registerUser(AuthHiveModel user) async {
    if (_authBox.values.any((u) => u.email == user.email)) {
      return false;
    }

    final hashedUser = AuthHiveModel(
      authId: user.authId,
      fullName: user.fullName,
      email: user.email,
      phoneNumber: user.phoneNumber,
      username: user.username,
      password: user.password != null ? _hashPassword(user.password!) : null,
    );

    await _authBox.put(hashedUser.authId, hashedUser);
    return true;
  }

  Future<AuthHiveModel?> login(String email, String password) async {
    final hashedPassword = _hashPassword(password);

    final user = _authBox.values.cast<AuthHiveModel?>().firstWhere(
      (u) => u?.email == email && u?.password == hashedPassword,
      orElse: () => null,
    );

    if (user != null) {
      await _authBox.put('currentUser', user);
    }

    return user;
  }

  Future<void> logout() async => _authBox.delete('currentUser');

  AuthHiveModel? getCurrentUser() => _authBox.get('currentUser');

  bool isEmailExists(String email) {
    return _authBox.values.any((u) => u.email == email);
  }
}