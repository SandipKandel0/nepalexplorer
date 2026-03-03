import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nepalexplorer/app/app.dart';
import 'package:nepalexplorer/core/services/hive/hive_service.dart';
import 'package:nepalexplorer/features/auth/data/models/auth_hive_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(AuthHiveModelAdapter());
  }

  await Hive.openBox<AuthHiveModel>('authBox');

  final hiveAuthService = HiveAuthService();
  await hiveAuthService.init();

  runApp(
    const ProviderScope(child: MyApp()),
  );
}
