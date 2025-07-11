import 'package:amina_ec/src/pages/Login/login_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:amina_ec/src/utils/textos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/iconos.dart';

LoginController con = Get.put(LoginController());

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: whiteLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: height * 0.9,
            child: Column(
              children: [
                const Spacer(),
                _titleLogin()
                    .animate()
                    .fade(duration: 500.ms)
                    .slideY(begin: 0.4),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      _textFieldEmail()
                          .animate()
                          .fade()
                          .slideY(begin: 0.4, delay: 200.ms),
                      const SizedBox(height: 20),
                      _textFieldPassword()
                          .animate()
                          .fade()
                          .slideY(begin: 0.4, delay: 400.ms),
                      const SizedBox(height: 30),
                      _buttonLogin(context)
                          .animate()
                          .fade()
                          .slideY(begin: 0.4, delay: 600.ms),
                    ],
                  ),
                ),
                const Spacer(),
                _textDontHaveAccount()
                    .animate()
                    .fade(duration: 400.ms)
                    .slideY(begin: 0.3, delay: 800.ms),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _titleLogin() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        txt_title_login_1,
        style: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: almostBlack,
        ),
      ),
      Text(
        txt_title_login_2,
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Colors.black54,
        ),
      ),
    ],
  );
}

Widget _textFieldEmail() {
  return TextField(
    controller: con.emailController,
    keyboardType: TextInputType.emailAddress,
    decoration: InputDecoration(
      floatingLabelStyle: TextStyle(color: whiteGrey),
      labelText: txt_email,
      hintText: txt_email,
      prefixIcon: Icon(icon_email),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: indigoAmina),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: indigoAmina),
      ),
    ),
  );
}

Widget _textFieldPassword() {
  return Obx(
    () => TextField(
      controller: con.passwordController,
      keyboardType: TextInputType.text,
      obscureText: con.obscureText.value,
      decoration: InputDecoration(
        floatingLabelStyle: TextStyle(color: whiteGrey),
        labelText: txt_password,
        hintText: txt_password,
        prefixIcon: Icon(icon_password),
        suffixIcon: AnimatedSwitcher(
          duration: 300.ms,
          transitionBuilder: (child, anim) =>
              RotationTransition(turns: anim, child: child),
          child: IconButton(
            key: ValueKey<bool>(con.obscureText.value),
            icon: Icon(
              con.obscureText.value ? icon_close_eye : icon_open_eye,
              color: whiteGrey,
            ),
            onPressed: () {
              con.obscureText.value = !con.obscureText.value;
            },
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: indigoAmina),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: indigoAmina),
        ),
      ),
    ),
  );
}

Widget _buttonLogin(BuildContext context) {
  return Obx(() {
    double scale = con.isPressed.value ? 0.96 : 1.0;
    return GestureDetector(
      onTapDown: (_) => con.isPressed.value = true,
      onTapUp: (_) {
        con.isPressed.value = false;
        con.login(context);
      },
      onTapCancel: () => con.isPressed.value = false,
      child: AnimatedScale(
        scale: scale,
        duration: 120.ms,
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () => con.login(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: almostBlack,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
            ),
            child: const Text(
              txt_login,
              style: TextStyle(
                color: whiteLight,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  });
}

Widget _textDontHaveAccount() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text(
        txt_no_cuenta,
        style: TextStyle(
          fontSize: 16,
          color: darkGrey,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(width: 10),
      GestureDetector(
        onTap: () => con.goToRegisterPage(),
        child: const Text(
          txt_registrate_aqui,
          style: TextStyle(
            color: indigoAmina,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
    ],
  );
}
