import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepalexplorer/app/app.dart';
import 'package:nepalexplorer/core/services/hive/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hiveAuthService = HiveAuthService();
  await hiveAuthService.init(); // ✅ HiveAuthService initialization

  runApp(
    const ProviderScope(child: MyApp()),
  );
}
