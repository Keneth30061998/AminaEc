import 'package:amina_ec/src/environment/environment.dart';
import 'package:get/get.dart';

import '../models/response_api.dart';
import '../models/user.dart';

class UserProvider extends GetConnect {
  String url = Environment.API_URL + 'api/users';

  //registrar un usuario
  Future<Response> create(User user) async {
    Response response = await post(
      '$url/create',
      user.toJson(),
      headers: {'Content-Type': 'application/json'},
    );
    return response; //espera hasta que el servidor nos retorne una respuesta
  }

  //login de usuario
  Future<ResponseApi> login(String email, String password) async {
    Response response = await post(
        '$url/login', {'email': email, 'password': password},
        headers: {'Content-Type': 'application/json'});

    if (response.body == null) {
      Get.snackbar('Error', 'No se pudo ejecutar la peticion');
      return ResponseApi();
    }
    ResponseApi responseApi = ResponseApi.fromJson(response.body);
    return responseApi;
  }
}
