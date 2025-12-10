import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../utils/color.dart';
import '../../../../../utils/iconos.dart';
import 'admin_sponsor_register_controller.dart';

class AdminSponsorRegisterPage extends StatelessWidget {
  final controller = Get.put(AdminSponsorRegisterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteLight,
      appBar: AppBar(
        title: Text(
          'Registrar Beneficio',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w900,
            color: almostBlack,
          ),
        ),
        backgroundColor: whiteLight,
        surfaceTintColor: whiteLight,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 12),
              _textField("Nombre del beneficio", controller.nameController, iconProfile),
              _textField("Descripción", controller.descriptionController, iconDescription, maxLines: 3),
              const SizedBox(height: 4),
              _prioritySelector(),
              const SizedBox(height: 12),
              _targetSelector(), // 🔥 NUEVO
              const SizedBox(height: 12),
              _imagePicker(context),
              const SizedBox(height: 28),
              _submitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // HEADER
  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Nuevo Beneficio",
          style: GoogleFonts.poppins(
            fontSize: 26,
            color: almostBlack,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Ingresa la información del sponsor/beneficio",
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  // TEXT FIELD
  Widget _textField(String label, TextEditingController controller, IconData icon,
      {int maxLines = 1}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.poppins(),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.black),
          labelStyle: GoogleFonts.poppins(color: Colors.black54),
          floatingLabelStyle: GoogleFonts.poppins(color: almostBlack),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: almostBlack)),
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        ),
      ),
    );
  }

  // PRIORIDAD
  Widget _prioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tamaño del card",
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black38),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _chip(1, "Grande"),
            const SizedBox(width: 10),
            _chip(2, "Mediana"),
            const SizedBox(width: 10),
            _chip(3, "Pequeña"),
          ],
        ),
      ],
    );
  }

  Widget _chip(int value, String label) {
    return Obx(() {
      return ChoiceChip(
        label: Text(label),
        selected: controller.priority.value == value,
        labelStyle: GoogleFonts.poppins(
          color: controller.priority.value == value ? Colors.white : almostBlack,
        ),
        selectedColor: indigoAmina,
        onSelected: (_) => controller.priority.value = value,
        backgroundColor: colorBackgroundBox,
        elevation: controller.priority.value == value ? 4 : 0,
      );
    });
  }

  // 🔥 SELECTOR DE TARGET
  Widget _targetSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Dirigido a",
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black38),
        ),
        const SizedBox(height: 8),
        Obx(() {
          return Row(
            children: [
              _targetChip("student", "Estudiantes"),
              const SizedBox(width: 10),
              _targetChip("coach", "Coaches"),
              const SizedBox(width: 10),
              _targetChip("both", "Ambos"),
            ],
          );
        })
      ],
    );
  }

  Widget _targetChip(String value, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: controller.target.value == value,
      labelStyle: GoogleFonts.poppins(
        color: controller.target.value == value ? Colors.white : almostBlack,
      ),
      selectedColor: indigoAmina,
      onSelected: (_) => controller.target.value = value,
      backgroundColor: colorBackgroundBox,
      elevation: controller.target.value == value ? 4 : 0,
    );
  }

  // IMAGE PICKER
  Widget _imagePicker(BuildContext context) {
    return Obx(() {
      return GestureDetector(
        onTap: () => controller.selectImage(ImageSource.gallery),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black12),
            image: controller.imageFile.value != null
                ? DecorationImage(
              image: FileImage(controller.imageFile.value!),
              fit: BoxFit.cover,
            )
                : null,
          ),
          child: controller.imageFile.value == null
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt_outlined,
                  size: 48, color: Colors.black45),
              const SizedBox(height: 10),
              Text(
                "Subir imagen del beneficio",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.black45,
                ),
              )
            ],
          )
              : null,
        ),
      );
    });
  }

  // BOTÓN
  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () => controller.registerSponsor(Get.context!),
        style: ElevatedButton.styleFrom(
          backgroundColor: almostBlack,
          foregroundColor: whiteLight,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        child: const Text("Registrar Beneficio"),
      ),
    );
  }
}
