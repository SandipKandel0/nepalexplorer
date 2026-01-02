import 'package:hive_flutter/hive_flutter.dart';
import 'package:nepalexplorer/features/auth/data/models/auth_hive_model.dart';

class HiveService {
  static const String authBoxName = 'authBox';

  static Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }

    await Hive.openBox<AuthHiveModel>(authBoxName);
  }

  static Box<AuthHiveModel> get _authBox => Hive.box<AuthHiveModel>(authBoxName);

  static Future<bool> register(AuthHiveModel user) async {
    final exists = _authBox.values.any((u) => u.email == user.email);
    if (exists) return false;

    await _authBox.put(user.authId, user);
    return true;
  }

  static bool login(String email, String password) {
    final user = _authBox.values.cast<AuthHiveModel?>().firstWhere(
      (u) => u?.email == email,
      orElse: () => null,
    );

    if (user != null && user.password == password) {
      _authBox.put('currentUser', user);
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
    return _authBox.values
        .where((u) => u.authId != 'currentUser')
        .toList();
  }
}
