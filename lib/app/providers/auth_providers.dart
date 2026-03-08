import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nepalexplorer/core/api/api_endpoints.dart';
import 'package:nepalexplorer/core/services/hive/hive_service.dart';
import 'package:nepalexplorer/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:nepalexplorer/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:nepalexplorer/features/auth/data/models/auth_hive_model.dart';
import 'package:nepalexplorer/features/auth/data/repositories/auth_repository.dart';
import 'package:nepalexplorer/features/auth/domain/repositories/auth_repository.dart';
import 'package:nepalexplorer/features/auth/domain/usecases/get_current_usecase.dart';
import 'package:nepalexplorer/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:nepalexplorer/features/auth/domain/usecases/login_usecase.dart';
import 'package:nepalexplorer/features/auth/domain/usecases/logout_usecase.dart';
import 'package:nepalexplorer/features/auth/domain/usecases/register_usecase.dart';

Future<void> initAuthStorage() async {
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(AuthHiveModelAdapter());
  }
  await Hive.openBox<AuthHiveModel>('authBox');
}

bool isAuthStorageReady() {
  return Hive.isBoxOpen('authBox');
}

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );
});

final hiveAuthServiceProvider = Provider<HiveAuthService>((ref) {
  return HiveAuthService();
});

final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hiveAuthService = ref.watch(hiveAuthServiceProvider);
  return AuthLocalDatasource(hiveAuthService: hiveAuthService);
});

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRemoteDatasource(dio: dio);
});

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final localDatasource = ref.watch(authLocalDatasourceProvider);
  final remoteDatasource = ref.watch(authRemoteDatasourceProvider);
  return AuthRepository(
    authDatasource: localDatasource,
    remoteDatasource: remoteDatasource,
  );
});

final loginUsecaseProvider = Provider<LoginUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return LoginUsecase(authRepository: authRepository);
});

final registerUsecaseProvider = Provider<RegisterUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return RegisterUsecase(authRepository: authRepository);
});

final logoutUsecaseProvider = Provider<LogoutUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return LogoutUsecase(authRepository: authRepository);
});

final getCurrentUserUsecaseProvider = Provider<GetCurrentUserUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return GetCurrentUserUsecase(authRepository: authRepository);
});

final forgotPasswordUsecaseProvider = Provider<ForgotPasswordUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return ForgotPasswordUsecase(authRepository: authRepository);
});
