import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Vérifier les préférences de notification
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;

    if (notificationsEnabled) {
      await _scheduleDefaultNotifications();
    }
  }

  Future<void> _onNotificationTapped(NotificationResponse response) async {
    // TODO: Gérer le tap sur la notification
    // Par exemple, naviguer vers l'écran approprié
  }

  Future<void> _scheduleDefaultNotifications() async {
    // Rappel quotidien pour entrer son humeur
    await _scheduleDailyMoodReminder();

    // Rappel pour les pauses
    await _scheduleBreakReminders();

    // Rappel pour les objectifs
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

    // Planifier pour 20h chaque jour
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      20,
      0,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      0,
      'Hoe voel je je vandaag?',
      'Neem even de tijd om je humeur in te voeren.',
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
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

    // Planifier des rappels toutes les 2 heures entre 9h et 21h
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      9,
      0,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    for (var i = 0; i < 7; i++) {
      final time = scheduledDate.add(Duration(hours: i * 2));
      if (time.hour < 21) {
        await _notifications.zonedSchedule(
          i + 1,
          'Tijd voor een pauze!',
          'Neem even de tijd om je ogen te laten rusten.',
          tz.TZDateTime.from(time, tz.local),
          details,
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

    // Planifier un rappel hebdomadaire pour les objectifs
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      10,
      0,
    );

    // Trouver le prochain lundi
    while (scheduledDate.weekday != DateTime.monday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    await _notifications.zonedSchedule(
      8,
      'Nieuwe week, nieuwe doelen!',
      'Bekijk je doelen voor deze week.',
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> updateNotificationSettings(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);

    if (enabled) {
      await _scheduleDefaultNotifications();
    } else {
      await _notifications.cancelAll();
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

    await _notifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
      payload: payload,
    );
  }
}
