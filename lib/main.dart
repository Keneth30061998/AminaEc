import 'package:amina_ec/src/models/user.dart';
import 'package:amina_ec/src/pages/Admin/Home/admin_home_page.dart';
import 'package:amina_ec/src/pages/Coach/Home/coach_home_page.dart';
import 'package:amina_ec/src/pages/Login/login_page.dart';
import 'package:amina_ec/src/pages/LoginOrRegister/login_or_register_page.dart';
import 'package:amina_ec/src/pages/Roles/roles_page.dart';
import 'package:amina_ec/src/pages/Splash/splash_page.dart';
import 'package:amina_ec/src/pages/user/Home/user_home_page.dart';
import 'package:amina_ec/src/pages/user/Profile/Update/user_profile_update_page.dart';
import 'package:amina_ec/src/pages/user/Register/register_page.dart';
import 'package:amina_ec/src/pages/user/Register/register_page_image.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

//para mantener abierta la session despues de login
User userSession = User.fromJson(GetStorage().read('user') ?? {});

void main() async {
  await GetStorage.init();
  //Get.put(UserProfileInfoController());
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
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: limeGreen),
        useMaterial3: true,
        scaffoldBackgroundColor: darkGrey,
        textTheme: const TextTheme(
          bodyMedium:
              TextStyle(color: Colors.white), // color global para textos
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: userSession.id != null
          ? userSession.roles!.length > 1
              ? '/roles'
              : '/user/home'
          : '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => SplashPage()),
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/login-register', page: () => LoginOrRegisterPage()),
        GetPage(name: '/register', page: () => RegisterPage()),
        GetPage(name: '/register-image', page: () => RegisterPageImage()),
        GetPage(name: '/roles', page: () => RolesPage()),
        //usuario
        GetPage(name: '/user/home', page: () => UserHomePage()),
        GetPage(
            name: '/user/profile/update', page: () => UserProfileUpdatePage()),
        //coach
        GetPage(name: '/coach/home', page: () => CoachHomePage()),
        //admin
        GetPage(name: '/admin/home', page: () => AdminHomePage()),
      ],
    );
  }
}
