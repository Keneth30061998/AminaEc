import 'package:get/get.dart';

import '../../../../components/Socket/socket_service.dart';
import '../../../../models/coach.dart';
import '../../../../providers/coachs_provider.dart';

class AdminCoachListController extends GetxController {
  final List<void Function()> _subscriptions = [];
  void _listen(String event, Function(dynamic) callback) {
    _subscriptions.add(SocketService().subscribe(event, callback));
  }
  @override
  void onClose() {
    for (final cancel in _subscriptions) { cancel(); }
    super.onClose();
  }
  final CoachProvider coachProvider = CoachProvider();
  var coaches = <Coach>[].obs;

  @override
  void onInit() {
    super.onInit();
    getCoaches();

    _listen('coach:new', (data) => refreshCoaches());
    _listen('coach:delete', (data) => refreshCoaches());
    _listen('coach:update', (data) => refreshCoaches());
  }

  Future<void> getCoaches() async {
    List<Coach> result = await coachProvider.getAll();
    coaches.value = result;
  }

  Future<void> refreshCoaches() async {
    await getCoaches();
  }

  void goToAdminCoachRegisterPage() async {
    await Get.toNamed('/admin/coach/register');
    refreshCoaches(); // 👈 Refresca al volver
  }

  void goToUpdateCoachSchedulePage(Coach coach) async {
    await Get.toNamed('/admin/coach/update/schedule', arguments: coach);
    refreshCoaches(); // 👈 Refresca al volver
  }

  void goToUpdateCoachPage(Coach coach) async {
    await Get.toNamed('/admin/coach/update', arguments: coach);
    refreshCoaches(); // 👈 Refresca al volver
  }

  void toggleCoachState(String id, int newState) async {
    final res = await coachProvider.setState(id, newState);
    if (res.statusCode == 200) {
      refreshCoaches();
      Get.snackbar('Éxito', 'Estado actualizado correctamente');
    } else {
      Get.snackbar('Error', 'No se pudo actualizar el estado');
    }
  }
}

