import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class HomeController extends GetxController {
  void signOut() {
    GetStorage().remove('user');
    Get.offNamedUntil('/splash', (route) => false);
  }
}
