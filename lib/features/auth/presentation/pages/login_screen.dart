import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:nepalexplorer/core/services/storage/user_session_service.dart';
import '../state/auth_state.dart';
import '../view_model/auth_view_model.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();
  final UserSessionService _sessionService = UserSessionService();
  bool _biometricLoading = false;

  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    // Trigger login via ViewModel
    await ref.read(authViewModelProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

    // No need to manually read authState here — ref.listen handles navigation and errors
  }

  Future<void> _loginWithBiometrics() async {
    try {
      setState(() => _biometricLoading = true);

      final isSupported = await _localAuth.isDeviceSupported();
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;

      if (!isSupported || !canCheckBiometrics) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Biometric authentication is not available on this device')),
          );
        }
        return;
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to login to NepalExplorer',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!authenticated) return;

      final isLoggedIn = await _sessionService.isLoggedIn();
      final role = await _sessionService.getRole();

      if (!mounted) return;

      if (!isLoggedIn) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No previous session found. Please login with email/password first.')),
        );
        return;
      }

      if (role == 'guide') {
        Navigator.pushReplacementNamed(context, '/guide_home');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Biometric login failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _biometricLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final containerWidth = screenWidth > 500 ? 400.0 : screenWidth * 0.9;

     ref.listen<AuthState>(authViewModelProvider, (previous, next) {
        if (next.status == AuthStatus.authenticated && next.authEntity != null) {
          final role = next.authEntity!.role;
          if (role == 'guide') {
            Navigator.pushReplacementNamed(context, '/guide_home');
          } else {
            Navigator.pushReplacementNamed(context, '/home');
          }
        } else if (next.status == AuthStatus.error && next.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next.errorMessage!)),
          );
        }
      });

    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: screenHeight,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/image1.png',
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),
            Center(
              child: SingleChildScrollView(
                child: Container(
                  width: containerWidth,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 10),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Text(
                          "Welcome Back!",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Login to your account",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) =>
                              value == null || value.isEmpty
                                  ? "Email is required"
                                  : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: const Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) =>
                              value == null || value.isEmpty
                                  ? "Password is required"
                                  : null,
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: authState.status == AuthStatus.loading
                                ? null
                                : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: authState.status == AuthStatus.loading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Login",
                                    style: TextStyle(fontSize: 18),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: _biometricLoading ? null : _loginWithBiometrics,
                            icon: _biometricLoading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.fingerprint),
                            label: Text(_biometricLoading ? 'Authenticating...' : 'Login with Biometrics'),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.blueAccent),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/guide_login'),
                          child: const Text(
                            "Login as Guide",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account?",
                              style: TextStyle(fontSize: 16),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pushReplacementNamed(
                                      context, '/register'),
                              child: const Text(
                                "Register",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
