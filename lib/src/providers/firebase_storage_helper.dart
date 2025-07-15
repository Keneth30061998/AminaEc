import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageHelper {
  static Future<String> uploadPdfToFirebase(
      File pdfFile, String fileName) async {
    final ref = FirebaseStorage.instance.ref().child('firmas/$fileName.pdf');
    final uploadTask = await ref.putFile(pdfFile);
    return await uploadTask.ref.getDownloadURL();
  }
}
