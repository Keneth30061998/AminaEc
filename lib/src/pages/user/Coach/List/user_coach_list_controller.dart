import 'dart:async';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../components/Socket/socket_service.dart';
import '../../../../models/coach.dart';
import '../../../../providers/coachs_provider.dart';

class UserCoachScheduleController extends GetxController {
  final CoachProvider _provider = CoachProvider();

  // Base para generar la lista visible de fechas (siempre la fecha real de hoy).
  var baseDate = DateTime.now().obs;
  // Fecha marcada por el usuario (inicialmente, también es hoy).
  var selectedDate = DateTime.now().obs;
  var allCoaches = <Coach>[].obs;
  var filteredCoaches = <Coach>[].obs;

  final int daysToShow = 7;
  Timer? _midnightTimer;

  @override
  void onInit() {
    super.onInit();
    loadCoaches();
    _scheduleMidnightTimer();

    // Escuchamos eventos en tiempo real
    SocketService().on('coach:new', (_) {
      loadCoaches();
    });
    SocketService().on('coach:delete', (_) {
      loadCoaches();
    });
    SocketService().on('coach:update', (_) {
      loadCoaches();
    });
  }

  //moverse entre pantallas
  void goToUserCoachReservePage() {
    Get.toNamed('/user/coach/reserve');
  }

  void loadCoaches() async {
    final list = await _provider.getAll();
    allCoaches.value = list;
    _filterCoachesByDay(selectedDate.value);
  }

  // El usuario selecciona manualmente una fecha sin afectar la base.
  void selectDate(DateTime date) {
    selectedDate.value = date;
    _filterCoachesByDay(date);
  }

  void _filterCoachesByDay(DateTime date) {
    final String dayName = DateFormat('EEEE', 'es_ES').format(date);
    final filtered = allCoaches.where((coach) {
      return coach.schedules?.any(
            (s) => s.day?.toLowerCase().trim() == dayName.toLowerCase(),
          ) ??
          false;
    }).toList();

    filteredCoaches.value = filtered;
  }

  // Genera la lista de fechas utilizando la base (día real).
  List<DateTime> generateDateRange() {
    final bd = baseDate.value;
    return List.generate(daysToShow,
        (i) => DateTime(bd.year, bd.month, bd.day).add(Duration(days: i)));
  }

  // Programa un Timer para detectar cuando llegue la medianoche y actualizar la base.
  void _scheduleMidnightTimer() {
    final now = DateTime.now();
    final nextMidnight =
        DateTime(now.year, now.month, now.day).add(Duration(days: 1));
    final difference = nextMidnight.difference(now);
    _midnightTimer = Timer(difference, () {
      // Guarda la base anterior.
      final oldBase = baseDate.value;
      // Actualiza la base a la nueva fecha real.
      baseDate.value = DateTime.now();
      // Si el usuario no había cambiado manualmente (la selección seguía en el antiguo día),
      // también actualizamos el selectedDate.
      if (_isSameDate(selectedDate.value, oldBase)) {
        selectedDate.value = baseDate.value;
        _filterCoachesByDay(selectedDate.value);
      }
      loadCoaches();
      _scheduleMidnightTimer();
    });
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  void onClose() {
    _midnightTimer?.cancel();
    super.onClose();
  }
}
