import 'package:amina_ec/src/providers/plans_provider.dart';
import 'package:get/get.dart';

import '../../../../../components/Socket/socket_service.dart';
import '../../../../../models/plan.dart';



class AdminPlanListController extends GetxController {
  final List<void Function()> _subscriptions = [];
  void _listen(String event, Function(dynamic) callback) {
    _subscriptions.add(SocketService().subscribe(event, callback));
  }
  @override
  void onClose() {
    for (final cancel in _subscriptions) { cancel(); }
    super.onClose();
  }
  final PlanProvider planProvider = PlanProvider();

  // Lista reactiva de planes
  var plans = <Plan>[].obs;
  final loading = false.obs;
  final error = RxnString();
  final deleting = <String>[].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getPlans();

    // 🔄 Escuchar cambios en tiempo real
    _listen('plan:new', (data) {
      //print('📡 Evento recibido: $data');
      getPlans(); // Recarga la lista
    });

    _listen('plan:delete', (data) {
      //print('🗑️ Evento plan:delete recibido');
      getPlans();
    });

    _listen('plan:update', (data) {
      //print('🗑️ Evento plan:update recibido');
      getPlans();
    });
  }

  Future<void> getPlans() async {
    loading.value = true;
    error.value = null;
    try { plans.value = await planProvider.getAll(); }
    catch (_) { error.value = 'No se pudieron cargar los planes.'; }
    finally { loading.value = false; }
  }

  @override
  void refresh() {
    getPlans();
  }

  Future<void> deletePlan(String id) async {
    if (deleting.contains(id)) return;
    deleting.add(id);
    try {
      final res = await planProvider.deletePlan(id);
      if (res.statusCode == 200 || res.statusCode == 201) {
        Get.snackbar('Éxito', 'Plan eliminado correctamente');
        await getPlans();
      } else { Get.snackbar('Error', 'No se pudo eliminar el plan'); }
    } catch (_) { Get.snackbar('Error', 'No se pudo eliminar el plan'); }
    finally { deleting.remove(id); }
  }
}
