import 'package:get/get.dart';

class LoginOrRegisterController extends GetxController {
  void goToRegisterPage() {
    Get.offNamedUntil('/register', (route) => true);
  }

  void goToLoginPage() {
    Get.offNamedUntil('/login', (route) => true);
  }
}
