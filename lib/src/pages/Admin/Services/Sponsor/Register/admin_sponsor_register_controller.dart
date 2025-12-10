import 'dart:convert';
import 'dart:io';
import 'package:amina_ec/src/components/Compress/image_compress_util.dart';
import 'package:amina_ec/src/components/Socket/socket_service.dart';
import 'package:amina_ec/src/models/sponsor.dart';
import 'package:amina_ec/src/providers/sponsor_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AdminSponsorRegisterController extends GetxController {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  final ImagePicker picker = ImagePicker();
  final SponsorProvider sponsorProvider = SponsorProvider();

  Rx<File?> imageFile = Rx<File?>(null);

  /// prioridad 1 = grande, 2 = mediano, 3 = pequeño
  RxInt priority = 3.obs;

  /// 🔥 NUEVO: target del sponsor (student / coach / both)
  RxString target = "student".obs;

  // -------------------------------------------
  // VALIDACIÓN PROFESIONAL
  // -------------------------------------------
  bool isValidForm(String name, String description) {
    if (name.isEmpty) {
      Get.snackbar('Nombre requerido', 'Ingrese el nombre del sponsor');
      return false;
    }
    if (description.isEmpty) {
      Get.snackbar('Descripción requerida', 'Ingrese la descripción');
      return false;
    }
    if (imageFile.value == null) {
      Get.snackbar('Imagen requerida', 'Seleccione una imagen');
      return false;
    }
    return true;
  }

  // -------------------------------------------
  // REGISTRO COMPLETO + COMPRESIÓN + LOADER
  // -------------------------------------------
  Future<void> registerSponsor(BuildContext context) async {
    String name = nameController.text.trim();
    String description = descriptionController.text.trim();

    if (!isValidForm(name, description)) return;

    // Loader oscuro
    Get.dialog(
      Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 5,
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      // COMPRESIÓN DE IMAGEN
      File compressed = await ImageCompressUtil.compress(
        input: imageFile.value!,
        minWidth: 1024,
        minHeight: 1024,
        quality: 80,
      );

      Sponsor sponsor = Sponsor(
        name: name,
        description: description,
        priority: priority.value,
        target: target.value, // 🔥 NUEVO
      );

      Stream stream = await sponsorProvider.createWithImage(
        sponsor,
        compressed,
      );

      await for (var res in stream) {
        final data = json.decode(res);

        Get.back(); // cerrar loader

        if (data["success"] == true) {
          SocketService().emit("sponsor:new", sponsor.toJson());
          clear();
          Get.back();
          Get.snackbar("Éxito", "Sponsor registrado correctamente");
        } else {
          Get.snackbar("Error", data["message"] ?? "No se pudo registrar");
        }
      }
    } catch (e) {
      Get.back();
      Get.snackbar("ERROR", "No se pudo registrar el sponsor: $e");
    }
  }

  // -------------------------------------------
  // LIMPIAR FORMULARIO
  // -------------------------------------------
  void clear() {
    nameController.clear();
    descriptionController.clear();
    priority.value = 3;
    imageFile.value = null;
    target.value = "student"; // 🔥 RESET
    update();
  }

  // -------------------------------------------
  // SELECCIONAR IMAGEN + COMPRESIÓN
  // -------------------------------------------
  Future selectImage(ImageSource source) async {
    XFile? picked = await picker.pickImage(source: source);

    if (picked != null) {
      File file = File(picked.path);

      // Loader mientras comprime
      Get.dialog(
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 5,
            ),
          ),
        ),
        barrierDismissible: false,
      );

      try {
        final compressed = await ImageCompressUtil.compress(input: file);
        imageFile.value = compressed;
      } finally {
        Get.back();
      }
      update();
    }
  }
}
