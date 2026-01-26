import 'package:amina_ec/src/models/user.dart';
import 'package:amina_ec/src/providers/plan_usage_report_provider.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../models/plan_usage_event.dart';


class AdminUserHistoryController extends GetxController {
  final PlanUsageReportProvider  _provider = PlanUsageReportProvider ();

  final loading = true.obs;
  final error = RxnString();

  final events = <PlanUsageEvent>[].obs;

  final filter = 'ALL'.obs; // ALL | CLASS | ATTENDANCE | PLAN

  final User userSession = User.fromJson(GetStorage().read('user') ?? {});
  late final User targetUser;

  @override
  void onInit() {
    super.onInit();
    targetUser = Get.arguments as User;
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    loading.value = true;
    error.value = null;

    try {
      final list = await _provider.getUserHistory(
        userId: targetUser.id!,
        token: userSession.session_token ?? '',
      );
      events.assignAll(list);
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }



  List<PlanUsageEvent> get filteredEvents {
    final f = filter.value;
    if (f == 'ALL') return events;

    if (f == 'CLASS') return events.where((e) => e.isClassEvent).toList();
    if (f == 'ATTENDANCE') return events.where((e) => e.isAttendanceEvent).toList();
    if (f == 'PLAN') return events.where((e) => e.isPlanEvent).toList();

    return events;
  }

  void setFilter(String v) => filter.value = v;
}
