import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepalexplorer/core/api/api_client.dart';
import 'package:nepalexplorer/core/api/api_endpoints.dart';
import 'package:nepalexplorer/core/services/storage/user_session_service.dart';
import 'package:nepalexplorer/features/guide/presentation/pages/dashboard/guide_dashboard_page.dart';

/// Provider for guide login view model
final guideViewModelProvider =
    ChangeNotifierProvider((ref) => GuideViewModel());

class GuideViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  late ApiClient _apiClient;
  late UserSessionService _userSessionService;

  GuideViewModel() {
    _apiClient = ApiClient();
    _userSessionService = UserSessionService();
  }

  /// Login guide and store token in secure storage
  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.post(
        ApiEndpoints.guideLogin,
        data: {'email': email, 'password': password},
      );

      isLoading = false;
      notifyListeners();

      if (response.statusCode == 200 && response.data['success'] == true) {
        final token = response.data['token'];
        final user = response.data['data']['user'];
        
        // Store token and user data in secure storage
        await _userSessionService.storeUserSession(
          userId: user['_id'] ?? '',
          fullName: user['fullName'] ?? '',
          email: user['email'] ?? '',
          role: user['role'] ?? 'guide',
          token: token,
        );
        
        return true; // ✅ LOGIN SUCCESS
      } else {
        errorMessage = response.data['message'] ?? 'Login failed';
        return false;
      }
    } catch (e) {
      isLoading = false;
      errorMessage = 'Server error: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
}

class GuideLoginPage extends ConsumerStatefulWidget {
  const GuideLoginPage({super.key});

  @override
  ConsumerState<GuideLoginPage> createState() => _GuideLoginPageState();
}

class _GuideLoginPageState extends ConsumerState<GuideLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(guideViewModelProvider);

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final containerWidth = screenWidth > 500 ? 400.0 : screenWidth * 0.9;

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
              child: Container(color: const Color.fromRGBO(0, 0, 0, 0.5)),
            ),
            Center(
              child: SingleChildScrollView(
                child: Container(
                  width: containerWidth,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(31, 251, 251, 251),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.white),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Text(
                          "Welcome Guide!",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Login to your guide account",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 20),

                        /// EMAIL
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: "Email",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) =>
                              value == null || value.isEmpty
                                  ? "Enter email"
                                  : null,
                        ),

                        const SizedBox(height: 20),

                        /// PASSWORD
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
                              value == null || value.isEmpty
                                  ? "Enter password"
                                  : null,
                        ),

                        const SizedBox(height: 25),

                        /// LOGIN BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: viewModel.isLoading
                              ? const Center(
                                  child: CircularProgressIndicator())
                              : ElevatedButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      final success = await viewModel.login(
                                        _emailController.text.trim(),
                                        _passwordController.text.trim(),
                                      );

                                      if (success) {
                                        // ✅ LOGIN SUCCESS - Navigate to dashboard
                                        if (mounted) {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const GuideDashboardPage(),
                                            ),
                                          );
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(viewModel.errorMessage ??
                                                "Login failed"),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: const Text("Login"),
                                ),
                        ),

                        const SizedBox(height: 20),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
