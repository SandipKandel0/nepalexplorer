import 'package:hive_flutter/hive_flutter.dart';
import 'package:crypto/crypto.dart';
import 'package:nepalexplorer/features/auth/data/models/auth_hive_model.dart';
import 'dart:convert';

class HiveAuthStorage {
  static const String _authBoxName = 'authBox';

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
    await Hive.openBox<AuthHiveModel>(_authBoxName);
  }

  static Box<AuthHiveModel> get _authBox => Hive.box<AuthHiveModel>(_authBoxName);

  static String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  static Future<bool> register(AuthHiveModel user) async {
    final exists = _authBox.values.any((u) => u.email == user.email);
    if (exists) return false;

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

  static Future<bool> login(String email, String password) async {
    final hashedPassword = _hashPassword(password);

    final user = _authBox.values.cast<AuthHiveModel?>().firstWhere(
      (u) => u?.email == email && u?.password == hashedPassword,
      orElse: () => null,
    );

    if (user != null) {
      await _authBox.put('currentUser', AuthHiveModel(
        authId: user.authId,
        fullName: user.fullName,
        email: user.email,
        phoneNumber: user.phoneNumber,
        username: user.username,
        password: user.password,
      ));
      return true;
    }
    return false;
  }
  static AuthHiveModel? getCurrentUser() {
    return _authBox.get('currentUser');
  }

  static Future<void> logout() async {
    await _authBox.delete('currentUser');
  }

  static List<AuthHiveModel> getAllUsers() {
    return _authBox.values.where((u) => u.authId != 'currentUser').toList();
  }

  static Future<void> clearAll() async {
    await _authBox.clear();
  }
}
