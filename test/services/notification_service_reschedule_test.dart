import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:social_balans/services/notification_service.dart';
import 'package:social_balans/providers/user_preferences_provider.dart';

class _FakeIOS implements IOSFlutterLocalNotificationsPlugin {
  @override
  Future<bool?> requestPermissions({
    bool? alert,
    bool? badge,
    bool? sound,
    bool? critical,
    bool? provisional,
    bool? announcement,
  }) async => true;
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeAndroid implements AndroidFlutterLocalNotificationsPlugin {
  @override
  Future<bool?> requestNotificationsPermission() async => true;
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeNotificationsPlugin implements FlutterLocalNotificationsPlugin {
  int cancelAllCount = 0;
  int scheduleCount = 0;

  @override
  Future<bool?> initialize(
    InitializationSettings initializationSettings, {
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
    DidReceiveBackgroundNotificationResponseCallback?
        onDidReceiveBackgroundNotificationResponse,
  }) async => true;

  @override
  Future<void> cancelAll() async {
    cancelAllCount++;
  }

  @override
  Future<void> zonedSchedule(
    int id,
    String? title,
    String? body,
    tz.TZDateTime scheduledDate,
    NotificationDetails notificationDetails, {
    required AndroidScheduleMode androidScheduleMode,
    DateTimeComponents? matchDateTimeComponents,
    String? payload,
  }) async {
    scheduleCount++;
  }

  @override
  T? resolvePlatformSpecificImplementation<
      T extends FlutterLocalNotificationsPlatform>() {
    if (T == IOSFlutterLocalNotificationsPlugin) return _FakeIOS() as T;
    if (T == AndroidFlutterLocalNotificationsPlugin) return _FakeAndroid() as T;
    return null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('NotificationService replanification', () {
    test("changement d'heure replanifie le rappel", () async {
      final service = NotificationService();
      final fake = FakeNotificationsPlugin();
      service.debugSetPluginOverride(fake);
      await service.init();

      final prefs1 = const UserPreferences(
        darkMode: false,
        notificationsEnabled: true,
        dailyReminderEnabled: true,
        dailyReminderTime: TimeOfDay(hour: 8, minute: 0),
        challengeUpdatesEnabled: false,
        dailyScreenTimeGoal: Duration(hours: 3),
        isScreenTimeLimitEnabled: true,
        focusAreas: ['Werk'],
      );
      await service.updateAllScheduledNotifications(prefs1);

      final prefs2 =
          prefs1.copyWith(dailyReminderTime: const TimeOfDay(hour: 20, minute: 0));
      await service.updateAllScheduledNotifications(prefs2);

      expect(fake.cancelAllCount, 2);
      expect(fake.scheduleCount, 2);
    });

    test('désactivation annule tout', () async {
      final service = NotificationService();
      final fake = FakeNotificationsPlugin();
      service.debugSetPluginOverride(fake);
      await service.init();

      final prefs = const UserPreferences(
        darkMode: false,
        notificationsEnabled: false,
        dailyReminderEnabled: true,
        dailyReminderTime: TimeOfDay(hour: 8, minute: 0),
        challengeUpdatesEnabled: false,
        dailyScreenTimeGoal: Duration(hours: 3),
        isScreenTimeLimitEnabled: true,
        focusAreas: ['Werk'],
      );
      await service.updateAllScheduledNotifications(prefs);
      expect(fake.cancelAllCount, 1);
      expect(fake.scheduleCount, 0);
    });
  });
}
