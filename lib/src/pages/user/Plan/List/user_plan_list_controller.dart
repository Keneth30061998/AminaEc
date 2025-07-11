import 'package:amina_ec/src/providers/plans_provider.dart';
import 'package:get/get.dart';

import '../../../../components/Socket/socket_service.dart';
import '../../../../models/plan.dart';

class UserPlanListController extends GetxController {
  final PlanProvider planProvider = PlanProvider();

  // Lista reactiva de planes
  var plans = <Plan>[].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getPlans();

    // 🔄 Escuchar cambios en tiempo real
    SocketService().on('plan:new', (data) {
      print('📡 Evento recibido: $data');
      getPlans(); // Recarga la lista
    });

    SocketService().on('plan:delete', (data) {
      print('🗑️ Evento plan:delete recibido');
      getPlans();
    });
    SocketService().on('plan:update', (data) {
      print('🗑️ Evento plan:update recibido');
      getPlans();
    });
  }

  void getPlans() async {
    List<Plan> result = await planProvider.getAll();
    plans.value = result;
  }

  void refresh() {
    getPlans();
  }

  void goToPlanBuy(Plan plan) {
    Get.toNamed('/user/plan/buy', arguments: plan);
  }

  void goToPlanBuyResume(Plan plan) {
    Get.toNamed('/user/plan/buy/resume', arguments: plan);
  }
}
