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

  /// Register user
  static Future<bool> register(AuthHiveModel user) async {
    final exists = _authBox.values.any((u) => u.email == user.email);
    if (exists) return false;
    final newUser = AuthHiveModel(
      authId: DateTime.now().millisecondsSinceEpoch.toString(),
      fullName: user.fullName,
      email: user.email,
      phoneNumber: user.phoneNumber,
      username: user.username,
      password: _hashPassword(user.password ?? ''),
    );

    await _authBox.put(newUser.authId, newUser);
    return true;
  }

  /// Login user
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
