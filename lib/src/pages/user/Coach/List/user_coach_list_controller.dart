import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../../components/Socket/socket_service.dart';
import '../../../../components/events/coach_events.dart';
import '../../../../models/coach.dart';
import '../../../../models/schedule.dart';
import '../../../../providers/coachs_provider.dart';

class UserCoachScheduleController extends GetxController {
  final CoachProvider _provider = CoachProvider();
  final calendarRefreshTrigger = 0.obs;


  var baseDate = DateTime.now().obs;
  var selectedDate = DateTime.now().obs;
  var allCoaches = <Coach>[].obs;
  var filteredCoaches = <Coach>[].obs;

  //var calendarDataSource = ScheduleDataSource([]).obs;
  final calendarDataSource = Rx<ScheduleDataSource>(ScheduleDataSource([]));

  Timer? _midnightTimer;

  @override
  void onInit() {
    super.onInit();
    loadCoaches();
    _scheduleMidnightTimer();

    // Suscribirse a eventos globales de coaches
    ever(CoachEvents.to.coachUpdated, (_) => loadCoaches());

    // Suscripción a eventos socket
    SocketService().on('coach:new', (_) => CoachEvents.to.notifyCoachesUpdated());
    SocketService().on('coach:update', (_) {
      //print('📡 Evento coach:update recibido');
      CoachEvents.to.notifyCoachesUpdated();
      _updateCalendar();
    });
    SocketService().on('coach:delete', (_) => CoachEvents.to.notifyCoachesUpdated());
  }

  Future<void> loadCoaches() async {
    //print('🔄 Ejecutando loadCoaches() tras evento');
    try {
      final list = await _provider.getAll();
      allCoaches.value = list;
      _filterCoachesByDate(selectedDate.value);
      _updateCalendar();
      selectedDate.refresh();
      calendarDataSource.refresh();
      filteredCoaches.refresh();
    } catch (e) {
      //print('Error cargando coaches: $e');
    }
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    _filterCoachesByDate(date);
  }

  void _filterCoachesByDate(DateTime date) {
    final filtered = allCoaches.where((coach) {
      return coach.schedules.any((s) {
        final sDate = DateTime.tryParse(s.date ?? '');
        return sDate != null &&
            sDate.year == date.year &&
            sDate.month == date.month &&
            sDate.day == date.day;
      });
    }).toList();
    filteredCoaches.value = filtered;
  }

  void _updateCalendar() {
    final allSchedules = allCoaches.expand((c) => c.schedules).whereType<Schedule>().toList();
    // ✅ Nueva instancia, no solo actualizar value
    final newDataSource = ScheduleDataSource(allSchedules);
    calendarDataSource.value = newDataSource;
    calendarRefreshTrigger.value++; // 🔁 fuerza reconstrucción visual
    //print('📅 Actualizando calendario con ${allSchedules.length} horarios');
    //print('🔁 Trigger visual: ${calendarRefreshTrigger.value}');
    //print('📊 Horarios reconstruidos: ${allSchedules.length}');
  }

  void goToUserCoachReservePage({
    required String coachId,
    required String classTime,
    required String coachName,
  }) {
    final classDate = selectedDate.value.toString().split(' ')[0];
    Get.toNamed('/user/coach/reserve', arguments: {
      'coach_id': coachId,
      'class_date': classDate,
      'class_time': classTime,
      'coach_name': coachName,
    });
  }

  void _scheduleMidnightTimer() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day).add(Duration(days: 1));
    final difference = nextMidnight.difference(now);

    _midnightTimer = Timer(difference, () {
      final oldBase = baseDate.value;
      baseDate.value = DateTime.now();

      if (_isSameDate(selectedDate.value, oldBase)) {
        selectedDate.value = baseDate.value;
        _filterCoachesByDate(selectedDate.value);
      }

      loadCoaches();
      _scheduleMidnightTimer(); // reprograma timer
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

class ScheduleDataSource extends CalendarDataSource {
  ScheduleDataSource(List<Schedule> source) {
    appointments = source.map((s) {
      final date = DateTime.tryParse(s.date ?? '');
      if (date == null) return null;

      final start = _parseTime(date, s.start_time);
      final end = _parseTime(date, s.end_time);

      return Appointment(
        startTime: start,
        endTime: end,
        subject: 'Disponible',
        color: const Color(0xFF4CAF50),
        isAllDay: false,
      );
    }).whereType<Appointment>().toList();
  }

  DateTime _parseTime(DateTime base, String? time) {
    final parts = (time ?? '00:00').split(':');
    return DateTime(base.year, base.month, base.day, int.parse(parts[0]), int.parse(parts[1]));
  }
}
