import 'package:flutter/material.dart';
import 'package:healthease/core/database/local_database.dart';
import 'package:healthease/core/helpers/notification_helper.dart';
import 'package:healthease/mobile/pages/appointments/appointment_list.dart';
import 'package:healthease/mobile/pages/home.dart';
import 'package:healthease/mobile/pages/pills/daily_intakes.dart';
import 'package:healthease/mobile/pages/pills/pill_details.dart';
import 'package:healthease/mobile/pages/pills/pills.dart';
import '../theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDatabase.instance;
  await NotificationHelper.init();
  await NotificationHelper.printAllScheduledNotifications();
  runApp(const MobileApp());
}

class MobileApp extends StatelessWidget {
  const MobileApp({super.key});

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
        '/appointments': (context) => const AppointmentListPage(),
        '/pill-details': (context) {
          final medicineId = ModalRoute.of(context)!.settings.arguments as int;
          return PillDetailsPage(medicineId: medicineId);
        },
      },
    );
  }
}
