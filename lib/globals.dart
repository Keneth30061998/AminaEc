import 'package:amina_ec/src/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:get_storage/get_storage.dart';

// =====================================
// 🌟 Variables Globales
// =====================================
User userSession = User.fromJson(GetStorage().read('user') ?? {});
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

// --- Canal personalizado para recordatorios ---
const AndroidNotificationChannel classReminderChannel =
AndroidNotificationChannel(
  'class_reminders',
  'Recordatorios de Clases',
  description: 'Canal para recordatorios de clases',
  importance: Importance.max,
  playSound: true,
  ledColor: Color(0xFF1D1C21),
);
