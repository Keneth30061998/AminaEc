import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/color.dart';
import 'splash_controller.dart';

class SplashPage extends StatelessWidget {
  SplashPage({super.key});

  final controller = Get.put(SplashController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.asset(
              'assets/img/splashImage.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Capa oscura para contraste
          Positioned.fill(
            child: Container(
              color: Colors.black.withAlpha((0.5 * 255).round()),
            ),
          ),

          // Animaciones y contenido
          FadeTransition(
            opacity: controller.fadeAnim,
            child: SlideTransition(
              position: controller.slideAnim,
              child: ScaleTransition(
                scale: controller.scaleAnim,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 30),

                      // Texto animado principal
                      DefaultTextStyle(
                        style: GoogleFonts.roboto(
                          fontSize: 34,
                          color: limeGreen,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          wordSpacing: 0.5
                        ),
                        child: AnimatedTextKit(
                          animatedTexts: [
                            TyperAnimatedText("FIND YOUR BALANCE"),
                            TyperAnimatedText("MOVE WITH INTENTION"),
                            TyperAnimatedText("LOVE THE MOVEMENT"),
                          ],
                          repeatForever: true,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Subtexto motivacional
                      Text(
                        "Entrena con energía, vive con propósito.",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
