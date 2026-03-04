import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static Future<void> init() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings android = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const InitializationSettings settings = InitializationSettings(
      android: android,
    );

    await _plugin.initialize(settings);
  }

  static Future<void> scheduleNotification(
    int id,
    String title,
    String body,
    DateTime scheduledDate,
  ) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel_v1',
          'Reminders',
          importance: Importance.max,
          priority: Priority.high,enableVibration: true,
          playSound: true
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> showInstantNotification(String title, String msg) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'reminder_channel_v1',
          'Reminders',
          importance: Importance.high,
          priority: Priority.high,playSound: true,
          enableVibration: true,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _plugin.show(0, title, msg, details);
  }
}
