import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepalexplorer/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:nepalexplorer/features/auth/domain/usecases/login_usecase.dart';
import 'package:nepalexplorer/features/auth/domain/usecases/logout_usecase.dart';
import 'package:nepalexplorer/features/auth/domain/usecases/register_usecase.dart';
import 'package:nepalexplorer/features/auth/presentation/state/auth_state.dart';


final authViewModelProvider =
    NotifierProvider<AuthViewModel, AuthState>(() => AuthViewModel());

class AuthViewModel extends Notifier<AuthState>{

  late final RegisterUsecase  _registerUsecase;
  late final LoginUsecase _loginUsecase;
  late final LogoutUsecase _logoutUsecase;
  late final ForgotPasswordUsecase _forgotPasswordUsecase;

  @override
AuthState build() {
  _registerUsecase = ref.read(registerUsecaseProvider);
  _loginUsecase = ref.read(loginUsecaseProvider);
  _logoutUsecase = ref.read(logoutUsecaseProvider);
  _forgotPasswordUsecase = ref.read(forgotPasswordUsecaseProvider);
  return const AuthState(); // uses default values
}

Future<void> register({
  required String fullName,
  required String email,
  String? phoneNumber,
  required String username,
  required String password,
}) async {
  state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

  final params = RegisterUsecaseParams(
    fullName: fullName,
    email: email,
    phoneNumber: phoneNumber,
    username: username,
    password: password,
  );

  final result = await _registerUsecase(params);

  result.fold(
    (failure) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      );
    },
    (isRegistered) {
      state = state.copyWith(
        status: isRegistered ? AuthStatus.register : AuthStatus.error,
        errorMessage: isRegistered ? null : 'Registration failed',
      );
    },
  );
}

  //login
  Future<void> login({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading,);

    final params = LoginUsecaseParams(username: username, password: password);
    final result = await _loginUsecase(params);
    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (authEntity) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          authEntity: authEntity,
        );
      },
    );
  }

  Future<bool> forgotPassword({
    required String email,
    required String role,
    required String newPassword,
    required String confirmPassword,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final params = ForgotPasswordUsecaseParams(
      email: email,
      role: role,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    final result = await _forgotPasswordUsecase(params);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (success) {
        state = state.copyWith(
          status: success ? AuthStatus.unauthenticated : AuthStatus.error,
          errorMessage: success ? null : 'Failed to reset password',
        );
        return success;
      },
    );
  }

  Future<bool> logout() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final result = await _logoutUsecase();
    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (success) {
        state = state.copyWith(
          status: success ? AuthStatus.unauthenticated : AuthStatus.error,
          authEntity: null,
          errorMessage: success ? null : 'Logout failed',
        );
        return success;
      },
    );
  }
}
