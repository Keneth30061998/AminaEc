import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../models/user.dart';

class UserProfileInfoController extends GetxController {
  var user = User.fromJson(GetStorage().read('user') ?? {}).obs;

  void signOut() {
    GetStorage().remove('user');
    Get.offNamedUntil('/splash', (route) => false);
  }

  void goToProfileUpdate() {
    Get.toNamed('/user/profile/update');
  }
}
