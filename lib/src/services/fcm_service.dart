import 'dart:convert';

import 'package:amina_ec/src/services/pending_navigation_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../../globals.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;

// =====================================
// 🌟 Enviar token al backend
// =====================================
Future<void> sendTokenToServer(String token) async {
  if (userSession.id != null && token.isNotEmpty) {
    try {
      final response = await http.post(
        Uri.parse('https://apiv1.pruebasinventario.com/api/notifications/token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"user_id": userSession.id, "token": token}),
      );
      print("💡 Respuesta backend token: ${response.statusCode} ${response.body}");
    } catch (e) {
      print("❌ Error enviando token al backend: $e");
    }
  } else {
    print("⚠️ userSession.id nulo o token vacío");
  }
}

Future<bool> _isIOSSimulator() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return false;
  try {
    final deviceInfo = await DeviceInfoPlugin().iosInfo;
    return deviceInfo.isPhysicalDevice == false;
  } catch (_) {
    return false;
  }
}

void _handleRatingNavigationFromMessage(RemoteMessage message) {
  try {
    final data = message.data;
    print("📩 Data recibida en notificación: $data");

    if (data['type'] == 'CLASS_RATING_REQUEST' &&
        data['attendance_id'] != null) {
      final String attendanceId = data['attendance_id'].toString();

      final args = {
        'attendanceId': attendanceId,
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
    print("❌ Error navegando desde notificación: $e");
  }
}

// =====================================
// 🌟 Configuración de FCM
// =====================================
Future<void> setupFCM() async {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  final isSimulator = await _isIOSSimulator();

  if (isSimulator) {
    print("⚠️ Ejecutando en simulador iOS → usando token FCM simulado");
    await sendTokenToServer("SIMULATOR_TOKEN");
    return;
  }

  if (settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional) {
    try {
      final fcmToken = await messaging.getToken();
      print("💡 Token FCM obtenido: $fcmToken");

      if (fcmToken != null) {
        await sendTokenToServer(fcmToken);
      }

      FirebaseMessaging.instance.onTokenRefresh.listen((updatedToken) async {
        print("🔄 Token FCM actualizado: $updatedToken");
        await sendTokenToServer(updatedToken);
      });
    } catch (e) {
      print("❌ Error obteniendo token FCM: $e");
    }
  } else {
    print("⚠️ Permiso de notificaciones no autorizado");
  }

  // ============================
  // APP ABIERTA → onMessage
  // ============================
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print(
      "📩 Mensaje FCM recibido (foreground): "
          "${message.notification?.title} - ${message.notification?.body}",
    );
    print("📦 Data foreground: ${message.data}");

    final title = message.notification?.title ?? "Notificación";
    final body = message.notification?.body ?? "";

    await flutterLocalNotificationsPlugin.show(
      id: message.hashCode,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          classReminderChannel.id,
          classReminderChannel.name,
          channelDescription: classReminderChannel.description,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );

    print("🔔 Notificación mostrada en foreground");
  });

  // ============================
  // APP EN BACKGROUND → tap en push
  // ============================
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("📲 onMessageOpenedApp ejecutado");
    _handleRatingNavigationFromMessage(message);
  });

  // ============================
  // APP CERRADA → tap en push
  // ============================
  final RemoteMessage? initialMessage =
  await FirebaseMessaging.instance.getInitialMessage();

  if (initialMessage != null) {
    print("🚀 App abierta desde notificación");
    _handleRatingNavigationFromMessage(initialMessage);
  }
}