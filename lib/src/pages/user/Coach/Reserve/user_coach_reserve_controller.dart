import 'package:amina_ec/src/models/class_reservation.dart';
import 'package:amina_ec/src/models/response_api.dart';
import 'package:amina_ec/src/providers/class_reservation_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../components/Socket/socket_service.dart';
import '../../../../models/user.dart';
import '../../../../providers/user_plan_provider.dart';

class UserCoachReserveController extends GetxController {
  //Datos del usuario - token - rides
  User user = User.fromJson(GetStorage().read('user') ?? {});
  final UserPlanProvider userPlanProvider =
      UserPlanProvider(context: Get.context!);

  //Equipo seleccionado
  var selectedEquipos = <int>{}.obs;

  //Máquinas ocupadas
  final occupiedEquipos = <int>{}.obs;

  //variable reactiva contadora de rides
  final RxInt totalRides = 0.obs;

  //Datos de reserva
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
    //Obtener argumentos de navegación
    final args = Get.arguments;
    coachId = args['coach_id'] ?? '';
    classDate = args['class_date'];
    classTime = args['class_time'];
    userId = _user['id'];
    coachName = args['coach_name'];
    sessionToken = (_user['session_token'] ?? '').toString();
    //Obtener total de rides
    getTotalRides();
    SocketService().updateUserSession(user);
    SocketService().on('rides:updated', (_) {
      print('📡 Evento rides:updated recibido');
      getTotalRides();
    });
    //mauinas ocuapadas
    listenToMachineStatus();
    fetchOccupiedEquiposInicial();
  }

  //Toggle visual de bicicleta seleccionada
  void toggleEquipo(int equipo) {
    if (occupiedEquipos.contains(equipo)) return;
    if (selectedEquipos.contains(equipo)) {
      selectedEquipos.remove(equipo);
    } else {
      selectedEquipos.clear();
      selectedEquipos.add(equipo);
    }
  }

  // 🚀 Agendar clase
  Future<void> reserveClass(BuildContext context) async {
    if (selectedEquipos.isEmpty) {
      Get.snackbar('Máquina no seleccionada', 'Debes elegir una bicicleta');
      return;
    }

    int bicycle = selectedEquipos.first;

    // 👉 Hacer la petición al backend
    ResponseApi response = await _provider.scheduleClass(
      coachId: coachId,
      bicycle: bicycle,
      classDate: classDate,
      classTime: classTime,
    );

    if (response.success! && response.data != null) {
      // ✔ Éxito
      ClassReservation reservation = response.data as ClassReservation;

      Get.snackbar('Clase agendada', '¡Tu ride está confirmado!');

      // 📡 Emitir sockets para usuario, coach y mapa
      SocketService().emit('class:reserved', reservation.toJson());
      SocketService().emit('class:coach:reserved', reservation.toJson());
      SocketService().emit('machine:status:update', {
        'bicycle': bicycle,
        'class_date': classDate,
        'class_time': classTime,
        'status': 'occupied'
      });

      // 🧭 Navegar (puedes redirigir al historial o calendario)
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pop(); // ← Ajusta según tu flujo
      });
    } else {
      // ❌ Error
      Get.snackbar('Error', response.message ?? 'No se pudo agendar la clase');
    }
  }

  //Obtener total de rides
  void getTotalRides() async {
    if (user.session_token != null) {
      int rides =
          await userPlanProvider.getTotalActiveRides(user.session_token!);
      totalRides.value = rides;
    }
    //print('***Total de Rides: $totalRides');
  }

  //maquinas ocupadas
  void listenToMachineStatus() {
    SocketService().on('machine:status:update', (payload) {
      String date = payload['class_date'];
      String time = payload['class_time'];
      int bicycle = payload['bicycle'];
      String status = payload['status'];

      // Verificar si corresponde a esta vista
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
