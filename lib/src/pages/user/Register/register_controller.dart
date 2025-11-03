import 'dart:convert';
import 'dart:io';

import 'package:amina_ec/src/models/response_api.dart';
import 'package:amina_ec/src/models/user.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../globals.dart';
import '../../../components/Compress/image_compress_util.dart';
import '../../../components/Socket/socket_service.dart';
import '../../../providers/users_provider.dart';
import '../../../services/fcm_service.dart';

class RegisterController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController ciController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  UserProvider usersProvider = UserProvider();

  // Variables para subir imagen (ahora observable)
  var imageFile = Rxn<File>();
  ImagePicker picker = ImagePicker();

  // Fecha de nacimiento
  var birthDate = Rxn<DateTime>();

  // Ver/ocultar contraseña
  var obscurePassword = true.obs;
  var obscureConfirmPassword = true.obs;

  // Variables para resaltar errores
  var emailError = false.obs;
  var nameError = false.obs;
  var lastnameError = false.obs;
  var ciError = false.obs;
  var phoneError = false.obs;
  var passwordError = false.obs;
  var confirmPasswordError = false.obs;
  var imageError = false.obs;
  var birthDateError = false.obs;

  // ----------------------
  // REGISTRO COMPLETO
  // ----------------------
  Future<bool> register() async {
    String email = emailController.text.trim();
    String name = nameController.text.trim();
    String lastname = lastnameController.text.trim();
    String ci = ciController.text.trim();
    String phone = phoneController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();
    DateTime? birth = birthDate.value;

    if (!isValidForm(
        email, name, lastname, ci, phone, password, confirmPassword, birth)) {
      return false; // <--- Retorna false si el form no es válido
    }

    if (imageFile.value == null) {
      Get.snackbar('Imagen vacía', 'Seleccione una imagen');
      return false; // <--- Asegura que siempre se retorne bool
    }

    User user = User(
      email: email,
      name: name,
      lastname: lastname,
      ci: ci,
      phone: phone,
      password: password,
      birthDate: birth != null ? birth.toIso8601String().split('T')[0] : '',
    );

    try {
      Stream stream = await usersProvider.createWithImage(user, imageFile.value!); // <-- desenvuelto
      await for (var res in stream) {
        ResponseApi responseApi = ResponseApi.fromJson(json.decode(res));
        if (responseApi.success == true) {
          // 1️⃣ Guardar usuario en almacenamiento local
          GetStorage().write('user', responseApi.data);

          // 2️⃣ Actualizar sesión global
          User myUser = User.fromJson(responseApi.data);
          userSession = myUser; // 🔹 Actualización crítica

          // 3️⃣ Configurar socket con nueva sesión
          SocketService().updateUserSession(myUser);

          // 4️⃣ Enviar token FCM al backend
          try {
            final fcmToken = await FirebaseMessaging.instance.getToken();
            if (fcmToken != null) {
              await sendTokenToServer(fcmToken);
              print("✅ Token FCM enviado al backend: $fcmToken");
            }
          } catch (e) {
            print("⚠️ No se pudo enviar token FCM: $e");
          }
          return true;
        } else {
          Get.snackbar('ERROR', 'Registro fallido');
          return false;
        }
      }
    } catch (e) {
      Get.snackbar('ERROR', 'Error de conexión');
      return false;
    }

    return false; // <--- Retorno seguro al final
  }


  // ----------------------
  // VALIDACIÓN GENERAL
  // ----------------------
  bool isValidForm(
      String email,
      String name,
      String lastname,
      String ci,
      String phone,
      String password,
      String confirmPassword,
      DateTime? birthDate,
      ) {
    emailError.value = email.isEmpty || !GetUtils.isEmail(email);
    nameError.value = name.isEmpty || !GetUtils.isUsername(name);
    lastnameError.value = lastname.isEmpty || !GetUtils.isUsername(lastname);
    ciError.value = ci.isEmpty || !GetUtils.isNum(ci);
    phoneError.value = phone.isEmpty || !GetUtils.isPhoneNumber(phone);
    passwordError.value = password.isEmpty;
    confirmPasswordError.value =
        confirmPassword.isEmpty || password != confirmPassword;
    imageError.value = imageFile.value == null;
    birthDateError.value = birthDate == null;

    if (emailError.value)
      Get.snackbar('Email inválido', 'Ingrese un email válido');
    if (nameError.value)
      Get.snackbar('Nombre inválido', 'Ingrese un nombre válido');
    if (lastnameError.value)
      Get.snackbar('Apellido inválido', 'Ingrese un apellido válido');
    if (ciError.value)
      Get.snackbar('Cédula inválida', 'Ingrese un número de CI válido');
    if (phoneError.value)
      Get.snackbar('Teléfono inválido', 'Ingrese un teléfono válido');
    if (passwordError.value)
      Get.snackbar('Contraseña vacía', 'Ingrese una contraseña');
    if (confirmPasswordError.value)
      Get.snackbar(
          'Contraseña incorrecta', 'Confirme la contraseña correctamente');
    if (imageError.value) Get.snackbar('Imagen vacía', 'Seleccione una imagen');
    if (birthDateError.value)
      Get.snackbar(
          'Fecha de nacimiento requerida', 'Seleccione su fecha de nacimiento');

    return !(emailError.value ||
        nameError.value ||
        lastnameError.value ||
        ciError.value ||
        phoneError.value ||
        passwordError.value ||
        confirmPasswordError.value ||
        imageError.value ||
        birthDateError.value);
  }

  // ----------------------
  // VALIDACIONES POR PASOS
  // ----------------------
  bool isValidStep1() {
    bool valid = true;

    nameError.value = nameController.text.trim().isEmpty ||
        !GetUtils.isUsername(nameController.text.trim());
    lastnameError.value = lastnameController.text.trim().isEmpty ||
        !GetUtils.isUsername(lastnameController.text.trim());
    birthDateError.value = birthDate.value == null;

    if (nameError.value)
      Get.snackbar('Nombre inválido', 'Ingrese un nombre válido');
    if (lastnameError.value)
      Get.snackbar('Apellido inválido', 'Ingrese un apellido válido');
    if (birthDateError.value)
      Get.snackbar(
          'Fecha de nacimiento requerida', 'Seleccione su fecha de nacimiento');

    valid = !(nameError.value || lastnameError.value || birthDateError.value);
    return valid;
  }

  bool isValidStep2() {
    bool valid = true;

    emailError.value = emailController.text.trim().isEmpty ||
        !GetUtils.isEmail(emailController.text.trim());
    phoneError.value = phoneController.text.trim().isEmpty ||
        !GetUtils.isPhoneNumber(phoneController.text.trim());
    ciError.value = ciController.text.trim().isEmpty ||
        !GetUtils.isNum(ciController.text.trim());

    if (emailError.value)
      Get.snackbar('Email inválido', 'Ingrese un email válido');
    if (phoneError.value)
      Get.snackbar('Teléfono inválido', 'Ingrese un teléfono válido');
    if (ciError.value)
      Get.snackbar('Cédula inválida', 'Ingrese un número de CI válido');

    valid = !(emailError.value || phoneError.value || ciError.value);
    return valid;
  }

  bool isValidStep3() {
    bool valid = true;

    passwordError.value = passwordController.text.trim().isEmpty;
    confirmPasswordError.value = confirmPasswordController.text
        .trim()
        .isEmpty ||
        passwordController.text.trim() != confirmPasswordController.text.trim();

    if (passwordError.value)
      Get.snackbar('Contraseña vacía', 'Ingrese una contraseña');
    if (confirmPasswordError.value)
      Get.snackbar(
          'Contraseña incorrecta', 'Confirme la contraseña correctamente');

    valid = !(passwordError.value || confirmPasswordError.value);
    return valid;
  }

  // ----------------------
  // SUBIR IMAGEN
  // ----------------------
  void showAlertDialog(BuildContext context) {
    Widget galleryButton = FloatingActionButton.extended(
      onPressed: () {
        Get.back();
        selectImage(ImageSource.gallery);
      },
      label: const Text('Galería'),
      icon: const Icon(Icons.photo_library_outlined),
      elevation: 3,
    );
    Widget cameraButton = FloatingActionButton.extended(
      onPressed: () {
        Get.back();
        selectImage(ImageSource.camera);
      },
      label: const Text('Cámara'),
      icon: const Icon(Icons.camera),
      elevation: 3,
    );

    AlertDialog alertDialog = AlertDialog(
      title: const Text('Seleccione una opción',
          style: TextStyle(fontWeight: FontWeight.w500)),
      actions: [galleryButton, cameraButton],
    );

    showDialog(context: context, builder: (_) => alertDialog);
  }

  Future selectImage(ImageSource imageSource) async {
    XFile? image = await picker.pickImage(source: imageSource);
    if (image != null) {
      imageFile.value = File(image.path);
      imageError.value = false;
      update();

      // Loader elegante sobrio
      Get.dialog(
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 5,
            ),
          ),
        ),
        barrierDismissible: false,
      );

      try {
        final compressed = await ImageCompressUtil.compress(input: imageFile.value!);
        imageFile.value = compressed;
        update();
      } catch (_) {
        // fallback silencioso
      } finally {
        Get.back(); // cerrar loader
      }
    }
  }

  // ----------------------
  // FECHA DE NACIMIENTO
  // ----------------------
  void setBirthDate(DateTime date) {
    birthDate.value = date;
    birthDateError.value = false;
  }

  // ----------------------
  // NAVEGACIÓN
  // ----------------------
  void goToUserHomePage() {
    Get.offNamedUntil('user/home', (route) => false);
  }

  void goToSignaturePage(User user) {
    Get.toNamed('/signature', arguments: user);
  }

  void goToRegisterImage() {
    Get.toNamed('/register-image');
  }
}
