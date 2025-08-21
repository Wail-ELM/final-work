import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../providers/user_preferences_provider.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  FlutterLocalNotificationsPlugin? _pluginOverride; // for tests
  FlutterLocalNotificationsPlugin get _plugin =>
      _pluginOverride ?? _notificationsPlugin;
  GlobalKey<NavigatorState>? _navigatorKey;
  bool _isInitialized = false;

  void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  Future<void> init() async {
    // Web: flutter_local_notifications is not supported; make this a no-op.
    if (kIsWeb) {
      debugPrint('[Notifications] Web detected: notifications are disabled.');
      _isInitialized =
          true; // Mark as initialized so callers can proceed safely.
      return;
    }
    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Europe/Brussels'));
    } catch (e) {
      debugPrint('Failed to set local location: $e. Using UTC as fallback.');
      tz.setLocalLocation(tz.UTC);
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          _onDidReceiveBackgroundNotificationResponse,
    );
    // Request permissions where required (iOS and Android 13+)
    try {
      await _requestPlatformPermissions();
    } catch (e) {
      debugPrint('Notification permission request failed: $e');
    }
    _isInitialized = true;
  }

  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    debugPrint('Notification Response: Payload: ${response.payload}');
    if (response.payload != null && response.payload!.isNotEmpty) {
      if (_navigatorKey?.currentState != null) {
        _navigatorKey!.currentState!.pushNamed(response.payload!);
      } else {
        debugPrint(
            'NavigatorKey not set or no current state, cannot navigate from notification.');
      }
    }
  }

  @pragma('vm:entry-point')
  static void _onDidReceiveBackgroundNotificationResponse(
      NotificationResponse response) {
    debugPrint(
        'Background Notification Response: Payload: ${response.payload}');
  }

  Future<bool> requestIOSPermissions() async {
    final result = await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    return result ?? false;
  }

  Future<void> showSimpleNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) {
      debugPrint('[Notifications] showSimpleNotification ignored on Web');
      return;
    }
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'social_balans_channel_id',
      'Social Balans Meldingen',
      channelDescription: 'Kanaal voor Social Balans app meldingen',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
            presentSound: true, presentBadge: true, presentAlert: true));

    await _plugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDateTime,
    String? payload,
    String channelId = 'social_balans_scheduled_channel',
    String channelName = 'Social Balans Geplande Meldingen',
    String channelDescription = 'Kanaal voor geplande Social Balans meldingen',
    bool repeatDaily = false,
  }) async {
    if (kIsWeb) {
      debugPrint('[Notifications] scheduleNotification ignored on Web');
      return;
    }
    // Windows: repeating schedules are not supported by plugin; fall back to one-time schedule.
    final bool isWindows = defaultTargetPlatform == TargetPlatform.windows;
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDateTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentSound: true,
          presentBadge: true,
          presentAlert: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
      matchDateTimeComponents:
          (repeatDaily && !isWindows) ? DateTimeComponents.time : null,
    );
    if (repeatDaily && isWindows) {
      debugPrint(
          '[Notifications] Windows detected: scheduled a one-time notification (daily repeat unsupported).');
    }
  }

  Future<void> updateAllScheduledNotifications(UserPreferences prefs) async {
    if (!_isInitialized) return;
    await cancelAllNotifications();

    if (!prefs.notificationsEnabled) {
      debugPrint(
          'Notifications are disabled. All scheduled notifications cancelled.');
      return;
    }

    if (prefs.dailyReminderEnabled) {
      await _scheduleDailyMoodReminder(prefs.dailyReminderTime);
    }

    // In the future, you can re-enable these
    // if (prefs.challengeUpdatesEnabled) {
    //   await _scheduleChallengeNotifications();
    // }
  }

  Future<void> _scheduleDailyMoodReminder(TimeOfDay reminderTime) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      reminderTime.hour,
      reminderTime.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await scheduleNotification(
      id: 0,
      title: 'Hoe voel je je vandaag?',
      body: 'Neem even de tijd om je humeur in te voeren.',
      scheduledDateTime: scheduledDate,
      payload: '/mood-entry',
      channelId: 'daily_mood_reminder',
      channelName: 'Dagelijkse Humeur Herinnering',
      channelDescription: 'Herinnering om je dagelijkse humeur te loggen.',
      repeatDaily: true,
    );

    debugPrint('Daily mood reminder scheduled for: $scheduledDate');
  }

  Future<void> showTestNotification() async {
    await showSimpleNotification(
      id: 999,
      title: '🌱 Test Notificatie',
      body: 'Je notificaties werken perfect!',
      payload: '/profile',
    );
  }

  Future<void> cancelNotification(int id) async {
    if (kIsWeb) return;
    await _plugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    if (!_isInitialized || kIsWeb) return;
    await _plugin.cancelAll();
    debugPrint('All scheduled notifications have been cancelled.');
  }

  Future<void> _requestPlatformPermissions() async {
    if (kIsWeb) return;
    // iOS
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // For tests only: inject a mock plugin
  @visibleForTesting
  void debugSetPluginOverride(FlutterLocalNotificationsPlugin plugin) {
    _pluginOverride = plugin;
  }
}
