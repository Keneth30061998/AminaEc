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

  //Variables para subir una imagen
  Rx<File?> imageFile = Rx<File?>(null);
  File? imageFile2;
  ImagePicker picker = ImagePicker();

  //Metodos para registar un plan
  void registerPlan(BuildContext context) async {
    String name = nameController.text;
    String description = descriptionController.text;
    String rides = ridesController.text;
    String price = priceController.text;
    String durationDays = durationDaysController.text;

    if (isValidForm(name, description, rides, price, durationDays)) {
      ProgressDialog progressDialog = ProgressDialog(context: context);
      progressDialog.show(max: 100, msg: 'Registrando Usuario...');
      Plan plan = Plan(
          name: name,
          description: description,
          rides: int.parse(rides),
          price: double.parse(price),
          duration_days: int.parse(durationDays));

      Stream stream =
          await plansProvider.createWithImage(plan, imageFile.value!);
      stream.listen((res) {
        ResponseApi responseApi = ResponseApi.fromJson(json.decode(res));
        progressDialog.close();
        print('Reponse: ${responseApi.success}');
        if (responseApi.success == true) {
          // ✅ Emitir evento por socket si fue exitoso
          SocketService().emit('plan:new', plan.toJson());

          clear();
          Get.back();
        }
      });
    }
  }

//Metodo para validar los campos
  bool isValidForm(String name, String description, String rides, String price,
      String durationDays) {
    //Validaciones - datos
    if (!GetUtils.isNum(rides)) {
      Get.snackbar('Rides incorrecto', 'Ingrese un número de rides válido');
      return false;
    }

    //Validaciones - campos vacios
    if (name.isEmpty) {
      Get.snackbar('Nombre vacío', 'Ingrese un nombre');
      return false;
    }
    if (description.isEmpty) {
      Get.snackbar('Descripción vacía', 'Ingrese una descripción');
      return false;
    }
    if (rides.isEmpty) {
      Get.snackbar('Rides vacío', 'Ingrese un número de rides');
      return false;
    }
    if (price.isEmpty) {
      Get.snackbar('Precio vacío', 'Ingrese un precio');
      return false;
    }

    if (durationDays.isEmpty) {
      Get.snackbar('Duracion vacío', 'Ingrese duración en dias');
      return false;
    }

    //Validacion de imagen
    if (imageFile.value == null) {
      Get.snackbar('Imagen vacía', 'Seleccione una imágen');
      return false;
    }
    return true;
  }

  //Metodo para limpiar los campos
  void clear() {
    nameController.text = '';
    descriptionController.text = '';
    ridesController.text = '';
    priceController.text = '';
    imageFile.value = null;
    durationDaysController.text = '';
    update();
  }

  //Metodo para seleccionar una imagen
  void showAlertDialog(BuildContext context) {
    Widget galleryButton = FloatingActionButton.extended(
      onPressed: () {
        Get.back();
        selectImage(ImageSource.gallery);
      },
      label: Text('Galeria'),
      icon: Icon(Icons.photo_library_outlined),
      elevation: 3,
    );
    Widget cameraButton = FloatingActionButton.extended(
      onPressed: () {
        Get.back();
        selectImage(ImageSource.camera);
      },
      label: Text('Cámara'),
      icon: Icon(Icons.camera),
      elevation: 3,
    );

    AlertDialog alertDialog = AlertDialog(
      title: Text(
        'Seleccione una opción',
        style: TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      actions: [
        galleryButton,
        cameraButton,
      ],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alertDialog;
        });
  }

  Future selectImage(ImageSource imageSource) async {
    XFile? image = await picker.pickImage(source: imageSource);
    if (image != null) {
      imageFile.value = File(image.path);
      update();
    }
  }
}
