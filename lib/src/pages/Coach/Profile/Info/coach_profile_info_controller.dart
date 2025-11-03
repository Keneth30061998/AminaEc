import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../components/Socket/socket_service.dart';
import '../../../../models/user.dart';

class CoachProfileInfoController extends GetxController {
  User user = User.fromJson(GetStorage().read('user') ?? {});

  void signOut() {
    final socketService = SocketService();
    socketService.disconnect();

    GetStorage().remove('user');
    Get.offNamedUntil('/splash', (route) => false);
  }
}
