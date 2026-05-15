import 'dart:convert';

import 'package:amina_ec/src/services/pending_navigation_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../../globals.dart';

Future<void> initializeLocalNotifications() async {
  const AndroidInitializationSettings androidSettings =
  AndroidInitializationSettings('@mipmap/launcher_icon');

  const DarwinInitializationSettings iosSettings =
  DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );

  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    settings: initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      print("🔔 Local notification tapped. Payload: ${response.payload}");

      if (response.payload == null || response.payload!.isEmpty) return;

      try {
        final Map<String, dynamic> data = json.decode(response.payload!);

        if (data['type'] == 'CLASS_RATING_REQUEST' &&
            data['attendance_id'] != null) {
          final args = {
            'attendanceId': data['attendance_id'].toString(),
          };

          if (Get.key.currentState != null) {
            Get.toNamed('/user/class-rating', arguments: args);
          } else {
            PendingNavigationService.setPendingRoute(
              route: '/user/class-rating',
              arguments: args,
            );
          }
        }
      } catch (e) {
        print("❌ Error procesando payload local notification: $e");
      }
    },
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(classReminderChannel);
}