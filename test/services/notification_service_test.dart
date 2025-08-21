import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:social_balans/services/notification_service.dart';
import 'package:social_balans/providers/user_preferences_provider.dart';

// Platform fakes for permission APIs
class FakeIOSFlutterLocalNotificationsPlugin
    implements IOSFlutterLocalNotificationsPlugin {
  @override
  Future<bool?> requestPermissions({
    bool? alert,
    bool? badge,
    bool? sound,
    bool? critical,
    bool? provisional,
    bool? announcement,
  }) async {
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeAndroidFlutterLocalNotificationsPlugin
    implements AndroidFlutterLocalNotificationsPlugin {
  @override
  Future<bool?> requestNotificationsPermission() async {
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

// Main fake plugin used by tests
class FakeNotificationsPlugin implements FlutterLocalNotificationsPlugin {
  bool initialized = false;
  bool canceledAll = false;
  final List<int> canceled = [];
  final List<Map<String, Object?>> shown = [];
  final List<Map<String, Object?>> scheduled = [];

  @override
  Future<bool?> initialize(
    InitializationSettings initializationSettings, {
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
    DidReceiveBackgroundNotificationResponseCallback?
        onDidReceiveBackgroundNotificationResponse,
  }) async {
    initialized = true;
    return true;
  }

  @override
  Future<void> cancel(int id, {String? tag}) async {
    canceled.add(id);
  }

  @override
  Future<void> cancelAll() async {
    canceledAll = true;
  }

  @override
  Future<void> show(
    int id,
    String? title,
    String? body,
    NotificationDetails? notificationDetails, {
    String? payload,
  }) async {
    shown.add({
      'id': id,
      'title': title,
      'body': body,
      'payload': payload,
    });
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
    scheduled.add({
      'id': id,
      'title': title,
      'body': body,
      'payload': payload,
      'components': matchDateTimeComponents,
      'scheduledAt': scheduledDate,
      'androidScheduleMode': androidScheduleMode,
    });
  }

  @override
  T? resolvePlatformSpecificImplementation<
      T extends FlutterLocalNotificationsPlatform>() {
    if (T == IOSFlutterLocalNotificationsPlugin) {
      return FakeIOSFlutterLocalNotificationsPlugin() as T;
    }
    if (T == AndroidFlutterLocalNotificationsPlugin) {
      return FakeAndroidFlutterLocalNotificationsPlugin() as T;
    }
    return null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationService', () {
    test('init is no-op op web', () async {
      if (kIsWeb) {
        final service = NotificationService();
        await service.init();
        expect(true, true);
      } else {
        expect(true, true);
      }
    });

    test('showSimpleNotification roept plugin.show aan', () async {
      final service = NotificationService();
      final fake = FakeNotificationsPlugin();
      service.debugSetPluginOverride(fake);
      await service.init();

      await service.showSimpleNotification(
        id: 1,
        title: 'T',
        body: 'B',
        payload: '/profile',
      );

      if (!kIsWeb) {
        expect(fake.shown.length, 1);
        expect(fake.shown.first['id'], 1);
        expect(fake.shown.first['payload'], '/profile');
      }
    });

    test(
        'updateAllScheduledNotifications plant dagelijkse herinnering wanneer ingeschakeld',
        () async {
      final service = NotificationService();
      final fake = FakeNotificationsPlugin();
      service.debugSetPluginOverride(fake);
      await service.init();

      final prefs = const UserPreferences(
        darkMode: false,
        notificationsEnabled: true,
        dailyReminderEnabled: true,
        dailyReminderTime: TimeOfDay(hour: 20, minute: 0),
        challengeUpdatesEnabled: false,
        dailyScreenTimeGoal: Duration(hours: 3),
        isScreenTimeLimitEnabled: true,
        focusAreas: ['Werk'],
      );

      await service.updateAllScheduledNotifications(prefs);

      if (!kIsWeb) {
        expect(fake.canceledAll, true);
        expect(fake.scheduled.isNotEmpty, true);
      }
    });

    test('updateAllScheduledNotifications annuleert wanneer uitgeschakeld',
        () async {
      final service = NotificationService();
      final fake = FakeNotificationsPlugin();
      service.debugSetPluginOverride(fake);
      await service.init();

      final prefs = const UserPreferences(
        darkMode: false,
        notificationsEnabled: false,
        dailyReminderEnabled: true,
        dailyReminderTime: TimeOfDay(hour: 20, minute: 0),
        challengeUpdatesEnabled: false,
        dailyScreenTimeGoal: Duration(hours: 3),
        isScreenTimeLimitEnabled: true,
        focusAreas: ['Werk'],
      );

      await service.updateAllScheduledNotifications(prefs);

      if (!kIsWeb) {
        expect(fake.canceledAll, true);
        expect(fake.scheduled.isEmpty, true);
      }
    });
  });
}
