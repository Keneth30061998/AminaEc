import 'package:amina_ec/src/components/Socket/socket_service.dart';
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
import 'package:amina_ec/src/pages/user/Plan/Buy/Resume/user_plan_buy_resume_page.dart';
import 'package:amina_ec/src/pages/user/Plan/Buy/WebView/user_plan_web_view_page.dart';
import 'package:amina_ec/src/pages/user/Plan/Buy/user_plan_buy_page.dart';
import 'package:amina_ec/src/pages/user/Profile/Update/user_profile_update_page.dart';
import 'package:amina_ec/src/pages/user/Register/register_page.dart';
import 'package:amina_ec/src/pages/user/Register/register_page_image.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';

//para mantener abierta la session despues de login
User userSession = User.fromJson(GetStorage().read('user') ?? {});

void main() async {
  await GetStorage.init();
  //Get.put(UserProfileInfoController());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // Solo modo vertical hacia arriba
  ]);
  await initializeDateFormatting('es_ES', null);
  if (userSession.session_token != null &&
      userSession.session_token!.isNotEmpty) {
    SocketService().connect(); // conecta automáticamente con token guardado
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('Token de session del usuario: ${userSession.session_token}');
  }

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
        textTheme: const TextTheme(
          bodyMedium:
              TextStyle(color: Colors.white), // color global para textos
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: userSession.id != null
          ? userSession.roles!.length > 1
              ? '/roles'
              : userSession.roles!.first.id != '3'
                  ? '/user/home'
                  : '/coach/home'
          : '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => SplashPage()),
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/login-register', page: () => LoginOrRegisterPage()),
        GetPage(name: '/register', page: () => RegisterPage()),
        GetPage(name: '/register-image', page: () => RegisterPageImage()),
        GetPage(name: '/roles', page: () => RolesPage()),
        GetPage(name: '/signature', page: () => SignaturePage()),
        //usuario
        GetPage(name: '/user/home', page: () => UserHomePage()),
        GetPage(
            name: '/user/profile/update', page: () => UserProfileUpdatePage()),
        GetPage(name: '/user/plan/buy', page: () => UserPlanBuyPage()),
        GetPage(name: '/user/plan/buy/webview', page: () => WebviewPage()),
        GetPage(
            name: '/user/plan/buy/resume', page: () => UserPlanBuyResumePage()),
        GetPage(
            name: '/user/coach/reserve', page: () => UserCoachReservePage()),
        //coach
        GetPage(name: '/coach/home', page: () => CoachHomePage()),
        //admin
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
            name: '/admin/coach/update', page: () => AdminCoachUpdatePage()),
        GetPage(
            name: '/admin/coach/update/schedule',
            page: () => AdminCoachUpdateSchedulePage()),
        GetPage(name: '/admin/plans/update', page: () => AdminPlanUpdatePage())
      ],
    );
  }
}
