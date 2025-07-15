import 'package:get/get.dart';
import 'package:signature/signature.dart';

import '../../components/PDF/pdf_service.dart';
import '../../models/user.dart';
import '../../providers/firebase_storage_helper.dart';

class SignaturePDFController extends GetxController {
  final signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Get.isDarkMode
        ? Get.theme.primaryColorLight
        : Get.theme.primaryColorDark,
    exportBackgroundColor: Get.theme.scaffoldBackgroundColor,
  );

  RxBool isUploading = false.obs;
  RxString downloadUrl = ''.obs;

  Future<void> saveSignature(User user) async {
    if (signatureController.isEmpty) return;

    try {
      isUploading.value = true;

      final signature = await signatureController.toPngBytes();
      if (signature == null)
        throw Exception("No se pudo generar imagen de la firma");

      final pdf = await PdfService.generatePdfWithSignature(
        signatureBytes: signature,
        user: user,
      );

      final url = await FirebaseStorageHelper.uploadPdfToFirebase(
        pdf,
        'firma_${user.name}_${user.ci}',
      );

      downloadUrl.value = url;
      Get.snackbar("Éxito", "Firma subida correctamente");
      clearSignature();
    } catch (e) {
      Get.snackbar("Error", e.toString());
      print('Error: ${e}');
    } finally {
      isUploading.value = false;
    }
  }

  void clearSignature() {
    signatureController.clear();
  }
}
