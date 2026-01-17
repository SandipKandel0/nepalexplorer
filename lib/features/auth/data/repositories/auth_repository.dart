import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepalexplorer/core/error/failures.dart';
import 'package:nepalexplorer/core/services/connectivity/network_info.dart';

import 'package:nepalexplorer/features/auth/data/datasources/auth_datasource.dart';
import 'package:nepalexplorer/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:nepalexplorer/features/auth/data/datasources/remote/auth_remote_datasources.dart';

import 'package:nepalexplorer/features/auth/data/models/auth_hive_model.dart';
import 'package:nepalexplorer/features/auth/domain/entities/auth_entity.dart';
import 'package:nepalexplorer/features/auth/domain/repositories/auth_repository.dart';


/// ✔ Riverpod Provider for Repository
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authLocal = ref.watch(authLocalDatasourceProvider);
  final authRemote = ref.watch(authRemoteDatasourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);

  return AuthRepository(
    authLocalDatasource: authLocal,
    authRemoteDatasource: authRemote,
    networkInfo: networkInfo,
  );
});


/// ✔ Repository Implementation
class AuthRepository implements IAuthRepository {
  final IAuthLocalDatasource _authLocalDatasource;
  final IAuthRemoteDatasource _authRemoteDatasource;
  final INetworkInfo _networkInfo;

  AuthRepository({
    required IAuthLocalDatasource authLocalDatasource,
    required IAuthRemoteDatasource authRemoteDatasource,
    required INetworkInfo networkInfo,
  })  : _authLocalDatasource = authLocalDatasource,
        _authRemoteDatasource = authRemoteDatasource,
        _networkInfo = networkInfo;


  /// ✔ LOGIN
  @override
  Future<Either<Failure, AuthEntity>> login(String email, String password) async {
    try {
      // LOCAL LOGIN
      final user = await _authLocalDatasource.login(email, password);
      if (user != null) return Right(user.toEntity());

      return Left(LocalDatabaseFailure(message: 'Invalid email or password'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }


  /// ✔ LOGOUT
  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await _authLocalDatasource.logout();
      if (result) return Right(true);

      return Left(LocalDatabaseFailure(message: 'Failed to logout user'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }


  /// ✔ REGISTER
  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    try {
      final model = AuthHiveModel.fromEntity(entity);

      final result = await _authLocalDatasource.register(model);
      if (result) return Right(true);

      return Left(LocalDatabaseFailure(message: 'Failed to register user'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }


  /// ✔ GET CURRENT USER
  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final user = await _authLocalDatasource.getCurrentUser();
      if (user != null) return Right(user.toEntity());

      return Left(LocalDatabaseFailure(message: 'No current user logged in'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}
