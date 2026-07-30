import 'dart:convert';

import 'package:amina_ec/src/environment/environment.dart';
import 'package:amina_ec/src/models/app_banner.dart';
import 'package:amina_ec/src/models/user.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AppBannerProvider extends GetConnect {
  String get url => '${Environment.API_URL}api/app-banner';

  User get _userSession {
    return User.fromJson(GetStorage().read('user') ?? {});
  }

  Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      'Authorization': _userSession.session_token ?? '',
    };
  }

  Map<String, dynamic> _normalizeBody(dynamic rawBody) {
    if (rawBody is Map<String, dynamic>) {
      return rawBody;
    }

    if (rawBody is Map) {
      return Map<String, dynamic>.from(rawBody);
    }

    if (rawBody is String && rawBody.trim().isNotEmpty) {
      final decoded = json.decode(rawBody);

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    }

    return <String, dynamic>{};
  }

  void _validateResponse(
      Response response,
      Map<String, dynamic> body,
      ) {
    final status = response.statusCode ?? 500;

    if (status < 200 || status >= 300) {
      throw Exception(
        body['message']?.toString() ??
            'El servidor devolvió el código $status.',
      );
    }

    if (body['success'] != true) {
      throw Exception(
        body['message']?.toString() ??
            'La solicitud no pudo ser procesada.',
      );
    }
  }

  /**
   * Utilizado por el Home del usuario.
   *
   * Retorna null cuando el administrador desactivó el banner.
   */
  Future<AppBanner?> getActive() async {
    final response = await get(
      '$url/active',
      headers: _headers,
    );

    final body = _normalizeBody(response.body);

    _validateResponse(response, body);

    final data = body['data'];

    if (data == null) {
      return null;
    }

    return AppBanner.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  /**
   * Utilizado por el administrador.
   *
   * Devuelve la configuración aunque esté desactivada.
   */
  Future<AppBanner?> getCurrentAdmin() async {
    final response = await get(
      '$url/admin',
      headers: _headers,
    );

    final body = _normalizeBody(response.body);

    _validateResponse(response, body);

    final data = body['data'];

    if (data == null) {
      return null;
    }

    return AppBanner.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  /**
   * Guarda el contenido y el estado activo/inactivo.
   */
  Future<AppBanner> updateBanner(AppBanner banner) async {
    final response = await put(
      '$url/admin',
      banner.toJson(),
      headers: _headers,
    );

    final body = _normalizeBody(response.body);

    _validateResponse(response, body);

    final data = body['data'];

    if (data == null) {
      throw Exception(
        'El servidor no devolvió la configuración actualizada.',
      );
    }

    return AppBanner.fromJson(
      Map<String, dynamic>.from(data),
    );
  }
}