import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImageCompressUtil {
  static Future<File> compress({
    required File input,
    int minWidth = 1024,
    int minHeight = 1024,
    int quality = 80,
  }) async {
    final dir = await getTemporaryDirectory();
    final targetPath = p.join(
      dir.path,
      'cmp_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    // compressAndGetFile devuelve Future<XFile?>
    final XFile? result = await FlutterImageCompress.compressAndGetFile(
      input.path,
      targetPath,
      minWidth: minWidth,
      minHeight: minHeight,
      quality: quality,
      format: CompressFormat.jpeg,
      keepExif: true,
    );

    // Convertimos XFile → File
    if (result != null) {
      return File(result.path);
    } else {
      return input; // fallback seguro
    }
  }
}