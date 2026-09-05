import 'dart:convert';
import 'dart:io';

import 'package:amina_ec/src/environment/environment.dart';
import 'package:amina_ec/src/models/app_banner.dart';
import 'package:amina_ec/src/models/user.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class AppBannerProvider extends GetConnect {
  String get url => '${Environment.API_URL}api/app-banner';

  User get _userSession => User.fromJson(
        GetStorage().read('user') ?? {},
      );

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': _userSession.session_token ?? '',
      };

  Map<String, dynamic> _normalizeBody(
    dynamic rawBody,
  ) {
    if (rawBody is Map<String, dynamic>) {
      return rawBody;
    }

    if (rawBody is Map) {
      return Map<String, dynamic>.from(
        rawBody,
      );
    }

    if (rawBody is String && rawBody.trim().isNotEmpty) {
      final decoded = json.decode(rawBody);

      if (decoded is Map) {
        return Map<String, dynamic>.from(
          decoded,
        );
      }
    }

    return <String, dynamic>{};
  }

  void _validateResponse(
    int statusCode,
    Map<String, dynamic> body,
  ) {
    if (statusCode < 200 || statusCode >= 300) {
      throw Exception(
        body['message']?.toString() ??
            'El servidor devolvió el código $statusCode.',
      );
    }

    if (body['success'] != true) {
      throw Exception(
        body['message']?.toString() ?? 'La solicitud no pudo ser procesada.',
      );
    }
  }

  /**
   * ======================================================
   * ACTIVOS
   * ======================================================
   */
  Future<List<AppBanner>> getActive() async {
    final response = await get(
      '$url/active',
      headers: _headers,
    );

    final body = _normalizeBody(
      response.body,
    );

    _validateResponse(
      response.statusCode ?? 500,
      body,
    );

    final data = body['data'];

    if (data is! List) {
      return [];
    }

    return data
        .map(
          (item) => AppBanner.fromJson(
            Map<String, dynamic>.from(
              item,
            ),
          ),
        )
        .toList();
  }

  /**
   * ======================================================
   * ADMIN
   * ======================================================
   */
  Future<List<AppBanner>> getAllAdmin() async {
    final response = await get(
      '$url/admin',
      headers: _headers,
    );

    final body = _normalizeBody(
      response.body,
    );

    _validateResponse(
      response.statusCode ?? 500,
      body,
    );

    final data = body['data'];

    if (data is! List) {
      return [];
    }

    return data
        .map(
          (item) => AppBanner.fromJson(
            Map<String, dynamic>.from(
              item,
            ),
          ),
        )
        .toList();
  }

  /**
   * ======================================================
   * CREAR
   * ======================================================
   */
  Future<AppBanner> createBanner(
    AppBanner banner, {
    File? imageFile,
  }) async {
    /**
     * Si no hay imagen podemos
     * enviar JSON.
     */
    if (imageFile == null) {
      final response = await post(
        '$url/admin',
        banner.toJson(),
        headers: _headers,
      );

      final body = _normalizeBody(
        response.body,
      );

      _validateResponse(
        response.statusCode ?? 500,
        body,
      );

      return _bannerFromBody(body);
    }

    /**
     * Multipart
     */
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$url/admin'),
    );

    request.headers['Authorization'] = _userSession.session_token ?? '';

    request.fields['banner'] = json.encode(
      banner.toJson(),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        filename: imageFile.path
            .split(
              Platform.pathSeparator,
            )
            .last,
        contentType: _imageContentType(
          imageFile.path,
        ),
      ),
    );

    final streamed = await request.send();

    final response = await http.Response.fromStream(
      streamed,
    );

    // =====================================================
// DEBUG - RESPUESTA CREAR BANNER
// =====================================================
    print('');
    print('══════════════════════════════════════════════════');
    print('📡 [CREATE BANNER] RESPUESTA DEL SERVIDOR');
    print('══════════════════════════════════════════════════');
    print('➡️ URL: ${request.url}');
    print('➡️ MÉTODO: ${request.method}');
    print('➡️ STATUS CODE: ${response.statusCode}');
    print('➡️ CONTENT-TYPE: ${response.headers['content-type']}');
    print('➡️ CONTENT-LENGTH: ${response.headers['content-length']}');
    print('➡️ BODY:');
    print(response.body);
    print('══════════════════════════════════════════════════');
    print('');

// =====================================================

    final body = _decodeResponse(
      response.body,
    );

    _validateResponse(
      response.statusCode,
      body,
    );

    return _bannerFromBody(body);
  }

  /**
   * ======================================================
   * ACTUALIZAR
   * ======================================================
   */
  Future<AppBanner> updateBanner(
    AppBanner banner, {
    File? imageFile,
  }) async {
    if (banner.id == null) {
      throw Exception(
        'No se puede actualizar un banner sin ID.',
      );
    }

    final endpoint = '$url/admin/${banner.id}';

    /**
     * JSON sin imagen
     */
    if (imageFile == null) {
      final response = await put(
        endpoint,
        banner.toJson(),
        headers: _headers,
      );

      final body = _normalizeBody(
        response.body,
      );

      _validateResponse(
        response.statusCode ?? 500,
        body,
      );

      return _bannerFromBody(body);
    }

    /**
     * Multipart con imagen
     */
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse(endpoint),
    );

    request.headers['Authorization'] = _userSession.session_token ?? '';

    request.fields['banner'] = json.encode(
      banner.toJson(),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        filename: imageFile.path
            .split(
              Platform.pathSeparator,
            )
            .last,
        contentType: _imageContentType(
          imageFile.path,
        ),
      ),
    );

    final streamed = await request.send();

    final response = await http.Response.fromStream(
      streamed,
    );
    // =====================================================
// DEBUG - RESPUESTA ACTUALIZAR BANNER
// =====================================================
    print('');
    print('══════════════════════════════════════════════════');
    print('📡 [UPDATE BANNER] RESPUESTA DEL SERVIDOR');
    print('══════════════════════════════════════════════════');
    print('➡️ URL: ${request.url}');
    print('➡️ MÉTODO: ${request.method}');
    print('➡️ STATUS CODE: ${response.statusCode}');
    print('➡️ CONTENT-TYPE: ${response.headers['content-type']}');
    print('➡️ CONTENT-LENGTH: ${response.headers['content-length']}');
    print('➡️ BODY:');
    print(response.body);
    print('══════════════════════════════════════════════════');
    print('');

// =====================================================
    final body = _decodeResponse(
      response.body,
    );

    _validateResponse(
      response.statusCode,
      body,
    );

    return _bannerFromBody(body);
  }

  /**
   * ======================================================
   * ELIMINAR
   * ======================================================
   */
  Future<void> deleteBanner(
    String id,
  ) async {
    final response = await delete(
      '$url/admin/$id',
      headers: _headers,
    );

    final body = _normalizeBody(
      response.body,
    );

    _validateResponse(
      response.statusCode ?? 500,
      body,
    );
  }

  /**
   * ======================================================
   * POSICIÓN
   * ======================================================
   */
  Future<AppBanner> updatePosition(
    String id,
    int position,
  ) async {
    final response = await patch(
      '$url/admin/$id/position',
      {
        'position': position,
      },
      headers: _headers,
    );

    final body = _normalizeBody(
      response.body,
    );

    _validateResponse(
      response.statusCode ?? 500,
      body,
    );

    return _bannerFromBody(body);
  }

  Map<String, dynamic> _decodeResponse(
      String raw,
      ) {
    if (raw.trim().isEmpty) {
      print('⚠️ [APP BANNER] El servidor devolvió un BODY vacío.');
      return {};
    }

    try {
      final decoded = json.decode(raw);

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }

      print(
        '⚠️ [APP BANNER] La respuesta JSON no es un objeto Map.',
      );

      return {};
    } catch (error, stackTrace) {
      print('');
      print('══════════════════════════════════════════════════');
      print('❌ [APP BANNER] ERROR DECODIFICANDO RESPUESTA');
      print('══════════════════════════════════════════════════');
      print('Error: $error');
      print('Respuesta recibida:');
      print(raw);
      print('StackTrace:');
      print(stackTrace);
      print('══════════════════════════════════════════════════');
      print('');

      rethrow;
    }
  }

  AppBanner _bannerFromBody(
    Map<String, dynamic> body,
  ) {
    final data = body['data'];

    if (data == null) {
      throw Exception(
        'El servidor no devolvió el banner actualizado.',
      );
    }

    return AppBanner.fromJson(
      Map<String, dynamic>.from(
        data,
      ),
    );
  }

  MediaType _imageContentType(
    String filePath,
  ) {
    final extension = filePath.split('.').last.trim().toLowerCase();

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return MediaType(
          'image',
          'jpeg',
        );

      case 'png':
        return MediaType(
          'image',
          'png',
        );

      case 'webp':
        return MediaType(
          'image',
          'webp',
        );

      default:
        return MediaType(
          'application',
          'octet-stream',
        );
    }
  }
}
