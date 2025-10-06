import 'package:amina_ec/src/components/Socket/socket_service.dart';
import 'package:amina_ec/src/components/events/coach_events.dart';
import 'package:amina_ec/src/models/user.dart';
import 'package:amina_ec/src/pages/Admin/Coach/Register/admin_coach_register_image_page.dart';
import 'package:amina_ec/src/pages/Admin/Coach/Register/admin_coach_register_page.dart';
import 'package:amina_ec/src/pages/Admin/Coach/Register/admin_coach_register_schedule_page.dart';
import 'package:amina_ec/src/pages/Admin/Coach/Update/Schedule/admin_coach_update_schedule_page.dart';
import 'package:amina_ec/src/pages/Admin/Coach/Update/admin_coach_update_page.dart';
import 'package:amina_ec/src/pages/Admin/Home/admin_home_page.dart';
import 'package:amina_ec/src/pages/Admin/Plan/Update/admin_plan_update_page.dart';
import 'package:amina_ec/src/pages/Coach/Home/coach_home_page.dart';
import 'package:amina_ec/src/pages/Login/login_page.dart';
import 'package:amina_ec/src/pages/LoginOrRegister/login_or_register_page.dart';
import 'package:amina_ec/src/pages/Roles/roles_page.dart';
import 'package:amina_ec/src/pages/Signature/signature_page.dart';
import 'package:amina_ec/src/pages/Splash/splash_page.dart';
import 'package:amina_ec/src/pages/user/Coach/Reserve/user_coach_reserve_page.dart';
import 'package:amina_ec/src/pages/user/Home/user_home_page.dart';
import 'package:amina_ec/src/pages/user/Plan/Buy/AddCard/user_plan_buy_addCard_webview_page.dart';
import 'package:amina_ec/src/pages/user/Plan/Buy/Resume/user_plan_buy_resume_page.dart';
import 'package:amina_ec/src/pages/user/Profile/Update/user_profile_update_page.dart';
import 'package:amina_ec/src/pages/user/Register/register_page.dart';
import 'package:amina_ec/src/pages/user/Register/register_page_image.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';

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

// =====================================
// 🌟 Inicialización de notificaciones locales
// =====================================
Future<void> initializeLocalNotifications() async {
  const AndroidInitializationSettings androidSettings =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(classReminderChannel);
}

// =====================================
// 🌟 Enviar token al backend
// =====================================
Future<void> sendTokenToServer(String token) async {
  if (userSession.id != null && token.isNotEmpty) {
    try {
      await http.post(
        Uri.parse(
            'https://api.pruebasinventario.com/api/notifications/token'),
        headers: {'Content-Type': 'application/json'},
        body: '{"user_id": ${userSession.id}, "token": "$token"}',
      );
    } catch (e) {
      //print('❌ Error enviando token al backend: $e');
    }
  }
}

Future<bool> _isIOSSimulator() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return false;
  try {
    final deviceInfo = await DeviceInfoPlugin().iosInfo;
    return deviceInfo.name.toLowerCase().contains('simulator');
  } catch (_) {
    return false;
  }
}

Future<void> setupFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional) {
    final isSimulator = await _isIOSSimulator();

    if (!isSimulator) {
      try {
        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
          final apnsToken = await messaging.getAPNSToken();
          print('✅ APNS Token: $apnsToken');
        }

        final fcmToken = await messaging.getToken();
        if (fcmToken != null) await sendTokenToServer(fcmToken);

        FirebaseMessaging.instance.onTokenRefresh
            .listen((updatedToken) async {
          await sendTokenToServer(updatedToken);
        });
      } catch (e) {
        //print('⚠️ Error configurando FCM: $e');
      }
    } else {
      //print('⚠️ Ignorando FCM/APNS token en iOS simulador');
    }
  }

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      flutterLocalNotificationsPlugin.show(
        message.hashCode,
        message.notification!.title,
        message.notification!.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            classReminderChannel.id,
            classReminderChannel.name,
            channelDescription: classReminderChannel.description,
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            icon: '@mipmap/ic_launcher',
            color: const Color(0xFF1D1C21),
            styleInformation:
            BigTextStyleInformation(message.notification!.body ?? ''),
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );
    }
  });
}

// =====================================
// 🌟 Función principal
// =====================================
void main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(CoachEvents());
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp]);
  await initializeDateFormatting('es_ES', null);
  await initializeLocalNotifications();
  await setupFCM();

  if (userSession.session_token != null &&
      userSession.session_token!.isNotEmpty) {
    print("📲 [main.dart] Conectando SocketService por token existente");
    SocketService().connect();
  }

  runApp(const MyApp());
}

// =====================================
// 🌟 Clase MyApp
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
      title: 'Amina EC',
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
        textTheme:
        const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: userSession.id != null
          ? (userSession.roles != null &&
          userSession.roles!.isNotEmpty
          ? (userSession.roles!.length > 1
          ? '/roles'
          : userSession.roles!.first.id != '3'
          ? '/user/home'
          : '/coach/home')
          : '/splash')
          : '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => SplashPage()),
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(
            name: '/login-register', page: () => LoginOrRegisterPage()),
        GetPage(name: '/register', page: () => RegisterPage()),
        GetPage(
            name: '/register-image', page: () => RegisterPageImage()),
        GetPage(name: '/roles', page: () => RolesPage()),
        GetPage(
            name: '/signature', page: () => SignaturePage()),
        GetPage(name: '/user/home', page: () => UserHomePage()),
        GetPage(
            name: '/user/profile/update',
            page: () => UserProfileUpdatePage()),
        GetPage(
            name: '/user/plan/buy/addCard',
            page: () => AddCardWebViewPage()),
        GetPage(
            name: '/user/plan/buy/resume',
            page: () => UserPlanBuyResumePage()),
        GetPage(
            name: '/user/coach/reserve',
            page: () => UserCoachReservePage()),
        GetPage(name: '/coach/home', page: () => CoachHomePage()),
        GetPage(name: '/admin/home', page: () => AdminHomePage()),
        GetPage(
            name: '/admin/coach/register',
            page: () => AdminCoachRegisterPage()),
        GetPage(
            name: '/admin/coach/register-image',
            page: () => AdminCoachRegisterImagePage()),
        GetPage(
            name: '/admin/coach/register-schedule',
            page: () => AdminCoachRegisterSchedulePage()),
        GetPage(
            name: '/admin/coach/update',
            page: () => AdminCoachUpdatePage()),
        GetPage(
            name: '/admin/coach/update/schedule',
            page: () => AdminCoachUpdateSchedulePage()),
        GetPage(
            name: '/admin/plans/update',
            page: () => AdminPlanUpdatePage())
      ],
    );
  }
}