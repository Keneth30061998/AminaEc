import 'dart:convert';
import 'dart:io';

import 'package:amina_ec/src/components/Socket/socket_service.dart';
import 'package:amina_ec/src/models/coach.dart';
import 'package:amina_ec/src/providers/coachs_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AdminCoachUpdateController extends GetxController {
  final CoachProvider coachProvider = CoachProvider();
  final picker = ImagePicker();

  late Coach coach;
  File? imageFile;

  // Text Controllers
  final nameController = TextEditingController();
  final lastnameController = TextEditingController();
  final ciController = TextEditingController();
  final phoneController = TextEditingController();

  final hobbyController = TextEditingController();
  final descriptionController = TextEditingController();
  final presentationController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    coach = Get.arguments as Coach;

    nameController.text = coach.user?.name ?? '';
    lastnameController.text = coach.user?.lastname ?? '';
    ciController.text = coach.user?.ci ?? '';
    phoneController.text = coach.user?.phone ?? '';
    hobbyController.text = coach.hobby ?? '';
    descriptionController.text = coach.description ?? '';
    presentationController.text = coach.presentation ?? '';
  }

  Future<void> selectImage(ImageSource imageSource) async {
    final picked = await picker.pickImage(source: imageSource);
    if (picked != null) {
      imageFile = File(picked.path);
      update();
    }
  }

  void showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Seleccione una opción'),
        actions: [
          FloatingActionButton.extended(
            onPressed: () {
              Get.back();
              selectImage(ImageSource.gallery);
            },
            label: const Text('Galería'),
            icon: const Icon(Icons.photo_library_outlined),
          ),
          FloatingActionButton.extended(
            onPressed: () {
              Get.back();
              selectImage(ImageSource.camera);
            },
            label: const Text('Cámara'),
            icon: const Icon(Icons.camera),
          ),
        ],
      ),
    );
  }

  Future<void> updateCoach(BuildContext context) async {
    coach.user!.name = nameController.text;
    coach.user!.lastname = lastnameController.text;
    coach.user!.ci = ciController.text;
    coach.user!.phone = phoneController.text;
    coach.hobby = hobbyController.text;
    coach.description = descriptionController.text;
    coach.presentation = presentationController.text;

    if (!isValidForm()) return;

    final schedules = coach.schedules;

    if (imageFile != null) {
      final stream = await coachProvider.updateWithImage(
        user: coach.user!,
        coach: coach,
        schedules: schedules,
        image: imageFile!,
      );
      stream.listen((res) {
        final data = json.decode(res);
        if (data['success'] == true) {
          SocketService().emit('coach:update', coach.toJson());
          Get.back();
          Get.snackbar('Éxito', 'Coach actualizado con imagen');
        } else {
          Get.snackbar('Error', 'No se pudo actualizar el coach');
        }
      });
    } else {
      final res = await coachProvider.updateWithoutImage(
        user: coach.user!,
        coach: coach,
        schedules: schedules,
      );

      if (res.statusCode == 201) {
        SocketService().emit('coach:update', coach.toJson());
        Get.back();
        Get.snackbar('Éxito', 'Coach actualizado correctamente');
      } else {
        Get.snackbar('Error', 'No se pudo actualizar el coach');
      }
    }
  }

  bool isValidForm() {
    if (!GetUtils.isUsername(nameController.text)) {
      Get.snackbar('Nombre incorrecto', 'Ingrese un nombre válido');
      return false;
    }
    if (!GetUtils.isUsername(lastnameController.text)) {
      Get.snackbar('Apellido incorrecto', 'Ingrese un apellido válido');
      return false;
    }
    if (!GetUtils.isNum(ciController.text)) {
      Get.snackbar('Cédula incorrecta', 'Ingrese un número de CI válido');
      return false;
    }
    if (!GetUtils.isPhoneNumber(phoneController.text)) {
      Get.snackbar('Teléfono incorrecto', 'Ingrese un teléfono válido');
      return false;
    }
    if (hobbyController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        presentationController.text.isEmpty) {
      Get.snackbar('Campos vacíos', 'Complete los datos del coach');
      return false;
    }
    return true;
  }
}
