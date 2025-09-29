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
    print('🔹 [UserProvider] updateWithoutImage iniciado');
    print('🌍 URL: $url/updateWithoutImage');
    print('📤 Body: ${user.toJson()}');

    Response response = await put(
      '$url/updateWithoutImage',
      user.toJson(),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': userSession.session_token ?? ''
      },
    );

    print('📡 STATUS updateWithoutImage: ${response.statusCode}');
    print('📥 Response body: ${response.body}');

    if (response.body == null) {
      print('❌ Error: response.body es null');
      Get.snackbar('Error', 'No se pudo actualizar la información');
      return ResponseApi();
    }

    if (response.statusCode == 401) {
      print('⚠️ Usuario no autorizado');
      Get.snackbar('Error', 'No está autorizado para realizar esta acción');
      return ResponseApi();
    }

    ResponseApi responseApi = ResponseApi.fromJson(response.body);
    print('✅ Update exitoso: ${responseApi.toJson()}');
    return responseApi;
  }

  // =======================
  // Actualizar usuario con imagen
  // =======================
  Future<Stream<String>> updateWithImage(User user, File image) async {
    Uri uri = Uri.parse('${Environment.API_URL_SOCKET}/api/users/updateWithImage');
    print('🔹 [UserProvider] updateWithImage iniciado');
    print('🌍 URL: $uri');
    print('📤 User body: ${json.encode(user.toJson())}');
    print('🖼️ Imagen: ${image.path}');

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
    print('📡 STATUS updateWithImage: ${response.statusCode}');
    return response.stream.transform(utf8.decoder);
  }

  // =======================
  // Registrar usuario con imagen
  // =======================
  Future<Stream<String>> createWithImage(User user, File image) async {
    Uri uri = Uri.parse('${Environment.API_URL_SOCKET}/api/users/createWithImage');
    print('🔹 [UserProvider] createWithImage iniciado');
    print('🌍 URL: $uri');
    print('📤 User body: ${json.encode(user.toJson())}');
    print('🖼️ Imagen: ${image.path}');

    final request = http.MultipartRequest('POST', uri);

    request.files.add(http.MultipartFile(
      'image',
      http.ByteStream(image.openRead().cast()),
      await image.length(),
      filename: basename(image.path),
    ));

    request.fields['user'] = json.encode(user.toJson());

    final response = await request.send();
    print('📡 STATUS createWithImage: ${response.statusCode}');
    return response.stream.transform(utf8.decoder);
  }

  // =======================
  // Registrar usuario sin imagen
  // =======================
  Future<Response> create(User user) async {
    print('🔹 [UserProvider] create iniciado');
    print('🌍 URL: $url/create');
    print('📤 Body: ${user.toJson()}');

    Response response = await post(
      '$url/create',
      user.toJson(),
      headers: {'Content-Type': 'application/json'},
    );

    print('📡 STATUS create: ${response.statusCode}');
    print('📥 Response body: ${response.body}');
    return response;
  }

  // =======================
  // Login de usuario
  // =======================
  Future<ResponseApi> login(String email, String password) async {
    print('🔹 [UserProvider] login iniciado');
    print('🌍 URL: $url/login');
    print('📤 Email: $email, Password: ******');

    Response response = await post(
      '$url/login',
      {'email': email, 'password': password},
      headers: {'Content-Type': 'application/json'},
    );

    print('📡 STATUS login: ${response.statusCode}');
    print('📥 Response body: ${response.body}');

    if (response.body == null) {
      print('❌ Error: response.body es null');
      Get.snackbar('Error', 'No se pudo ejecutar la petición');
      return ResponseApi();
    }

    ResponseApi responseApi = ResponseApi.fromJson(response.body);
    print('✅ Login exitoso: ${responseApi.toJson()}');
    return responseApi;
  }

  // =======================
  // Recuperar contraseña
  // =======================
  Future<ResponseApi> sendRecoveryCode(String email) async {
    print('🔹 [UserProvider] sendRecoveryCode iniciado');
    print('🌍 URL: $url/recover-password');
    print('📤 Email: $email');

    Response response = await post(
      '$url/recover-password',
      {'email': email},
      headers: {'Content-Type': 'application/json'},
    );

    print('📡 STATUS sendRecoveryCode: ${response.statusCode}');
    print('📥 Response body: ${response.body}');

    if (response.body is Map<String, dynamic>) {
      return ResponseApi.fromJson(response.body);
    } else if (response.body is String) {
      return ResponseApi.fromJson(json.decode(response.body));
    } else {
      print('⚠️ Respuesta inesperada en sendRecoveryCode');
      return ResponseApi(
        success: false,
        message: 'Respuesta inesperada del servidor',
      );
    }
  }

  // =======================
  // Resetear contraseña
  // =======================
  Future<ResponseApi> resetPassword(
      String email, String code, String newPassword) async {
    print('🔹 [UserProvider] resetPassword iniciado');
    print('🌍 URL: $url/reset-password');
    print('📤 Email: $email, Code: $code, NewPassword: ******');

    Response response = await post(
      '$url/reset-password',
      {
        'email': email,
        'code': code,
        'newPassword': newPassword,
      },
      headers: {'Content-Type': 'application/json'},
    );

    print('📡 STATUS resetPassword: ${response.statusCode}');
    print('📥 Response body: ${response.body}');
    return ResponseApi.fromJson(response.body);
  }
}
