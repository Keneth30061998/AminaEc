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
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 40),
                  _titleLogin()
                      .animate()
                      .fade(duration: 500.ms)
                      .slideY(begin: 0.4),
                  const SizedBox(height: 30),
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
                  _buttonRecoverPassword(context)
                      .animate()
                      .fade()
                      .slideY(begin: 0.4, delay: 700.ms),
                  const SizedBox(height: 40),
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
      ),
    );
  }
}

Widget _titleLogin() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        txtTitleLogin1,
        style: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: almostBlack,
        ),
      ),
      Text(
        txtTitleLogin2,
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
    onChanged: (value) => con.emailText.value = value,
    keyboardType: TextInputType.emailAddress,
    decoration: InputDecoration(
      floatingLabelStyle: TextStyle(color: whiteGrey),
      labelText: txtEmail,
      hintText: txtEmail,
      prefixIcon: Icon(iconEmail),
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
      onChanged: (value) => con.passwordText.value = value,
      keyboardType: TextInputType.text,
      obscureText: con.obscureText.value,
      decoration: InputDecoration(
        floatingLabelStyle: TextStyle(color: whiteGrey),
        labelText: txtPassword,
        hintText: txtPassword,
        prefixIcon: Icon(iconPassword),
        suffixIcon: AnimatedSwitcher(
          duration: 300.ms,
          transitionBuilder: (child, anim) =>
              RotationTransition(turns: anim, child: child),
          child: IconButton(
            key: ValueKey<bool>(con.obscureText.value),
            icon: Icon(
              con.obscureText.value ? iconCloseEye : iconOpenEye,
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
              txtLogin,
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

Widget _buttonRecoverPassword(BuildContext context) {
  return Obx(() {
    final showRecover =
        con.emailText.value.isNotEmpty && con.passwordText.value.isEmpty;

    return Visibility(
      visible: showRecover,
      child: TextButton(
        onPressed: () => con.showRecoveryDialog(context),
        child: const Text(
          '¿Olvidaste tu contraseña?',
          style: TextStyle(
            color: indigoAmina,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  });
}

Widget _textDontHaveAccount() {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          txtNoCuenta,
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
            txtRegistrateAqui,
            style: TextStyle(
              color: indigoAmina,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
        ),
      ],
    ),
  );
}
