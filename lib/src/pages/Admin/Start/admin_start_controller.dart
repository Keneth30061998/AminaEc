import 'package:amina_ec/src/utils/color.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../components/Socket/socket_service.dart';
import '../../../models/attendance.dart';
import '../../../models/coach.dart';
import '../../../models/student_inscription.dart';
import '../../../providers/attendance_provider.dart';
import '../../../providers/class_reservation_provider.dart';
import '../../../providers/coachs_provider.dart';

class AdminStartController extends GetxController {
  final coachProvider = CoachProvider();
  final classReservationProvider = ClassReservationProvider();
  final attendanceProvider = AttendanceProvider();

  RxList<Coach> coaches = <Coach>[].obs;
  RxString selectedCoachId = ''.obs;

  Map<String, RxList<StudentInscription>> studentMap = {};
  Map<String, Rx<DateTime>> selectedDatePerCoach = {};
  Map<String, RxBool> attendanceMap = {};

  DateTime get today => DateTime.now();
  final int daysToShow = 30;

  @override
  void onInit() {
    super.onInit();
    SocketService().join('admin');
    getCoaches();
    setupSockets();
  }

  Future<void> refreshAll() async {
    await getCoaches();
  }

  Future<void> getCoaches() async {
    final result = await coachProvider.getAll();
    coaches.value = result;

    if (result.isNotEmpty && selectedCoachId.value.isEmpty) {
      selectedCoachId.value = result.first.id!;
    }

    for (var coach in result) {
      selectedDatePerCoach.putIfAbsent(
        coach.id!,
            () => Rx<DateTime>(DateTime(today.year, today.month, today.day)),
      );
      await loadStudents(coach.id!);
    }
  }

  Future<void> loadStudents(String coachId) async {
    final list = await classReservationProvider.getStudentsByCoach(coachId);
    studentMap[coachId] = RxList<StudentInscription>.from(list);

    for (var s in list) {
      final key = getStudentKey(s);
      attendanceMap.putIfAbsent(key, () => false.obs);
    }

    print('📌 Students cargados para coach $coachId: ${list.map((s) => s.studentName).toList()}');
  }

  void selectCoach(String coachId) {
    selectedCoachId.value = coachId;
  }

  void selectDateForCoach(String coachId, DateTime date) {
    selectedDatePerCoach[coachId]?.value =
        DateTime(date.year, date.month, date.day);
  }

  List<DateTime> generateDateRange() {
    final base = DateTime(today.year, today.month, today.day);
    return List.generate(daysToShow, (i) => base.add(Duration(days: i)));
  }

  /// ✅ Filtra estudiantes del coach por fecha seleccionada (normalizado)
  List<StudentInscription> getStudentsByCoachAndDate(
      String coachId, DateTime date) {
    final List<StudentInscription> students =
        studentMap[coachId]?.toList().cast<StudentInscription>() ??
            <StudentInscription>[];

    final selectedDateStr = DateFormat('yyyy-MM-dd').format(date);

    final filtered = students.where((s) {
      try {
        final classDate = DateTime.parse(s.classDate);
        final classDateOnlyStr = DateFormat('yyyy-MM-dd').format(classDate);

        final sameDay = classDateOnlyStr == selectedDateStr;

        print(
            '🔍 student=${s.studentName}, classDate=$classDateOnlyStr, selectedDate=$selectedDateStr, sameDay=$sameDay');

        return sameDay;
      } catch (e) {
        print('❌ Error parseando fecha para ${s.studentName}: ${s.classDate}');
        return false;
      }
    }).toList();

    filtered.sort((a, b) => a.classTime.compareTo(b.classTime));

    print(
        '📌 Students filtrados para fecha $selectedDateStr: ${filtered.map((s) => s.studentName).toList()}');

    return filtered;
  }

  /// ✅ Genera key única normalizada
  String getStudentKey(StudentInscription s) {
    try {
      final date = DateTime.parse(s.classDate);
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      return '${s.studentId}_${dateStr}_${s.classTime}';
    } catch (e) {
      print('❌ Error creando student key para ${s.studentName}: $e');
      return '${s.studentId}_${s.classDate}_${s.classTime}';
    }
  }

  /// ✅ Registra asistencia para el coach visible
  Future<void> registerAttendanceForSelectedCoach() async {
    print('📌 [AdminStartController] → registerAttendanceForSelectedCoach() llamado');
    final coachId = selectedCoachId.value;
    print('📌 Coach seleccionado: $coachId');

    if (coachId.isEmpty) {
      print('❌ CoachId vacío, se cancela registro');
      return;
    }

    final selectedDate =
        selectedDatePerCoach[coachId]?.value ?? DateTime(today.year, today.month, today.day);
    print('📌 Fecha seleccionada: $selectedDate');

    final students = getStudentsByCoachAndDate(coachId, selectedDate);

    if (students.isEmpty) {
      print('⚠️ No hay estudiantes para registrar en esta fecha');
      Get.snackbar('Aviso', 'No hay estudiantes para registrar asistencia');
      return;
    }

    print('📌 Estudiantes a enviar al backend: ${students.map((s) => s.studentName).toList()}');

    for (var s in students) {
      final key = getStudentKey(s);
      final isPresent = attendanceMap[key]?.value ?? false;
      print('📌 Preparando registro: student=${s.studentName}, key=$key, isPresent=$isPresent');

      final attendance = Attendance(
        userId: s.studentId,
        coachId: coachId,
        classDate: DateTime.parse(s.classDate),
        classTime: s.classTime,
        bicycle: s.bicycle,
        status: isPresent ? 'present' : 'absent',
      );

      try {
        final response = await attendanceProvider.registerAttendance(attendance);
        print('📥 Respuesta backend para ${s.studentName}: success=${response.success}, message=${response.message}');
        if (response.success != true) {
          Get.snackbar('Error',
              'No se pudo registrar asistencia para ${s.studentName}: ${response.message ?? 'error'}');
        }
      } catch (e) {
        print('❌ Error registrando asistencia de ${s.studentName}: $e');
        Get.snackbar('Error', 'Error registrando asistencia: $e');
      }
    }

    print('✅ Registro completado para coach $coachId');
    Get.snackbar("Éxito", "Asistencia registrada correctamente");
  }

  void confirmAttendanceRegister() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Confirmar asistencia"),
        content: Text(
          "¿Deseas enviar la asistencia de este coach y día?",
          style: GoogleFonts.poppins(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancelar",
                style: TextStyle(color: Colors.blue)),
          ),
          FilledButton(
            onPressed: () async {
              print('📌 Confirmación aceptada, iniciando registro...');
              Get.back();
              await registerAttendanceForSelectedCoach();
            },
            child: const Text("Confirmar"),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void setupSockets() {
    SocketService().on('class:reserved', (data) {
      final coachId = data['coach_id'].toString();
      print('📡 Socket recibido: class:reserved → coachId=$coachId');
      loadStudents(coachId);
    });
  }
}
