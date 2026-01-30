import 'package:amina_ec/src/providers/class_reservation_provider.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../../components/Socket/socket_service.dart';
import '../../../../../models/user.dart';

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

    final args = (Get.arguments ?? {}) as Map;

    // ✅ Parse seguro: si coach_id viene como int, no revienta.
    coachId = (args['coach_id'] ?? '').toString();
    classDate = (args['class_date'] ?? '').toString();
    classTime = (args['class_time'] ?? '').toString();
    coachName = (args['coach_name'] ?? '').toString();

    fetchInitialState();
    listenSocketUpdates();
  }

  Future<void> fetchInitialState() async {
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
    // Normalmente RxSet ya refresca en add/remove/clear, pero esto
    // no hace daño y asegura UI siempre actualizada.
    occupiedEquipos.refresh();
    blockedEquipos.refresh();
  }

  void listenSocketUpdates() {
    SocketService().on('machine:status:update', (payload) {
      if (payload['class_date'] == classDate &&
          payload['class_time'] == classTime) {
        final bicycle = int.tryParse(payload['bicycle'].toString()) ?? 0;
        final status = payload['status'].toString();

        if (bicycle == 0) return;

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

        blockedEquipos.refresh();
        occupiedEquipos.refresh();
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
    selectedEquipos.refresh();
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
        'status': 'blocked',
      });

      blockedEquipos.add(bicycle);
    }

    selectedEquipos.clear();

    blockedEquipos.refresh();
    selectedEquipos.refresh();

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
        'status': 'available',
      });

      blockedEquipos.remove(bicycle);
    }

    selectedEquipos.clear();

    blockedEquipos.refresh();
    selectedEquipos.refresh();

    Get.snackbar('Listo', 'Bicicletas desbloqueadas');
  }
}
