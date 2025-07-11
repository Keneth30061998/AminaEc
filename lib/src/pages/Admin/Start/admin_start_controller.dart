import 'package:get/get.dart';

import '../../../components/Socket/socket_service.dart';
import '../../../models/coach.dart';
import '../../../models/student_inscription.dart';
import '../../../providers/class_reservation_provider.dart';
import '../../../providers/coachs_provider.dart';

class AdminStartController extends GetxController {
  CoachProvider coachProvider = CoachProvider();
  ClassReservationProvider classReservationProvider =
      ClassReservationProvider();

  RxList<Coach> coaches = <Coach>[].obs;

  AdminStartController() {
    getCoaches();
    setupSockets();
  }

  void getCoaches() async {
    var result = await coachProvider.getAll();
    print('👥 Coaches cargados: ${coaches.length}');
    coaches.clear();
    coaches.addAll(result);
  }

  Future<List<StudentInscription>> getStudents(String coachId) async {
    return await classReservationProvider.getStudentsByCoach(coachId);
  }

  void setupSockets() {
    SocketService().on('class:coach:reserved', (data) {
      final coachId = data['coach_id'].toString();
      getStudents(coachId);
    });
  }
}
