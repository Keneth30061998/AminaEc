import 'dart:ui';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:amina_ec/src/models/user.dart';
import 'package:amina_ec/src/pages/Signature/signature_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signature/signature.dart';
import '../../utils/iconos.dart';
import '../user/Register/register_controller.dart';

class SignaturePage extends StatelessWidget {
  final SignaturePDFController con = Get.put(SignaturePDFController());
  final RxBool isProcessing = false.obs;

  SignaturePage({super.key});

  @override
  Widget build(BuildContext context) {
    final User user = Get.arguments as User;
    final RegisterController registerCon = Get.find<RegisterController>();

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            backgroundColor: whiteLight,
            elevation: 0,
            iconTheme: IconThemeData(color: almostBlack),
            title: _appBarTitle(),
            centerTitle: true,
          ),
          body: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Color(0xFFF9F9F9)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Por favor, firma dentro del recuadro para continuar con el registro.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Signature(
                          controller: con.signatureController,
                          backgroundColor: Colors.grey[200]!,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Obx(() {
                  if (con.isUploading.value) {
                    return const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _actionButton(
                          icon: iconEraser,
                          label: "Limpiar",
                          color: Colors.grey[300]!,
                          textColor: almostBlack,
                          onTap: con.clearSignature,
                        ),
                        _actionButton(
                          icon: iconSignature,
                          label: "Firmar",
                          color: almostBlack,
                          textColor: whiteLight,
                          onTap: () async {
                            isProcessing.value = true;

                            bool validForm = registerCon.isValidForm(
                              registerCon.emailController.text.trim(),
                              registerCon.nameController.text.trim(),
                              registerCon.lastnameController.text.trim(),
                              registerCon.ciController.text.trim(),
                              registerCon.phoneController.text.trim(),
                              registerCon.passwordController.text.trim(),
                              registerCon.confirmPasswordController.text.trim(),
                              registerCon.birthDate.value,
                            );

                            if (!validForm) {
                              isProcessing.value = false;
                              Get.snackbar(
                                "Atención",
                                "Debe completar todos los campos obligatorios antes de firmar",
                              );
                              return;
                            }

                            if (con.signatureController.isEmpty) {
                              isProcessing.value = false;
                              Get.snackbar(
                                "Atención",
                                "Debe firmar antes de continuar",
                              );
                              return;
                            }

                            final url =
                            await con.saveSignature(user, shouldUpload: true);
                            if (url == null) {
                              isProcessing.value = false;
                              return;
                            }

                            bool success = await registerCon.register();
                            isProcessing.value = false;

                            if (!success) {
                              Get.offAllNamed('/register');
                              return;
                            }

                            Get.offAllNamed('user/home');
                          },
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),

        // Overlay elegante de carga
        Obx(() => isProcessing.value
            ? Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withOpacity(0.3),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Container(
                  width: 180,
                  padding: const EdgeInsets.symmetric(
                      vertical: 20, horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 55,
                        height: 55,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 4.5,
                        ),
                      ),
                      const SizedBox(height: 15),
                      DefaultTextStyle(
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        child: AnimatedTextKit(
                          animatedTexts: [
                            FadeAnimatedText('Generando firma...'),
                            FadeAnimatedText('Guardando información...'),
                            FadeAnimatedText('Conectando...'),
                            FadeAnimatedText('Sincronizando datos...'),
                            FadeAnimatedText('Casi listo...'),
                          ],
                          repeatForever: true,
                          pause:
                          const Duration(milliseconds: 650),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
            : const SizedBox.shrink()),
      ],
    );
  }

  Widget _appBarTitle() {
    return Text(
      'Firmar documento',
      style: GoogleFonts.montserrat(
        fontSize: 21,
        fontWeight: FontWeight.w800,
        color: almostBlack,
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        textStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}
