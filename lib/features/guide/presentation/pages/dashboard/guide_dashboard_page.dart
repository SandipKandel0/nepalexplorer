import 'package:flutter/material.dart';
import '../../widgets/guide_bottom_nav.dart';
import '../home_screen.dart';
import '../profile_screen.dart';
import '../requests_screen.dart';

class GuideDashboardPage extends StatefulWidget {
  const GuideDashboardPage({super.key});

  @override
  State<GuideDashboardPage> createState() => _GuideDashboardPageState();
}

class _GuideDashboardPageState extends State<GuideDashboardPage> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Initialize screens
    _screens = [
      const HomeScreen(),
      const RequestsScreen(),
      const ProfileScreen(),
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
