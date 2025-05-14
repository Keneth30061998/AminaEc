import 'package:amina_ec/src/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../providers/users_provider.dart';

class RegisterController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController ciController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  UserProvider usersProvider = UserProvider();

  void register() async {
    String email = emailController.text.trim();
    String name = nameController.text;
    String lastname = lastnameController.text;
    String ci = ciController.text;
    String phone = phoneController.text;
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (isValidForm(
        email, name, lastname, ci, phone, password, confirmPassword)) {
      User user = User(
        email: email,
        name: name,
        lastname: lastname,
        ci: ci,
        phone: phone,
        password: password,
      );

      Response response = await usersProvider.create(user);

      print('Reponse: ${response.body}');

      Get.snackbar('Formulario válido', 'Registro usuario OK!');
    }
  }

  //metodo de validacion de campos
  bool isValidForm(
    String email,
    String name,
    String lastname,
    String ci,
    String phone,
    String password,
    String confirmPassword,
  ) {
    //Validaciones - datos
    if (!GetUtils.isEmail(email)) {
      Get.snackbar('Email incorrecto', 'Ingrese un email válido');
      return false;
    }
    if (!GetUtils.isUsername(name)) {
      Get.snackbar('Nombre incorrecto', 'Ingrese un nombre válido');
      return false;
    }
    if (!GetUtils.isUsername(lastname)) {
      Get.snackbar('Apellido incorrecto', 'Ingrese un apellido válido');
      return false;
    }
    if (!GetUtils.isNum(ci)) {
      Get.snackbar('Cédula incorrecta', 'Ingrese un número de CI válido');
      return false;
    }
    if (!GetUtils.isPhoneNumber(phone)) {
      Get.snackbar('Teléfono incorrecto', 'Ingrese un teléfono válido');
      return false;
    }
    //validaciones - campos vacíos
    if (email.isEmpty) {
      Get.snackbar('Email vacío', 'Ingrese un email');
      return false;
    }
    if (name.isEmpty) {
      Get.snackbar('Email vacío', 'Ingrese un email');
      return false;
    }
    if (lastname.isEmpty) {
      Get.snackbar('Email vacío', 'Ingrese un email');
      return false;
    }
    if (ci.isEmpty) {
      Get.snackbar('Email vacío', 'Ingrese un email');
      return false;
    }
    if (phone.isEmpty) {
      Get.snackbar('Email vacío', 'Ingrese un email');
      return false;
    }
    if (password.isEmpty) {
      Get.snackbar('Email vacío', 'Ingrese un email');
      return false;
    }
    if (confirmPassword.isEmpty) {
      Get.snackbar('Email vacío', 'Ingrese un email');
      return false;
    }
    // validacion - contraseñas
    if (password != confirmPassword) {
      Get.snackbar('Contraseñas no coinciden',
          'Revise las contraseñas e intente nuevamente');
      return false;
    }

    //  validacion de imagen de usuario ?

    return true;
  }
}
