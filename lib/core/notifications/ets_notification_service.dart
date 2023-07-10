import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notredame/core/notifications/arn_endpoint_handler.dart';
import 'package:notredame/firebase_messaging_handler.dart';
import 'package:notredame/locator.dart';

class ETSNotificationService {
  final ArnEndpointHandler arnEndpoint = locator<ArnEndpointHandler>();

  Future<void> initNotifications() async {
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    firebaseMessaging.requestPermission(alert: true, badge: true, sound: true);
    final fcmToken = await firebaseMessaging.getToken();
    if (kDebugMode) {
      print("FCM Token: $fcmToken");
    }

    // local notif init
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        .requestPermission();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ets_logo');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // arn init
    await arnEndpoint.loadAwsConfig();
    await arnEndpoint.createOrUpdateEndpoint(fcmToken);

    // background notif
    print("registering firebase messaging");
    FirebaseMessaging.onMessage.listen(firebaseMessagingForegroundHandler);
    FirebaseMessaging.onMessageOpenedApp
        .listen(firebaseMessagingForegroundHandler);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }
}
