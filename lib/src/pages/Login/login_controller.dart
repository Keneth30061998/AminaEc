import 'package:amina_ec/src/models/response_api.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../models/user.dart';
import '../../providers/users_provider.dart';

class LoginController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  UserProvider usersProvider = UserProvider();

  User user = User.fromJson(GetStorage().read('user') ?? {});

  //Moverse a Registro de usuario
  void goToRegisterPage() {
    Get.toNamed('/register');
  }

  //Moverse a User - Home ? Roles
  void goToUserHomePage() {
    Get.offNamedUntil('/user/home', (route) => false);

    Get.toNamed('/user/home');
  }

  void goToRolesPage() {
    Get.offNamedUntil('/roles', (route) => false);
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
        User myUser = User.fromJson(GetStorage().read('user') ?? {});
        print('Roles del cliente: ${myUser.roles!.length}');
        if (myUser.roles!.length > 1) {
          goToRolesPage();
        } else {
          goToUserHomePage();
        }
        Get.snackbar('Login Exitoso', responseApi.message ?? '');
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
