import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:mobile/screens/messaging/model/chat_model.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Initialize FCM and Local Notifications
  static Future<void> initializeFCM() async {
    await _firebaseMessaging.requestPermission();

    // Fetch and log FCM Token (For debugging)
    String? token = await _firebaseMessaging.getToken();
    log('FCM Token: $token');

    // Initialize Local Notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await _flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        log("Clicked Notification Payload: ${response.payload}");
        if (response.payload != null && response.payload!.isNotEmpty) {
          handleNotificationClick({'redirection': response.payload});
        }
      },
    );

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        log('Foreground Notification: ${message.notification!.title}');
        log('Notification Data: ${message.data}');
        _showLocalNotification(message);
      }
    });

    // Handle notification click when the app is in the background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('Notification Opened from Background: ${message.data}');
      handleNotificationClick(message.data);
    });

    // Handle notification when the app is completely closed
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        log('Notification Opened from Terminated State: ${message.data}');
        handleNotificationClick(message.data);
      }
    });
  }

  // Show Local Notification
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    log("Showing Local Notification: ${message.data}");
    await _flutterLocalNotificationsPlugin.show(
      0,
      message.notification!.title,
      message.notification!.body,
      platformDetails,
      payload: message.data.toString(), // Corrected payload key
    );
  }

  // Handle Navigation Based on Notification Payload
  static void handleNotificationClick(Map<String, dynamic> data) {
    String? route = data['redirection']; // Corrected to use 'redirection' key
    log("Handling Notification Click: $route");
    if (route == null || route.isEmpty) {
      Get.toNamed(AppRoutes.notification);
      return;
    }

    switch (route) {
      case '/notification':
        Get.toNamed(AppRoutes.notification);
        break;
      case '/inboxScreen':
        Get.toNamed(AppRoutes.inbox, arguments: {
          'chatModel': ChatModel.fromJson(data['chat']),
          'chatName': data['chatName'],
          'participantImage': data['participantImage'],
          'isNotification': true
        });
        break;
      default:
        Get.toNamed(AppRoutes.notification);
        break;
    }
  }
}
