import 'package:get/get.dart';

import '../../../../components/Socket/socket_service.dart';
import '../../../../models/coach.dart';
import '../../../../providers/coachs_provider.dart';

class AdminCoachListController extends GetxController {
  final CoachProvider coachProvider = CoachProvider();
  var coaches = <Coach>[].obs;

  @override
  void onInit() {
    super.onInit();
    getCoaches();

    SocketService().on('coach:new', (data) {
      //print('📡 Evento coach:new recibido');
      getCoaches();
    });

    SocketService().on('coach:delete', (data) {
      //print('🗑️ Evento coach:delete recibido');
      getCoaches();
    });

    SocketService().on('coach:update', (data) {
      //print('📡 Evento coach:update recibido');
      getCoaches();
    });
  }

  void getCoaches() async {
    List<Coach> result = await coachProvider.getAll();
    coaches.value = result;
  }

  @override
  void refresh() {
    getCoaches();
  }

  void goToAdminCoachRegisterPage() {
    Get.toNamed('/admin/coach/register');
  }

  void goToUpdateCoachSchedulePage(Coach coach) {
    Get.toNamed('/admin/coach/update/schedule', arguments: coach);
  }

  void goToUpdateCoachPage(Coach coach) {
    Get.toNamed('/admin/coach/update', arguments: coach);
  }

  void deleteCoach(String id) async {
    final res = await coachProvider.deleteCoach(id);
    if (res.statusCode == 201) {
      Get.snackbar('Exito', 'Coach eliminado correctamente');
      getCoaches(); //recarga la lista de coachs
    } else {
      Get.snackbar('Error', 'No se pudo eliminar el coach');
    }
  }
}
