import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'app_settings_service.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  final _settings = AppSettingsService();

  Future<void> init() async {
    tz.initializeTimeZones();
    
    const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    
    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );
  }

  Future<bool> requestPermissions() async {
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, badge: true, sound: true) ?? false;
    }
    return true; // Android permissions handled via manifest/runtime if needed
  }

  Future<void> syncNotifications() async {
    final enabled = await _settings.notificationsEnabled();
    await _plugin.cancelAll();
    
    if (enabled) {
      final hour = await _settings.notificationHour();
      await _scheduleDaily(
        id: 1,
        title: "Daily Check-in",
        body: "Your council is waiting. How are you feeling today?",
        hour: hour,
      );
    }
  }

  Future<void> _scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfHour(hour),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminders',
          'Daily Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfHour(int hour) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
