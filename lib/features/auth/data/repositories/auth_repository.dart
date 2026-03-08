import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepalexplorer/core/api/api_endpoints.dart';
import 'package:nepalexplorer/core/error/failures.dart';
import 'package:nepalexplorer/features/auth/data/datasources/auth_datasource.dart';
import 'package:nepalexplorer/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:nepalexplorer/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:nepalexplorer/features/auth/data/models/auth_hive_model.dart';
import 'package:nepalexplorer/features/auth/domain/entities/auth_entity.dart';
import 'package:nepalexplorer/features/auth/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authDatasource = ref.watch(authLocalDatasourceProvider);
  final remoteDatasource = ref.watch(authRemoteDatasourceProvider);
  return AuthRepository(
    authDatasource: authDatasource,
    remoteDatasource: remoteDatasource,
  );
});

class AuthRepository implements IAuthRepository {
  final IAuthDatasource _authDatasource;
  final AuthRemoteDatasource? _remoteDatasource;

  AuthRepository({
    required IAuthDatasource authDatasource,
    AuthRemoteDatasource? remoteDatasource,
  })  : _authDatasource = authDatasource,
        _remoteDatasource = remoteDatasource;

  @override
  Future<Either<Failure, AuthEntity>> login(String email, String password) async {
    try {
      final user = await _authDatasource.login(email, password);
      if (user != null) return Right(user.toEntity());
      return Left(LocalDatabaseFailure(message: 'Invalid email or password'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await _authDatasource.logout();
      if (result) return Right(true);
      return Left(LocalDatabaseFailure(message: 'Failed to logout user'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    try {
      final model = AuthHiveModel.fromEntity(entity);
      final result = await _authDatasource.register(model);
      if (result) return Right(true);
      return Left(LocalDatabaseFailure(message: 'Failed to register user'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final user = await _authDatasource.getCurrentUser();
      if (user != null) return Right(user.toEntity());
      return Left(LocalDatabaseFailure(message: 'No current user logged in'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> forgotPassword({
    required String email,
    required String role,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final remoteDatasource = _remoteDatasource ??
          AuthRemoteDatasource(
            dio: Dio(
              BaseOptions(
                baseUrl: ApiEndpoints.baseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                headers: {'Content-Type': 'application/json'},
              ),
            ),
          );

      final success = await remoteDatasource.forgotPassword(
        email: email,
        role: role,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (success) return const Right(true);
      return Left(LocalDatabaseFailure(message: 'Failed to reset password'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}
