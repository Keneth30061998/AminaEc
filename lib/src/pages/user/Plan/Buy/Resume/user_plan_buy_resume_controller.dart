import 'package:get/get.dart';

import '../../../../../models/plan.dart';

class UserPlanBuyResumeController extends GetxController {
  late Plan plan;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    plan = Get.arguments as Plan;
  }

  double calculate_subtotal() {
    double subtotal = plan.price! - (plan.price! * 0.15);
    return subtotal;
  }

  double calculate_iva() {
    return (plan.price! * 0.15);
  }

  double calculate_total() {
    return calculate_subtotal() + calculate_iva();
  }
}
