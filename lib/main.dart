import 'package:flutter/material.dart';
import 'package:healthease/pages/daily_intakes.dart';
import 'package:healthease/pages/home.dart';
import 'package:healthease/pages/pill_details.dart';
import 'package:healthease/pages/pills.dart';
import 'theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HealthEase',
      theme: AppTheme.lightTheme,
      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomePage(),
        '/pills': (context) => const PillsPage(),
        '/in-takes': (context) => const DailyIntakePage(),
        '/pill-details': (context) => const PillDetailsPage(),
      },
    );
  }
}
