import 'dart:convert';
import 'dart:io';

import 'package:amina_ec/src/models/response_api.dart';
import 'package:amina_ec/src/providers/plans_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

import '../../../../components/Socket/socket_service.dart';
import '../../../../models/plan.dart';

class AdminPlanRegisterController extends GetxController {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController ridesController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController durationDaysController = TextEditingController();

  PlanProvider plansProvider = PlanProvider();

  // Variables para subir una imagen
  Rx<File?> imageFile = Rx<File?>(null);
  ImagePicker picker = ImagePicker();

  // Método para registrar un plan
  void registerPlan(BuildContext context) async {
    String name = nameController.text.trim();
    String description = descriptionController.text.trim();
    String rides = ridesController.text.trim();
    String price = priceController.text.trim();
    String durationDays = durationDaysController.text.trim();

    if (isValidForm(name, description, rides, price, durationDays)) {
      ProgressDialog progressDialog = ProgressDialog(context: context);
      progressDialog.show(max: 100, msg: 'Registrando Plan...');

      // Convertir valores numéricos de forma segura
      int ridesInt = int.tryParse(rides) ?? 0;
      int durationInt = int.tryParse(durationDays) ?? 0;
      double priceDouble = double.tryParse(price.replaceAll(',', '.')) ?? 0.0;

      Plan plan = Plan(
        name: name,
        description: description,
        rides: ridesInt,
        price: priceDouble,
        duration_days: durationInt,
      );

      Stream stream =
          await plansProvider.createWithImage(plan, imageFile.value!);
      stream.listen((res) {
        ResponseApi responseApi = ResponseApi.fromJson(json.decode(res));
        progressDialog.close();
        if (responseApi.success == true) {
          // Emitir evento por socket si fue exitoso
          SocketService().emit('plan:new', plan.toJson());

          clear();
          Get.back();
        } else {
          Get.snackbar('Error', responseApi.message ?? 'Error desconocido');
        }
      });
    }
  }

  // Validación de campos
  bool isValidForm(String name, String description, String rides, String price,
      String durationDays) {
    if (name.isEmpty) {
      Get.snackbar('Nombre vacío', 'Ingrese un nombre');
      return false;
    }
    if (description.isEmpty) {
      Get.snackbar('Descripción vacía', 'Ingrese una descripción');
      return false;
    }
    if (rides.isEmpty || int.tryParse(rides) == null) {
      Get.snackbar('Rides incorrecto', 'Ingrese un número válido');
      return false;
    }
    if (price.isEmpty || double.tryParse(price.replaceAll(',', '.')) == null) {
      Get.snackbar('Precio incorrecto', 'Ingrese un precio válido');
      return false;
    }
    if (durationDays.isEmpty || int.tryParse(durationDays) == null) {
      Get.snackbar('Duración incorrecta', 'Ingrese duración válida');
      return false;
    }
    if (imageFile.value == null) {
      Get.snackbar('Imagen vacía', 'Seleccione una imagen');
      return false;
    }
    return true;
  }

  // Limpiar campos
  void clear() {
    nameController.clear();
    descriptionController.clear();
    ridesController.clear();
    priceController.clear();
    durationDaysController.clear();
    imageFile.value = null;
    update();
  }

  // Selección de imagen
  void showAlertDialog(BuildContext context) {
    Widget galleryButton = FloatingActionButton.extended(
      onPressed: () {
        Get.back();
        selectImage(ImageSource.gallery);
      },
      label: Text('Galería'),
      icon: Icon(Icons.photo_library_outlined),
    );
    Widget cameraButton = FloatingActionButton.extended(
      onPressed: () {
        Get.back();
        selectImage(ImageSource.camera);
      },
      label: Text('Cámara'),
      icon: Icon(Icons.camera),
    );

    AlertDialog alertDialog = AlertDialog(
      title: Text('Seleccione una opción'),
      actions: [galleryButton, cameraButton],
    );

    showDialog(context: context, builder: (_) => alertDialog);
  }

  Future selectImage(ImageSource imageSource) async {
    XFile? image = await picker.pickImage(source: imageSource);
    if (image != null) {
      imageFile.value = File(image.path);
      update();
    }
  }
}
