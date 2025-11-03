import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

// =====================================
// 🌟 Solicitar permiso de rastreo (ATT)
// =====================================
Future<void> requestTrackingAuthorization() async {
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        await Future.delayed(const Duration(milliseconds: 150));
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    } catch (e) {
      // ignore
    }
  }
}
