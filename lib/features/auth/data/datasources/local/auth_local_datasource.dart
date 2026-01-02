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


class AuthLocalDatasource implements IAuthDatasource{
  final HiveAuthService _hiveAuthService;
    AuthLocalDatasource({required HiveAuthService hiveAuthService})
    : _hiveAuthService = hiveAuthService;
    
  @override
  Future<AuthHiveModel> getCurrentUser() {
    // TODO: implement getCurrentUser
    throw UnimplementedError();
  }

  @override
  Future<bool> isEmailExists(String email) async{
  try {
    final exists = _hiveAuthService.isEmailExists(email);
    return Future.value(exists);
    }catch(e){
      return Future.value(false);
    }
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) async{
    try {
    final user= await HiveAuthService.login(email,password);
    return Future.value(user);
    }catch(e){
      return Future.value(null);
    }
  }

  @override
  Future<bool> logout() async{
  try {
    await HiveAuthService.logout();
    return Future.value(true);
    }catch(e){
      return Future.value(false);
    }
  }

  @override
  Future<bool> register(AuthHiveModel model) async{
    try{
      await HiveAuthService.registerUser(model);
      return Future.value(true);
    }catch(e){
      return Future.value(false);
    }
}
}