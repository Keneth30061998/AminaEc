import 'package:get/get.dart';

class AdminHomeController extends GetxController {
  var indexTab = 0.obs;

  void changeTab(int index) {
    if (index < 0 || index > 4) return;
    indexTab.value = index;
  }
}

