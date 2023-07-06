import 'package:flutter/material.dart';
import 'package:notredame/core/notifications/ets_notification.dart';

// UTILS
import 'package:notredame/ui/utils/app_theme.dart';

class InAppNotification extends StatelessWidget {
  final ETSNotification notification;

  InAppNotification({this.notification});

  final Map<String, String> typeToTitle = <String, String>{
    'SignetsNouvelleNote': 'Nouvelle note disponible',
    'SignetsModificationNote': 'Note modifié',
    'SignetsLotsNouvellesNotes': 'Plusieurs nouvelles notes disponibles',
    'SignetsCoteFinale': 'Côte finale disponible',
  };

  @override
  Widget build(BuildContext context) {
    final bool isLightMode = Theme.of(context).brightness == Brightness.light;
    final String type = notification.notificationData.typeNotification;
    final String title = typeToTitle[type] ?? 'Nouvelle notification';
    final String message =
        '${notification.notificationData.sigle} - ${notification.notificationData.element}';

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        color: isLightMode
            ? const Color.fromARGB(255, 158, 155, 155)
            : AppTheme.etsBlack,
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.gradeGoodMax,
              ),
              child: const Icon(
                Icons.notification_important,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        color: isLightMode ? Colors.black : Colors.white,
                        fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                        color: isLightMode ? Colors.black : Colors.white,
                        fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
