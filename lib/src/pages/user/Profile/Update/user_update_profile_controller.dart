import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

import '../../../../models/response_api.dart';
import '../../../../models/user.dart';
import '../../../../providers/users_provider.dart';
import '../Info/user_profile_info_controller.dart';

class UserProfileUpdateController extends GetxController {
  User user = User.fromJson(GetStorage().read('user'));

  TextEditingController nameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController ciController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  UserProvider usersProvider = UserProvider();

  //Metodo para seleccionar una imagen
  File? imageFile;
  ImagePicker picker = ImagePicker(); //arriba

  UserProfileInfoController userProfileInfoController = Get.find();

  //Cargar datos del usuario - constructor
  UserProfileUpdateController() {
    nameController.text = user.name ?? '';
    lastnameController.text = user.lastname ?? '';
    ciController.text = user.ci ?? '';
    phoneController.text = user.phone ?? '';
  }

  void updateProfile(BuildContext context) async {
    String name = nameController.text;
    String lastname = lastnameController.text;
    String ci = ciController.text;
    String phone = phoneController.text;

    if (isValidForm(name, lastname, ci, phone)) {
      //Para usar progress dialog
      ProgressDialog progressDialog = ProgressDialog(context: context);
      progressDialog.show(max: 100, msg: 'Actualizando Usuario...');

      User myUser = User(
        id: user.id,
        name: name,
        lastname: lastname,
        ci: ci,
        phone: phone,
        //enviar el session token
        session_token: user.session_token,
      );

      if (imageFile == null) {
        ResponseApi responseApi = await usersProvider.update(myUser);
        //print('Response Api Update : ${responseApi.data}');
        if (responseApi.success == true) {
          //almacernar en sesion los cambios
          GetStorage().write('user', responseApi.data);
          userProfileInfoController.user.value =
              User.fromJson(GetStorage().read('user'));
          progressDialog.close();
        }
      } else {
        Stream stream = await usersProvider.updateWithImage(myUser, imageFile!);
        stream.listen((res) {
          //print('Respuesta cruda: $res');
          progressDialog.close();

          ResponseApi responseApi = ResponseApi.fromJson(json.decode(res));

          //print('Response Api Update : ${responseApi.data}');
          Get.snackbar('Registro', responseApi.message ?? '');

          if (responseApi.success == true) {
            GetStorage().write('user', responseApi.data);
            userProfileInfoController.user.value =
                User.fromJson(GetStorage().read('user') ?? {});
          } else {
            Get.snackbar('Registro Fallido E2', responseApi.message ?? '');
          }
        });
      }
    }
  }

  //metodo de validacion de campos
  bool isValidForm(
    String name,
    String lastname,
    String ci,
    String phone,
  ) {
    //Validaciones - datos

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
    Get.toNamed('/user/home');
  }

  void goToRegisterImage() {
    Get.toNamed('/register-image');
  }
}
