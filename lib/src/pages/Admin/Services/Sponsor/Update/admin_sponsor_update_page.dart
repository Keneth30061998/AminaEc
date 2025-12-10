import 'dart:io';
import 'package:amina_ec/src/utils/iconos.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../utils/color.dart';
import 'admin_sponsor_update_controller.dart';

class AdminSponsorUpdatePage extends StatelessWidget {
  final AdminSponsorUpdateController con =
  Get.put(AdminSponsorUpdateController());

  AdminSponsorUpdatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: _appBarTitle()),
      body: GetBuilder<AdminSponsorUpdateController>(
        builder: (_) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 30),
          child: Column(
            children: [
              GestureDetector(
                onTap: con.pickImage,
                child: con.imageFile != null
                    ? Image.file(con.imageFile!, height: 150)
                    : con.sponsor.image != null
                    ? Image.network(con.sponsor.image!, height: 150)
                    : Container(
                  height: 150,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 50),
                ),
              ),
              const SizedBox(height: 16),

              _textFieldName(),
              _textFieldDescription(),
              const SizedBox(height: 10),

              _prioritySelector(),
              const SizedBox(height: 20),

              /// 🔥 NUEVO: selector de target
              _targetSelector(),
              const SizedBox(height: 20),

              _buttonUpdate(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appBarTitle() {
    return Text(
      'Editar Sponsor',
      style: GoogleFonts.montserrat(
        fontSize: 22,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _textFieldName() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: con.nameController,
        decoration: InputDecoration(
          floatingLabelStyle: TextStyle(color: darkGrey),
          labelText: "Nombre",
          prefixIcon: const Icon(iconGift),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: darkGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: darkGrey),
          ),
        ),
      ),
    );
  }

  Widget _textFieldDescription() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: con.descriptionController,
        maxLines: 2,
        decoration: InputDecoration(
          floatingLabelStyle: TextStyle(color: darkGrey),
          labelText: "Descripción",
          prefixIcon: const Icon(iconDescription),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: darkGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: darkGrey),
          ),
        ),
      ),
    );
  }

  Widget _prioritySelector() {
    return Obx(() {
      return Row(
        children: [
          _chip(1, "Grande"),
          const SizedBox(width: 10),
          _chip(2, "Mediana"),
          const SizedBox(width: 10),
          _chip(3, "Pequeña"),
        ],
      );
    });
  }

  Widget _chip(int value, String label) {
    final selected = con.priority.value == value;

    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.poppins(
          color: selected ? Colors.white : Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: selected,
      onSelected: (_) => con.priority.value = value,
      selectedColor: indigoAmina,
      backgroundColor: Colors.grey[200],
    );
  }

  /// 🔥 SELECTOR DE TARGET (igual estilo que priority)
  Widget _targetSelector() {
    return Obx(
          () => Row(
        children: [
          _targetChip("student", "Estudiantes"),
          const SizedBox(width: 10),
          _targetChip("coach", "Coaches"),
          const SizedBox(width: 10),
          _targetChip("both", "Ambos"),
        ],
      ),
    );
  }

  Widget _targetChip(String value, String label) {
    final selected = con.target.value == value;

    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.poppins(
          color: selected ? Colors.white : Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: selected,
      onSelected: (_) => con.target.value = value,
      selectedColor: indigoAmina,
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buttonUpdate(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      width: double.infinity,
      height: 50,
      child: FloatingActionButton.extended(
        onPressed: con.updateSponsor,
        label: Text(
          'Actualizar',
          style: const TextStyle(
            fontSize: 16,
            color: whiteLight,
            fontWeight: FontWeight.w700,
          ),
        ),
        icon: const Icon(iconSave, color: whiteLight),
        backgroundColor: almostBlack,
      ),
    );
  }
}
