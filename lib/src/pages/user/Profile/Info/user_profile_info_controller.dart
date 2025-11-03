import 'package:amina_ec/src/components/Socket/socket_service.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../models/response_api.dart';
import '../../../../models/user.dart';
import '../../../../providers/users_provider.dart';

class UserProfileInfoController extends GetxController {
  var user = User.fromJson(GetStorage().read('user') ?? {}).obs;
  UserProvider userProvider = UserProvider();

  /// 🚪 Cerrar sesión del usuario
  void signOut() {
    // 🧩 1. Desconectar sockets activos
    final socketService = SocketService();
    socketService.disconnect();

    // 🧹 2. Limpiar la sesión almacenada
    final box = GetStorage();
    box.remove('user');

    // 🔄 3. Redirigir al Splash o Login
    Get.offNamedUntil('/splash', (route) => false);
  }

  /// 🗑️ Confirmar eliminación de cuenta
  Future<void> confirmDeleteAccount(BuildContext context) async {
    final TextEditingController emailController =
    TextEditingController(text: user.value.email);
    final TextEditingController passwordController = TextEditingController();

    await Get.dialog(
      AlertDialog(
        backgroundColor: whiteLight,
        title: Text(
          'Eliminar cuenta',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        content: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400),
            child: IntrinsicHeight(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Por favor, confirma tu correo y contraseña para eliminar tu cuenta permanentemente. Esta acción no se puede deshacer.',
                    style: GoogleFonts.roboto(color: almostBlack),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancelar',
              style: TextStyle(color: darkGrey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: indigoAmina),
            onPressed: () async {
              final email = emailController.text.trim();
              final password = passwordController.text.trim();

              if (email.isEmpty || password.isEmpty) {
                Get.snackbar('Error', 'Por favor completa todos los campos');
                return;
              }

              Get.back(); // Cierra el diálogo
              await _deleteAccount(context, email, password);
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: whiteLight),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount(
      BuildContext context, String email, String password) async {
    Get.dialog(const Center(child: CircularProgressIndicator()),
        barrierDismissible: false);

    ResponseApi response = await userProvider.deleteAccount(email, password);

    Get.back(); // Cierra el loader

    if (response.success == true) {
      // 🧩 Desconectar socket también al eliminar cuenta
      final socketService = SocketService();
      socketService.disconnect();

      GetStorage().erase();
      Get.offAllNamed('/splash');
      Get.snackbar('Cuenta eliminada',
          response.message ?? 'Tu cuenta fue eliminada correctamente');
    } else {
      Get.snackbar(
          'Error', response.message ?? 'No se pudo eliminar la cuenta');
      print('${response.message}');
    }
  }

  void goToProfileUpdate() {
    Get.toNamed('/user/profile/update');
  }
}
