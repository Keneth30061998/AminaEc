import 'dart:convert';
import 'dart:io';

import 'package:amina_ec/src/models/response_api.dart';
import 'package:amina_ec/src/models/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

import '../../../providers/users_provider.dart';

class RegisterController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController ciController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  UserProvider usersProvider = UserProvider();

  //Metodo para seleccionar una imagen
  File? imageFile;
  ImagePicker picker = ImagePicker(); //arriba

  void register(BuildContext context) async {
    String email = emailController.text.trim();
    String name = nameController.text;
    String lastname = lastnameController.text;
    String ci = ciController.text;
    String phone = phoneController.text;
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (isValidForm(
        email, name, lastname, ci, phone, password, confirmPassword)) {
      //Para usar progress dialog
      ProgressDialog progressDialog = ProgressDialog(context: context);
      progressDialog.show(max: 100, msg: 'Registrando Usuario...');
      User user = User(
        email: email,
        name: name,
        lastname: lastname,
        ci: ci,
        phone: phone,
        password: password,
      );
      Stream stream = await usersProvider.createWithImage(user, imageFile!);
      stream.listen((res) {
        ResponseApi responseApi = ResponseApi.fromJson(json.decode(
            res)); //me permite mapear el json y poder usarlo como objeto de dart
        progressDialog.close();
        if (responseApi.success == true) {
          GetStorage().write('user', responseApi.data);
          goToUserHomePage();
          print('Reponse: ${responseApi}');
        } else {
          Get.snackbar('ERROR!!!', 'Registro fallido');
        }
      });
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

    //  validacion de imagen de usuario
    if (imageFile == null) {
      Get.snackbar('Imagen vacía', 'Seleccione una imagen');
      return false;
    }
    return true;
  }

  // Para subir una foto
  void showAlertDialog(BuildContext context) {
    Widget galleryButton = FloatingActionButton.extended(
      onPressed: () {
        Get.back();
        selectImage(ImageSource.gallery);
      },
      label: Text('Galeria'),
      icon: Icon(Icons.photo_library_outlined),
      elevation: 3,
    );
    Widget cameraButton = FloatingActionButton.extended(
      onPressed: () {
        Get.back();
        selectImage(ImageSource.camera);
      },
      label: Text('Cámara'),
      icon: Icon(Icons.camera),
      elevation: 3,
    );

    AlertDialog alertDialog = AlertDialog(
      title: Text(
        'Seleccione una opción',
        style: TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      actions: [
        galleryButton,
        cameraButton,
      ],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alertDialog;
        });
  }

  Future selectImage(ImageSource imageSource) async {
    XFile? image = await picker.pickImage(source: imageSource);
    if (image != null) {
      imageFile = File(image.path);
      update();
    }
  }

  //Metodos para moverse
  void goToUserHomePage() {
    Get.toNamed('/home');
  }

  void goToRegisterImage() {
    Get.toNamed('/register-image');
  }
}
