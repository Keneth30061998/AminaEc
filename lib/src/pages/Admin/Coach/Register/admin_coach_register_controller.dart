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

import '../../../../components/Socket/socket_service.dart';

class AdminCoachRegisterController extends GetxController {
  // Controladores de texto
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final lastnameController = TextEditingController();
  final ciController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final hobbyController = TextEditingController();
  final descriptionController = TextEditingController();
  final presentationController = TextEditingController();

  // Imagen
  File? imageFile;
  final ImagePicker picker = ImagePicker();

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
  var horariosPorDia = <String, List<Map<String, TimeOfDay?>>>{}.obs;

  final CoachProvider coachProvider = CoachProvider();

  @override
  void onInit() {
    super.onInit();
    for (var dia in dias) {
      horariosPorDia[dia] = [];
    }
  }

  void agregarRango(String dia) {
    horariosPorDia[dia]!.add({'entrada': null, 'salida': null});
    update();
  }

  void eliminarRango(String dia, int index) {
    horariosPorDia[dia]!.removeAt(index);
    update();
  }

  Future<void> seleccionarHora(
      String dia, int index, String tipo, BuildContext context) async {
    final picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (picked == null) return;

    var rango = horariosPorDia[dia]![index];

    if (tipo == 'entrada') {
      if (rango['salida'] != null &&
          _compararHoras(picked, rango['salida']!) >= 0) {
        _mostrarError('La hora de entrada debe ser menor que la de salida');
        return;
      }
      rango['entrada'] = picked;
    } else {
      if (rango['entrada'] != null &&
          _compararHoras(rango['entrada']!, picked) >= 0) {
        _mostrarError('La hora de salida debe ser mayor que la de entrada');
        return;
      }
      rango['salida'] = picked;
    }

    if (_rangoDuplicado(dia, index)) {
      _mostrarError('Este rango ya existe para este día');
      return;
    }

    update();
  }

  bool _rangoDuplicado(String dia, int indexActual) {
    var actual = horariosPorDia[dia]![indexActual];
    for (int i = 0; i < horariosPorDia[dia]!.length; i++) {
      if (i == indexActual) continue;
      var otro = horariosPorDia[dia]![i];
      if (actual['entrada'] == otro['entrada'] &&
          actual['salida'] == otro['salida']) {
        return true;
      }
    }
    return false;
  }

  void _mostrarError(String mensaje) {
    Get.snackbar('Error', mensaje,
        backgroundColor: Colors.redAccent, colorText: Colors.white);
  }

  int _compararHoras(TimeOfDay hora1, TimeOfDay hora2) =>
      (hora1.hour * 60 + hora1.minute)
          .compareTo(hora2.hour * 60 + hora2.minute);

  String formatHora(TimeOfDay? time) {
    if (time == null) return 'Seleccionar';
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Seleccione una opción',
            style: TextStyle(fontWeight: FontWeight.w500)),
        actions: [
          FloatingActionButton.extended(
            onPressed: () {
              Get.back();
              selectImage(ImageSource.gallery);
            },
            label: const Text('Galería'),
            icon: const Icon(Icons.photo_library_outlined),
            elevation: 3,
          ),
          FloatingActionButton.extended(
            onPressed: () {
              Get.back();
              selectImage(ImageSource.camera);
            },
            label: const Text('Cámara'),
            icon: const Icon(Icons.camera),
            elevation: 3,
          ),
        ],
      ),
    );
  }

  Future<void> selectImage(ImageSource imageSource) async {
    final image = await picker.pickImage(source: imageSource);
    if (image != null) {
      imageFile = File(image.path);
      update();
    }
  }

  void goToRegisterAdminCoachImage() =>
      Get.toNamed('/admin/coach/register-image');

  void goToRegisterAdminCoachSchedule() =>
      Get.toNamed('/admin/coach/register-schedule');

  Future<void> registerCoach(BuildContext context) async {
    if (!isValidForm()) return;

    final progressDialog = ProgressDialog(context: context);
    progressDialog.show(max: 100, msg: 'Registrando Coach...');

    final user = User(
      email: emailController.text.trim(),
      name: nameController.text,
      lastname: lastnameController.text,
      ci: ciController.text,
      phone: phoneController.text,
      password: passwordController.text.trim(),
    );

    final coach = Coach(
      hobby: hobbyController.text,
      description: descriptionController.text,
      presentation: presentationController.text,
      state: 1,
    );

    final scheduleList = getHorariosComoLista();

    final stream = await coachProvider.registerCoach(
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
        if (SocketService().socket.connected) {
          print(
              '📤 Enviando horarios: ${json.encode(scheduleList.map((s) => s.toJson()).toList())}');
          SocketService().emit('coach:new', coach.toJson());
        } else {
          print('Socket no conectado');
        }
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

  List<Schedule> getHorariosComoLista() {
    final lista = <Schedule>[];
    horariosPorDia.forEach((dia, rangos) {
      for (var rango in rangos) {
        if (rango['entrada'] != null && rango['salida'] != null) {
          lista.add(Schedule(
            day: dia,
            start_time: formatHora(rango['entrada']),
            end_time: formatHora(rango['salida']),
          ));
        }
      }
    });
    return lista;
  }
}
