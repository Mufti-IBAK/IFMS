import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/di/service_locator.dart';
import 'core/sync/sync_manager.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Request Storage & Notification permissions at startup via Native MethodChannel
  try {
    const platform = MethodChannel('com.namanzo.ifms/permissions');
    await platform.invokeMethod('requestStoragePermissions');
  } catch (e) {
    debugPrint('Permission request error: $e');
  }

  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Setup Background Handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize Local Notifications for Foreground
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/launcher_icon');
  const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      if (response.payload != null && appNavigatorKey.currentState != null) {
        // Attempt to pop any open dialogs/sheets
        if (appNavigatorKey.currentState!.canPop()) {
           appNavigatorKey.currentState!.pop();
        }
        // Navigate to the route specified in the payload
        appNavigatorKey.currentState!.pushNamed(response.payload!);
      }
    },
  );

  // Initialize dependency injection
  await setupLocator();

  // On fresh install (empty DB), pull all data from Supabase
  sl<SyncManager>().restoreFromSupabaseIfNeeded().then((restored) {
    if (restored) debugPrint('[Restore] Data restored from Supabase on fresh install.');
  });

  // Start offline sync manager
  sl<SyncManager>().triggerSync();

  runApp(const IFMSApp());
}
