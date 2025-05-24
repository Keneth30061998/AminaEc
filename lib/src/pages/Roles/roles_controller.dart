import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../models/rol.dart';
import '../../models/user.dart';

class RolesController extends GetxController {
  User user = User.fromJson(GetStorage().read('user') ?? {});

  void goToPage(Rol rol) {
    Get.offNamedUntil(rol.route ?? '', (route) => false);
  }
}
