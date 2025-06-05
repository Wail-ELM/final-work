import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  GlobalKey<NavigatorState>? _navigatorKey;

  void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  Future<void> init() async {
    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Europe/Brussels'));
    } catch (e) {
      print('Failed to set local location: $e. Using UTC as fallback.');
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

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          _onDidReceiveBackgroundNotificationResponse,
    );

    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;

    if (notificationsEnabled) {
      await _scheduleDefaultNotifications();
    }
  }

  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    print('Notification Response: Payload: ${response.payload}');
    if (response.payload != null && response.payload!.isNotEmpty) {
      if (_navigatorKey?.currentState != null) {
        _navigatorKey!.currentState!.pushNamed(response.payload!);
      } else {
        print(
            'NavigatorKey not set or no current state, cannot navigate from notification.');
      }
    }
  }

  @pragma('vm:entry-point')
  static void _onDidReceiveBackgroundNotificationResponse(
      NotificationResponse response) {
    print('Background Notification Response: Payload: ${response.payload}');
  }

  Future<bool> requestIOSPermissions() async {
    final result = await _notificationsPlugin
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

    await _notificationsPlugin.show(
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
    required DateTime scheduledDateTime,
    String? payload,
    String? channelId = 'social_balans_scheduled_channel',
    String? channelName = 'Social Balans Geplande Meldingen',
    String? channelDescription = 'Kanaal voor geplande Social Balans meldingen',
  }) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDateTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId!,
          channelName!,
          channelDescription: channelDescription,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
            presentSound: true, presentBadge: true, presentAlert: true),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<void> _scheduleDefaultNotifications() async {
    await _scheduleDailyMoodReminder();
    await _scheduleBreakReminders();
    await _scheduleGoalReminders();
  }

  Future<void> _scheduleDailyMoodReminder() async {
    const androidDetails = AndroidNotificationDetails(
      'mood_reminder',
      'Humeur Rappel',
      channelDescription: 'Rappels pour entrer votre humeur quotidienne',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, 20, 0);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notificationsPlugin.zonedSchedule(
      0,
      'Hoe voel je je vandaag?',
      'Neem even de tijd om je humeur in te voeren.',
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      payload: '/mood-entry',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> _scheduleBreakReminders() async {
    const androidDetails = AndroidNotificationDetails(
      'break_reminder',
      'Pauze Rappel',
      channelDescription: 'Rappels pour prendre des pauses',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, 9, 0);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    for (var i = 0; i < 7; i++) {
      final time = scheduledDate.add(Duration(hours: i * 2));
      if (time.hour < 21) {
        await _notificationsPlugin.zonedSchedule(
          i + 1,
          'Tijd voor een pauze!',
          'Neem even de tijd om je ogen te laten rusten.',
          tz.TZDateTime.from(time, tz.local),
          details,
          payload: '/home',
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
    }
  }

  Future<void> _scheduleGoalReminders() async {
    const androidDetails = AndroidNotificationDetails(
      'goal_reminder',
      'Doel Rappel',
      channelDescription: 'Rappels pour vos objectifs',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, 10, 0);
    while (scheduledDate.weekday != DateTime.monday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    await _notificationsPlugin.zonedSchedule(
      8,
      'Nieuwe week, nieuwe doelen!',
      'Bekijk je doelen voor deze week.',
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      payload: '/challenges',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> updateNotificationSettings(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);

    if (enabled) {
      await _scheduleDefaultNotifications();
    } else {
      await _notificationsPlugin.cancelAll();
    }
  }

  Future<void> showCustomNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'custom_notification',
      'Custom Notifications',
      channelDescription: 'Notifications personnalisées',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> showScreenTimeLimitNotification(
      Duration goal, Duration actual) async {
    final goalHours = goal.inHours;
    final goalMinutes = goal.inMinutes % 60;
    final actualHours = actual.inHours;
    final actualMinutes = actual.inMinutes % 60;

    final String goalText = "${goalHours}u ${goalMinutes}m";
    final String actualText = "${actualHours}u ${actualMinutes}m";

    await showSimpleNotification(
      id: 100, // Use a unique ID for this type of notification
      title: 'Schermtijd Limiet Bereikt',
      body:
          'Je hebt je dagelijkse doel van $goalText overschreden. Huidige tijd: $actualText.',
      payload: '/stats', // Navigate to stats screen on tap
    );
  }
}
