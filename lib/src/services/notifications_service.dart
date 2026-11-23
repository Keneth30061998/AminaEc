import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../globals.dart';
import 'notification_navigation.dart';
void _handlePayload(String? payload){
  if(payload==null||payload.isEmpty)return;
  try{final data=jsonDecode(payload);if(data is Map)handleNotificationData(Map<String,dynamic>.from(data));}catch(_){}
}
Future<void> initializeLocalNotifications() async {
  const settings=InitializationSettings(android:AndroidInitializationSettings('@mipmap/launcher_icon'),
      iOS:DarwinInitializationSettings(requestAlertPermission:false,requestBadgePermission:false,requestSoundPermission:false));
  await flutterLocalNotificationsPlugin.initialize(settings:settings,
      onDidReceiveNotificationResponse:(response)=>_handlePayload(response.payload));
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(classReminderChannel);
  final details=await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  if(details?.didNotificationLaunchApp==true)_handlePayload(details?.notificationResponse?.payload);
}
