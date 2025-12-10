import 'dart:convert';
import 'dart:io';

import 'package:amina_ec/src/components/Compress/image_compress_util.dart';
import 'package:amina_ec/src/models/sponsor.dart';
import 'package:amina_ec/src/providers/sponsor_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AdminSponsorUpdateController extends GetxController {
  final SponsorProvider sponsorProvider = SponsorProvider();
  Sponsor sponsor = Get.arguments['sponsor'];

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  RxInt priority = 3.obs;

  /// 🔥 NUEVO: target del sponsor
  RxString target = "student".obs;

  File? imageFile;
  final picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();

    nameController.text = sponsor.name ?? '';
    descriptionController.text = sponsor.description ?? '';
    priority.value = sponsor.priority ?? 3;

    // 🔥 IMPORTANTE: cargar target actual del sponsor
    target.value = sponsor.target ?? "student";
  }

  // -------------------------------------------
  // SELECCIONAR IMAGEN + COMPRESIÓN
  // -------------------------------------------
  Future pickImage() async {
    XFile? picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      File file = File(picked.path);

      Get.dialog(
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const CircularProgressIndicator(color: Colors.white),
          ),
        ),
        barrierDismissible: false,
      );

      try {
        final compressed = await ImageCompressUtil.compress(input: file);
        imageFile = compressed;
      } finally {
        Get.back();
      }

      update();
    }
  }

  // -------------------------------------------
  // UPDATE SPONSOR COMPLETO
  // -------------------------------------------
  Future updateSponsor() async {
    String name = nameController.text.trim();
    String description = descriptionController.text.trim();

    if (name.isEmpty || description.isEmpty) {
      Get.snackbar("Error", "Todos los campos son obligatorios");
      return;
    }

    sponsor.name = name;
    sponsor.description = description;
    sponsor.priority = priority.value;
    sponsor.target = target.value; // 🔥 NUEVO

    // loader
    Get.dialog(
      Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const CircularProgressIndicator(color: Colors.white),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      if (imageFile != null) {
        Stream stream = await sponsorProvider.updateWithImage(sponsor, imageFile!);

        await for (var res in stream) {
          Get.back();
          final data = json.decode(res);

          if (data["success"] == true) {
            Get.snackbar("Éxito", "Sponsor actualizado correctamente");
            Get.offAllNamed("/admin/home");
          } else {
            Get.snackbar("Error", "No se pudo actualizar");
          }
        }
      } else {
        final res = await sponsorProvider.updateWithoutImage(sponsor);

        Get.back();

        if (res.statusCode == 200 || res.statusCode == 201) {
          Get.snackbar("Éxito", "Sponsor actualizado");
          Get.offAllNamed("/admin/home");
        } else {
          Get.snackbar("Error", "No se pudo actualizar el sponsor");
        }
      }
    } catch (e) {
      Get.back();
      Get.snackbar("ERROR", "Hubo un error: $e");
    }
  }
}
