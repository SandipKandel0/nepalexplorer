import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepalexplorer/features/auth/presentation/state/auth_state.dart';
import 'package:nepalexplorer/features/auth/presentation/view_model/auth_view_model.dart';


class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isGuide = false; // new role toggle

 Future<void> _register() async {
  if (!_formKey.currentState!.validate()) return;

  if (_passwordController.text != _confirmPasswordController.text) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Passwords do not match")),
    );
    return;
  }
  // Trigger registration via ViewModel
  await ref.read(authViewModelProvider.notifier).register(
    fullName: _fullNameController.text.trim(),
    email: _emailController.text.trim(),
    phoneNumber: _phoneController.text.trim(),
    username: _usernameController.text.trim(),
    password: _passwordController.text.trim(),
    role: _isGuide ? 'guide' : 'user',
  );
}
  @override
  Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final containerWidth = screenWidth > 500 ? 400.0 : screenWidth * 0.9;

  // Watch the auth state
  final authState = ref.watch(authViewModelProvider);

  // Listen to state changes for navigation / messages
  ref.listen<AuthState>(authViewModelProvider, (previous, next) {
    if (next.status == AuthStatus.register) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration successful!")),
      );
      if (_isGuide) {
        Navigator.pushReplacementNamed(context, '/guide_login');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
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
        child: Container(
          color: const Color.fromARGB(255, 225, 213, 181),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                width: containerWidth,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 251, 251, 251),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Color.fromARGB(66, 236, 171, 6))
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Register",
                        style: TextStyle(fontSize: 18, color: Colors.blueAccent),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _fullNameController,
                        decoration: InputDecoration(
                          labelText: "Full Name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? "Full Name is required" : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: "Mobile Number",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Email is required";
                          if (!value.contains('@')) return "Enter a valid email";
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: "Username",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? "Username is required" : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? "Password is required" : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Confirm Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? "Confirm your password" : null,
                      ),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Register as Guide"),
                          Switch(
                            value: _isGuide,
                            onChanged: (val) {
                              setState(() {
                                _isGuide = val;
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: authState.status == AuthStatus.loading ? null : _register,
                          child:authState.status == AuthStatus.loading 
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("Register", style: TextStyle(fontSize: 18)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Flexible(
                            child: Text(
                              "Already have an account?",
                              style: TextStyle(fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pushReplacementNamed(context, '/login'),
                            child: const Text(
                              "Login",
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
        ),
      ),
    );
  }
}
