import 'dart:async';
import 'package:amina_ec/src/models/class_reservation.dart';
import 'package:amina_ec/src/models/response_api.dart';

import 'package:amina_ec/src/providers/class_reservation_provider.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../components/Socket/socket_service.dart';
import '../../../../models/user.dart';
import '../../../../providers/user_plan_provider.dart';
import '../../Start/user_start_controller.dart';
import 'package:amina_ec/src/services/calendar_sync_service.dart';
import 'package:amina_ec/src/providers/google_calendar_provider.dart';

class UserCoachReserveController extends GetxController {
  User user = User.fromJson(GetStorage().read('user') ?? {});
  late UserPlanProvider userPlanProvider;

  var selectedEquipos = <int>{}.obs;
  final occupiedEquipos = <int>{}.obs;
  final blockedEquipos = <int>{}.obs;
  final RxInt totalRides = 0.obs;

  final RxBool isInitializing = true.obs;
  final RxBool isSubmittingReservation = false.obs;
  final RxString loadingMessage = 'Cargando estudio...'.obs;

  bool get isBusy =>
      isInitializing.value ||
          isSubmittingReservation.value ||
          _isGoogleAuthInProgress.value;

  late String coachId;
  late String classDate;
  late String classTime;
  late String userId;
  late String sessionToken;
  late String coachName;

  final GoogleCalendarProvider _gcalProvider = GoogleCalendarProvider();
  final ClassReservationProvider _provider = ClassReservationProvider();
  final Map<String, dynamic> _user = GetStorage().read('user');

  static const String _appStoreUrl =
      'https://apps.apple.com/ec/app/amina/id6753769136?l=en-GB';
  static const String _appAndroid =
      'https://apiv1.pruebasinventario.com/public/amina-android.html';

  int? _lastReservedBicycle;
  Timer? _autoNavTimer;


  // evita que navegación/timer tumben el flujo de Google Sign-In
  final RxBool _isGoogleAuthInProgress = false.obs;


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

    SocketService().updateUserSession(user);
    SocketService().on('rides:updated', (_) => getTotalRides());
    listenToMachineStatus();

    _initializePage();
  }

  @override
  void onClose() {
    _autoNavTimer?.cancel();
    super.onClose();
  }

  Future<void> _initializePage() async {
    isInitializing.value = true;
    loadingMessage.value = 'Cargando estudio...';

    try {
      await Future.wait([
        getTotalRides(),
        fetchOccupiedEquiposInicial(),
      ]);
    } finally {
      isInitializing.value = false;
      loadingMessage.value = '';
    }
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


  DateTime _parseLocalStartDateTime(String dateRaw, String timeRaw) {
    final dateOnly = dateRaw.split('T').first.trim();
    final t = timeRaw.trim();
    final hhmm = (t.length >= 5) ? t.substring(0, 5) : t;

    final d = dateOnly.split('-').map(int.parse).toList();
    final partsTime = hhmm.split(':').map(int.parse).toList();

    return DateTime(d[0], d[1], d[2], partsTime[0], partsTime[1]);
  }

  void _startAutoRedirect() {
    _autoNavTimer?.cancel();
    _autoNavTimer = Timer(const Duration(seconds: 7), () {
      if (_isGoogleAuthInProgress.value) return;
      if (Get.isOverlaysOpen) Get.back();
      Get.offAllNamed('/user/home');
    });
  }

  void _cancelAutoRedirect() {
    _autoNavTimer?.cancel();
    _autoNavTimer = null;
  }

  void _showGooglePermissionExplanation() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              const Icon(
                Icons.calendar_month,
                size: 55,
                color: Colors.black87,
              ),

              const SizedBox(height: 14),

              const Text(
                'Conectar Google Calendar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                'AMINA utilizará Google Calendar únicamente para crear '
                    'recordatorios automáticos de tus clases reservadas.\n\n'
                    '✔ Solo se crean eventos de tus reservas.\n'
                    '✔ No leemos eventos personales.\n'
                    '✔ No modificamos tu calendario existente.\n'
                    '✔ Puedes desconectarlo cuando quieras.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.4,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 22),

              Row(
                children: [

                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Ahora no'),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        await _connectGoogleCalendarFlow();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                      ),
                      child: const Text(
                        'Continuar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> reserveClass() async {
    if (isBusy) return;

    FocusManager.instance.primaryFocus?.unfocus();

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

    await _submitReservation();
  }

  Future<void> _submitReservation() async {
    final int bicycle = selectedEquipos.first;

    isSubmittingReservation.value = true;
    loadingMessage.value = 'Confirmando tu reserva...';

    try {
      final ResponseApi response = await _provider.scheduleClass(
        coachId: coachId,
        bicycle: bicycle,
        classDate: classDate,
        classTime: classTime,
      );

      if (response.success == true && response.data != null) {
        try {
          final reservationMap = response.data as Map<String, dynamic>;
          final reservation = ClassReservation.fromJson(reservationMap);

          final gc = reservationMap['google_calendar'];
          final bool googleConnected = (gc is Map) && (gc['connected'] == true);
          final bool googleSynced = (gc is Map) && (gc['synced'] == true);
          final bool offerGoogleButton = (gc is Map) && (gc['connected'] == false);
          final String? googleError =
          (gc is Map && gc['error'] != null) ? gc['error'].toString() : null;

          _lastReservedBicycle = bicycle;

          occupiedEquipos.add(bicycle);
          selectedEquipos.clear();
          totalRides.value = totalRides.value > 0 ? totalRides.value - 1 : 0;

          if (!googleSynced) {
            try {
              final reservationIdSafe = reservation.id.toString();
              final start = _parseLocalStartDateTime(classDate, classTime);

              final title = 'AMINA — Clase con $coachName';
              final description =
                  'Reserva confirmada en AMINA.\nCoach: $coachName\nBici: #$bicycle\nFecha: ${_formatDateEs(classDate)}\nHora: ${_formatTimeHHmm(classTime)}';

              final eventId = await CalendarSyncService.instance.createOrUpdateEvent(
                reservationId: reservationIdSafe,
                title: title,
                start: start,
                durationMinutes: 50,
                description: description,
                location: 'AMINA Studio',
              );

              if (eventId == null) {
                Get.snackbar(
                  'Calendario',
                  'No se pudo agregar el recordatorio. Revisa permisos del calendario.',
                  backgroundColor: Colors.black87,
                  colorText: Colors.white,
                );
              }
            } catch (_) {}
          }

          if (Get.isRegistered<UserStartController>()) {
            Get.find<UserStartController>().getScheduledClasses();
          }

          final reservationJson = reservation.toJson();
          SocketService().emit('class:reserved', reservationJson);
          SocketService().emit('class:coach:reserved', reservationJson);
          SocketService().emit('machine:status:update', {
            'bicycle': bicycle,
            'class_date': classDate,
            'class_time': classTime,
            'status': 'occupied'
          });

          showReservationDialog(
            Get.context!,
            offerGoogleCalendar: offerGoogleButton,
            googleConnected: googleConnected,
            googleSynced: googleSynced,
            googleError: googleError,
          );

          if (!offerGoogleButton) {
            _startAutoRedirect();
          }
        } catch (e) {
          print('❌ Error convirtiendo respuesta a ClassReservation: $e');
          Get.snackbar('Error', 'No se pudo procesar la reserva correctamente');
        }
      } else {
        Get.snackbar('Error', response.message ?? 'No se pudo agendar la clase');
      }
    } finally {
      isSubmittingReservation.value = false;
      loadingMessage.value = '';
    }
  }

  Future<void> _connectGoogleCalendarFlow() async {
    _cancelAutoRedirect();
    _isGoogleAuthInProgress.value = true;

    try {
      Get.snackbar(
        'Google Calendar',
        'Abriendo conexión...',
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // ✅ delay para evitar "activity cancelled" por transición de overlays
      await Future.delayed(const Duration(milliseconds: 250));

      print("🟦 [GCAL] connect() start...");
      final resp = await _gcalProvider.connect();
      print("🟦 [GCAL] connect() resp: success=${resp.success} message=${resp.message}");

      ResponseApi finalResp = resp;

      final msg = (resp.message ?? "").toLowerCase();
      final needsForceConsent =
          msg.contains("refresh_token") || msg.contains("no devolvió refresh_token");

      if (resp.success != true && needsForceConsent) {
        print("🟦 [GCAL] refresh_token missing -> connectForceConsent()");
        await Future.delayed(const Duration(milliseconds: 250));
        finalResp = await _gcalProvider.connectForceConsent();
        print("🟦 [GCAL] connectForceConsent resp: success=${finalResp.success} message=${finalResp.message}");
      }

      if (finalResp.success == true) {
        Get.snackbar(
          'Google Calendar',
          'Conectado ✅. Las próximas reservas se agregarán automáticamente.',
          backgroundColor: Colors.black87,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        Future.delayed(const Duration(milliseconds: 700), () {
          Get.offAllNamed('/user/home');
        });
      } else {
        Get.snackbar(
          'Google Calendar',
          finalResp.message ?? 'No se pudo conectar',
          backgroundColor: Colors.black87,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } finally {
      _isGoogleAuthInProgress.value = false;
    }
  }

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

    final iosSection = '📲 iOS (App Store)\n$_appStoreUrl';
    final androidSection =
    (_appAndroid.trim().isNotEmpty) ? '\n\n🤖 Android (Google Play)\n$_appAndroid' : '';

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
      return DateFormat("EEEE d 'de' MMMM", 'es_ES').format(dt);
    } catch (_) {
      return isoDate;
    }
  }

  void showReservationDialog(
      BuildContext context, {
        bool offerGoogleCalendar = false,
        bool googleConnected = false,
        bool googleSynced = false,
        String? googleError,
      }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
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
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Sabemos que a veces surgen imprevistos — recuerda que puedes cancelar tu clase hasta 12 horas antes.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
                  ),
                  const SizedBox(height: 16),

                  if (googleSynced) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.calendar_month, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Agregado a Google Calendar ✅', style: TextStyle(color: almostBlack),),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ] else if (googleConnected && googleError != null && googleError.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Google Calendar no pudo sincronizar: $googleError',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: almostBlack
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],

                  const SizedBox(height: 8),
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

                  if (offerGoogleCalendar) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_month_outlined),
                        label: const Text('Conectar Google Calendar',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () async {
                          Get.back();
                          Future.delayed(const Duration(milliseconds: 250), () {
                            _showGooglePermissionExplanation();
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          side: BorderSide(color: Colors.black.withOpacity(.12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Google Calendar se aplicará automáticamente para tus próximas reservas.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12.5, color: Colors.black54),
                    ),
                    const SizedBox(height: 10),
                  ],

                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => shareInvite(context),
                          icon: const Icon(Icons.ios_share_rounded),
                          label: const Text('Invitar a un amigo',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black87,
                            side: BorderSide(color: Colors.black.withOpacity(.12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _cancelAutoRedirect();
                            Get.back();
                            //Get.offAllNamed('/user/home');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Aceptar',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: whiteLight),
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

  Future<void> getTotalRides() async {
    if (user.session_token != null) {
      int rides = await userPlanProvider.getTotalActiveRides(user.session_token!);
      totalRides.value = rides;
    }
  }

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

  Future<void> fetchOccupiedEquiposInicial() async {
    final reservations =
    await _provider.getReservationsForSlot(
      classDate: classDate,
      classTime: classTime,
    );

    occupiedEquipos.clear();
    blockedEquipos.clear();

    for (final reservation in reservations) {
      /*
     * bicycle es nullable en el modelo.
     * Primero comprobamos que exista y luego Dart
     * reconoce la variable local como int.
     */
      final bicycle = reservation.bicycle;

      if (bicycle == null) {
        continue;
      }

      if (reservation.status == 'blocked') {
        blockedEquipos.add(bicycle);
      } else if (
      reservation.status == 'scheduled') {
        occupiedEquipos.add(bicycle);
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
              style: const TextStyle(fontSize: 14.5, color: Colors.black87, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}