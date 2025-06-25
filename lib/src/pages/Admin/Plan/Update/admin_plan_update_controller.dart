import 'dart:io';

import 'package:amina_ec/src/models/plan.dart';
import 'package:amina_ec/src/providers/plans_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AdminPlanUpdateController extends GetxController {
  final PlanProvider planProvider = PlanProvider();

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
    priceController.text = plan.price?.toStringAsFixed(2) ?? '';
    ridesController.text = plan.rides?.toString() ?? '';
    durationController.text = plan.duration_days?.toString() ?? '';
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
    plan.name = nameController.text;
    plan.description = descriptionController.text;
    plan.price = double.tryParse(priceController.text) ?? 0.0;
    plan.rides = int.tryParse(ridesController.text) ?? 0;
    plan.duration_days = int.tryParse(durationController.text) ?? 0;

    if (imageFile != null) {
      final stream = await planProvider.updateWithImage(plan, imageFile!);
      stream.listen((res) {
        Get.snackbar('Éxito', 'Plan actualizado con imagen');
        Get.offAllNamed('/admin/home');
        //Get.back();
      });
    } else {
      final res = await planProvider.updateWithoutImage(plan);
      if (res.statusCode == 201) {
        Get.snackbar('Éxito', 'Plan actualizado');
        Get.offAllNamed('/admin/home');
        //Get.back();
      } else {
        Get.snackbar('Error', 'No se pudo actualizar');
      }
    }
  }
}
