import 'package:flutter/material.dart';
import 'services/database_service.dart';
import 'screens/main_navigation_screen.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ FIRST: initialize SQLite for Windows
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // ✅ THEN: use the database
  await DatabaseService.instance.database;
  await DatabaseService.instance.ensureDefaultZoneExists();
  await DatabaseService.instance.ensureDefaultUserExists();
  await DatabaseService.instance.seedProductsIfEmpty();
  await DatabaseService.instance.seedStockIfEmpty();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AgriSync CRM',
      theme: AppTheme.lightTheme,
      home: const MainNavigationScreen(),
    );
  }
}