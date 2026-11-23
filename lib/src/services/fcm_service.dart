import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../globals.dart';
import '../environment/environment.dart';
import 'notification_navigation.dart';

bool _initialized = false, _registrationEnabled = true;
String? _pushToken;
String _lastRegistration = '';
Future<bool> _isIOSSimulator() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return false;
  try {
    return !(await DeviceInfoPlugin().iosInfo).isPhysicalDevice;
  } catch (_) {
    return false;
  }
}

Future<void> sendTokenToServer(String token) async {
  if (!_registrationEnabled || token.isEmpty || token.contains('SIMULATOR'))
    return;
  _pushToken = token;
  final user = GetStorage().read('user') ?? {};
  final jwt = '${user['session_token'] ?? ''}';
  if (jwt.isEmpty) return;
  final key = '${user['id']}:$jwt:$token';
  if (key == _lastRegistration) return;
  try {
    final response = await http
        .post(Uri.parse('${Environment.API_URL}api/notifications/token'),
            headers: {'Content-Type': 'application/json', 'Authorization': jwt},
            body: jsonEncode({'token': token}))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) _lastRegistration = key;
  } catch (_) {/* Se reintenta al iniciar sesión o al reanudar. */}
}

Future<void> registerCurrentPushToken() async {
  if ('${(GetStorage().read('user') ?? {})['session_token'] ?? ''}'.isEmpty)
    return;
  _registrationEnabled = true;
  if (await _isIOSSimulator()) return;
  try {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      String? apns;
      for (var i = 0; i < 6; i++) {
        apns = await FirebaseMessaging.instance.getAPNSToken();
        if (apns != null) break;
        await Future.delayed(const Duration(milliseconds: 500));
      }
      if (apns == null) return;
    }
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) await sendTokenToServer(token);
  } catch (_) {
    /* REST sigue permitiendo consultar y aceptar ofertas sin push. */
  }
}

Future<void> unregisterCurrentPushToken() async {
  _registrationEnabled = false;
  final user = GetStorage().read('user') ?? {}, token = _pushToken;
  _lastRegistration = '';
  _pushToken = null;
  if (token != null) {
    try {
      await http
          .delete(Uri.parse('${Environment.API_URL}api/notifications/token'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': '${user['session_token'] ?? ''}'
              },
              body: jsonEncode({'token': token}))
          .timeout(const Duration(seconds: 5));
    } catch (_) {}
  }
  try {
    if (!await _isIOSSimulator())
      await FirebaseMessaging.instance
          .deleteToken()
          .timeout(const Duration(seconds: 5));
  } catch (_) {}
}

Future<void> setupFCM() async {
  if (_initialized) return;
  _initialized = true;
  final messaging = FirebaseMessaging.instance;
  // Las escuchas no dependen del permiso ni del registro del dispositivo.
  messaging.onTokenRefresh.listen((token) {
    sendTokenToServer(token);
  });
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    handleNotificationData(message.data);
  });
  FirebaseMessaging.onMessage.listen((message) async {
    final expiry = DateTime.tryParse('${message.data['offer_expires_at']}');
    if (expiry != null && !expiry.isAfter(DateTime.now().toUtc())) return;
    await flutterLocalNotificationsPlugin.show(
        id: message.data['queue_id'] != null
            ? int.tryParse('${message.data['queue_id']}') ?? message.hashCode
            : message.hashCode,
        title: message.notification?.title ?? 'AMINA',
        body: message.notification?.body ?? '',
        notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
                classReminderChannel.id, classReminderChannel.name,
                channelDescription: classReminderChannel.description,
                importance: Importance.max,
                priority: Priority.high,
                playSound: true,
                icon: '@mipmap/launcher_icon'),
            iOS: const DarwinNotificationDetails(
                presentAlert: true, presentBadge: true, presentSound: true)),
        payload: jsonEncode(message.data));
  });
  final initial = await messaging.getInitialMessage();
  if (initial != null) handleNotificationData(initial.data);
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
    await messaging.setForegroundNotificationPresentationOptions(
        alert: false, badge: false, sound: false);
  }
  await messaging.requestPermission(alert: true, badge: true, sound: true);
  await registerCurrentPushToken();
}
