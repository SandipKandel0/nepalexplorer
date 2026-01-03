import 'package:dartz/dartz.dart';
import 'package:nepalexplorer/core/error/failures.dart';
import 'package:nepalexplorer/core/usecase/app_usecase.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUsecase implements UsecaseWithParams<AuthEntity, Map<String, String>> {
  final IAuthRepository _authRepository;

  LoginUsecase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call(Map<String, String> params) {
    return _authRepository.login(params['email']!, params['password']!);
  }
}
