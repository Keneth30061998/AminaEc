import 'package:amina_ec/src/models/response_api.dart';
import 'package:amina_ec/src/utils/textos.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

import '../../components/Socket/socket_service.dart';
import '../../models/user.dart';
import '../../providers/users_provider.dart';

class LoginController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  UserProvider usersProvider = UserProvider();

  User user = User.fromJson(GetStorage().read('user') ?? {});

  var obscureText = true.obs;
  var isPressed = false.obs;

  //Moverse a Registro de usuario
  void goToRegisterPage() {
    Get.toNamed('/register');
  }

  //Moverse a User - Home ? Roles
  void goToUserHomePage() {
    Get.offNamedUntil('/user/home', (route) => false);
  }

  void goToCoachHomePage() {
    Get.offNamedUntil('/coach/home', (route) => false);
  }

  void goToRolesPage() {
    Get.offNamedUntil('/roles', (route) => false);
  }

  void login(BuildContext context) async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (isValidForm(email, password)) {
      //Para usar progress dialog
      ProgressDialog progressDialog = ProgressDialog(context: context);
      progressDialog.show(max: 100, msg: txt_iniciando_sesion);
      ResponseApi responseApi = await usersProvider.login(email, password);

      print('Response Api ${responseApi.toJson()}');

      if (responseApi.success == true) {
        //Para guardar el usuario en el inicio de sesion
        GetStorage().write('user', responseApi.data);
        User myUser = User.fromJson(GetStorage().read('user') ?? {});

        progressDialog.close();
        // Actualiza el usuario en SocketService
        // Actualiza sesión en socket con el nuevo token
        SocketService().updateUserSession(myUser);
        //SocketService().setUser(myUser);
        SocketService().connect();
        print('Roles del cliente: ${myUser.roles!.length}');
        if (myUser.roles!.length > 1) {
          goToRolesPage();
        } else {
          print('roles: ${myUser.roles!.first.id}');
          if (myUser.roles!.first.id == '3') {
            goToCoachHomePage();
          } else {
            goToUserHomePage();
          }
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
