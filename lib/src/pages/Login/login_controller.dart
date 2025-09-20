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
      ProgressDialog progressDialog = ProgressDialog(context: context);
      progressDialog.show(max: 100, msg: txtIniciandoSesion);

      try {
        ResponseApi responseApi = await usersProvider.login(email, password);

        if (responseApi.success == true) {
          // Guardar usuario en almacenamiento local
          GetStorage().write('user', responseApi.data);
          User myUser = User.fromJson(GetStorage().read('user') ?? {});

          // Actualizar sesión en socket
          SocketService().updateUserSession(myUser);
          SocketService().connect();

          progressDialog.close();

          // Redirección según rol
          if (myUser.roles != null && myUser.roles!.length > 1) {
            goToRolesPage();
          } else {
            if (myUser.roles != null && myUser.roles!.isNotEmpty) {
              if (myUser.roles!.first.id == '3') {
                goToCoachHomePage();
              } else {
                goToUserHomePage();
              }
            } else {
              Get.snackbar('Error', 'No se encontraron roles asignados');
            }
          }

          Get.snackbar('Login Exitoso', responseApi.message ?? '');
        } else {
          progressDialog.close(); // 🔥 Cierre garantizado en login fallido
          Get.snackbar('Login Fallido',
              responseApi.message ?? 'Credenciales incorrectas');
        }
      } catch (e) {
        progressDialog.close(); // 🔥 Cierre garantizado en excepción
        Get.snackbar('Error', 'Ocurrió un problema: ${e.toString()}');
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
