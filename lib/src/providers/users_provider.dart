import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:amina_ec/src/environment/environment.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

import '../models/response_api.dart';
import '../models/user.dart';
import '../utils/login_response_parser.dart';

class UserProvider extends GetConnect {
  // Base URL
  String url =
      '${Environment.API_URL.replaceFirst(RegExp(r'/+$'), '')}/api/users';

  // User session
  User userSession = _readStoredSession();

  static User _readStoredSession() {
    try {
      final data = decodeJsonObject(GetStorage().read('user'));
      return User.fromJson(data ?? <String, dynamic>{});
    } catch (error) {
      if (kDebugMode) {
        debugPrint(
          '[AMINA][UserProvider] etapa=sesion_guardada '
              'errorType=${error.runtimeType}',
        );
      }
      return User.fromJson(<String, dynamic>{});
    }
  }

  // Update user (no image)
  Future<ResponseApi> update(User user) async {
    Response response = await put(
      '$url/updateWithoutImage',
      user.toJson(),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': userSession.session_token ?? '',
      },
    );

    if (response.body == null) {
      Get.snackbar('Error', 'No se pudo actualizar la información');
      return ResponseApi();
    }

    if (response.statusCode == 401) {
      Get.snackbar('Error', 'No está autorizado para realizar esta acción');
      return ResponseApi();
    }

    return ResponseApi.fromJson(response.body);
  }

  // Update user (with image)
  Future<Stream<String>> updateWithImage(User user, File image) async {
    Uri uri = Uri.parse(
      '${Environment.API_URL_SOCKET}/api/users/updateWithImage',
    );

    final request = http.MultipartRequest('PUT', uri);

    request.headers['Authorization'] = userSession.session_token ?? '';
    request.files.add(
      http.MultipartFile(
        'image',
        http.ByteStream(image.openRead().cast()),
        await image.length(),
        filename: basename(image.path),
      ),
    );

    request.fields['user'] = json.encode(user.toJson());

    final response = await request.send();
    return response.stream.transform(utf8.decoder);
  }

  // Create user (with image)
  Future<ResponseApi> createWithImage(User user, File image) async {
    final uri = Uri.parse('$url/createWithImage');
    final request = http.MultipartRequest('POST', uri);

    request.files.add(
      http.MultipartFile(
        'image',
        http.ByteStream(image.openRead().cast()),
        await image.length(),
        filename: basename(image.path),
      ),
    );

    request.fields['user'] = json.encode(user.toJson());

    final streamedResponse = await request
        .send()
        .timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamedResponse);

    if (kDebugMode) {
      debugPrint(
        '[AMINA][createWithImage] HTTP=${response.statusCode} body=${response.body}',
      );
    }

    if (response.body.trim().isEmpty) {
      return ResponseApi(
        success: false,
        message: 'Respuesta vacía del servidor (HTTP ${response.statusCode})',
      );
    }

    final decoded = json.decode(response.body);
    if (decoded is Map<String, dynamic>) {
      return ResponseApi.fromJson(decoded);
    }

    return ResponseApi(
      success: false,
      message: 'Formato de respuesta inválido (HTTP ${response.statusCode})',
    );
  }

  // Create user (no image)
  Future<Response> create(User user) async {
    Response response = await post(
      '$url/create',
      user.toJson(),
      headers: {'Content-Type': 'application/json'},
    );

    return response;
  }

  // Login
  Future<ResponseApi> login(String email, String password) async {
    var stage = 'peticion';
    try {
      if (kDebugMode) {
        final uri = Uri.tryParse('$url/login');
        final target = uri == null
            ? 'URL no valida'
            : '${uri.scheme}://${uri.host}'
            '${uri.hasPort ? ':${uri.port}' : ''}${uri.path}';
        debugPrint('[AMINA][UserProvider] destino=$target');
      }
      final Response response = await post(
        '$url/login',
        {'email': email, 'password': password},
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 20));

      if (kDebugMode) {
        final contentType =
            response.headers?['content-type'] ??
                response.headers?['Content-Type'] ??
                'sin cabecera';
        debugPrint(
          '[AMINA][UserProvider] HTTP=${response.statusCode} '
              'contentType=$contentType bodyType=${response.body.runtimeType}',
        );
      }

      stage = 'parser';
      final data = parseLoginResponse(
        statusCode: response.statusCode,
        body: response.body ?? response.bodyString,
      );
      if (kDebugMode) {
        debugPrint(
          '[AMINA][UserProvider] parserSuccess=${data['success']} '
              'dataType=${data['data'].runtimeType}',
        );
      }
      if (data['success'] != true) {
        return ResponseApi(success: false, message: data['message'] as String);
      }

      stage = 'modelo_respuesta';
      return ResponseApi.fromJson(data);
    } on TimeoutException {
      if (kDebugMode) {
        debugPrint(
          '[AMINA][UserProvider] etapa=$stage errorType=TimeoutException',
        );
      }
      return ResponseApi(
        success: false,
        message:
        'El servidor tardó demasiado en responder. Inténtalo de nuevo.',
      );
    } on SocketException {
      if (kDebugMode) {
        debugPrint(
          '[AMINA][UserProvider] etapa=$stage errorType=SocketException',
        );
      }
      return ResponseApi(
        success: false,
        message: 'No se pudo conectar con el servidor. Revisa tu conexión.',
      );
    } on HandshakeException {
      if (kDebugMode) {
        debugPrint(
          '[AMINA][UserProvider] etapa=$stage errorType=HandshakeException',
        );
      }
      return ResponseApi(
        success: false,
        message: 'No se pudo establecer una conexión segura con el servidor.',
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint(
          '[AMINA][UserProvider] etapa=$stage errorType=${error.runtimeType}',
        );
      }
      return ResponseApi(
        success: false,
        message: stage == 'modelo_respuesta'
            ? 'La respuesta recibida no coincide con el modelo de la aplicación.'
            : 'No se pudo procesar el inicio de sesión. Inténtalo de nuevo.',
      );
    }
  }

  // Send recovery code
  Future<ResponseApi> sendRecoveryCode(String email) async {
    Response response = await post(
      '$url/recover-password',
      {'email': email},
      headers: {'Content-Type': 'application/json'},
    );

    if (response.body is Map<String, dynamic>) {
      return ResponseApi.fromJson(response.body);
    } else if (response.body is String) {
      return ResponseApi.fromJson(json.decode(response.body));
    } else {
      return ResponseApi(
        success: false,
        message: 'Respuesta inesperada del servidor',
      );
    }
  }

  // Reset password
  Future<ResponseApi> resetPassword(
      String email,
      String code,
      String newPassword,
      ) async {
    Response response = await post(
      '$url/reset-password',
      {'email': email, 'code': code, 'newPassword': newPassword},
      headers: {'Content-Type': 'application/json'},
    );

    return ResponseApi.fromJson(response.body);
  }

  // Attended classes (legacy)
  Future<int> getAttendedClasses(String token, {String? userId}) async {
    try {
      Response response = await get(
        '$url/attended-classes',
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200 && response.body != null) {
        final body = response.body is Map
            ? response.body
            : json.decode(response.body);
        if (body['success'] == true && body['attended_classes'] != null) {
          return body['attended_classes'] as int;
        }
      }
    } catch (_) {}

    return 0;
  }

  // Completed rides (new)
  Future<int> getCompletedRides(String token, {String? userId}) async {
    try {
      final query = <String, String>{};
      if (userId != null && userId.trim().isNotEmpty) {
        query['user_id'] = userId.trim();
      }

      Response response = await get(
        '$url/completed-rides',
        query: query,
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200 && response.body != null) {
        final body = response.body is Map
            ? response.body
            : json.decode(response.body);

        if (body['success'] == true) {
          final v =
              body['completed_rides'] ??
                  body['completedRides'] ??
                  body['rides_completed'] ??
                  body['attended_classes'];

          if (v != null) return int.tryParse(v.toString()) ?? 0;
        }
      }
    } catch (_) {}

    return 0;
  }

  // Delete account
  Future<ResponseApi> deleteAccount(String email, String password) async {
    try {
      final response = await post(
        '$url/delete-account',
        {'email': email, 'password': password},
        headers: {
          'Content-Type': 'application/json',
          'Authorization': userSession.session_token ?? '',
        },
      );

      final Map<String, dynamic> data = response.body is String
          ? jsonDecode(response.body)
          : response.body;

      return ResponseApi.fromJson(data);
    } catch (e) {
      return ResponseApi(success: false, message: 'Error: $e');
    }
  }
}
