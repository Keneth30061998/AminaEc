import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../models/user.dart';

class CoachProfileInfoController extends GetxController {
  User user = User.fromJson(GetStorage().read('user') ?? {});

  void signOut() {
    GetStorage().remove('user');
    Get.offNamedUntil('/splash', (route) => false);
  }
}
