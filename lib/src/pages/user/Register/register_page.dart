import 'package:amina_ec/src/pages/user/Register/register_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/color.dart';
import '../../../utils/iconos.dart';

class RegisterPage extends StatelessWidget {
  final RegisterController con = Get.put(RegisterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // HEADER animado
                _header()
                    .animate()
                    .fade(duration: 500.ms)
                    .slideY(begin: 0.3)
                    .then(delay: 150.ms),

                const SizedBox(height: 30),

                // TextFields animados con delay progresivo
                _textField("Correo Electrónico", con.emailController,
                        icon_email, TextInputType.emailAddress)
                    .animate(delay: 200.ms)
                    .fade()
                    .slideY(begin: 0.3),

                _textField("Nombre", con.nameController, icon_profile,
                        TextInputType.name)
                    .animate(delay: 350.ms)
                    .fade()
                    .slideY(begin: 0.3),

                _textField("Apellido", con.lastnameController,
                        icon_profile_invert, TextInputType.name)
                    .animate(delay: 500.ms)
                    .fade()
                    .slideY(begin: 0.3),

                _textField("Cédula", con.ciController, icon_ci,
                        TextInputType.number)
                    .animate(delay: 650.ms)
                    .fade()
                    .slideY(begin: 0.3),

                _textField("Teléfono", con.phoneController, icon_phone,
                        TextInputType.phone)
                    .animate(delay: 800.ms)
                    .fade()
                    .slideY(begin: 0.3),

                _passwordField("Contraseña", con.passwordController,
                        icon_password, con.obscurePassword)
                    .animate(delay: 950.ms)
                    .fade()
                    .slideY(begin: 0.3),

                _passwordField(
                        "Confirmar Contraseña",
                        con.confirmPasswordController,
                        icon_confirm_password,
                        con.obscureConfirmPassword)
                    .animate(delay: 1100.ms)
                    .fade()
                    .slideY(begin: 0.3),

                const SizedBox(height: 30),

                // Botón animado
                _buttonRegister(context)
                    .animate(delay: 1250.ms)
                    .fade()
                    .slideY(begin: 0.3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Registro de Usuario',
          style: GoogleFonts.poppins(
            color: almostBlack,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Completa tu información personal',
          style: GoogleFonts.poppins(
            color: Colors.black54,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _textField(String label, TextEditingController controller,
      IconData icon, TextInputType inputType) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        style: GoogleFonts.poppins(),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.black),
          labelStyle: GoogleFonts.poppins(color: Colors.black54),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }

  Widget _passwordField(String label, TextEditingController controller,
      IconData icon, RxBool toggleValue) {
    return Obx(() => Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: TextField(
            controller: controller,
            obscureText: toggleValue.value,
            keyboardType: TextInputType.visiblePassword,
            style: GoogleFonts.poppins(),
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon, color: Colors.black),
              suffixIcon: IconButton(
                icon: Icon(
                  toggleValue.value ? icon_close_eye : icon_open_eye,
                  color: Colors.black54,
                ),
                onPressed: () => toggleValue.value = !toggleValue.value,
              ),
              labelStyle: GoogleFonts.poppins(color: Colors.black54),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.black12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.black),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
          ),
        ));
  }

  Widget _buttonRegister(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: () => con.goToRegisterImage(),
        icon: Icon(icon_next, color: whiteLight),
        label: Text(
          'Siguiente',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: whiteLight,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: almostBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
        ),
      ),
    );
  }
}
