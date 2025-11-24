import 'dart:io';

import 'package:amina_ec/src/models/plan.dart';
import 'package:amina_ec/src/providers/plans_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AdminPlanUpdateController extends GetxController {
  final PlanProvider planProvider = PlanProvider();

  //variable para activar/desactivar plan de usuario nuevo
  RxBool isNewUserOnly = false.obs;

  Plan plan = Get.arguments['plan'];
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final ridesController = TextEditingController();
  final durationController = TextEditingController();

  File? imageFile;

  @override
  void onInit() {
    super.onInit();
    nameController.text = plan.name ?? '';
    descriptionController.text = plan.description ?? '';
    priceController.text =
        plan.price?.toStringAsFixed(2).replaceAll('.', ',') ?? '';
    ridesController.text = plan.rides?.toString() ?? '';
    durationController.text = plan.duration_days?.toString() ?? '';
    isNewUserOnly.value = plan.is_new_user_only == 1;
  }

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      update(); // Para refrescar la imagen en la vista
    }
  }

  void updatePlan() async {
    String name = nameController.text.trim();
    String description = descriptionController.text.trim();
    String priceText = priceController.text.trim();
    String ridesText = ridesController.text.trim();
    String durationText = durationController.text.trim();

    // Validaciones
    if (name.isEmpty ||
        description.isEmpty ||
        priceText.isEmpty ||
        ridesText.isEmpty ||
        durationText.isEmpty) {
      Get.snackbar('Error', 'Todos los campos son obligatorios');
      return;
    }

    double? price = double.tryParse(priceText.replaceAll(',', '.'));
    int? rides = int.tryParse(ridesText);
    int? duration = int.tryParse(durationText);

    if (price == null) {
      Get.snackbar('Error', 'Precio inválido');
      return;
    }
    if (rides == null) {
      Get.snackbar('Error', 'Rides inválido');
      return;
    }
    if (duration == null) {
      Get.snackbar('Error', 'Duración inválida');
      return;
    }

    plan.name = name;
    plan.description = description;
    plan.price = price;
    plan.rides = rides;
    plan.duration_days = duration;
    plan.is_new_user_only = isNewUserOnly.value ? 1 : 0;


    if (imageFile != null) {
      final stream = await planProvider.updateWithImage(plan, imageFile!);
      stream.listen((res) {
        Get.snackbar('Éxito', 'Plan actualizado con imagen');
        Get.offAllNamed('/admin/home');
      });
    } else {
      final res = await planProvider.updateWithoutImage(plan);
      if (res.statusCode == 201) {
        Get.snackbar('Éxito', 'Plan actualizado');
        Get.offAllNamed('/admin/home');
      } else {
        Get.snackbar('Error', 'No se pudo actualizar');
      }
    }
  }
}
