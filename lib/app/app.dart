// lib/app.dart
import 'package:flutter/material.dart';
import 'package:nepalexplorer/app/theme/theme_data.dart';
import 'package:nepalexplorer/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:nepalexplorer/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:nepalexplorer/features/splash/presentation/pages/splash_screen.dart';
import 'package:nepalexplorer/features/auth/presentation/pages/login_screen.dart';
import 'package:nepalexplorer/features/auth/presentation/pages/register_screen.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NepalExplorer',
      debugShowCheckedModeBanner: false,
      theme: getApplicationTheme(),
      home: const SplashScreen(),
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const DashboardScreen(),
      },
    );
  }
}
