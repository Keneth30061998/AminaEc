import 'dart:convert';
import 'dart:io';

import 'package:amina_ec/src/components/Compress/image_compress_util.dart';
import 'package:amina_ec/src/components/Socket/socket_service.dart';
import 'package:amina_ec/src/models/plan.dart';
import 'package:amina_ec/src/models/response_api.dart';
import 'package:amina_ec/src/providers/plans_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AdminPlanRegisterController extends GetxController {
  // CONTROLADORES DE TEXTO
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final ridesController = TextEditingController();
  final priceController = TextEditingController();
  final durationDaysController = TextEditingController();

  // PROVIDERS
  final PlanProvider plansProvider = PlanProvider();

  // IMAGEN
  Rx<File?> imageFile = Rx<File?>(null);
  final ImagePicker picker = ImagePicker();

  // SOLO NUEVO USUARIO
  RxBool isNewUserOnly = false.obs;

  // ---------------------------------------------------------
  // VALIDACIÓN PROFESIONAL
  // ---------------------------------------------------------
  bool isValidForm(
      String name, String description, String rides, String price, String durationDays) {
    if (name.isEmpty) {
      Get.snackbar("Nombre vacío", "Ingrese un nombre");
      return false;
    }
    if (description.isEmpty) {
      Get.snackbar("Descripción vacía", "Ingrese una descripción");
      return false;
    }
    if (rides.isEmpty || int.tryParse(rides) == null) {
      Get.snackbar("Rides incorrecto", "Ingrese un número válido de rides");
      return false;
    }
    if (price.isEmpty || double.tryParse(price.replaceAll(",", ".")) == null) {
      Get.snackbar("Precio incorrecto", "Ingrese un precio válido");
      return false;
    }
    if (durationDays.isEmpty || int.tryParse(durationDays) == null) {
      Get.snackbar("Duración inválida", "Ingrese una duración en días válida");
      return false;
    }
    if (imageFile.value == null) {
      Get.snackbar("Imagen requerida", "Seleccione una imagen para el plan");
      return false;
    }
    return true;
  }

  // ---------------------------------------------------------
  // REGISTRAR PLAN + COMPRESIÓN + LOADER OSCURO
  // ---------------------------------------------------------
  Future<void> registerPlan(BuildContext context) async {
    String name = nameController.text.trim();
    String description = descriptionController.text.trim();
    String rides = ridesController.text.trim();
    String price = priceController.text.trim();
    String durationDays = durationDaysController.text.trim();

    if (!isValidForm(name, description, rides, price, durationDays)) return;

    // Mostrar loader personalizado
    Get.dialog(
      Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.black87, borderRadius: BorderRadius.circular(15)),
          child: const CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 5,
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      // COMPRESIÓN DE LA IMAGEN
      File compressedImage = await ImageCompressUtil.compress(
        input: imageFile.value!,
        minWidth: 1024,
        minHeight: 1024,
        quality: 80,
      );

      // Conversión de valores
      int ridesInt = int.tryParse(rides) ?? 0;
      int durationInt = int.tryParse(durationDays) ?? 0;
      double priceDouble = double.tryParse(price.replaceAll(",", ".")) ?? 0.0;

      Plan plan = Plan(
        name: name,
        description: description,
        rides: ridesInt,
        price: priceDouble,
        duration_days: durationInt,
        is_new_user_only: isNewUserOnly.value ? 1 : 0,
      );

      // Enviar al backend con imagen
      Stream stream = await plansProvider.createWithImage(plan, compressedImage);

      await for (String response in stream) {
        Get.back(); // Cerrar loader

        ResponseApi api = ResponseApi.fromJson(json.decode(response));

        if (api.success == true) {
          // Emitir evento socket
          SocketService().emit('plan:new', plan.toJson());

          clear();
          Get.back(); // regresar a la lista
          Get.snackbar("Éxito", "Plan registrado con éxito");
        } else {
          Get.snackbar("Error", api.message ?? "No se pudo registrar el plan");
        }
      }
    } catch (e) {
      Get.back();
      Get.snackbar("ERROR", "Ocurrió un error al registrar: $e");
    }
  }

  // ---------------------------------------------------------
  // SELECCIONAR IMAGEN CON OPCIÓN DE COMPRESIÓN
  // ---------------------------------------------------------
  void showAlertDialog(BuildContext context) {
    AlertDialog dialog = AlertDialog(
      title: const Text("Seleccione una opción"),
      actions: [
        FloatingActionButton.extended(
          onPressed: () {
            Get.back();
            selectImage(ImageSource.gallery);
          },
          label: const Text("Galería"),
          icon: const Icon(Icons.photo_library_outlined),
        ),
        FloatingActionButton.extended(
          onPressed: () {
            Get.back();
            selectImage(ImageSource.camera);
          },
          label: const Text("Cámara"),
          icon: const Icon(Icons.camera_alt_outlined),
        ),
      ],
    );

    showDialog(context: context, builder: (_) => dialog);
  }

  Future<void> selectImage(ImageSource source) async {
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

  // ---------------------------------------------------------
  // LIMPIAR FORMULARIO
  // ---------------------------------------------------------
  void clear() {
    nameController.clear();
    descriptionController.clear();
    ridesController.clear();
    priceController.clear();
    durationDaysController.clear();
    imageFile.value = null;
    isNewUserOnly.value = false;

    update();
  }
}
