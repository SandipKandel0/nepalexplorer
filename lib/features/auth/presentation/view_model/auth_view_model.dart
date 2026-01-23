import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepalexplorer/features/auth/domain/usecases/login_usecase.dart';
import 'package:nepalexplorer/features/auth/domain/usecases/register_usecase.dart';
import 'package:nepalexplorer/features/auth/presentation/state/auth_state.dart';


final authViewModelProvider =
    NotifierProvider<AuthViewModel, AuthState>(() => AuthViewModel());

class AuthViewModel extends Notifier<AuthState>{

  late final RegisterUsecase  _registerUsecase;
  late final LoginUsecase _loginUsecase;

  @override
AuthState build() {
  _registerUsecase = ref.read(registerUsecaseProvider);
  _loginUsecase = ref.read(loginUsecaseProvider);
  return const AuthState(); // uses default values
}

Future<void> register({
  required String fullName,
  required String email,
  String? phoneNumber,
  required String username,
  required String password,
  required String role,
}) async {
  state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

  final params = RegisterUsecaseParams(
    fullName: fullName,
    email: email,
    phoneNumber: phoneNumber,
    username: username,
    password: password,
    role: role,
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
    state = state.copyWith(
    status: AuthStatus.loading,
    errorMessage: null,
    );

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
}
