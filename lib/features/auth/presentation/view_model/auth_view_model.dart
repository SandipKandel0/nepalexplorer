import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepalexplorer/features/auth/domain/usecases/get_current_usecase.dart';
import '../state/auth_state.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  AuthViewModel.new,
);

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;
  late final GetCurrentUserUsecase _getCurrentUserUsecase;
  late final LogoutUsecase _logoutUsecase;

  @override
  AuthState build() {
    // Initialize use cases
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _getCurrentUserUsecase = ref.read(getCurrentUserUsecaseProvider);
    _logoutUsecase = ref.read(logoutUsecaseProvider);

    return const AuthState(); // default state
  }

  // ================= REGISTER =================
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
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (isRegistered) => state = state.copyWith(
        status: isRegistered ? AuthStatus.register : AuthStatus.error,
        errorMessage: isRegistered ? null : 'Registration failed',
      ),
    );
  }

  // ================= LOGIN =================
Future<void> login({
  required String email,
  required String password,
}) async {
  state = const AuthState(status: AuthStatus.loading);

  final params = LoginUsecaseParams(email: email, password: password);
  final result = await _loginUsecase(params);

  result.fold(
    (failure) => state = AuthState(
      status: AuthStatus.error,
      errorMessage: failure.message,
    ),
    (authEntity) => state = AuthState(
      status: AuthStatus.authenticated,
      authEntity: authEntity,
    ),
  );
}


  // ================= GET CURRENT USER =================
  Future<void> getCurrentUser() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _getCurrentUserUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (authEntity) => state = state.copyWith(
        status: AuthStatus.authenticated,
        authEntity: authEntity,
      ),
    );
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _logoutUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = const AuthState(), // reset state on logout
    );
  }
}
