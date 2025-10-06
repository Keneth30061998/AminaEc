import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../components/Socket/socket_service.dart';
import '../../../models/student_inscription.dart';
import '../../../providers/class_reservation_provider.dart';

class CoachClassController extends GetxController {
  final classReservationProvider = ClassReservationProvider();
  final _user = GetStorage().read('user');

  RxList<StudentInscription> students = <StudentInscription>[].obs;
  Rx<DateTime> selectedDate = DateTime.now().obs;

  DateTime get today => DateTime.now();
  final int daysToShow = 10;

  @override
  void onInit() {
    super.onInit();
    SocketService().join('coach');
    loadStudents();
    setupSockets();
  }

  Future<void> loadStudents() async {
    final coachId = _user['id'].toString();
    final list = await classReservationProvider.getStudentsByCoach(coachId);
    students.value = list;
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
  }

  List<DateTime> generateDateRange() {
    final base = DateTime(today.year, today.month, today.day);
    return List.generate(daysToShow, (i) => base.add(Duration(days: i)));
  }

  List<StudentInscription> getStudentsByDate(DateTime date) {
    return students.where((s) {
      try {
        final classDate = DateTime.parse(s.classDate);
        final d1 = DateTime(classDate.year, classDate.month, classDate.day);
        final d2 = DateTime(date.year, date.month, date.day);
        return d1 == d2;
      } catch (_) {
        return false;
      }
    }).toList()
      ..sort((a, b) => a.classTime.compareTo(b.classTime));
  }

  void setupSockets() {
    SocketService().on('class:reserved', (data) {
      loadStudents();
    });

    // 🔄 Nuevo: escuchar reagendamiento
    SocketService().on('class:coach:rescheduled', (data) {
      //print('📡 Socket -> class:coach:rescheduled (coach) $data');
      loadStudents();
    });
  }

}
