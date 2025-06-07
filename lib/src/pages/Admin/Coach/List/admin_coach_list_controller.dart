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
      print('📡 Evento coach:new recibido');
      getCoaches();
    });

    SocketService().on('coach:delete', (data) {
      print('🗑️ Evento coach:delete recibido');
      getCoaches();
    });
  }

  void getCoaches() async {
    List<Coach> result = await coachProvider.getAll();
    coaches.value = result;
  }

  void refresh() {
    getCoaches();
  }

  void goToAdminCoachRegisterPage() {
    Get.toNamed('/admin/coach/register');
  }
}
