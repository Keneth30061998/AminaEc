import 'dart:convert';
import 'dart:io';

import 'package:amina_ec/src/models/coach.dart';
import 'package:amina_ec/src/models/schedule.dart';
import 'package:amina_ec/src/models/user.dart';
import 'package:amina_ec/src/providers/coachs_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

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

  // Horarios seleccionados
  final selectedSchedules = <Schedule>[].obs;
  final calendarDataSource = Rx<ScheduleDataSource>(ScheduleDataSource([]));

  final CoachProvider coachProvider = CoachProvider();

  //Ver - ocultar cobntraseña
  var obscurePassword = true.obs;
  var obscureConfirmPassword = true.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    ever<List<Schedule>>(selectedSchedules, (_) => _actualizarCalendario());
  }

  // Navegación entre pantallas
  void goToRegisterAdminCoachImage() =>
      Get.toNamed('/admin/coach/register-image');

  void goToRegisterAdminCoachSchedule() =>
      Get.toNamed('/admin/coach/register-schedule');

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

  Future<void> selectDateAndPromptTime(DateTime? date) async {
    if (date == null) return;

    final formattedDate = DateFormat('dd MMM y', 'es_ES').format(date);

    await Get.dialog(
      AlertDialog(
        title: Text('Seleccionar disponibilidad'),
        content: Text(
          'Escoge el rango horario para el día $formattedDate',
          style: const TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Get.back(); // cierra el AlertDialog

              TimeOfDay? start = await showTimePicker(
                context: Get.context!,
                helpText: 'Hora de inicio',
                initialTime: const TimeOfDay(hour: 8, minute: 0),
              );
              if (start == null) return;

              TimeOfDay? end = await showTimePicker(
                context: Get.context!,
                helpText: 'Hora de fin',
                initialTime:
                    TimeOfDay(hour: start.hour + 1, minute: start.minute),
              );
              if (end == null) return;

              await _validarYAgregarHorario(date, start, end);
            },
            child: const Text('Escoger horas'),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _validarYAgregarHorario(
      DateTime date, TimeOfDay start, TimeOfDay end) async {
    if (_compararHoras(start, end) >= 0) {
      Get.snackbar(
          'Rango inválido', 'La hora de fin debe ser mayor que la de inicio',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    final formattedDate =
        "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    final newSchedule = Schedule(
      date: formattedDate,
      start_time: _formatHora(start),
      end_time: _formatHora(end),
    );

    if (selectedSchedules.any((s) =>
        s.date == newSchedule.date &&
        s.start_time == newSchedule.start_time &&
        s.end_time == newSchedule.end_time)) {
      Get.snackbar('Duplicado', 'Ya agregaste ese horario',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    selectedSchedules.add(newSchedule);
    _actualizarCalendario();
  }

  void removeSchedule(int index) {
    selectedSchedules.removeAt(index);
    _actualizarCalendario();
  }

  void _actualizarCalendario() {
    calendarDataSource.value = ScheduleDataSource(selectedSchedules);
  }

  String _formatHora(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }

  int _compararHoras(TimeOfDay h1, TimeOfDay h2) =>
      (h1.hour * 60 + h1.minute) - (h2.hour * 60 + h2.minute);

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
      Get.snackbar('Cédula incorrecta', 'Ingrese un número válido');
      return false;
    }
    if (!GetUtils.isPhoneNumber(phoneController.text)) {
      Get.snackbar('Teléfono incorrecto', 'Número no válido');
      return false;
    }
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar('Contraseñas no coinciden',
          'Revisa las contraseñas e intenta nuevamente');
      return false;
    }
    if (imageFile == null) {
      Get.snackbar('Imagen requerida', 'Debes elegir una imagen');
      return false;
    }

    if (selectedSchedules.isEmpty) {
      Get.snackbar('Sin disponibilidad', 'Agrega al menos un horario');
      return false;
    }
    return true;
  }

  Future<void> registerCoach() async {
    if (!isValidForm()) return;

    final progressDialog = ProgressDialog(context: Get.context!);
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

    final stream = await coachProvider.registerCoach(
      user: user,
      coach: coach,
      schedule: selectedSchedules,
      image: imageFile!,
    );

    stream.listen((res) {
      progressDialog.close();
      final data = json.decode(res);
      if (data['success'] == true) {
        Get.snackbar('Éxito', 'Coach registrado correctamente');
        if (SocketService().socket.connected) {
          SocketService().emit('coach:new', coach.toJson());
        }
        Get.offAllNamed('/admin/home'); // navegación segura sin context
      } else {
        Get.snackbar('Error', 'No se pudo registrar el coach');
      }
    });
  }
}

// DataSource para Syncfusion Calendar
class ScheduleDataSource extends CalendarDataSource {
  ScheduleDataSource(List<Schedule> source) {
    appointments = source.map((s) {
      final date = DateTime.parse(s.date!);
      final startParts = s.start_time!.split(':');
      final endParts = s.end_time!.split(':');

      final startTime = DateTime(date.year, date.month, date.day,
          int.parse(startParts[0]), int.parse(startParts[1]));
      final endTime = DateTime(date.year, date.month, date.day,
          int.parse(endParts[0]), int.parse(endParts[1]));

      return Appointment(
        startTime: startTime,
        endTime: endTime,
        subject:
            'Disponible: ${s.start_time!.substring(0, 5)} - ${s.end_time!.substring(0, 5)}',
        color: Colors.green.shade400,
        isAllDay: false,
      );
    }).toList();
  }
}
