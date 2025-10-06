import 'package:amina_ec/src/models/class_reservation.dart';
import 'package:amina_ec/src/models/response_api.dart';
import 'package:amina_ec/src/providers/class_reservation_provider.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../components/Socket/socket_service.dart';
import '../../../../models/user.dart';
import '../../../../providers/user_plan_provider.dart';
import '../../Start/user_start_controller.dart';

class UserCoachReserveController extends GetxController {
  User user = User.fromJson(GetStorage().read('user') ?? {});
  late UserPlanProvider userPlanProvider;

  var selectedEquipos = <int>{}.obs;
  final occupiedEquipos = <int>{}.obs;
  final RxInt totalRides = 0.obs;

  late String coachId;
  late String classDate;
  late String classTime;
  late String userId;
  late String sessionToken;
  late String coachName;

  final ClassReservationProvider _provider = ClassReservationProvider();
  final Map<String, dynamic> _user = GetStorage().read('user');

  @override
  void onInit() {
    super.onInit();

    userPlanProvider = UserPlanProvider();

    final args = Get.arguments;
    coachId = args['coach_id'] ?? '';
    classDate = args['class_date'] ?? '';
    classTime = args['class_time'] ?? '';
    userId = _user['id'] ?? '';
    coachName = args['coach_name'] ?? '';
    sessionToken = (_user['session_token'] ?? '').toString();

    getTotalRides();

    SocketService().updateUserSession(user);
    SocketService().on('rides:updated', (_) => getTotalRides());

    listenToMachineStatus();
    fetchOccupiedEquiposInicial();
  }

  void toggleEquipo(int equipo) {
    if (occupiedEquipos.contains(equipo)) return;
    if (selectedEquipos.contains(equipo)) {
      selectedEquipos.remove(equipo);
    } else {
      selectedEquipos.clear();
      selectedEquipos.add(equipo);
    }
  }

  Future<void> reserveClass() async {
    if (selectedEquipos.isEmpty) {
      Get.snackbar('Máquina no seleccionada', 'Debes elegir una bicicleta');
      return;
    }

    int bicycle = selectedEquipos.first;

    ResponseApi response = await _provider.scheduleClass(
      coachId: coachId,
      bicycle: bicycle,
      classDate: classDate,
      classTime: classTime,
    );

    if (response.success! && response.data != null) {
      ClassReservation reservation = response.data as ClassReservation;

      Get.snackbar('Clase agendada', '¡Tu ride está confirmado!');
      if (Get.isRegistered<UserStartController>()) {
        Get.find<UserStartController>().getScheduledClasses();
      }

      SocketService().emit('class:reserved', reservation.toJson());
      SocketService().emit('class:coach:reserved', reservation.toJson());
      SocketService().emit('machine:status:update', {
        'bicycle': bicycle,
        'class_date': classDate,
        'class_time': classTime,
        'status': 'occupied'
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (Get.isOverlaysOpen) Get.back();
        Get.offAllNamed('/user/home');
      });
    } else {
      Get.snackbar('Error', response.message ?? 'No se pudo agendar la clase');
    }
  }

  void getTotalRides() async {
    if (user.session_token != null) {
      int rides =
      await userPlanProvider.getTotalActiveRides(user.session_token!);
      totalRides.value = rides;
    }
  }

  void listenToMachineStatus() {
    SocketService().on('machine:status:update', (payload) {
      String date = payload['class_date'];
      String time = payload['class_time'];
      int bicycle = payload['bicycle'];
      String status = payload['status'];

      if (date == classDate && time == classTime) {
        if (status == 'occupied') {
          occupiedEquipos.add(bicycle);
        } else {
          occupiedEquipos.remove(bicycle);
        }
      }
    });
  }

  void fetchOccupiedEquiposInicial() async {
    final reservations = await _provider.getReservationsForSlot(
      classDate: classDate,
      classTime: classTime,
    );

    occupiedEquipos.clear();
    for (var r in reservations) {
      occupiedEquipos.add(r.bicycle);
    }
  }
}
