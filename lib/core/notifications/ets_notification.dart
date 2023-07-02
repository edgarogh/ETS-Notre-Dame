import 'dart:convert';

import 'package:notredame/core/notifications/ets_notification_data.dart';

class ETSNotification {
  String notificationTexte;
  int notificationApplicationId;
  String nomUsager;
  ETSNotificationData notificationData;
  String url;

  ETSNotification(
      {this.notificationTexte,
      this.notificationApplicationId,
      this.nomUsager,
      this.notificationData,
      this.url});

  ETSNotification.fromJson(Map<String, dynamic> map) {
    notificationTexte = map['NotificationTexte'] as String ?? "No data";
    notificationApplicationId =
        int.parse(map['NotificationApplicationId'] as String);
    nomUsager = map['NomUsager'] as String;
    notificationData = map['NotificationData'] != null
        ? ETSNotificationData.fromJson(json
            .decode(map['NotificationData'] as String) as Map<String, dynamic>)
        : null;
    url = map['Url'] as String;
  }
}
