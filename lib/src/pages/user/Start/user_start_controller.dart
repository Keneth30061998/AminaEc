import 'package:amina_ec/src/pages/user/Start/reschedule_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';


import '../../../components/Socket/socket_service.dart';
import '../../../models/coach.dart';
import '../../../models/scheduled_class.dart';
import '../../../models/user.dart';
import '../../../models/user_plan.dart';
import '../../../providers/class_reservation_provider.dart';
import '../../../providers/coachs_provider.dart';
import '../../../providers/scheduled_class_provider.dart';
import '../../../providers/user_plan_provider.dart';
import '../../../providers/users_provider.dart';

class UserStartController extends GetxController {
  User user = User.fromJson(GetStorage().read('user') ?? {});

  final CoachProvider coachProvider = CoachProvider();
  final UserPlanProvider userPlanProvider = UserPlanProvider();
  final ScheduledClassProvider scheduledClassProvider =
  ScheduledClassProvider();
  final ClassReservationProvider classResProv = ClassReservationProvider();
  final RxList<UserPlan> acquiredPlans = <UserPlan>[].obs;
  var coaches = <Coach>[].obs;
  final RxInt totalRides = 0.obs;
  final RxList<ScheduledClass> scheduledClasses = <ScheduledClass>[].obs;
  final RxInt attendedClasses = 0.obs;


  @override
  void onInit() {
    super.onInit();
    getCoaches();
    getTotalRides();
    getScheduledClasses();
    getAcquiredPlans();
    getAttendedClasses();

    // ---- Socket listeners ----
    SocketService().updateUserSession(user);

    SocketService().on('coach:new', (_) {
      //print('📡 Socket -> coach:new');
      getCoaches();
    });

    SocketService().on('coach:delete', (_) {
      //print('📡 Socket -> coach:delete');
      getCoaches();
    });

    SocketService().on('coach:update', (_) {
      //print('📡 Socket -> coach:update');
      getCoaches();
    });

    SocketService().on('rides:updated', (payload) {
      //print('📡 Socket -> rides:updated');
      refreshTotalRides();
    });

    SocketService().on('class:coach:reserved', (payload) {
      //print('📡 Socket -> class:coach:reserved $payload');
      if (payload['user_id'].toString() == user.id.toString()) {
        //print('✅ Refrescando clases reservadas (class:coach:reserved)');
        getScheduledClasses();
      }
    });

    SocketService().on('class:reserved', (payload) {
      //print('📡 Socket -> class:reserved $payload');
      getScheduledClasses();
    });

    // 🔑 Importante: escuchar re-agendamiento
    SocketService().on('class:coach:rescheduled', (payload) {
      //print('📡 Socket -> class:coach:rescheduled $payload');
      if (payload['user_id'].toString() == user.id.toString()) {
        //print('✅ Refrescando clases reservadas (class:coach:rescheduled)');
        getScheduledClasses();
      }
    });
  }

  void getAttendedClasses() async {
    if (user.session_token == null || user.session_token!.isEmpty) return;
    try {
      int count = await UserProvider().getAttendedClasses(user.session_token!, userId: user.id);
      attendedClasses.value = count;
      //print('✅ attendedClasses cargadas: $count');
    } catch (e) {
      //print('❌ Error obteniendo attendedClasses: $e');
    }
  }


  void getAcquiredPlans() async {
    if (user.session_token != null) {
      final result =
      await userPlanProvider.getAllPlansWithRides(user.session_token!);
      acquiredPlans.value = result;
    }
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
  }

  void refreshTotalRides() {
    getTotalRides();
    getAcquiredPlans();
  }

  void getScheduledClasses() async {
    //print('🔄 Refrescando clases reservadas...');
    List<ScheduledClass> result = await scheduledClassProvider.getByUser();
    scheduledClasses.value = result;
    //print('✅ Total clases cargadas: ${scheduledClasses.length}');
  }

  void onPressReschedule(ScheduledClass c, BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => RescheduleSheet(
        reservation: c,
        coaches: coaches,
        onSuccess: () {
          //print('📌 RescheduleSheet -> éxito en reagendar, refrescando lista');
          getScheduledClasses();
        },
      ),
    );
  }


}
