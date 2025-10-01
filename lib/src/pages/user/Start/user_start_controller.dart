// lib/src/pages/user/Start/user_start_controller.dart

import 'package:amina_ec/src/pages/user/Start/reschedule_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

import '../../../components/Socket/socket_service.dart';
import '../../../models/coach.dart';
import '../../../models/scheduled_class.dart';
import '../../../models/user.dart';
import '../../../models/user_plan.dart';
import '../../../providers/class_reservation_provider.dart';
import '../../../providers/coachs_provider.dart';
import '../../../providers/scheduled_class_provider.dart';
import '../../../providers/user_plan_provider.dart';

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

  @override
  void onInit() {
    super.onInit();
    getCoaches();
    getTotalRides();
    getScheduledClasses();
    getAcquiredPlans();
    SocketService().on('coach:new', (_) => getCoaches());
    SocketService().on('coach:delete', (_) => getCoaches());
    SocketService().on('coach:update', (_) => getCoaches());
    SocketService().updateUserSession(user);
    SocketService().on('rides:updated', (_) => refreshTotalRides());
    SocketService().on('class:coach:reserved', (payload) {
      if (payload['user_id'].toString() == user.id.toString()) {
        getScheduledClasses();
      }
    });
    SocketService().on('class:reserved', (_) => getScheduledClasses());
  }

  void getAcquiredPlans() async {
    if (user.session_token != null) {
      final result = await userPlanProvider.getAllPlansWithRides(user.session_token!);
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
    List<ScheduledClass> result = await scheduledClassProvider.getByUser();
    scheduledClasses.value = result;
  }

  void onPressReschedule(ScheduledClass c, BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => RescheduleSheet(
        reservation: c,
        coaches: coaches,
        onSuccess: () {
          getScheduledClasses(); // refresca clases después de reagendar
        },
      ),
    );
  }


  Widget _rescheduleSheet(ScheduledClass c) {
    String selectedCoach = c.coachId;
    String selectedDate = c.classDate.split('T').first;
    String selectedTime = c.classTime;
    int selectedBike = c.bicycle;

    List<String> dates = [];
    List<String> times = [];
    List<int> bikes = [];

    Future<void> loadBikes() async {
      if (times.isEmpty) {
        bikes = [];
        return;
      }
      bikes = await classResProv.getAvailableBikes(
        coachId: selectedCoach,
        date: selectedDate,
        time: selectedTime,
      );
      if (!bikes.contains(selectedBike) && bikes.isNotEmpty) {
        selectedBike = bikes.first;
      }
    }

    Future<void> loadTimes() async {
      if (dates.isEmpty) {
        times = [];
        return;
      }
      times = await classResProv.getAvailableTimes(
        coachId: selectedCoach,
        date: selectedDate,
      );
      if (!times.contains(selectedTime) && times.isNotEmpty) {
        selectedTime = times.first;
      }
      await loadBikes();
    }

    Future<void> loadDates() async {
      dates = await classResProv.getAvailableDates(
        coachId: selectedCoach,
      );
      if (!dates.contains(selectedDate) && dates.isNotEmpty) {
        selectedDate = dates.first;
      }
      await loadTimes();
    }

    loadDates();

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(Get.context!).viewInsets.bottom),
      child: StatefulBuilder(
        builder: (context, setState) {
          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Reagendar Clase', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 12),

                  // Dropdown Coach
                  Obx(() {
                    final uniqueCoaches = <String, Coach>{
                      for (var x in coaches) x.id!: x
                    }.values.toList();

                    return DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Coach'),
                      initialValue: selectedCoach,
                      items: uniqueCoaches.map((coach) {
                        return DropdownMenuItem<String>(
                          value: coach.id,
                          child: Text(coach.user?.name ?? ''),
                        );
                      }).toList(),
                      onChanged: (v) async {
                        if (v == null) return;
                        setState(() {
                          selectedCoach = v;
                          dates = [];
                          times = [];
                          bikes = [];
                        });
                        await loadDates();
                        setState(() {});
                      },
                    );
                  }),

                  const SizedBox(height: 8),

                  // Dropdown Fecha
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Fecha'),
                    initialValue:
                        dates.contains(selectedDate) ? selectedDate : null,
                    items: dates.map((d) {
                      return DropdownMenuItem<String>(
                        value: d,
                        child: Text(DateFormat.yMd().format(DateTime.parse(d))),
                      );
                    }).toList(),
                    onChanged: (v) async {
                      if (v == null) return;
                      setState(() {
                        selectedDate = v;
                        times = [];
                        bikes = [];
                      });
                      await loadTimes();
                      setState(() {});
                    },
                  ),

                  const SizedBox(height: 8),

                  // Dropdown Hora
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Hora'),
                    initialValue:
                        times.contains(selectedTime) ? selectedTime : null,
                    items: times.map((t) {
                      return DropdownMenuItem<String>(
                        value: t,
                        child: Text(t.substring(0, 5)),
                      );
                    }).toList(),
                    onChanged: (v) async {
                      if (v == null) return;
                      setState(() {
                        selectedTime = v;
                        bikes = [];
                      });
                      await loadBikes();
                      setState(() {});
                    },
                  ),

                  const SizedBox(height: 8),

                  // Dropdown Máquina
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(labelText: 'Máquina'),
                    initialValue:
                        bikes.contains(selectedBike) ? selectedBike : null,
                    items: bikes.map((b) {
                      return DropdownMenuItem<int>(
                        value: b,
                        child: Text('Bicicleta $b'),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        selectedBike = v;
                      });
                    },
                  ),

                  const SizedBox(height: 16),
                  ElevatedButton(
                    child: Text('Confirmar'),
                    onPressed: () async {
                      final resp = await classResProv.rescheduleClass(
                        reservationId: c.id,
                        newDate: selectedDate,
                        newTime: selectedTime,
                        newCoachId: selectedCoach,
                        newBicycle: selectedBike,
                      );
                      if (resp.success == true) {
                        Get.back();
                        getScheduledClasses();
                        Get.snackbar('Éxito', resp.message ?? 'Reagendada');
                      } else {
                        Get.snackbar(
                            'Error', resp.message ?? 'No se pudo reagendar');
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
