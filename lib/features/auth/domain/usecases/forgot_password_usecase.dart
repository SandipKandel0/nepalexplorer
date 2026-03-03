import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:nepalexplorer/core/error/failures.dart';
import 'package:nepalexplorer/core/usecase/app_usecase.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordUsecaseParams extends Equatable {
  final String email;
  final String role;
  final String newPassword;
  final String confirmPassword;

  const ForgotPasswordUsecaseParams({
    required this.email,
    required this.role,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [email, role, newPassword, confirmPassword];
}

class ForgotPasswordUsecase implements UsecaseWithParams<bool, ForgotPasswordUsecaseParams> {
  final IAuthRepository _authRepository;

  ForgotPasswordUsecase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(ForgotPasswordUsecaseParams params) {
    return _authRepository.forgotPassword(
      email: params.email,
      role: params.role,
      newPassword: params.newPassword,
      confirmPassword: params.confirmPassword,
    );
  }
}
