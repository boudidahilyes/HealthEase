import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationHelper {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Tunis'));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);

    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  static Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final now = DateTime.now();

    if (now.isAfter(endDate)) return;

    DateTime firstTriggerDate = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (firstTriggerDate.isBefore(now)) {
      firstTriggerDate = firstTriggerDate.add(const Duration(days: 1));
    }

    if (firstTriggerDate.isBefore(startDate)) {
      firstTriggerDate = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
        hour,
        minute,
        0,
      );
    }

    final tz.TZDateTime tzFirstTrigger = tz.TZDateTime.from(
      firstTriggerDate,
      tz.local,
    );
    print(
      "⏰ Scheduling notification at: $tzFirstTrigger (${tzFirstTrigger.timeZoneName})",
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzFirstTrigger,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'medicine_reminders',
          'Medicine Reminders',
          channelDescription: 'Daily reminders to take your medicine',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          vibrationPattern: Int64List.fromList(const [0, 500, 1000, 500]),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  static Future<void> printAllScheduledNotifications() async {
    final List<PendingNotificationRequest> pendingNotifications = await _plugin
        .pendingNotificationRequests();

    if (pendingNotifications.isEmpty) {
      print("No scheduled notifications.");
      return;
    }

    print("📅 Scheduled notifications:");
    for (var n in pendingNotifications) {
      print("""
-------------------------
ID: ${n.id}
Title: ${n.title}
Body: ${n.body}
Payload: ${n.payload}
-------------------------
""");
    }
  }
}
