import 'package:get/get.dart';

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
  Map<String, RxList<StudentInscription>> studentMap = {};
  Map<String, Rx<DateTime>> selectedDatePerCoach = {};
  Map<String, RxBool> attendanceMap = {};

  DateTime get today => DateTime.now();
  final int daysToShow = 10;

  @override
  void onInit() {
    super.onInit();
    SocketService().join('admin');
    getCoaches(); // inicializa sin await
    setupSockets();
  }

  /// 🔄 Recarga completa de coaches y estudiantes
  Future<void> refreshAll() async {
    await getCoaches();
  }

  /// 🔹 Cambiado a Future<void>
  Future<void> getCoaches() async {
    final result = await coachProvider.getAll();
    coaches.value = result;

    for (var coach in result) {
      selectedDatePerCoach[coach.id!] = Rx<DateTime>(today);
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

  void selectDateForCoach(String coachId, DateTime date) {
    selectedDatePerCoach[coachId]?.value = date;
  }

  List<DateTime> generateDateRange() {
    final base = DateTime(today.year, today.month, today.day);
    return List.generate(daysToShow, (i) => base.add(Duration(days: i)));
  }

  List<StudentInscription> getStudentsByCoachAndDate(
      String coachId, DateTime date) {
    final students = studentMap[coachId] ?? [];

    return students
        .where((s) {
      try {
        final classDate = DateTime.parse(s.classDate);
        final d1 = DateTime(classDate.year, classDate.month, classDate.day);
        final d2 = DateTime(date.year, date.month, date.day);
        return d1 == d2;
      } catch (_) {
        return false;
      }
    })
        .toList()
        .cast<StudentInscription>()
      ..sort((a, b) => a.classTime.compareTo(b.classTime));
  }

  String getStudentKey(StudentInscription s) {
    return '${s.studentId}_${s.classDate}_${s.classTime}';
  }

  void registerAllAttendances() async {
    for (var coach in coaches) {
      final coachId = coach.id!;
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

        final response =
        await attendanceProvider.registerAttendance(attendance);

        if (response.success == true) {
          //print('✅ Asistencia registrada: ${s.studentName} - ${attendance.status}');
        } else {
          //print('❌ Error al registrar asistencia: ${s.studentName}');
        }
      }
    }
  }

  void setupSockets() {
    SocketService().on('class:coach:reserved', (data) {
      final coachId = data['coach_id'].toString();
      loadStudents(coachId);
      getCoaches();
    });

    SocketService().on('class:reserved', (data) {
      final coachId = data['coach_id'].toString();
      loadStudents(coachId);
      getCoaches();
    });

    SocketService().on('class:coach:rescheduled', (data) {
      final coachId = data['coach_id'].toString();
      loadStudents(coachId);
      getCoaches();
    });
  }
}
