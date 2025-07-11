import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController logoController;
  late Animation<double> scaleAnim;
  late Animation<double> fadeAnim;
  late Animation<Offset> slideAnim;

  @override
  void onInit() {
    super.onInit();

    logoController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(
      parent: logoController,
      curve: Curves.easeOutBack,
    ));

    fadeAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: logoController,
      curve: Curves.easeIn,
    ));

    slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: logoController,
        curve: Curves.decelerate,
      ),
    );

    logoController.forward();

    Future.delayed(const Duration(seconds: 5), () {
      Get.offAllNamed('/login'); // Asegúrate de registrar esta ruta
    });
  }

  @override
  void onClose() {
    logoController.dispose();
    super.onClose();
  }
}
