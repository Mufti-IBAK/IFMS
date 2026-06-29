import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../di/service_locator.dart';
import 'api_client.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
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
}
