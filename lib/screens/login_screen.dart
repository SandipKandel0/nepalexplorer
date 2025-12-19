import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              child: Container(
                color: Color.fromRGBO(0, 0, 0, 0.5),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Container(
                  width: containerWidth,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(31, 235, 228, 228),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.white)
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Welcome back!!",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/dashboard'),
                          child: const Text("Login"),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/register'),
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?",
                              style: TextStyle(fontSize: 16)),
                          TextButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/register'),
                            child: const Text(
                              "Register",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent),
                            ),
                          )
                        ],
                      )
                    ],
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
