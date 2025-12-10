import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
        body: '{"user_id": ${userSession.id}, "token": "$token"}',
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

// =====================================
// 🌟 Configuración de FCM (Optimizada)
// =====================================
Future<void> setupFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  final isSimulator = await _isIOSSimulator();

  if (isSimulator) {
    print("⚠️ Ejecutando en simulador iOS → usando token FCM simulado");
    await sendTokenToServer("SIMULATOR_TOKEN");
    return; // ← ESTE RETURN ES LA CLAVE
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

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print("📩 Mensaje FCM recibido (foreground): ${message.notification?.title} - ${message.notification?.body}");

    // Extraer título y cuerpo
    final title = message.notification?.title ?? "Notificación";
    final body = message.notification?.body ?? "";

    // Mostrar notificación local en iOS / Android
    await flutterLocalNotificationsPlugin.show(
      message.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'class_reminders',
          'Recordatorios de Clases',
          channelDescription: 'Canal para recordatorios de clases',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,     // 👈 muestra alerta
          presentBadge: true,     // 👈 actualiza badge
          presentSound: true,     // 👈 reproduce sonido
        ),
      ),
    );

    print("🔔 Notificación mostrada en foreground");
  });


}
