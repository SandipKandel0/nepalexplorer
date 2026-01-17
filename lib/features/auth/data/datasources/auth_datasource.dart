// import 'package:dartz/dartz.dart';
// import 'package:nepalexplorer/core/error/failures.dart';
import 'package:nepalexplorer/features/auth/data/models/auth_hive_model.dart';
import 'package:nepalexplorer/features/auth/data/models/auth_api_model.dart';
// import 'package:nepalexplorer/features/auth/domain/entities/auth_entity.dart';

abstract interface class IAuthLocalDatasource{
  Future <bool> register(AuthHiveModel model);
  Future <AuthHiveModel?> login(String email, String password);
  Future < AuthHiveModel?> getCurrentUser();
  Future <bool> logout();

  Future<bool>isEmailExists(String email);
  Future<bool> isUsernameExists(String username);
  Future<bool> isPhoneExists(String phoneNumber);
}
abstract interface class IAuthRemoteDatasource{ 
  Future<UserApiModel?> register(UserApiModel user);
  Future<UserApiModel?> login(String email, String password);
  Future<bool> logout();
  Future<UserApiModel?> getCurrentUser(String userId);

  Future<bool> isEmailExists(String email);
  Future<bool> isUsernameExists(String username);
  Future<bool> isPhoneExists(String phoneNumber);
} 