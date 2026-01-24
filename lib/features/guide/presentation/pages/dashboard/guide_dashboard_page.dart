import 'package:flutter/material.dart';
import '../../widgets/guide_bottom_nav.dart';
import '../home_screen.dart';
import '../profile_screen.dart';
import '../requests_screen.dart';

class GuideDashboardPage extends StatefulWidget {
  final String token; // Pass the JWT token here

  const GuideDashboardPage({super.key, required this.token});

  @override
  State<GuideDashboardPage> createState() => _GuideDashboardPageState();
}

class _GuideDashboardPageState extends State<GuideDashboardPage> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Initialize screens with token where required
    _screens = [
      const HomeScreen(),
      const RequestsScreen(),
      ProfileScreen(token: widget.token), // Pass token to ProfileScreen
    ];
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: GuideBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
