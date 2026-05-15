import 'dart:io';

import 'package:amina_ec/src/models/plan.dart';
import 'package:amina_ec/src/providers/plans_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AdminPlanUpdateController extends GetxController {
  final PlanProvider planProvider = PlanProvider();

  // Variable para activar/desactivar plan exclusivo para usuario nuevo
  RxBool isNewUserOnly = false.obs;

  // Variable para activar/desactivar pago diferido
  RxBool allowDeferredPayment = false.obs;

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
    allowDeferredPayment.value = plan.allow_deferred_payment == 1;
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    ridesController.dispose();
    durationController.dispose();
    super.onClose();
  }

  Future<void> pickImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      update(); // Para refrescar la imagen en la vista
    }
  }

  Future<void> updatePlan() async {
    final String name = nameController.text.trim();
    final String description = descriptionController.text.trim();
    final String priceText = priceController.text.trim();
    final String ridesText = ridesController.text.trim();
    final String durationText = durationController.text.trim();

    // Validaciones
    if (name.isEmpty ||
        description.isEmpty ||
        priceText.isEmpty ||
        ridesText.isEmpty ||
        durationText.isEmpty) {
      Get.snackbar('Error', 'Todos los campos son obligatorios');
      return;
    }

    final double? price = double.tryParse(priceText.replaceAll(',', '.'));
    final int? rides = int.tryParse(ridesText);
    final int? duration = int.tryParse(durationText);

    if (price == null || price <= 0) {
      Get.snackbar('Error', 'Precio inválido');
      return;
    }

    if (rides == null || rides <= 0) {
      Get.snackbar('Error', 'Rides inválido');
      return;
    }

    if (duration == null || duration <= 0) {
      Get.snackbar('Error', 'Duración inválida');
      return;
    }

    plan.name = name;
    plan.description = description;
    plan.price = price;
    plan.rides = rides;
    plan.duration_days = duration;
    plan.is_new_user_only = isNewUserOnly.value ? 1 : 0;
    plan.allow_deferred_payment = allowDeferredPayment.value ? 1 : 0;

    try {
      if (imageFile != null) {
        final stream = await planProvider.updateWithImage(plan, imageFile!);

        stream.listen(
              (res) {
            Get.snackbar('Éxito', 'Plan actualizado con imagen');
            Get.offAllNamed('/admin/home');
          },
          onError: (error) {
            Get.snackbar('Error', 'No se pudo actualizar el plan: $error');
          },
        );
      } else {
        final res = await planProvider.updateWithoutImage(plan);

        if (res.statusCode == 200 || res.statusCode == 201) {
          Get.snackbar('Éxito', 'Plan actualizado');
          Get.offAllNamed('/admin/home');
        } else {
          Get.snackbar('Error', 'No se pudo actualizar: ${res.body}');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Ocurrió un error al actualizar: $e');
    }
  }
}