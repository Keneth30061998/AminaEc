import 'dart:io';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'admin_coach_update_controller.dart';

// --- Input Formatters ---
final onlyLettersNoSpacesFormatter = FilteringTextInputFormatter.allow(
  RegExp(r'[A-Za-zÁÉÍÓÚáéíóúÑñ]+'),
);

final onlyNumbersFormatter = FilteringTextInputFormatter.allow(RegExp(r'[0-9]'));

final noEmojisFormatter = FilteringTextInputFormatter.allow(
  RegExp(r"[A-Za-zÁÉÍÓÚáéíóúÑñ0-9 .,\-_/()!¡¿?]+"),
);

class AdminCoachUpdatePage extends StatelessWidget {
  final AdminCoachUpdateController con = Get.put(AdminCoachUpdateController());

  AdminCoachUpdatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteLight,
        shadowColor: whiteLight,
        surfaceTintColor: whiteLight,
        forceMaterialTransparency: true,
      ),
      backgroundColor: whiteLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                _header()
                    .animate()
                    .fade(duration: 450.ms)
                    .slideY(begin: 0.3),

                const SizedBox(height: 25),

                _photoSection(context)
                    .animate(delay: 200.ms)
                    .fade()
                    .slideY(begin: 0.3),

                const SizedBox(height: 25),

                _textField(
                  "Nombre",
                  con.nameController,
                  Icons.person,
                  inputFormatters: [onlyLettersNoSpacesFormatter],
                ).animate(delay: 300.ms).fade().slideY(begin: 0.3),

                _textField(
                  "Apellido",
                  con.lastnameController,
                  Icons.person_outline,
                  inputFormatters: [onlyLettersNoSpacesFormatter],
                ).animate(delay: 450.ms).fade().slideY(begin: 0.3),

                _textField(
                  "Cédula",
                  con.ciController,
                  Icons.assignment_ind,
                  keyboardType: TextInputType.number,
                  inputFormatters: [onlyNumbersFormatter],
                ).animate(delay: 600.ms).fade().slideY(begin: 0.3),

                _textField(
                  "Teléfono",
                  con.phoneController,
                  Icons.phone_android,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [onlyNumbersFormatter],
                ).animate(delay: 750.ms).fade().slideY(begin: 0.3),

                _textField(
                  "Hobby",
                  con.hobbyController,
                  Icons.gamepad,
                  inputFormatters: [noEmojisFormatter],
                ).animate(delay: 900.ms).fade().slideY(begin: 0.3),

                _textField(
                  "Descripción",
                  con.descriptionController,
                  Icons.description,
                  maxLines: 2,
                  inputFormatters: [noEmojisFormatter],
                ).animate(delay: 1050.ms).fade().slideY(begin: 0.3),

                _textField(
                  "Presentación",
                  con.presentationController,
                  Icons.subject,
                  maxLines: 3,
                  inputFormatters: [noEmojisFormatter],
                ).animate(delay: 1200.ms).fade().slideY(begin: 0.3),

                const SizedBox(height: 25),

                _buttonSave(context)
                    .animate(delay: 1350.ms)
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
      children: [
        Text(
          'Editar Datos del Coach',
          style: GoogleFonts.poppins(
            color: almostBlack,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Actualiza la información del coach',
          style: GoogleFonts.poppins(
            color: Colors.black54,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _photoSection(BuildContext context) {
    return Column(
      children: [
        GetBuilder<AdminCoachUpdateController>(
          builder: (_) => CircleAvatar(
            radius: 55,
            backgroundColor: darkGrey,
            backgroundImage: con.imageFile != null
                ? FileImage(con.imageFile!)
                : (con.coach.user?.photo_url != null
                ? NetworkImage(con.coach.user!.photo_url!)
                : const AssetImage('assets/img/user_photo1.png'))
            as ImageProvider,
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => con.showAlertDialog(context),
          child: Text(
            "Cambiar foto",
            style: GoogleFonts.poppins(
              color: almostBlack,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _textField(
      String label,
      TextEditingController controller,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
        List<TextInputFormatter>? inputFormatters,
        int maxLines = 1,
      }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        inputFormatters: inputFormatters,
        style: GoogleFonts.poppins(),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.black),
          labelStyle: GoogleFonts.poppins(color: Colors.black54),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buttonSave(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: FloatingActionButton.extended(
        onPressed: () {
          // --- Si están vacíos, reemplazar por "..." automáticamente ---
          if (con.hobbyController.text.trim().isEmpty) {
            con.hobbyController.text = "...";
          }
          if (con.descriptionController.text.trim().isEmpty) {
            con.descriptionController.text = "...";
          }
          if (con.presentationController.text.trim().isEmpty) {
            con.presentationController.text = "...";
          }

          con.updateCoach(context);
        },
        label: const Text(
          'Guardar Cambios',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        icon: const Icon(Icons.save, color: Colors.white),
        backgroundColor: almostBlack,
      ),
    );
  }
}
