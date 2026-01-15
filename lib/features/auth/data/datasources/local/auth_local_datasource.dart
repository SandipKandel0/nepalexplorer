import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepalexplorer/core/services/hive/hive_service.dart';
import 'package:nepalexplorer/features/auth/data/datasources/auth_datasource.dart';
import 'package:nepalexplorer/features/auth/data/models/auth_hive_model.dart';

final hiveAuthServiceProvider = Provider<HiveAuthService>((ref) {
  return HiveAuthService();
});

final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hiveAuthService = ref.watch(hiveAuthServiceProvider);
  return AuthLocalDatasource(hiveAuthService: hiveAuthService);
});

class AuthLocalDatasource implements IAuthDatasource {
  final HiveAuthService _hiveAuthService;

  AuthLocalDatasource({required HiveAuthService hiveAuthService})
      : _hiveAuthService = hiveAuthService;

  /// LOGIN
  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    try {
      return await _hiveAuthService.login(email, password);
    } catch (_) {
      return null;
    }
  }

  /// REGISTER
  @override
  Future<bool> register(AuthHiveModel model) async {
    try {
      return await _hiveAuthService.registerUser(model);
    } catch (_) {
      return false;
    }
  }


@override
Future<bool> isEmailExists(String email) async {
  try {
    return Future.value(_hiveAuthService.isEmailExists(email));
  } catch (_) {
    return false;
  }
}

  /// LOGOUT
  @override
  Future<bool> logout() async {
    try {
      await _hiveAuthService.logout();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// CURRENT USER
@override
Future<AuthHiveModel?> getCurrentUser() async {
  try {
    return Future.value(_hiveAuthService.getCurrentUser());
  } catch (_) {
    return null;
  }
}
}
