import 'package:get/get.dart';

import '../../../components/Socket/socket_service.dart';
import '../../../models/coach.dart';
import '../../../models/student_inscription.dart';
import '../../../providers/class_reservation_provider.dart';
import '../../../providers/coachs_provider.dart';

class AdminStartController extends GetxController {
  final coachProvider = CoachProvider();
  final classReservationProvider = ClassReservationProvider();

  RxList<Coach> coaches = <Coach>[].obs;
  Map<String, RxList<StudentInscription>> studentMap =
      {}; // coachId → estudiantes
  Map<String, Rx<DateTime>> selectedDatePerCoach =
      {}; // coachId → fecha seleccionada

  DateTime get today => DateTime.now();
  final int daysToShow = 5;

  @override
  void onInit() {
    super.onInit();
    SocketService().join('admin');
    getCoaches();
    setupSockets();
  }

  void getCoaches() async {
    final result = await coachProvider.getAll();
    coaches.value = result;

    for (var coach in result) {
      selectedDatePerCoach[coach.id!] = Rx<DateTime>(today);
      await loadStudents(coach.id!);
    }
  }

  Future<void> loadStudents(String coachId) async {
    final list = await classReservationProvider.getStudentsByCoach(coachId);

    print('👥 Coach $coachId tiene ${list.length} estudiantes');
    for (var s in list) {
      print(
          '🗓️ ${s.studentName} — Fecha: ${s.classDate} — Hora: ${s.classTime}');
    }

    studentMap[coachId] = RxList<StudentInscription>.from(list);
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

  void setupSockets() {
    SocketService().on('class:coach:reserved', (data) {
      print('📡 Evento recibido: $data');
      final coachId = data['coach_id'].toString();
      loadStudents(coachId);
      getCoaches();
    });
    SocketService().on('class:reserved', (data) {
      print('📡 Evento recibido: $data');
      final coachId = data['coach_id'].toString();
      loadStudents(coachId);
      getCoaches();
    });
  }
}
