import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notredame/core/notifications/arn_endpoint_handler.dart';
import 'package:notredame/core/notifications/ets_notification.dart';
import 'package:notredame/core/notifications/in_app_notification_widget.dart';
import 'package:notredame/locator.dart';
import 'package:overlay_support/overlay_support.dart';

// UTILS
import 'package:notredame/ui/utils/app_theme.dart';

final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
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
  final arnEndpoint = locator<ArnEndpointHandler>();
  await arnEndpoint.loadAwsConfig();
  await arnEndpoint.createOrUpdateEndpoint(fcmToken);

  // background notif
  FirebaseMessaging.onMessage.listen(firebaseMessagingForegroundHandler);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}${message.data}");
  }
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails('channel-etsmobile', 'ÉTS Mobile',
          channelDescription:
              'A channel to receive all important notifications for ÉTS Mobile',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'ticker');
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);
  flutterLocalNotificationsPlugin.show(0, "ÉTSMobile",
      message.data["NotificationTexte"].toString(), notificationDetails);
}

Future<void> firebaseMessagingForegroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print("Handling a foreground message: ${message.messageId}${message.data}");
  }

  showSimpleNotification(
    InAppNotification(
      notification: ETSNotification.fromJson(message.data),
    ),
    background: Colors.transparent,
    autoDismiss: true,
    duration: const Duration(seconds: 8),
  );
}
