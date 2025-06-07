import 'dart:convert';
import 'dart:io';

import 'package:amina_ec/src/models/coach.dart';
import 'package:amina_ec/src/models/schedule.dart';
import 'package:amina_ec/src/models/user.dart';
import 'package:amina_ec/src/providers/coachs_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

class AdminCoachRegisterController extends GetxController {
  // Datos personales
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController ciController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  // Datos del coach
  TextEditingController hobbyController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController presentationController = TextEditingController();

  // Imagen
  File? imageFile;
  ImagePicker picker = ImagePicker();

  // Horarios
  final List<String> dias = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo'
  ];
  var horaEntrada = <String, TimeOfDay?>{}.obs;
  var horaSalida = <String, TimeOfDay?>{}.obs;
  var estadoDia = <String, bool>{}.obs;

  CoachProvider coachProvider = CoachProvider();

  @override
  void onInit() {
    super.onInit();
    for (var dia in dias) {
      horaEntrada[dia] = null;
      horaSalida[dia] = null;
      estadoDia[dia] = false;
    }
  }

  void seleccionarHora(String tipo, String dia, BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      TimeOfDay? entrada = horaEntrada[dia];
      TimeOfDay? salida = horaSalida[dia];

      if (tipo == 'entrada') {
        if (salida != null && _compararHoras(picked, salida) >= 0) {
          Get.snackbar('Hora inválida',
              'La hora de entrada no puede ser mayor o igual que la hora de salida.',
              backgroundColor: Colors.redAccent, colorText: Colors.white);
          return;
        }
        horaEntrada[dia] = picked;
      } else {
        if (entrada != null && _compararHoras(entrada, picked) >= 0) {
          Get.snackbar('Hora inválida',
              'La hora de salida no puede ser menor o igual que la hora de entrada.',
              backgroundColor: Colors.redAccent, colorText: Colors.white);
          return;
        }
        horaSalida[dia] = picked;
      }

      update();
    }
  }

  int _compararHoras(TimeOfDay hora1, TimeOfDay hora2) {
    final minutos1 = hora1.hour * 60 + hora1.minute;
    final minutos2 = hora2.hour * 60 + hora2.minute;
    return minutos1.compareTo(minutos2);
  }

  String formatHora(TimeOfDay? time) {
    if (time == null) return 'Seleccionar';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void showAlertDialog(BuildContext context) {
    Widget galleryButton = FloatingActionButton.extended(
      onPressed: () {
        Get.back();
        selectImage(ImageSource.gallery);
      },
      label: Text('Galería'),
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
      title: Text('Seleccione una opción',
          style: TextStyle(fontWeight: FontWeight.w500)),
      actions: [galleryButton, cameraButton],
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

  void goToRegisterAdminCoachImage() {
    Get.toNamed('/admin/coach/register-image');
  }

  void goToRegisterAdminCoachSchedule() {
    Get.toNamed('/admin/coach/register-schedule');
  }

  void registerCoach(BuildContext context) async {
    if (!isValidForm()) return;

    ProgressDialog progressDialog = ProgressDialog(context: context);
    progressDialog.show(max: 100, msg: 'Registrando Coach...');

    User user = User(
      email: emailController.text.trim(),
      name: nameController.text,
      lastname: lastnameController.text,
      ci: ciController.text,
      phone: phoneController.text,
      password: passwordController.text.trim(),
    );

    Coach coach = Coach(
      hobby: hobbyController.text,
      description: descriptionController.text,
      presentation: presentationController.text,
      state: 1,
    );

    List<Schedule> scheduleList = [];
    for (var dia in dias) {
      if (estadoDia[dia] == true &&
          horaEntrada[dia] != null &&
          horaSalida[dia] != null) {
        scheduleList.add(Schedule(
          day: dia,
          start_time: formatHora(horaEntrada[dia]),
          end_time: formatHora(horaSalida[dia]),
        ));
      }
    }

    Stream stream = await coachProvider.registerCoach(
      user: user,
      coach: coach,
      schedule: scheduleList,
      image: imageFile!,
    );

    stream.listen((res) {
      progressDialog.close();
      final data = json.decode(res);
      if (data['success'] == true) {
        Get.snackbar('Éxito', 'Coach registrado correctamente');
        Get.offAllNamed('/admin/home');
      } else {
        Get.snackbar('Error', 'No se pudo registrar el coach');
      }
    });
  }

  bool isValidForm() {
    if (!GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar('Email incorrecto', 'Ingrese un email válido');
      return false;
    }
    if (!GetUtils.isUsername(nameController.text)) {
      Get.snackbar('Nombre incorrecto', 'Ingrese un nombre válido');
      return false;
    }
    if (!GetUtils.isUsername(lastnameController.text)) {
      Get.snackbar('Apellido incorrecto', 'Ingrese un apellido válido');
      return false;
    }
    if (!GetUtils.isNum(ciController.text)) {
      Get.snackbar('Cédula incorrecta', 'Ingrese un número de CI válido');
      return false;
    }
    if (!GetUtils.isPhoneNumber(phoneController.text)) {
      Get.snackbar('Teléfono incorrecto', 'Ingrese un teléfono válido');
      return false;
    }
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar('Contraseñas no coinciden',
          'Revise las contraseñas e intente nuevamente');
      return false;
    }
    if (imageFile == null) {
      Get.snackbar('Imagen vacía', 'Seleccione una imagen');
      return false;
    }
    if (hobbyController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        presentationController.text.isEmpty) {
      Get.snackbar('Campos vacíos', 'Complete los datos del coach');
      return false;
    }
    return true;
  }
}
