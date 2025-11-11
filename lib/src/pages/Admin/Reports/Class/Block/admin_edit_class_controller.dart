import 'package:amina_ec/src/models/class_reservation.dart';
import 'package:amina_ec/src/providers/class_reservation_provider.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../components/Socket/socket_service.dart';
import '../../../../models/user.dart';

class AdminCoachBlockController extends GetxController {
  User user = User.fromJson(GetStorage().read('user') ?? {});

  final occupiedEquipos = <int>{}.obs;
  final blockedEquipos = <int>{}.obs;
  final selectedEquipos = <int>{}.obs;

  late String coachId;
  late String classDate;
  late String classTime;
  late String coachName;

  final ClassReservationProvider _provider = ClassReservationProvider();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    coachId = args['coach_id'] ?? '';
    classDate = args['class_date'] ?? '';
    classTime = args['class_time'] ?? '';
    coachName = args['coach_name'] ?? '';

    fetchInitialState();
    listenSocketUpdates();
  }

  void fetchInitialState() async {
    final reservations = await _provider.getReservationsForSlot(
      classDate: classDate,
      classTime: classTime,
    );

    occupiedEquipos.clear();
    blockedEquipos.clear();

    for (var r in reservations) {
      if (r.status == 'blocked') {
        blockedEquipos.add(r.bicycle);
      } else {
        occupiedEquipos.add(r.bicycle);
      }
    }
  }

  void listenSocketUpdates() {
    SocketService().on('machine:status:update', (payload) {
      if (payload['class_date'] == classDate &&
          payload['class_time'] == classTime) {
        int bicycle = payload['bicycle'];
        String status = payload['status'];

        if (status == 'blocked') {
          blockedEquipos.add(bicycle);
          occupiedEquipos.remove(bicycle);
        } else if (status == 'occupied') {
          occupiedEquipos.add(bicycle);
          blockedEquipos.remove(bicycle);
        } else {
          occupiedEquipos.remove(bicycle);
          blockedEquipos.remove(bicycle);
        }
      }
    });
  }

  void toggleSeat(int number) {
    if (occupiedEquipos.contains(number)) return; // no tocar ocupadas

    if (selectedEquipos.contains(number)) {
      selectedEquipos.remove(number);
    } else {
      selectedEquipos.add(number);
    }
  }

  Future<void> applyBlock() async {
    if (selectedEquipos.isEmpty) {
      Get.snackbar('Nada seleccionado', 'Selecciona al menos una máquina.');
      return;
    }

    for (int bicycle in selectedEquipos) {
      await _provider.blockBike(
        coachId: coachId,
        bicycle: bicycle,
        classDate: classDate,
        classTime: classTime,
      );

      SocketService().emit('machine:status:update', {
        'bicycle': bicycle,
        'class_date': classDate,
        'class_time': classTime,
        'status': 'blocked'
      });

      blockedEquipos.add(bicycle);
    }

    selectedEquipos.clear();

    Get.snackbar('Listo', 'Bicicletas bloqueadas correctamente');
  }

  Future<void> applyUnblock() async {
    for (int bicycle in selectedEquipos) {
      await _provider.unblockBike(
        coachId: coachId,
        bicycle: bicycle,
        classDate: classDate,
        classTime: classTime,
      );

      SocketService().emit('machine:status:update', {
        'bicycle': bicycle,
        'class_date': classDate,
        'class_time': classTime,
        'status': 'available'
      });

      blockedEquipos.remove(bicycle);
    }

    selectedEquipos.clear();

    Get.snackbar('Listo', 'Bicicletas desbloqueadas');
  }
}
