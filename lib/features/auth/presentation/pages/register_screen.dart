import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:nepalexplorer/core/api/api_client.dart';
import 'package:nepalexplorer/core/api/api_endpoints.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiClient _apiClient = ApiClient();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _languagesController = TextEditingController();

  bool _isLoading = false;
  bool _isGuide = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: {
          'fullName': _fullNameController.text.trim(),
          'email': _emailController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'username': _usernameController.text.trim(),
          'password': _passwordController.text.trim(),
          'role': _isGuide ? 'guide' : 'user',
          if (_isGuide) 'bio': _bioController.text.trim(),
          if (_isGuide)
            'experience': int.tryParse(_experienceController.text.trim()) ?? 0,
          if (_isGuide)
            'languages': _languagesController.text
                .split(',')
                .map((language) => language.trim())
                .where((language) => language.isNotEmpty)
                .toList(),
        },
      );

      setState(() => _isLoading = false);

      final data = response.data;
      if (response.statusCode == 200 && data is Map<String, dynamic> && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration successful!")),
        );
        if (_isGuide) {
          Navigator.pushReplacementNamed(context, '/guide_login');
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        final message = data is Map<String, dynamic>
            ? (data['message'] ?? 'Registration failed')
            : 'Registration failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message.toString())),
        );
      }
    } on DioException catch (e) {
      setState(() => _isLoading = false);
      final responseData = e.response?.data;
      final message = responseData is Map<String, dynamic>
          ? (responseData['message'] ?? 'Registration failed')
          : 'Registration failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message.toString())),
      );
    } catch (_) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth > 500 ? 400.0 : screenWidth * 0.9;

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
                      const SizedBox(height: 25),
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
                      if (_isGuide) ...[
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _bioController,
                          decoration: InputDecoration(
                            labelText: "Bio",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          maxLines: 3,
                          validator: (value) => !_isGuide
                              ? null
                              : (value == null || value.isEmpty
                                  ? "Bio is required for guide"
                                  : null),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _experienceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Years of Experience",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) => !_isGuide
                              ? null
                              : (value == null || value.isEmpty
                                  ? "Experience is required for guide"
                                  : null),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _languagesController,
                          decoration: InputDecoration(
                            labelText: "Languages (comma separated)",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) => !_isGuide
                              ? null
                              : (value == null || value.isEmpty
                                  ? "Languages are required for guide"
                                  : null),
                        ),
                        const SizedBox(height: 25),
                      ],
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("Register", style: TextStyle(fontSize: 18)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account?", style: TextStyle(fontSize: 16)),
                          TextButton(
                            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
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
