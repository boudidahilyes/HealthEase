import 'package:flutter/material.dart';
import 'package:healthease/core/database/local_database.dart';
import 'package:healthease/pages/pills/daily_intakes.dart';
import 'package:healthease/pages/home.dart';
import 'package:healthease/pages/pills/pill_details.dart';
import 'package:healthease/pages/pills/pills.dart';
import 'theme.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDatabase.instance;
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
        '/pill-details': (context) {
          final medicineId = ModalRoute.of(context)!.settings.arguments as int;
          return PillDetailsPage(medicineId: medicineId);
        },
      },
    );
  }
}
