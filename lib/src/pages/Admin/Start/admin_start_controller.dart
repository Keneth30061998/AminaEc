// lib/src/pages/admin/start/admin_start_controller.dart

import 'package:amina_ec/src/utils/color.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  /// Guardamos qué coach está seleccionado en la TabView
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

    // Si hay coaches, seleccionamos por defecto el primero
    if (result.isNotEmpty && selectedCoachId.value.isEmpty) {
      selectedCoachId.value = result.first.id!;
    }

    for (var coach in result) {
      selectedDatePerCoach.putIfAbsent(coach.id!, () => Rx<DateTime>(today));
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
  }

  void selectCoach(String coachId) {
    selectedCoachId.value = coachId;
  }

  void selectDateForCoach(String coachId, DateTime date) {
    selectedDatePerCoach[coachId]?.value = date;
  }

  List<DateTime> generateDateRange() {
    final base = DateTime(today.year, today.month, today.day);
    return List.generate(daysToShow, (i) => base.add(Duration(days: i)));
  }

  List<StudentInscription> getStudentsByCoachAndDate(
      String coachId, DateTime date) {
    final List<StudentInscription> students =
        studentMap[coachId]?.toList().cast<StudentInscription>() ??
            <StudentInscription>[];

    final filtered = students.where((s) {
      try {
        final classDate = DateTime.parse(s.classDate);
        return DateUtils.isSameDay(classDate, date);
      } catch (_) {
        return false;
      }
    }).toList();

    filtered.sort((a, b) => a.classTime.compareTo(b.classTime));
    return filtered;
  }

  String getStudentKey(StudentInscription s) {
    return '${s.studentId}_${s.classDate}_${s.classTime}';
  }

  /// ✅ Nuevo método: solo registra asistencias del coach visible
  Future<void> registerAttendanceForSelectedCoach() async {
    final coachId = selectedCoachId.value;
    if (coachId.isEmpty) return;

    final selectedDate = selectedDatePerCoach[coachId]?.value ?? today;
    final students = getStudentsByCoachAndDate(coachId, selectedDate);

    for (var s in students) {
      final key = getStudentKey(s);
      final isPresent = attendanceMap[key]?.value ?? false;

      final attendance = Attendance(
        userId: s.studentId,
        coachId: coachId,
        classDate: DateTime.parse(s.classDate),
        classTime: s.classTime,
        bicycle: s.bicycle,
        status: isPresent ? 'present' : 'absent',
      );

      await attendanceProvider.registerAttendance(attendance);
    }

    Get.snackbar("Éxito", "Asistencia registrada correctamente");
  }

  /// ✅ Diálogo de confirmación antes de registrar
  void confirmAttendanceRegister() {
    Get.dialog(
      AlertDialog(
        backgroundColor: colorBackgroundBox,
        title: const Text("Confirmar asistencia"),
        content: Text("¿Deseas enviar la asistencia de este coach y día?", style: GoogleFonts.poppins(color: whiteGrey),),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancelar", style: TextStyle(color: indigoAmina),),
          ),
          FilledButton(
            onPressed: () async {
              Get.back();
              await registerAttendanceForSelectedCoach();
            },
            child: const Text("Confirmar"),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(almostBlack)
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void setupSockets() {
    SocketService().on('class:reserved', (data) {
      final coachId = data['coach_id'].toString();
      loadStudents(coachId);
    });
  }
}
