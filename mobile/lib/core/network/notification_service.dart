import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../di/service_locator.dart';
import 'api_client.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    // Request permissions
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get token and send to backend
    String? token = await _fcm.getToken();
    if (token != null) {
      _sendTokenToBackend(token);
    }

    // Listen for token refreshes
    _fcm.onTokenRefresh.listen(_sendTokenToBackend);

    // Foreground listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      final apiClient = sl<ApiClient>();
      await apiClient.dio.post('/auth/fcm-token', data: {'token': token});
    } catch (e) {
      debugPrint('Failed to send FCM token to backend: $e');
    }
  }

  Future<void> showLocalNotification(String title, String body, {String? payload}) async {
    final android = AndroidNotificationDetails(
      'local_channel',
      'Local Notifications',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
        summaryText: 'RoyalHeritage Operations',
      ),
      actions: const <AndroidNotificationAction>[
        AndroidNotificationAction(
          'action_mark_read',
          'Mark Read',
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          'action_view',
          'View',
          showsUserInterface: true,
        ),
      ],
    );
    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      NotificationDetails(android: android),
      payload: payload,
    );
  }

  Future<void> scheduleDailyTaskSummaries(List<dynamic> localTasks) async {
    // 1. Cancel previous daily summaries to prevent duplicates (ids 100-113 reserved for this)
    for (int i = 100; i < 114; i++) {
      await _localNotifications.cancel(i);
    }
    
    if (localTasks.isEmpty) return;

    // 2. Group tasks by date
    final Map<String, int> tasksByDate = {};
    for (var task in localTasks) {
      final status = task is Map ? task['status'] : task.status;
      if (status == 'completed') continue;
      
      final dueDateRaw = task is Map ? task['due_date'] : task.dueDate;
      if (dueDateRaw == null) continue;
      
      String dateStr = '';
      if (dueDateRaw is DateTime) {
        dateStr = dueDateRaw.toIso8601String().split('T')[0];
      } else {
        dateStr = dueDateRaw.toString().split('T')[0];
        if (dateStr.length > 10) dateStr = dateStr.substring(0, 10);
      }
      tasksByDate[dateStr] = (tasksByDate[dateStr] ?? 0) + 1;
    }

    if (tasksByDate.isEmpty) return;

    // 3. Schedule for the next 7 days
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final targetDate = now.add(Duration(days: i));
      final dateStr = targetDate.toIso8601String().split('T')[0];
      final taskCount = tasksByDate[dateStr] ?? 0;

      if (taskCount > 0) {
        // Morning Notification (7:00 AM)
        var morningTime = tz.TZDateTime(tz.local, targetDate.year, targetDate.month, targetDate.day, 7, 0);
        if (morningTime.isAfter(tz.TZDateTime.now(tz.local))) {
          await _localNotifications.zonedSchedule(
            100 + i, // unique ID
            'Morning Operations Briefing',
            'Good morning! You have $taskCount pending task(s) scheduled for today. Tap to check your log.',
            morningTime,
            NotificationDetails(
              android: AndroidNotificationDetails(
                'daily_summary',
                'Daily Summaries',
                importance: Importance.high,
                styleInformation: BigTextStyleInformation(
                  'Good morning! You have $taskCount pending task(s) scheduled for today. Tap to check your log.',
                  contentTitle: 'Morning Operations Briefing',
                  summaryText: 'RoyalHeritage Briefing',
                ),
                actions: const <AndroidNotificationAction>[
                  AndroidNotificationAction(
                    'action_mark_read',
                    'Mark Read',
                    cancelNotification: true,
                  ),
                  AndroidNotificationAction(
                    'action_view',
                    'Open Tasks',
                    showsUserInterface: true,
                  ),
                ],
              ),
            ),
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.time,
            payload: '/tasks',
          );
        }

        // Evening Notification (4:30 PM = 16:30)
        var eveningTime = tz.TZDateTime(tz.local, targetDate.year, targetDate.month, targetDate.day, 16, 30);
        if (eveningTime.isAfter(tz.TZDateTime.now(tz.local))) {
          await _localNotifications.zonedSchedule(
            107 + i, // unique ID offset by 7
            'Evening Operations Wrap-up',
            'Reminder: You still have $taskCount task(s) remaining for today. Please check and complete them.',
            eveningTime,
            NotificationDetails(
              android: AndroidNotificationDetails(
                'daily_summary',
                'Daily Summaries',
                importance: Importance.high,
                styleInformation: BigTextStyleInformation(
                  'Reminder: You still have $taskCount task(s) remaining for today. Please check and complete them.',
                  contentTitle: 'Evening Operations Wrap-up',
                  summaryText: 'RoyalHeritage Briefing',
                ),
                actions: const <AndroidNotificationAction>[
                  AndroidNotificationAction(
                    'action_mark_read',
                    'Dismiss',
                    cancelNotification: true,
                  ),
                  AndroidNotificationAction(
                    'action_view',
                    'View Tasks',
                    showsUserInterface: true,
                  ),
                ],
              ),
            ),
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.time,
            payload: '/tasks',
          );
        }
      }
    }
  }
}
