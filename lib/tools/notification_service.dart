import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:typed_data';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      await androidImplementation.requestExactAlarmsPermission();
    }

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
    var tzDate = tz.TZDateTime.from(scheduledDate, tz.local);
    final now = tz.TZDateTime.now(tz.local);

    if (tzDate.isBefore(now)) {
      tzDate = tzDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel_v20',
          'High Priority Reminders',
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
          playSound: true,
          vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
          channelShowBadge: true,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.reminder,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> showInstantNotification(String title, String msg) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'reminder_channel_v21',
          'Urgent Reminders',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
          channelShowBadge: true,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.reminder,
        );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _plugin.show(0, title, msg, details);
  }
}
