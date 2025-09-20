import 'package:amina_ec/src/providers/user_plan_provider.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../components/Socket/socket_service.dart';
import '../../../models/coach.dart';
import '../../../models/scheduled_class.dart';
import '../../../models/user.dart';
import '../../../providers/coachs_provider.dart';
import '../../../providers/scheduled_class_provider.dart';

class UserStartController extends GetxController {
  User user = User.fromJson(GetStorage().read('user') ?? {});

  final CoachProvider coachProvider = CoachProvider();
  final UserPlanProvider userPlanProvider = UserPlanProvider();
  final ScheduledClassProvider scheduledClassProvider =
      ScheduledClassProvider();

  var coaches = <Coach>[].obs;
  final RxInt totalRides = 0.obs;

  final RxList<ScheduledClass> scheduledClasses = <ScheduledClass>[].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getCoaches();
    getTotalRides();
    getScheduledClasses();
    SocketService().on('coach:new', (data) {
      //print('📡 Evento coach:new recibido');
      getCoaches();
    });

    SocketService().on('coach:delete', (data) {
      //print('🗑️ Evento coach:delete recibido');
      getCoaches();
    });
    SocketService().on('coach:update', (data) {
      //print('🗑️ Evento coach:update recibido');
      getCoaches();
    });
    SocketService().updateUserSession(user);
    SocketService().on('rides:updated', (_) {
      //print('📡 Evento rides:updated recibido');
      refreshTotalRides();
    });
    SocketService().on('class:coach:reserved', (payload) {
      if (payload['user_id'].toString() == user.id.toString()) {
        //print('📡 Detected class:coach:reserved for current user');
        getScheduledClasses(); // 🔄 Actualiza listado en tiempo real
      }
    });

    SocketService().on('class:reserved', (_) => getScheduledClasses());
  }

  void getCoaches() async {
    List<Coach> result = await coachProvider.getAll();
    coaches.value = result;
  }

  void getTotalRides() async {
    if (user.session_token != null) {
      int rides =
          await userPlanProvider.getTotalActiveRides(user.session_token!);
      totalRides.value = rides;
    }
    //print('***Total de Rides: $totalRides');
  }

  void refreshTotalRides() {
    getTotalRides();
  }

  void getScheduledClasses() async {
    List<ScheduledClass> result = await scheduledClassProvider.getByUser();
    scheduledClasses.value = result;
  }
}
