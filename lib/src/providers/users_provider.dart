import 'dart:convert';
import 'dart:io';

import 'package:amina_ec/src/environment/environment.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

import '../models/response_api.dart';
import '../models/user.dart';

class UserProvider extends GetConnect {
  // Base URL
  String url = '${Environment.API_URL}api/users';

  // User session
  User userSession = User.fromJson(GetStorage().read('user') ?? {});

  // Update user (no image)
  Future<ResponseApi> update(User user) async {
    Response response = await put(
      '$url/updateWithoutImage',
      user.toJson(),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': userSession.session_token ?? ''
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
    Uri uri =
        Uri.parse('${Environment.API_URL_SOCKET}/api/users/updateWithImage');

    final request = http.MultipartRequest('PUT', uri);

    request.headers['Authorization'] = userSession.session_token ?? '';
    request.files.add(http.MultipartFile(
      'image',
      http.ByteStream(image.openRead().cast()),
      await image.length(),
      filename: basename(image.path),
    ));

    request.fields['user'] = json.encode(user.toJson());

    final response = await request.send();
    return response.stream.transform(utf8.decoder);
  }

  // Create user (with image)
  Future<Stream<String>> createWithImage(User user, File image) async {
    Uri uri =
        Uri.parse('${Environment.API_URL_SOCKET}/api/users/createWithImage');

    final request = http.MultipartRequest('POST', uri);

    request.files.add(http.MultipartFile(
      'image',
      http.ByteStream(image.openRead().cast()),
      await image.length(),
      filename: basename(image.path),
    ));

    request.fields['user'] = json.encode(user.toJson());

    final response = await request.send();
    return response.stream.transform(utf8.decoder);
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
    Response response = await post(
      '$url/login',
      {'email': email, 'password': password},
      headers: {'Content-Type': 'application/json'},
    );

    if (response.body == null) {
      Get.snackbar('Error', 'No se pudo ejecutar la petición');
      return ResponseApi();
    }

    return ResponseApi.fromJson(response.body);
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
      String email, String code, String newPassword) async {
    Response response = await post(
      '$url/reset-password',
      {
        'email': email,
        'code': code,
        'newPassword': newPassword,
      },
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
        final body =
            response.body is Map ? response.body : json.decode(response.body);
        if (body['success'] == true && body['attended_classes'] != null) {
          return body['attended_classes'] as int;
        }
      }
    } catch (_) {}

    return 0;
  }

  // ✅ Completed rides (new)
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
        final body =
            response.body is Map ? response.body : json.decode(response.body);

        if (body['success'] == true) {
          final v = body['completed_rides'] ??
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
        {
          'email': email,
          'password': password,
        },
        headers: {
          'Content-Type': 'application/json',
          'Authorization': userSession.session_token ?? '',
        },
      );

      final Map<String, dynamic> data =
          response.body is String ? jsonDecode(response.body) : response.body;

      return ResponseApi.fromJson(data);
    } catch (e) {
      return ResponseApi(success: false, message: 'Error: $e');
    }
  }
}
