// import 'package:dartz/dartz.dart';
// import 'package:nepalexplorer/core/error/failures.dart';
import 'package:nepalexplorer/features/auth/data/models/auth_hive_model.dart';
// import 'package:nepalexplorer/features/auth/domain/entities/auth_entity.dart';

abstract interface class IAuthDatasource{
  Future <bool> register(AuthHiveModel model);
  Future <AuthHiveModel?> login(String email, String password);
  Future < AuthHiveModel> getCurrentUser();
  Future <bool> logout();

  //get email exists
  Future<bool>isEmailExists(String email);
}
