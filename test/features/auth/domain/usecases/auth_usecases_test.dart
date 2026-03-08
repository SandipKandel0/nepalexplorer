import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepalexplorer/core/error/failures.dart';
import 'package:nepalexplorer/features/auth/domain/entities/auth_entity.dart';
import 'package:nepalexplorer/features/auth/domain/repositories/auth_repository.dart';
import 'package:nepalexplorer/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:nepalexplorer/features/auth/domain/usecases/get_current_usecase.dart';
import 'package:nepalexplorer/features/auth/domain/usecases/login_usecase.dart';
import 'package:nepalexplorer/features/auth/domain/usecases/logout_usecase.dart';
import 'package:nepalexplorer/features/auth/domain/usecases/register_usecase.dart';

class FakeAuthRepository implements IAuthRepository {
  Either<Failure, bool> registerResult = const Right(true);
  Either<Failure, AuthEntity> loginResult = const Right(
    AuthEntity(
      authId: '1',
      fullName: 'Test User',
      email: 'test@example.com',
      username: 'tester',
      password: 'secret',
    ),
  );
  Either<Failure, AuthEntity> currentUserResult = const Right(
    AuthEntity(
      authId: '1',
      fullName: 'Current User',
      email: 'current@example.com',
      username: 'current_user',
      password: 'secret',
    ),
  );
  Either<Failure, bool> logoutResult = const Right(true);
  Either<Failure, bool> forgotPasswordResult = const Right(true);

  AuthEntity? lastRegisteredEntity;
  String? lastLoginEmail;
  String? lastLoginPassword;
  String? lastForgotEmail;
  String? lastForgotRole;
  String? lastForgotNewPassword;
  String? lastForgotConfirmPassword;

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    lastRegisteredEntity = entity;
    return registerResult;
  }

  @override
  Future<Either<Failure, AuthEntity>> login(String email, String password) async {
    lastLoginEmail = email;
    lastLoginPassword = password;
    return loginResult;
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    return currentUserResult;
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    return logoutResult;
  }

  @override
  Future<Either<Failure, bool>> forgotPassword({
    required String email,
    required String role,
    required String newPassword,
    required String confirmPassword,
  }) async {
    lastForgotEmail = email;
    lastForgotRole = role;
    lastForgotNewPassword = newPassword;
    lastForgotConfirmPassword = confirmPassword;
    return forgotPasswordResult;
  }
}

void main() {
  group('Auth usecases', () {
    late FakeAuthRepository repository;

    setUp(() {
      repository = FakeAuthRepository();
    });

    test('RegisterUsecase maps params to AuthEntity and succeeds', () async {
      final usecase = RegisterUsecase(authRepository: repository);
      const params = RegisterUsecaseParams(
        fullName: 'Jane Doe',
        email: 'jane@example.com',
        phoneNumber: '9800000000',
        username: 'janed',
        password: 'secret',
      );

      final result = await usecase(params);

      expect(result, const Right<Failure, bool>(true));
      expect(repository.lastRegisteredEntity, isNotNull);
      expect(repository.lastRegisteredEntity!.fullName, 'Jane Doe');
      expect(repository.lastRegisteredEntity!.email, 'jane@example.com');
      expect(repository.lastRegisteredEntity!.phoneNumber, '9800000000');
      expect(repository.lastRegisteredEntity!.username, 'janed');
      expect(repository.lastRegisteredEntity!.password, 'secret');
    });

    test('RegisterUsecase returns failure from repository', () async {
      repository.registerResult = const Left(LocalDatabaseFailure(message: 'register failed'));
      final usecase = RegisterUsecase(authRepository: repository);

      final result = await usecase(
        const RegisterUsecaseParams(
          fullName: 'Jane',
          email: 'jane@example.com',
          phoneNumber: null,
          username: 'jane',
          password: '1234',
        ),
      );

      expect(result.isLeft(), isTrue);
    });

    test('LoginUsecase passes credentials to repository', () async {
      final usecase = LoginUsecase(authRepository: repository);
      const params = LoginUsecaseParams(username: 'mail@test.com', password: 'p@ss');

      final result = await usecase(params);

      expect(result.isRight(), isTrue);
      expect(repository.lastLoginEmail, 'mail@test.com');
      expect(repository.lastLoginPassword, 'p@ss');
    });

    test('LogoutUsecase delegates and returns repository value', () async {
      final usecase = LogoutUsecase(authRepository: repository);

      final result = await usecase();

      expect(result, const Right<Failure, bool>(true));
    });

    test('GetCurrentUserUsecase returns current user', () async {
      final usecase = GetCurrentUserUsecase(authRepository: repository);

      final result = await usecase();

      expect(result.isRight(), isTrue);
      expect(result.getOrElse(
        () => const AuthEntity(fullName: '', email: '', username: ''),
      ).email, 'current@example.com');
    });

    test('ForgotPasswordUsecase forwards all parameters', () async {
      final usecase = ForgotPasswordUsecase(authRepository: repository);
      const params = ForgotPasswordUsecaseParams(
        email: 'forgot@example.com',
        role: 'user',
        newPassword: 'newpass',
        confirmPassword: 'newpass',
      );

      final result = await usecase(params);

      expect(result, const Right<Failure, bool>(true));
      expect(repository.lastForgotEmail, 'forgot@example.com');
      expect(repository.lastForgotRole, 'user');
      expect(repository.lastForgotNewPassword, 'newpass');
      expect(repository.lastForgotConfirmPassword, 'newpass');
    });
  });
}
