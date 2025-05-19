import 'package:amina_ec/src/models/response_api.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../providers/users_provider.dart';

class LoginController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  UserProvider usersProvider = UserProvider();

  //Moverse a Registro de usuario
  void goToRegisterPage() {
    Get.toNamed('/register');
  }

  //Moverse a User - Home ? Roles
  void goToUserHomePage() {
    Get.toNamed('/home');
  }

  void login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (isValidForm(email, password)) {
      ResponseApi responseApi = await usersProvider.login(email, password);

      print('Response Api ${responseApi.toJson()}');

      if (responseApi.success == true) {
        //Para guardar el usuario en el inicio de sesion
        GetStorage().write('user', responseApi.data);

        Get.snackbar('Login Exitoso', responseApi.message ?? '');

        goToUserHomePage();
      } else {
        Get.snackbar('Login Fallido', responseApi.message ?? '');
      }
    }
  }

  bool isValidForm(String email, String password) {
    if (!GetUtils.isEmail(email)) {
      Get.snackbar('Email Incorrecto', 'Ingrese un email válido');
      return false;
    }
    if (email.isEmpty) {
      Get.snackbar('Email Vacío', 'Ingrese su email');
      return false;
    }
    if (password.isEmpty) {
      Get.snackbar('Contraseña vacía', 'Ingrese su contraseña');
      return false;
    }
    return true;
  }
}
