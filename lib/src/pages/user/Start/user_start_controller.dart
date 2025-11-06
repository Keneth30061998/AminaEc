import 'package:amina_ec/src/pages/user/Start/reschedule_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';


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
import '../../../utils/color.dart';

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

  void onPressCancel(ScheduledClass c, BuildContext context) async {
    try {
      // Convertir classDate + classTime a DateTime local
      final dateString = c.classDate.split('T').first;
      final timeString = c.classTime.substring(0, 5); // HH:mm
      final partsDate = dateString.split('-').map(int.parse).toList();
      final partsTime = timeString.split(':').map(int.parse).toList();

      final classDateTime = DateTime(
        partsDate[0],
        partsDate[1],
        partsDate[2],
        partsTime[0],
        partsTime[1],
      );

      final now = DateTime.now();
      final hoursDiff = classDateTime.difference(now).inHours;

      // Validación UI/UX: solo permitir si hay >= 12 horas
      if (hoursDiff < 12) {
        Get.snackbar(
          'No es posible cancelar',
          'Solo puedes cancelar con al menos 12 horas de anticipación.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }

      // Confirmación
      final shouldCancel = await Get.dialog<bool>(
        AlertDialog(
          title: Text('Cancelar clase',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
          content: Text(
            '¿Estás seguro de cancelar tu clase?\nTu ride será devuelto.',
            style: GoogleFonts.roboto(color: darkGrey),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('Volver', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: indigoAmina,),),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: almostBlack),
              onPressed: () => Get.back(result: true),
              child: Text('Cancelar clase' ,style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: whiteLight,),),
            ),
          ],
        ),
      );

      // Si el usuario cerró el diálogo o dijo "No"
      if (shouldCancel != true) return;

      // Llamada al provider
      final res = await classResProv.cancelClass(c.id);

      // CORRECCIÓN: comparar explícitamente con true para evitar nullable error
      if (res != null && (res.success == true)) {
        // actualizar lista local y rides
        scheduledClasses.removeWhere((sc) => sc.id == c.id);
        refreshTotalRides();

        Get.snackbar(
          'Clase cancelada',
          'Tu ride ha sido devuelto.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        // si res es null o success != true
        final msg = (res != null && res.message != null) ? res.message! : 'No se pudo cancelar la clase.';
        Get.snackbar(
          'Error',
          msg,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // fallback genérico
      Get.snackbar(
        'Error',
        'Ocurrió un error al cancelar la clase: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }



  void showUserPlansInfo() async {
    final token = user.session_token!;
    final plans = await userPlanProvider.getUserPlansSummary(user.id!, token);

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          "Planes de ${user.name}",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: almostBlack,
          ),
        ),
        content: SizedBox(
          width: Get.width * 0.8,
          child: plans.isEmpty
              ? Center(
            child: Text(
              "Este usuario no tiene planes activos.",
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          )
              : Column(
            mainAxisSize: MainAxisSize.min,
            children: plans.map((plan) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                width: Get.width * 0.8,
                decoration: BoxDecoration(
                  color: colorBackgroundBox,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan["plan_name"] ?? "Plan sin nombre",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: indigoAmina,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Rides restantes: ${plan["remaining_rides"]}",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: almostBlack,
                      ),
                    ),
                    Text(
                      "Inicio: ${plan["start_date"]?.split('T').first.split('-').reversed.join('/') ?? 'No definida'} ",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: almostBlack,
                      ),
                    ),
                    Text(
                      "Fin: ${plan["end_date"]?.split('T').first.split('-').reversed.join('/') ?? 'No definida'} ",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: almostBlack,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text("Cerrar",
                style: TextStyle(
                  color: indigoAmina,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                )),
          ),
        ],
      ),
    );
  }


}
