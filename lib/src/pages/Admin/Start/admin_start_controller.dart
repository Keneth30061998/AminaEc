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

  // =====================================================
  // GET COACHES
  // =====================================================
  Future<void> getCoaches() async {
    print("\n===============================");
    print("🔵 [getCoaches] Iniciando...");
    print("===============================\n");

    final result = await coachProvider.getAll();

    print("📌 [getCoaches] Resultado API coaches (${result.length} coaches):");
    for (var c in result) {
      print("  → CoachID: ${c.id}  | Nombre: ${c.user?.name}");
    }

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

      refreshAttendanceMapForCoachDate(
        coach.id!,
        selectedDatePerCoach[coach.id!]!.value,
      );
    }
  }

  // =====================================================
  // LOAD STUDENTS
  // =====================================================
  Future<void> loadStudents(String coachId) async {
    print("\n========================================");
    print("🟠 [loadStudents] coachId: $coachId");
    print("========================================");

    final list = await classReservationProvider.getStudentsByCoach(coachId);

    print("📌 Estudiantes recibidos desde API (${list.length}) →");
    for (var s in list) {
      print("  🧍 ${s.studentName} | Fecha: ${s.classDate} | Hora: ${s.classTime}");
    }

    studentMap[coachId] = RxList<StudentInscription>.from(list);

    for (var s in list) {
      final key = getStudentKey(s);
      attendanceMap.putIfAbsent(key, () => false.obs);
      print("  🔑 KEY generado: $key");
    }

    print("🔵 Fin de loadStudents()");
  }

  void selectCoach(String coachId) {
    print("🔄 [selectCoach] coachId seleccionado: $coachId");
    selectedCoachId.value = coachId;
  }

  void selectDateForCoach(String coachId, DateTime date) {
    print("📅 [selectDateForCoach] coachId=$coachId  | date=$date");

    selectedDatePerCoach[coachId]?.value =
        DateTime(date.year, date.month, date.day);

    refreshAttendanceMapForCoachDate(
      coachId,
      selectedDatePerCoach[coachId]!.value,
    );
  }

  List<DateTime> generateDateRange() {
    final base = DateTime(today.year, today.month, today.day);
    return List.generate(daysToShow, (i) => base.add(Duration(days: i)));
  }

  // =====================================================
  // FILTER STUDENTS BY DATE
  // =====================================================
  List<StudentInscription> getStudentsByCoachAndDate(
      String coachId,
      DateTime date,
      ) {
    final students = studentMap[coachId]?.toList() ?? <StudentInscription>[];
    final selectedDateStr = DateFormat('yyyy-MM-dd').format(date);

    print("\n------------------------------------");
    print("🔍 [getStudentsByCoachAndDate]");
    print("  coachId: $coachId");
    print("  selectedDate: $selectedDateStr");
    print("------------------------------------");

    final filtered = students.where((s) {
      try {
        final classDate = DateTime.parse(s.classDate).toLocal();
        final classDateOnlyStr = DateFormat('yyyy-MM-dd').format(classDate);
        final match = classDateOnlyStr == selectedDateStr;

        print(
            "  ✔ Estudiante: ${s.studentName} | FechaClase: $classDateOnlyStr | Match: $match");

        return match;
      } catch (e) {
        print("  ❌ Error parseando fecha: ${s.classDate}");
        return false;
      }
    }).toList();

    filtered.sort((a, b) => a.classTime.compareTo(b.classTime));

    print("📌 Filtrados final: ${filtered.length} estudiantes\n");

    return filtered;
  }

  // =====================================================
  // GROUP BY TIME
  // =====================================================
  Map<String, List<StudentInscription>> groupStudentsByTime(
      String coachId,
      DateTime date) {
    final students = getStudentsByCoachAndDate(coachId, date);

    print("⏱ [groupStudentsByTime] Total estudiantes: ${students.length}");

    final Map<String, List<StudentInscription>> groups = {};

    for (var s in students) {
      final timeKey =
      s.classTime.length >= 5 ? s.classTime.substring(0, 5) : s.classTime;

      groups.putIfAbsent(timeKey, () => []);
      groups[timeKey]!.add(s);

      print("  ⏰ Grupo $timeKey → ${groups[timeKey]!.length} estudiantes");
    }

    return groups;
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
    print("\n🔄 [refreshAttendanceMap] coach=$coachId | date=$date");

    final students = getStudentsByCoachAndDate(coachId, date);

    for (var s in students) {
      final key = getStudentKey(s);
      attendanceMap.putIfAbsent(key, () => false.obs);
      print("  🎯 KEY válido: $key");
    }

    final validKeys =
    students.map((s) => getStudentKey(s)).toSet();

    final keysToRemove =
    attendanceMap.keys.where((k) => !validKeys.contains(k)).toList();

    for (var k in keysToRemove) {
      print("  🗑 Eliminando KEY inválido: $k");
      attendanceMap.remove(k);
    }
  }

  // =====================================================
  // REGISTER ATTENDANCE
  // =====================================================
  Future<void> registerAttendanceForGroup({
    required String coachId,
    required DateTime date,
    required String classTime,
  }) async {
    print("\n=======================================");
    print("🟢 [registerAttendanceForGroup]");
    print("  coachId: $coachId");
    print("  date: $date");
    print("  classTime: $classTime");
    print("=======================================\n");

    final students = getStudentsByCoachAndDate(coachId, date)
        .where((s) => s.classTime.substring(0, 5) == classTime)
        .toList();

    print("📌 Total estudiantes en este grupo: ${students.length}");
    // UI optimista: remover grupo inmediatamente
    removeGroupLocally(
      coachId: coachId,
      date: date,
      classTime: classTime,
    );

    for (var s in students) {
      final key = getStudentKey(s);
      final isPresent = attendanceMap[key]?.value ?? false;

      print(
          "  ↳ Enviando asistencia: ${s.studentName} | status=${isPresent ? 'present' : 'absent'}");

      final attendance = Attendance(
        userId: s.studentId,
        coachId: coachId,
        classDate: DateTime.parse(s.classDate).toLocal(),
        classTime: s.classTime.split(".").first,
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
      print("📡 SOCKET EVENT → class:reserved | coachId=$coachId");
      loadStudents(coachId);
    });

    SocketService().on('attendance:group:registered', (data) {
      final coachId = data['coach_id'].toString();
      final date = DateTime.parse(data['class_date']);
      final classTime = data['class_time'].substring(0, 5);

      print("📡 SOCKET → attendance:group:registered | $coachId $classTime");

      removeGroupLocally(
        coachId: coachId,
        date: date,
        classTime: classTime,
      );
    });

  }

  void removeGroupLocally({
    required String coachId,
    required DateTime date,
    required String classTime,
  }) {
    final list = studentMap[coachId];
    if (list == null) return;

    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    list.removeWhere((s) {
      final sDate = DateFormat('yyyy-MM-dd')
          .format(DateTime.parse(s.classDate).toLocal());

      final sameDate = sDate == dateStr;
      final sameTime = s.classTime.substring(0, 5) == classTime;

      return sameDate && sameTime;
    });

    list.refresh();

    attendanceMap.removeWhere((key, _) =>
    key.contains(classTime) && key.contains(dateStr));
  }

}
