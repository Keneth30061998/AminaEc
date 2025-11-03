import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'globals.dart';
import 'src/components/Socket/socket_service.dart';
import 'src/components/events/coach_events.dart';
import 'src/pages/maintenance/maintenance_page.dart';
import 'src/routes/app_routes.dart';
import 'src/utils/color.dart';

// Servicios separados
import 'src/services/fcm_service.dart';
import 'src/services/notifications_service.dart';
import 'src/services/app_config_service.dart';
import 'src/services/att_service.dart';

// =====================================
// 🌟 Variables Globales
// =====================================


// =====================================
// 🌟 Función principal
// =====================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  Get.put(CoachEvents());

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await initializeDateFormatting('es_ES', null);
  await initializeLocalNotifications();

  // FCM y ATT
  await setupFCM();
  await Future.delayed(const Duration(seconds: 3));
  await requestTrackingAuthorization();

  // Conectar sockets solo si hay session_token
  if (userSession.session_token != null &&
      userSession.session_token!.isNotEmpty) {
    SocketService().connect();
  }

  // Consultamos el estado remoto antes de construir la UI
  final remoteCfg = await fetchRemoteAppConfig();
  final bool isMaintenance = remoteCfg['maintenance'] == true;
  final String maintenanceTitle = remoteCfg['title'] ?? 'Mantenimiento';
  final String maintenanceMessage =
      remoteCfg['message'] ?? 'La app está en mantenimiento.';
  final String maintenanceEstimated = remoteCfg['estimated_time'] ?? '';

  runApp(MyAppBootstrap(
    isMaintenance: isMaintenance,
    title: maintenanceTitle,
    message: maintenanceMessage,
    estimatedTime: maintenanceEstimated,
  ));
}

// =====================================
// 🌟 MyAppBootstrap decide si mostrar MaintenancePage o la app normal
// =====================================
class MyAppBootstrap extends StatelessWidget {
  final bool isMaintenance;
  final String title;
  final String message;
  final String estimatedTime;

  const MyAppBootstrap({
    super.key,
    required this.isMaintenance,
    required this.title,
    required this.message,
    required this.estimatedTime,
  });

  @override
  Widget build(BuildContext context) {
    if (isMaintenance) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MaintenancePage(
          title: title,
          message: message,
          estimatedTime: estimatedTime,
        ),
      );
    }

    // No maintenance -> app normal
    return const MyApp();
  }
}

// =====================================
// 🌟 Clase MyApp (sin modificar tu flujo)
// =====================================
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Amina',
      theme: ThemeData(
        timePickerTheme: TimePickerThemeData(
          helpTextStyle: GoogleFonts.montserrat(
            color: almostBlack,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: whiteLight),
        useMaterial3: true,
        scaffoldBackgroundColor: whiteLight,
        textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: userSession.id != null
          ? (userSession.roles != null && userSession.roles!.isNotEmpty
          ? (userSession.roles!.length > 1
          ? '/roles'
          : userSession.roles!.first.id != '3'
          ? '/user/home'
          : '/coach/home')
          : '/splash')
          : '/splash',
      getPages: appRoutes,
    );
  }
}
