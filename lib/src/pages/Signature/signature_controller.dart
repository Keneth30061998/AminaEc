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

  /// Solo genera y sube la firma si `shouldUpload` es true
  Future<String?> saveSignature(User user, {required bool shouldUpload}) async {
    if (!shouldUpload) return null; // Evitar subir si validación falla

    if (signatureController.isEmpty) return null;

    try {
      isUploading.value = true;

      final signature = await signatureController.toPngBytes();
      if (signature == null) {
        throw Exception("No se pudo generar la imagen de la firma");
      }

      final pdf = await PdfService.generatePdfWithSignature(
        signatureBytes: signature,
        user: user,
      );

      final url = await FirebaseStorageHelper.uploadPdfToFirebase(
        pdf,
        'firma_${user.name}_${user.ci}',
      );

      downloadUrl.value = url;
      clearSignature();
      return url;
    } catch (e) {
      Get.snackbar("Error", e.toString());
      return null;
    } finally {
      isUploading.value = false;
    }
  }

  void clearSignature() {
    signatureController.clear();
  }
}
