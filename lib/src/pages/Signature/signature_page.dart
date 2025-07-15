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

  @override
  Widget build(BuildContext context) {
    final User user = Get.arguments as User;

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
          Obx(() => con.isUploading.value
              ? const Padding(
                  padding: EdgeInsets.all(10),
                  child: CircularProgressIndicator(),
                )
              : Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton.icon(
                        onPressed: con.clearSignature,
                        label: const Text("Limpiar"),
                        icon: Icon(icon_eraser),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: almostBlack,
                            foregroundColor: whiteLight,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await con.saveSignature(user);
                          if (con.downloadUrl.isNotEmpty) {
                            final registerCon = Get.find<RegisterController>();
                            registerCon.register(context);
                          }
                        },
                        label: const Text("Firmar"),
                        icon: Icon(icon_signature),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: almostBlack,
                            foregroundColor: whiteLight,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5),
                      ),
                    ],
                  ),
                )),
          Obx(() {
            if (con.downloadUrl.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.all(10),
                child: Text("URL PDF: ${con.downloadUrl.value}",
                    style: const TextStyle(fontSize: 12)),
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
      style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w900),
    );
  }
}
