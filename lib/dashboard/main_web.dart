import 'package:flutter/material.dart';
import 'package:healthease/dashboard/layout/dashboard_layout.dart';
import 'package:healthease/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const DashboardApp());
}

class DashboardApp extends StatelessWidget {
  const DashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "HealthEase Dashboard",
      theme: AppTheme.lightTheme,
      home: const DashboardPage(),
    );
  }
}
