import 'package:hive_flutter/hive_flutter.dart';
import 'package:nepalexplorer/features/auth/data/models/auth_hive_model.dart';

class HiveAuthService {
  static const String _authBoxName = 'authBox';

  // Initialize Hive and open the auth box
  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
    await Hive.openBox<AuthHiveModel>(_authBoxName);
  }

  static Box<AuthHiveModel> get _authBox => Hive.box<AuthHiveModel>(_authBoxName);

  // Register a new user, returns false if email already exists
   static Future<bool> registerUser(AuthHiveModel user) async {
    if (_authBox.values.any((u) => u.email == user.email)) {
      return false; // email already exists
    }
    await _authBox.put(user.authId, user);
    return true;
  }

  // Login user, returns true if credentials match
   static Future<AuthHiveModel?> login(String email, String password) async {
    final user = _authBox.values.cast<AuthHiveModel?>().firstWhere(
      (u) => u?.email == email && u?.password == password,
      orElse: () => null,
    );

    if (user != null) {
      await _authBox.put('currentUser', user);
    }

    return user;
  }

  // Get currently logged-in user
  static AuthHiveModel? getCurrentUser() {
    return _authBox.get('currentUser');
  }

  // Logout current user
  static Future<void> logout() async {
    await _authBox.delete('currentUser');
  }

  // Check if a user exists by email
  static bool userExists(String email) {
    return _authBox.values.any((u) => u.email == email);
  }

  // Get a user by email
  static AuthHiveModel? getUserByEmail(String email) {
    try {
      return _authBox.values.firstWhere((u) => u.email == email);
    } catch (_) {
      return null;
    }
  }

  // Get all registered users (excluding session key)
  static List<AuthHiveModel> getAllUsers() {
    return _authBox.values
        .where((u) => u.authId != 'currentUser')
        .toList();
  }

  // Delete a specific user by ID
  static Future<void> deleteUser(String authId) async {
    await _authBox.delete(authId);
  }

  // Clear all users from Hive
  static Future<void> clearAll() async {
    await _authBox.clear();
  }
  //is email exists
  bool isEmailExists (String email){
    final users = _authBox.values.where((user) =>user.email == email);
    return users.isNotEmpty;
  }
}
