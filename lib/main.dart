import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'globals.dart';

// Servicios / configuración
import 'src/components/Socket/socket_service.dart';
import 'src/components/events/coach_events.dart';
import 'src/pages/maintenance/maintenance_page.dart';
import 'src/routes/app_routes.dart';
import 'src/utils/color.dart';

import 'src/services/fcm_service.dart';
import 'src/services/notifications_service.dart';
import 'src/services/app_config_service.dart';
import 'src/services/att_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  Get.put(CoachEvents());

  // =====================================
  // 1️⃣ Inicializar Firebase
  // =====================================
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // =====================================
  // 2️⃣ Simular versión antigua: Delay antes de ATT
  // Solo en iOS, ayuda a que el cuadro ATT aparezca
  // =====================================
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    await Future.delayed(const Duration(seconds: 3));
  }

  // Solicitar permiso ATT
  await requestTrackingAuthorization();

  // =====================================
  // 3️⃣ Inicializar notificaciones locales
  // =====================================
  await initializeLocalNotifications();

  // =====================================
  // 4️⃣ Inicializar FCM
  // =====================================
  await setupFCM();

  // =====================================
  // 5️⃣ Configuraciones generales
  // =====================================
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await initializeDateFormatting('es_ES', null);

  // Conectar sockets solo si hay session_token
  if (userSession.session_token != null &&
      userSession.session_token!.isNotEmpty) {
    SocketService().connect();
  }

  // =====================================
  // 6️⃣ Consultar configuración remota (mantenimiento)
  // =====================================
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

    return const MyApp();
  }
}

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
