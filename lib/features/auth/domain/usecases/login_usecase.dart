import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepalexplorer/features/auth/data/repositories/auth_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/app_usecase.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

/// ===== Login Usecase Parameters =====
class LoginUsecaseParams extends Equatable {
  final String email;
  final String password;

  const LoginUsecaseParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// ===== Riverpod Provider for LoginUsecase =====
final loginUsecaseProvider = Provider<LoginUsecase>((ref) {
  final repo = ref.read(authRepositoryProvider); // inject repository
  return LoginUsecase(authRepository: repo);
});

/// ===== LoginUsecase Class =====
class LoginUsecase
    implements UsecaseWithParams<AuthEntity, LoginUsecaseParams> {
  final IAuthRepository _authRepository;

  // Constructor with dependency injection
  LoginUsecase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call(LoginUsecaseParams params) {
    return _authRepository.login(params.email, params.password);
  }
}
