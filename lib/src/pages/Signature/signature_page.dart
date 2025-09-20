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

    return Scaffold(
      appBar: AppBar(
        title: _appBarTitle(),
      ),
      body: Column(
        children: [
          // Área de la firma
          Expanded(
            child: Signature(
              controller: con.signatureController,
              backgroundColor: Colors.grey[200]!,
            ),
          ),

          // Botones y estado de carga
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
                  // Limpiar firma
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

                  // Guardar firma y registrar
                  ElevatedButton.icon(
                    onPressed: () async {
                      await con.saveSignature(user);

                      if (con.downloadUrl.isNotEmpty) {
                        // Usamos Get.context seguro
                        final registerCon = Get.find<RegisterController>();
                        registerCon.register(Get.context!);
                      }
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

          // Mostrar URL del PDF generado
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
