import 'dart:async';

import 'package:amina_ec/src/models/response_api.dart';
import 'package:amina_ec/src/utils/textos.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';

import '../../../globals.dart';
import '../../components/Socket/socket_service.dart';
import '../../models/user.dart';
import '../../providers/users_provider.dart';
import '../../services/fcm_service.dart';
import '../../utils/color.dart';

class LoginController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  var emailText = ''.obs;
  var passwordText = ''.obs;

  UserProvider usersProvider = UserProvider();
  late User user = usersProvider.userSession;

  var obscureText = true.obs;
  var isPressed = false.obs;
  bool _loginInProgress = false;

  void goToRegisterPage() {
    Get.toNamed('/register');
  }

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
    if (_loginInProgress) return;

    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    if (!isValidForm(email, password)) return;

    _loginInProgress = true;
    ProgressDialog progressDialog = ProgressDialog(context: context);
    progressDialog.show(max: 100, msg: txtIniciandoSesion);

    User? authenticatedUser;
    String successMessage = '';
    var stage = 'peticion';

    try {
      ResponseApi responseApi = await usersProvider.login(email, password);
      if (!context.mounted) return;

      if (responseApi.success != true) {
        Get.snackbar(
          'Login Fallido',
          responseApi.message ?? 'No se pudo iniciar sesión',
        );
        return;
      }

      stage = 'datos_respuesta';
      final data = responseApi.data;
      if (kDebugMode) {
        debugPrint(
          '[AMINA][LoginController] dataType=${data.runtimeType}',
        );
      }
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Datos de usuario inválidos');
      }

      // Convertir antes de guardar: una respuesta inválida no reemplaza la sesión.
      stage = 'modelo_usuario';
      final myUser = User.fromJson(data);
      if (myUser.session_token == null || myUser.session_token!.trim().isEmpty ||
          myUser.roles == null || myUser.roles!.isEmpty) {
        throw const FormatException('Modelo de usuario sin sesión o roles');
      }
      stage = 'guardar_sesion';
      await GetStorage().write('user', data);
      userSession = myUser;
      usersProvider.userSession = myUser;
      user = myUser;

      // Los servicios auxiliares no deben convertir un login válido en fallido.
      unawaited(
        Future<void>.sync(() => SocketService().updateUserSession(myUser))
            .catchError((Object error, StackTrace stackTrace) {
          if (kDebugMode) {
            debugPrint('[AMINA][LoginController] etapa=socket errorType=${error.runtimeType}');
          }
        }),
      );
      unawaited(
        Future<void>.sync(registerCurrentPushToken)
            .catchError((Object error, StackTrace stackTrace) {
          if (kDebugMode) {
            debugPrint('[AMINA][LoginController] etapa=push errorType=${error.runtimeType}');
          }
        }),
      );

      authenticatedUser = myUser;
      successMessage = responseApi.message ?? '';
    } catch (error) {
      if (kDebugMode) {
        debugPrint(
          '[AMINA][LoginController] etapa=$stage errorType=${error.runtimeType}',
        );
      }
      final message = stage == 'modelo_usuario' || stage == 'datos_respuesta'
          ? 'Los datos recibidos no coinciden con el modelo de usuario de la app.'
          : stage == 'guardar_sesion'
          ? 'No se pudo guardar la sesión en el dispositivo.'
          : 'No se pudo completar el inicio de sesión.';
      Get.snackbar('Error', message);
    } finally {
      _loginInProgress = false;
      if (context.mounted) progressDialog.close();
    }

    final myUser = authenticatedUser;
    if (myUser == null || !context.mounted) return;

    FocusScope.of(context).unfocus();

    if (myUser.roles != null && myUser.roles!.length > 1) {
      goToRolesPage();
    } else if (myUser.roles != null && myUser.roles!.isNotEmpty) {
      if (myUser.roles!.first.id == '3') {
        goToCoachHomePage();
      } else {
        goToUserHomePage();
      }
    } else {
      Get.snackbar('Error', 'No se encontraron roles asignados');
      return;
    }

    Get.snackbar('Login Exitoso', successMessage);
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

  void showRecoveryDialog(BuildContext context) {
    final email = emailController.text.trim();

    if (!GetUtils.isEmail(email)) {
      Get.snackbar('Email inválido', 'Ingresa un correo válido');
      return;
    }

    Get.defaultDialog(
      title: 'Recuperar contraseña',
      content: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Se enviará un código a tu correo',
              style: TextStyle(
                color: darkGrey,
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                ResponseApi res = await usersProvider.sendRecoveryCode(email);
                Get.back();
                if (res.success == true) {
                  showCodeDialog(context, email);
                } else {
                  Get.snackbar(
                      'Error', res.message ?? 'No se pudo enviar el código');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: indigoAmina,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Enviar código',
                style: TextStyle(
                  color: whiteLight,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showCodeDialog(BuildContext context, String email) {
    final codeController = TextEditingController();
    final passController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Ingresar código',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: darkGrey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _textField(
                    true,
                    'Código recibido',
                    codeController,
                    TextInputType.number,
                    [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 10),
                  _textField(
                    false,
                    'Nueva contraseña',
                    passController,
                    TextInputType.text,
                    [],
                  ),
                  const SizedBox(height: 10),
                  _textField(
                    false,
                    'Confirmar contraseña',
                    confirmController,
                    TextInputType.text,
                    [],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final code = codeController.text.trim();
                      final pass = passController.text.trim();
                      final confirm = confirmController.text.trim();

                      if (pass != confirm) {
                        Get.snackbar('Error', 'Las contraseñas no coinciden');
                        return;
                      }

                      ResponseApi res =
                      await usersProvider.resetPassword(email, code, pass);
                      if (res.success == true) {
                        Navigator.of(context).pop();
                        Get.snackbar('Éxito', 'Contraseña actualizada');
                      } else {
                        Get.snackbar(
                            'Error', res.message ?? 'No se pudo actualizar');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: indigoAmina,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Actualizar contraseña',
                      style: TextStyle(
                        color: whiteLight,
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Cierre manual
                    },
                    child: const Text(
                      'Cerrar',
                      style: TextStyle(
                        color: darkGrey,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _textField(
      bool visible,
      String text,
      TextEditingController controller,
      TextInputType type,
      List<TextInputFormatter> formatters,
      ) {
    return TextField(
      controller: controller,
      keyboardType: type,
      inputFormatters: formatters,
      obscureText: visible,
      decoration: InputDecoration(
        floatingLabelStyle: TextStyle(color: whiteGrey),
        labelText: text,
        hintText: text,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: indigoAmina),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: indigoAmina),
        ),
      ),
    );
  }
}
