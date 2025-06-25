import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../components/Socket/socket_service.dart';
import '../../../models/coach.dart';
import '../../../models/user.dart';
import '../../../providers/coachs_provider.dart';

class UserSatartController extends GetxController {
  User user = User.fromJson(GetStorage().read('user') ?? {});

  final CoachProvider coachProvider = CoachProvider();

  var coaches = <Coach>[].obs;

  @override
  void onInit() {
    // TODO: implement onInit
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
    SocketService().on('coach:update', (data) {
      print('🗑️ Evento coach:update recibido');
      getCoaches();
    });
  }

  void getCoaches() async {
    List<Coach> result = await coachProvider.getAll();
    coaches.value = result;
  }
}
