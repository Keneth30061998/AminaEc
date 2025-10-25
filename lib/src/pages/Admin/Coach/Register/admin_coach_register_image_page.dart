import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../utils/color.dart';
import 'admin_coach_register_controller.dart';


class AdminCoachRegisterImagePage extends StatelessWidget {
  final AdminCoachRegisterController controller =
  Get.find<AdminCoachRegisterController>();

  AdminCoachRegisterImagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteLight,
      appBar: AppBar(
        title: const Text('Registrar Coach - Imagen'),
        backgroundColor: whiteLight,
        elevation: 0,
        foregroundColor: almostBlack,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // HEADER
                Text(
                  'Foto de Perfil del Coach',
                  style: GoogleFonts.poppins(
                      color: almostBlack,
                      fontSize: 24,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),

                // FOTO CIRCULAR
                _buildImagePicker(context).animate().fade().slideY(begin: 0.2),

                const SizedBox(height: 30),

                // CAMPOS ADICIONALES
                Obx(() => controller.addPersonalData.value
                    ? Column(
                  children: [
                    _buildTextField(
                        label: 'Hobby',
                        controller: controller.hobbyController)
                        .animate(delay: 200.ms).fade().slideY(begin: 0.3),
                    _buildTextField(
                        label: 'Descripción',
                        controller: controller.descriptionController)
                        .animate(delay: 350.ms).fade().slideY(begin: 0.3),
                    _buildTextField(
                        label: 'Presentación',
                        controller: controller.presentationController)
                        .animate(delay: 500.ms).fade().slideY(begin: 0.3),
                  ],
                )
                    : const SizedBox.shrink()),

                const SizedBox(height: 20),

                // SWITCH PARA ACTIVAR CAMPOS ADICIONALES
                Obx(() => SwitchListTile(
                  title: Text(
                    'Agregar datos personales adicionales',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                  value: controller.addPersonalData.value,
                  onChanged: (value) =>
                  controller.addPersonalData.value = value,
                )),

                const SizedBox(height: 30),

                // BOTÓN REGISTRAR
                _buttonRegister(context).animate(delay: 600.ms).fade().slideY(begin: 0.3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Obx(() => CircleAvatar(
          radius: 75,
          backgroundColor: Colors.grey[300],
          backgroundImage: controller.imageFile.value != null
              ? FileImage(controller.imageFile.value!)
              : null,
          child: controller.imageFile.value == null
              ? const Icon(Icons.person, size: 80)
              : null,
        )),
        Positioned(
          bottom: 4,
          right: 4,
          child: InkWell(
            onTap: () => controller.showAlertDialog(context),
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: const Icon(Icons.edit, size: 20, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
      {required String label, required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        style: GoogleFonts.poppins(),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.black54),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black)),
          contentPadding:
          const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buttonRegister(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () => controller.registerCoach(),
        style: ElevatedButton.styleFrom(
          backgroundColor: almostBlack,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 4,
        ),
        child: Text(
          'Registrar Coach',
          style: GoogleFonts.poppins(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
