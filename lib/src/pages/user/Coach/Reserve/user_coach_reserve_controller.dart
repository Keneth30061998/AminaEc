import 'package:amina_ec/src/models/class_reservation.dart';
import 'package:amina_ec/src/models/response_api.dart';
import 'package:amina_ec/src/providers/class_reservation_provider.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../components/Socket/socket_service.dart';
import '../../../../models/user.dart';
import '../../../../providers/user_plan_provider.dart';
import '../../Start/user_start_controller.dart';

class UserCoachReserveController extends GetxController {
  User user = User.fromJson(GetStorage().read('user') ?? {});
  late UserPlanProvider userPlanProvider;

  var selectedEquipos = <int>{}.obs;
  final occupiedEquipos = <int>{}.obs;
  final blockedEquipos = <int>{}.obs;
  final RxInt totalRides = 0.obs;

  late String coachId;
  late String classDate;
  late String classTime;
  late String userId;
  late String sessionToken;
  late String coachName;

  final ClassReservationProvider _provider = ClassReservationProvider();
  final Map<String, dynamic> _user = GetStorage().read('user');

  // ✅ Link fijo App Store (solo iOS por ahora)
  static const String _appStoreUrl =
      'https://apps.apple.com/ec/app/amina/id6753769136?l=en-GB';
  static const String _appAndroid =
    'https://apiv1.pruebasinventario.com/public/amina-android.html';

  // ✅ Guardamos la bici usada en la última reserva confirmada
  int? _lastReservedBicycle;

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
    if (occupiedEquipos.contains(equipo) || blockedEquipos.contains(equipo)) return;

    if (selectedEquipos.contains(equipo)) {
      selectedEquipos.remove(equipo);
    } else {
      selectedEquipos.clear();
      selectedEquipos.add(equipo);
    }
  }

  Future<void> reserveClass() async {
    // 1️⃣ Validaciones iniciales
    if (totalRides.value <= 0) {
      Get.snackbar(
        'No tienes rides disponibles',
        'Compra un plan para reservar esta clase',
        backgroundColor: almostBlack,
        colorText: whiteLight,
        duration: const Duration(seconds: 2),
      );

      await Future.delayed(const Duration(seconds: 2));
      Get.offNamed('/user/plan');
      return;
    }

    if (selectedEquipos.isEmpty) {
      Get.snackbar('Máquina no seleccionada', 'Debes elegir una bicicleta');
      return;
    }

    final int bicycle = selectedEquipos.first;

    // 2️⃣ Llamada a la API
    ResponseApi response = await _provider.scheduleClass(
      coachId: coachId,
      bicycle: bicycle,
      classDate: classDate,
      classTime: classTime,
    );

    // 3️⃣ Verificación de éxito y conversión segura
    if (response.success == true && response.data != null) {
      try {
        final reservationMap = response.data as Map<String, dynamic>;
        final reservation = ClassReservation.fromJson(reservationMap);

        // ✅ Guardamos bici confirmada para el invite
        _lastReservedBicycle = bicycle;

        // 4️⃣ Mostrar diálogo de confirmación (con invitación)
        showReservationDialog(Get.context!);

        // 5️⃣ Actualizar listado de clases si está registrado UserStartController
        if (Get.isRegistered<UserStartController>()) {
          Get.find<UserStartController>().getScheduledClasses();
        }

        // 6️⃣ Emitir eventos por socket
        final reservationJson = reservation.toJson();
        SocketService().emit('class:reserved', reservationJson);
        SocketService().emit('class:coach:reserved', reservationJson);
        SocketService().emit('machine:status:update', {
          'bicycle': bicycle,
          'class_date': classDate,
          'class_time': classTime,
          'status': 'occupied'
        });

        // 7️⃣ Redirección con delay
        Future.delayed(const Duration(seconds: 7), () {
          if (Get.isOverlaysOpen) Get.back();
          Get.offAllNamed('/user/home');
        });
      } catch (e) {
        print('❌ Error convirtiendo respuesta a ClassReservation: $e');
        Get.snackbar('Error', 'No se pudo procesar la reserva correctamente');
      }
    } else {
      // 8️⃣ Manejo de error de API
      Get.snackbar('Error', response.message ?? 'No se pudo agendar la clase');
    }
  }

  // ✅ INVITACIÓN: arma mensaje con datos de la clase + link App Store y abre Share Sheet
  Future<void> shareInvite(BuildContext context) async {
    final msg = _buildInviteMessage();
    final subject = 'Únete conmigo en AMINA';

    try {
      final box = context.findRenderObject() as RenderBox?;
      if (box != null) {
        await Share.share(
          msg,
          subject: subject,
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
        );
      } else {
        await Share.share(msg, subject: subject);
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudo abrir el menú de compartir');
    }
  }

  String _buildInviteMessage() {
    final datePretty = _formatDateEs(classDate);
    final timePretty = _formatTimeHHmm(classTime);
    final bike = _lastReservedBicycle;

    //final bikeLine = (bike != null) ? '🪑 Bici: #$bike\n' : '';

    final iosSection = '📲 iOS (App Store)\n$_appStoreUrl';
    final androidSection = (_appAndroid.trim().isNotEmpty)
        ? '\n\n🤖 Android (Google Play)\n$_appAndroid'
        : '';

    return '🚴‍♂️ *AMINA* — Invitación a clase\n'
        '──────────────\n'
        '👤 Coach: $coachName\n'
        '📅 Fecha: $datePretty\n'
        '🕒 Hora: $timePretty\n'
        '\n'
        'Descarga la app aquí:\n\n'
        '$iosSection'
        '$androidSection';
  }


  String _formatTimeHHmm(String rawTime) {
    final parts = rawTime.split(":");
    if (parts.length < 2) return rawTime;
    final hh = parts[0].padLeft(2, '0');
    final mm = parts[1].padLeft(2, '0');
    return '$hh:$mm';
  }

  String _formatDateEs(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      // Ej: "viernes 14 de febrero"
      return DateFormat("EEEE d 'de' MMMM", 'es_ES').format(dt);
    } catch (_) {
      return isoDate;
    }
  }

  void showReservationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  const Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
                  const SizedBox(height: 15),
                  const Text(
                    '¡Reserva confirmada!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Sabemos que a veces surgen imprevistos — recuerda que puedes cancelar tu clase hasta 12 horas antes.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _BulletPoint(
                        text:
                        'Las puertas se abrirán únicamente al final de la primera y segunda canción (no podemos interrumpir la clase).',
                      ),
                      _BulletPoint(
                        text:
                        'Si no llegas a tiempo, tu bici será liberada entre la primera y segunda canción, pero podrás ingresar solo si hay disponibilidad.',
                      ),
                      _BulletPoint(text: 'Usa ropa cómoda.'),
                      _BulletPoint(
                        text:
                        'Evita el uso del teléfono para que todos podamos disfrutar la experiencia al máximo.',
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // ✅ Botones: Invitar + Aceptar
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => shareInvite(context),
                          icon: const Icon(Icons.ios_share_rounded),
                          label: const Text(
                            'Invitar a un amigo',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black87,
                            side: BorderSide(color: Colors.black.withOpacity(.12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back();
                            Get.offAllNamed('/user/home');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Aceptar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: whiteLight,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void getTotalRides() async {
    if (user.session_token != null) {
      int rides = await userPlanProvider.getTotalActiveRides(user.session_token!);
      totalRides.value = rides;
    }
  }

  /// ✅ CORREGIDO → maneja correctamente bicicletas bloqueadas & conversion String → int
  void listenToMachineStatus() {
    SocketService().on('machine:status:update', (payload) {
      final String date = payload['class_date'] ?? '';
      final String time = payload['class_time'] ?? '';
      final int bicycle = int.tryParse(payload['bicycle'].toString()) ?? -1;
      final String status = payload['status'] ?? '';

      if (bicycle == -1) return;
      if (date != classDate || time != classTime) return;

      if (status == 'occupied') {
        occupiedEquipos.add(bicycle);
        blockedEquipos.remove(bicycle);
      } else if (status == 'blocked') {
        blockedEquipos.add(bicycle);
        occupiedEquipos.remove(bicycle);
      } else {
        occupiedEquipos.remove(bicycle);
        blockedEquipos.remove(bicycle);
      }

      update();
    });
  }

  void fetchOccupiedEquiposInicial() async {
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
}

class _BulletPoint extends StatelessWidget {
  final String text;

  const _BulletPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 5.0),
            child: Icon(Icons.circle, size: 6, color: Colors.black87),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14.5,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
