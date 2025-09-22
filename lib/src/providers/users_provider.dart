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
  // URL base
  String url = '${Environment.API_URL}api/users';

  // Sesión del usuario
  User userSession = User.fromJson(GetStorage().read('user') ?? {});

  // =======================
  // Actualizar usuario sin imagen
  // =======================
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

    ResponseApi responseApi = ResponseApi.fromJson(response.body);
    return responseApi;
  }

  // =======================
  // Actualizar usuario con imagen
  // =======================
  Future<Stream<String>> updateWithImage(User user, File image) async {
    Uri uri = Uri.parse('${Environment.API_URL_OLD}/api/users/updateWithImage');
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

  // =======================
  // Registrar usuario con imagen
  // =======================
  Future<Stream<String>> createWithImage(User user, File image) async {
    Uri uri = Uri.parse('${Environment.API_URL_OLD}/api/users/createWithImage');
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

  // =======================
  // Registrar usuario sin imagen
  // =======================
  Future<Response> create(User user) async {
    Response response = await post(
      '$url/create',
      user.toJson(),
      headers: {'Content-Type': 'application/json'},
    );
    return response;
  }

  // =======================
  // Login de usuario
  // =======================
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

    ResponseApi responseApi = ResponseApi.fromJson(response.body);
    return responseApi;
  }

  // Recuperar contraseña
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
          success: false, message: 'Respuesta inesperada del servidor');
    }
  }

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
}
