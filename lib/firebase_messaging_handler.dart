import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notredame/core/notifications/ets_notification.dart';
import 'package:notredame/core/notifications/in_app_notification_widget.dart';
import 'package:overlay_support/overlay_support.dart';

final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

/// Every function defined in this file is a top-level function as defined in the
/// documentation of the firebase_messaging package. They are registered from the service
/// ETSNotificationService.

/// This function is called when a notification is received while the app is in
/// the foreground. It will display the notification in the notification tray.
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}${message.data}");
  }

  if (message.data.isEmpty || message.data["NotificationTexte"] == null) {
    return;
  }

  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails('channel-etsmobile', 'ÉTS Mobile',
          channelDescription:
              'A channel to receive all important notifications for ÉTS Mobile',
          importance: Importance.max,
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
  print("test123");
  if (message.data.isEmpty || message.data["NotificationTexte"] == null) {
    return;
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
