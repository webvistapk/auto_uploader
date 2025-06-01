import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  log("Title: ${message.notification?.title}");

  log("Body: ${message.notification?.body}");

  log("Payload: ${message.data}");
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    final fCMToken = await getFirebaseFCMToken();
    log("FCM Token : $fCMToken");

    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }

  Future<String?> getFirebaseFCMToken() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    log("FCM Token : $fCMToken");
    return fCMToken;
  }
}
