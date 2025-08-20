
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:advisor_desk/domain/repositories/performance_repository.dart';

import 'package:advisor_desk/domain/entities/daily_entry.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final PerformanceRepository performanceRepository;

  NotificationService({required this.performanceRepository});

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    tz.initializeTimeZones();
  }

  Future<void> scheduleDailyReminders() async {
    await cancelAllReminders(); // Cancel any existing reminders before scheduling new ones
    await _scheduleNotification(12, 0, 0, 0, 'Morning Reminder'); // 12:00 PM
    await _scheduleNotification(17, 0, 0, 1, 'Afternoon Reminder'); // 5:00 PM
    await _scheduleNotification(21, 0, 0, 2, 'Evening Reminder'); // 9:00 PM
  }

  Future<void> _scheduleNotification(int hour, int minute, int second, int id, String channelId) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute, second);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final DailyEntry? entry = await performanceRepository.getEntryForDate(scheduledDate);
    if (entry == null) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        'Advisor Desk Reminder',
        "Don't forget to add today's entry!",
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            'Daily Reminders',
            channelDescription: 'Reminders to add daily entries',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'daily_reminder',
      );
    }
  }

  Future<void> cancelAllReminders() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> cancelTodaysRemindersIfEntryExists() async {
    final DailyEntry? entry = await performanceRepository.getEntryForDate(DateTime.now());
    if (entry != null) {
      // If an entry for today exists, cancel all pending notifications.
      await cancelAllReminders();
      // And reschedule for tomorrow
      await scheduleDailyReminders();
    }
  }
}
