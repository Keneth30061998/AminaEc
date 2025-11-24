// admin_coach_register_controller.dart
import 'dart:convert';
import 'dart:io';

import 'package:amina_ec/src/models/coach.dart';
import 'package:amina_ec/src/models/schedule.dart';
import 'package:amina_ec/src/models/user.dart';
import 'package:amina_ec/src/providers/coachs_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../../components/Compress/image_compress_util.dart';

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
  var imageFile = Rxn<File>();
  final ImagePicker picker = ImagePicker();

  // Fecha de nacimiento
  var birthDate = Rxn<DateTime>();

  // Horarios seleccionados
  final selectedSchedules = <Schedule>[].obs;
  final calendarDataSource = Rx<ScheduleDataSource>(ScheduleDataSource([]));

  final CoachProvider coachProvider = CoachProvider();

  // Ver - ocultar contraseña
  var obscurePassword = true.obs;
  var obscureConfirmPassword = true.obs;

  // Switch para datos personales
  var addPersonalData = false.obs;

  @override
  void onInit() {
    super.onInit();
    ever(selectedSchedules, (_) => _actualizarCalendario());
  }

  void goToRegisterAdminCoachImage() =>
      Get.toNamed('/admin/coach/register-image');

  void goToRegisterAdminCoachSchedule() =>
      Get.toNamed('/admin/coach/register-schedule');

  // Selección de imagen
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
          ),
          FloatingActionButton.extended(
            onPressed: () {
              Get.back();
              selectImage(ImageSource.camera);
            },
            label: const Text('Cámara'),
            icon: const Icon(Icons.camera),
          ),
        ],
      ),
    );
  }

  Future<void> selectImage(ImageSource imageSource) async {
    final image = await picker.pickImage(source: imageSource);
    if (image != null) {
      imageFile.value = File(image.path);

      Get.dialog(const Center(child: CircularProgressIndicator()),
          barrierDismissible: false);

      try {
        final compressed =
        await ImageCompressUtil.compress(input: imageFile.value!);
        imageFile.value = compressed;
      } catch (_) {}

      Get.back();
    }
  }

  void setBirthDate(DateTime date) => birthDate.value = date;

  // ✅ DIALOGO CORREGIDO — SIN TextEditingController que cause dispose error
  Future<void> selectDateAndPromptTime(DateTime? date) async {
    if (date == null) return;

    final TextEditingController themeCtrl = TextEditingController();

    String? theme = await Get.dialog<String>(
      AlertDialog(
        title: const Text("Tema de la clase (opcional)"),
        content: TextField(
          controller: themeCtrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Ej: Shakira',
            labelText: 'Tema de clase',
            labelStyle: GoogleFonts.poppins(color: Colors.black54),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.black)),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: null),
            child: const Text("Omitir"),
          ),
          TextButton(
            onPressed: () => Get.back(result: themeCtrl.text.trim()),
            child: const Text("Continuar"),
          ),
        ],
      ),
    );

    final start = await showTimePicker(
      context: Get.context!,
      helpText: "Hora de inicio",
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (start == null) return;

    final end = await showTimePicker(
      context: Get.context!,
      helpText: "Hora de fin",
      initialTime: TimeOfDay(hour: start.hour + 1, minute: start.minute),
    );
    if (end == null) return;

    await _validarYAgregarHorario(date, start, end, theme);
  }


  Future<void> _validarYAgregarHorario(
      DateTime date, TimeOfDay start, TimeOfDay end, String? theme) async {
    if (_compararHoras(start, end) >= 0) {
      Get.snackbar("Rango inválido",
          "La hora de fin debe ser mayor que la de inicio",
          backgroundColor: Colors.red);
      return;
    }

    final formattedDate =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    final newSchedule = Schedule(
      date: formattedDate,
      start_time: _formatHora(start),
      end_time: _formatHora(end),
      class_theme: (theme?.trim().isNotEmpty == true) ? theme : "Clase",
    );

    if (selectedSchedules.any((s) =>
    s.date == newSchedule.date &&
        s.start_time == newSchedule.start_time &&
        s.end_time == newSchedule.end_time)) {
      Get.snackbar("Duplicado", "Ese horario ya fue agregado",
          backgroundColor: Colors.orange);
      return;
    }

    selectedSchedules.add(newSchedule);
  }

  void removeSchedule(int index) {
    selectedSchedules.removeAt(index);
  }

  void _actualizarCalendario() =>
      calendarDataSource.value = ScheduleDataSource(selectedSchedules);

  String _formatHora(TimeOfDay t) =>
      "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00";

  int _compararHoras(TimeOfDay a, TimeOfDay b) =>
      (a.hour * 60 + a.minute) - (b.hour * 60 + b.minute);

  bool isValidForm() {
    if (!GetUtils.isEmail(emailController.text)) {
      Get.snackbar("Email incorrecto", "Ingrese un email válido");
      return false;
    }
    if (selectedSchedules.isEmpty) {
      Get.snackbar("Sin disponibilidad", "Agrega al menos un horario");
      return false;
    }
    return true;
  }

  Future<void> registerCoach() async {
    if (!isValidForm()) return;

    final progressDialog = ProgressDialog(context: Get.context!);
    progressDialog.show(max: 100, msg: "Registrando...");

    final user = User(
      email: emailController.text.trim(),
      name: nameController.text,
      lastname: lastnameController.text,
      ci: ciController.text,
      phone: phoneController.text,
      password: passwordController.text.trim(),
      birthDate: DateFormat('yyyy-MM-dd').format(birthDate.value!),
    );

    final coach = Coach(
      hobby: hobbyController.text,
      description: descriptionController.text,
      presentation: presentationController.text,
      state: 1,
      schedules: selectedSchedules.toList(),
      user: null,
    );

    final stream = await coachProvider.registerCoach(
      user: user,
      coach: coach,
      schedule: selectedSchedules.toList(),
      image: imageFile.value!,
    );

    stream.listen((res) {
      progressDialog.close();
      final data = json.decode(res);
      if (data["success"]) {
        Get.snackbar("Éxito", "Coach registrado correctamente");
        Get.offAllNamed('/admin/home');
      } else {
        Get.snackbar("Error", data["message"] ?? "Ocurrió un problema");
      }
    });
  }
}

// DataSource
class ScheduleDataSource extends CalendarDataSource {
  ScheduleDataSource(List<Schedule> source) {
    appointments = source.map((s) {
      final d = DateTime.parse(s.date!);
      final st = s.start_time!.split(":");
      final et = s.end_time!.split(":");

      return Appointment(
        startTime:
        DateTime(d.year, d.month, d.day, int.parse(st[0]), int.parse(st[1])),
        endTime:
        DateTime(d.year, d.month, d.day, int.parse(et[0]), int.parse(et[1])),
        subject: s.class_theme!,
        color: Colors.green.shade400,
      );
    }).toList();
  }
}
