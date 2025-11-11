import 'package:get/get.dart';
import 'package:amina_ec/src/models/response_api.dart';
import 'package:amina_ec/src/providers/class_reservation_provider.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class AdminCoachBlockController extends GetxController {
  final ClassReservationProvider _provider = ClassReservationProvider();

  final occupiedEquipos = <int>{}.obs;
  final blockedEquipos = <int>{}.obs;
  final selectedEquipos = <int>{}.obs;

  late String coachId;
  late String classDate;
  late String classTime;
  late String coachName;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    coachId = args['coach_id'];
    classDate = args['class_date'];
    classTime = args['class_time'];
    coachName = args['coach_name'];
    loadState();
  }

  Future<void> loadState() async {
    final reservations = await _provider.getReservationsForSlot(
      classDate: classDate,
      classTime: classTime,
    );

    occupiedEquipos.clear();
    blockedEquipos.clear();
    selectedEquipos.clear();

    for (var r in reservations) {
      if (r.status == 'blocked') {
        blockedEquipos.add(r.bicycle);
      } else {
        occupiedEquipos.add(r.bicycle);
      }
    }
  }

  void toggleSeat(int seat) {
    if (occupiedEquipos.contains(seat)) return;
    if (selectedEquipos.contains(seat)) {
      selectedEquipos.remove(seat);
    } else {
      selectedEquipos.add(seat);
    }
  }

  Future<void> applyBlock() async {
    print('🟣 applyBlock() iniciado');
    print('➡️ selectedEquipos: $selectedEquipos');

    for (int seat in selectedEquipos) {
      print('🚲 Intentando bloquear bici: $seat');

      ResponseApi res = await _provider.blockBike(
        coachId: coachId,
        bicycle: seat,
        classDate: classDate,
        classTime: classTime,
      );

      print('🔍 Respuesta backend: success=${res.success}, message=${res.message}');

      if (res.success == true) {
        print('✅ Bicicleta $seat bloqueada');
        blockedEquipos.add(seat);
      } else {
        print('❌ Error al bloquear $seat → ${res.message}');
        Get.snackbar('Error', res.message!, backgroundColor: Colors.redAccent, colorText: whiteLight);
      }
    }

    print('🧹 Limpiando selección…');
    selectedEquipos.clear();

    print('♻️ Recargando estado desde el servidor…');
    await loadState(); // 👈 IMPORTANTE PARA QUE UI SE ACTUALICE
  }


  Future<void> applyUnblock() async {
    for (int seat in selectedEquipos) {
      await _provider.unblockBike(
        coachId: coachId,
        bicycle: seat,
        classDate: classDate,
        classTime: classTime,
      );
      blockedEquipos.remove(seat);
    }
    selectedEquipos.clear();
  }
}
