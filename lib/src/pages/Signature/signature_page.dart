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

  SignaturePage({super.key});

  @override
  Widget build(BuildContext context) {
    final User user = Get.arguments as User;
    final RegisterController registerCon = Get.find<RegisterController>();

    return Scaffold(
      appBar: AppBar(
        title: _appBarTitle(),
      ),
      body: Column(
        children: [
          Expanded(
            child: Signature(
              controller: con.signatureController,
              backgroundColor: Colors.grey[200]!,
            ),
          ),

          Obx(() {
            if (con.isUploading.value) {
              return const Padding(
                padding: EdgeInsets.all(10),
                child: CircularProgressIndicator(),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    onPressed: con.clearSignature,
                    label: const Text("Limpiar"),
                    icon: Icon(iconEraser),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: almostBlack,
                      foregroundColor: whiteLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      // Validar que todos los campos del registro estén correctos
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
                        Get.snackbar(
                          "Atención",
                          "Debe completar todos los campos obligatorios antes de firmar",
                        );
                        return; // Salir sin generar firma ni snackbar de éxito
                      }

                      if (con.signatureController.isEmpty) {
                        Get.snackbar(
                          "Atención",
                          "Debe firmar antes de continuar",
                        );
                        return;
                      }

                      // Guardar firma solo si todo está correcto
                      final url = await con.saveSignature(user, shouldUpload: true);
                      if (url == null) {
                        // Error al generar la firma
                        return;
                      }

                      // Registrar usuario
                      bool success = await registerCon.register(Get.context!);

                      if (!success) {
                        Get.offAllNamed('/register'); // Volver a registro si falla
                        return;
                      }

                      // Registro exitoso → Home
                      Get.offAllNamed('user/home');
                    },
                    label: const Text("Firmar"),
                    icon: Icon(iconSignature),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: almostBlack,
                      foregroundColor: whiteLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                  ),
                ],
              ),
            );
          }),

          Obx(() {
            if (con.downloadUrl.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  "URL PDF: ${con.downloadUrl.value}",
                  style: const TextStyle(fontSize: 12),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _appBarTitle() {
    return Text(
      'Firmar documento',
      style: GoogleFonts.montserrat(
        fontSize: 22,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}
