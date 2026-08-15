import 'dart:convert';
import 'dart:io';

import 'package:amina_ec/src/environment/environment.dart';
import 'package:amina_ec/src/models/app_banner.dart';
import 'package:http_parser/http_parser.dart';
import 'package:amina_ec/src/models/user.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class AppBannerProvider extends GetConnect {
  String get url => '${Environment.API_URL}api/app-banner';

  User get _userSession => User.fromJson(GetStorage().read('user') ?? {});

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': _userSession.session_token ?? '',
      };

  Map<String, dynamic> _normalizeBody(dynamic rawBody) {
    if (rawBody is Map<String, dynamic>) return rawBody;
    if (rawBody is Map) return Map<String, dynamic>.from(rawBody);
    if (rawBody is String && rawBody.trim().isNotEmpty) {
      final decoded = json.decode(rawBody);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    }
    return <String, dynamic>{};
  }

  void _validateResponse(int statusCode, Map<String, dynamic> body) {
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

  Future<AppBanner?> getActive() async {
    final response = await get('$url/active', headers: _headers);
    final body = _normalizeBody(response.body);
    _validateResponse(response.statusCode ?? 500, body);
    final data = body['data'];
    if (data == null) return null;
    return AppBanner.fromJson(Map<String, dynamic>.from(data));
  }

  Future<AppBanner?> getCurrentAdmin() async {
    final response = await get('$url/admin', headers: _headers);
    final body = _normalizeBody(response.body);
    _validateResponse(response.statusCode ?? 500, body);
    final data = body['data'];
    if (data == null) return null;
    return AppBanner.fromJson(Map<String, dynamic>.from(data));
  }

  Future<AppBanner> updateBanner(
    AppBanner banner, {
    File? imageFile,
  }) async {
    if (imageFile == null) {
      final response =
          await put('$url/admin', banner.toJson(), headers: _headers);
      final body = _normalizeBody(response.body);
      _validateResponse(response.statusCode ?? 500, body);
      return _bannerFromBody(body);
    }

    final request = http.MultipartRequest('PUT', Uri.parse('$url/admin'));
    request.headers['Authorization'] = _userSession.session_token ?? '';
    request.fields['banner'] = json.encode(banner.toJson());
    final imageContentType =
    _imageContentType(imageFile.path);

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        filename: imageFile.path
            .split(Platform.pathSeparator)
            .last,
        contentType: imageContentType,
      ),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    Map<String, dynamic> body = {};
    if (response.body.trim().isNotEmpty) {
      final decoded = json.decode(response.body);
      if (decoded is Map) body = Map<String, dynamic>.from(decoded);
    }
    _validateResponse(response.statusCode, body);
    return _bannerFromBody(body);
  }

  AppBanner _bannerFromBody(Map<String, dynamic> body) {
    final data = body['data'];
    if (data == null) {
      throw Exception('El servidor no devolvió la configuración actualizada.');
    }
    return AppBanner.fromJson(Map<String, dynamic>.from(data));
  }

  MediaType _imageContentType(String filePath) {
    final extension = filePath
        .split('.')
        .last
        .trim()
        .toLowerCase();

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');

      case 'png':
        return MediaType('image', 'png');

      case 'webp':
        return MediaType('image', 'webp');

      default:
        return MediaType(
          'application',
          'octet-stream',
        );
    }
  }
}
