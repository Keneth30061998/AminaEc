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

  // Mapas para mantener estado de estudiantes, fechas y asistencia
  Map<String, RxList<StudentInscription>> studentMap = {};
  Map<String, Rx<DateTime>> selectedDatePerCoach = {};
  Map<String, RxBool> attendanceMap = {};

  DateTime get today => DateTime.now();
  final int daysToShow = 15;

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
      refreshAttendanceMapForCoachDate(coach.id!, selectedDatePerCoach[coach.id!]!.value);
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
    refreshAttendanceMapForCoachDate(coachId, selectedDatePerCoach[coachId]!.value);
  }

  List<DateTime> generateDateRange() {
    final base = DateTime(today.year, today.month, today.day);
    return List.generate(daysToShow, (i) => base.add(Duration(days: i)));
  }

  List<StudentInscription> getStudentsByCoachAndDate(String coachId, DateTime date) {
    final students = studentMap[coachId]?.toList() ?? <StudentInscription>[];
    final selectedDateStr = DateFormat('yyyy-MM-dd').format(date);

    final filtered = students.where((s) {
      try {
        final classDate = DateTime.parse(s.classDate).toLocal();
        final classDateOnlyStr = DateFormat('yyyy-MM-dd').format(classDate);
        return classDateOnlyStr == selectedDateStr;
      } catch (e) {
        return false;
      }
    }).toList();

    filtered.sort((a, b) => a.classTime.compareTo(b.classTime));
    return filtered;
  }

  Map<String, List<StudentInscription>> groupStudentsByTime(String coachId, DateTime date) {
    final students = getStudentsByCoachAndDate(coachId, date);
    final Map<String, List<StudentInscription>> groups = {};

    for (var s in students) {
      final timeKey = s.classTime.length >= 5 ? s.classTime.substring(0, 5) : s.classTime;
      groups.putIfAbsent(timeKey, () => []);
      groups[timeKey]!.add(s);
    }

    final sortedKeys = groups.keys.toList()..sort();
    final Map<String, List<StudentInscription>> ordered = {};
    for (var k in sortedKeys) {
      ordered[k] = groups[k]!;
    }
    return ordered;
  }

  String getStudentKey(StudentInscription s) {
    try {
      final date = DateTime.parse(s.classDate).toLocal();
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      return '${s.studentId}_${dateStr}_${s.classTime}';
    } catch (e) {
      return '${s.studentId}_${s.classDate}_${s.classTime}';
    }
  }

  void refreshAttendanceMapForCoachDate(String coachId, DateTime date) {
    final students = getStudentsByCoachAndDate(coachId, date);

    for (var s in students) {
      final key = getStudentKey(s);
      attendanceMap.putIfAbsent(key, () => false.obs);
    }

    final validKeys = students.map((s) => getStudentKey(s)).toSet();
    final keysToRemove = attendanceMap.keys.where((k) => !validKeys.contains(k)).toList();
    for (var k in keysToRemove) attendanceMap.remove(k);
  }

  Future<void> registerAttendanceForGroup({
    required String coachId,
    required DateTime date,
    required String classTime,
  }) async {
    final students = getStudentsByCoachAndDate(coachId, date)
        .where((s) => s.classTime.substring(0, 5) == classTime)
        .toList();

    for (var s in students) {
      final key = getStudentKey(s);
      final isPresent = attendanceMap[key]?.value ?? false;

      final attendance = Attendance(
        userId: s.studentId,
        coachId: coachId,
        classDate: DateTime.parse(s.classDate).toLocal(),
        classTime: s.classTime,
        bicycle: s.bicycle,
        status: isPresent ? 'present' : 'absent',
      );

      await attendanceProvider.registerAttendance(attendance);
    }

    Get.snackbar("Éxito", "Asistencia del grupo $classTime registrada correctamente");
  }

  void confirmRegisterGroup(String coachId, DateTime date, String classTime) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: Text("Confirmar asistencia - $classTime"),
        content: Text(
          "¿Deseas enviar la asistencia del grupo $classTime?",
          style: GoogleFonts.poppins(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancelar", style: TextStyle(color: Colors.blue)),
          ),
          FilledButton(
            onPressed: () async {
              Get.back();
              await registerAttendanceForGroup(coachId: coachId, date: date, classTime: classTime);
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
      loadStudents(coachId);
    });
  }
}
