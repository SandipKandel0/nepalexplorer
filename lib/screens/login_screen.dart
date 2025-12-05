import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(color: Color.fromARGB(255, 248, 247, 246)),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/image1.png', width: 300, height: 120),
                const SizedBox(height: 20),
                const Text("Welcome back!!",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                const SizedBox(height: 8),
                const Text("Login", style: TextStyle(color: Colors.blueAccent, fontSize: 18)),
                const SizedBox(height: 40),
                Container(
                  width: 400,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 153, 174, 235),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Color.fromARGB(66, 236, 171, 6))]),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurpleAccent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                          onPressed: () => Navigator.pushNamed(context, '/home'),
                          child: const Text("Login",
                              style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 237, 83, 75))),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/register'),
                          child: const Text("Forgot Password?",
                              style: TextStyle(fontSize: 14, color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?", style: TextStyle(fontSize: 14)),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(context, '/register'),
                            child: const Text("Register",
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
