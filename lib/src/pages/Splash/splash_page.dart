import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/color.dart';
import 'splash_controller.dart';

class SplashPage extends StatelessWidget {
  SplashPage({Key? key}) : super(key: key);

  final controller = Get.put(SplashController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: almostBlack,
      body: FadeTransition(
        opacity: controller.fadeAnim,
        child: SlideTransition(
          position: controller.slideAnim,
          child: ScaleTransition(
            scale: controller.scaleAnim,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/img/bicicleta.png',
                    height: 180,
                  ),
                  const SizedBox(height: 25),
                  DefaultTextStyle(
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontFamily: 'Roboto',
                      color: limeGreen,
                      fontWeight: FontWeight.bold,
                    ),
                    child: AnimatedTextKit(
                      animatedTexts: [
                        TyperAnimatedText('Cargando tu energía...'),
                        TyperAnimatedText('Conectando con el servidor...'),
                        TyperAnimatedText('Listo para pedalear!!️'),
                      ],
                      repeatForever: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
