import 'package:amina_ec/src/models/user.dart';
import 'package:amina_ec/src/pages/Login/login_page.dart';
import 'package:amina_ec/src/pages/LoginOrRegister/login_or_register_page.dart';
import 'package:amina_ec/src/pages/Splash/splash_page.dart';
import 'package:amina_ec/src/pages/home/home_page.dart';
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
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      initialRoute: userSession.id != null ? '/home' : '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => SplashPage()),
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/login-register', page: () => LoginOrRegisterPage()),
        GetPage(name: '/register', page: () => RegisterPage()),
        GetPage(name: '/register-image', page: () => RegisterPageImage()),
        GetPage(name: '/home', page: () => HomePage())
      ],
    );
  }
}
