// File: user_coach_schedule_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../../components/Socket/socket_service.dart';
import '../../../../components/events/coach_events.dart';
import '../../../../models/coach.dart';
import '../../../../models/schedule.dart';
import '../../../../providers/class_reservation_provider.dart';
import '../../../../providers/coachs_provider.dart';

class UserCoachScheduleController extends GetxController {
  final CoachProvider _provider = CoachProvider();
  final calendarRefreshTrigger = 0.obs;

  var baseDate = DateTime.now().obs;
  var selectedDate = DateTime.now().obs;
  var allCoaches = <Coach>[].obs;
  var filteredCoaches = <Coach>[].obs;

  final calendarDataSource = Rx<ScheduleDataSource>(ScheduleDataSource([]));

  Timer? _midnightTimer;

  // ✅ Contador de bicicletas ocupadas reactivo
  final occupiedBikeMap = <String, int>{}.obs;

  // Mapa de colores persistentes
  final Map<String, Color> _coachColors = {};
  final List<Color> _palette = [
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.cyan,
    Colors.teal,
    Colors.red,
    Colors.indigo,
  ];

  Color _assignColor(String coachId) {
    if (_coachColors.containsKey(coachId)) return _coachColors[coachId]!;
    final color = _palette[_coachColors.length % _palette.length];
    _coachColors[coachId] = color;
    return color;
  }

  @override
  void onInit() {
    super.onInit();
    loadCoaches();
    _scheduleMidnightTimer();

    ever(CoachEvents.to.coachUpdated, (_) => loadCoaches());

    SocketService().on('coach:new', (_) => CoachEvents.to.notifyCoachesUpdated());
    SocketService().on('coach:update', (_) {
      CoachEvents.to.notifyCoachesUpdated();
      _updateCalendar();
    });
    SocketService().on('coach:delete', (_) => CoachEvents.to.notifyCoachesUpdated());

    // ✅ Socket en tiempo real para actualizar contador de bicicletas
    SocketService().on('reservation:update', (data) {
      if (data is Map) {
        fetchOccupiedCount(
          coachId: data['coach_id'],
          date: data['class_date'],
          time: data['class_time'],
        );
      }
    });
  }

  Future<void> loadCoaches() async {
    try {
      final list = await _provider.getAll();
      allCoaches.value = list;
      _filterCoachesByDate(selectedDate.value);
      _updateCalendar();
    } catch (_) {}
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    _filterCoachesByDate(date);
  }

  void _filterCoachesByDate(DateTime date) {
    filteredCoaches.value = allCoaches.where((coach) {
      return coach.schedules.any((s) {
        final sDate = DateTime.tryParse(s.date ?? '');
        return sDate != null &&
            sDate.year == date.year &&
            sDate.month == date.month &&
            sDate.day == date.day;
      });
    }).toList();
  }

  void _updateCalendar() {
    final appointments = <Appointment>[];

    for (final coach in allCoaches) {
      final coachColor = _assignColor(coach.id ?? '');

      for (final s in coach.schedules) {
        final date = DateTime.tryParse(s.date ?? '');
        if (date == null) continue;

        final start = _parseTime(date, s.start_time);
        final end = _parseTime(date, s.end_time);
        final theme = (s.class_theme?.trim().isNotEmpty == true) ? s.class_theme! : 'Clase';

        appointments.add(
          Appointment(
            startTime: start,
            endTime: end,
            subject: "${coach.user?.name ?? 'Coach'} - $theme",
            color: coachColor,
            isAllDay: false,
          ),
        );
      }
    }

    calendarDataSource.value = ScheduleDataSource.fromAppointments(appointments);

    calendarRefreshTrigger.value++;
    calendarDataSource.refresh();
  }

  DateTime _parseTime(DateTime base, String? time) {
    final parts = (time ?? '00:00').split(':');
    final hh = int.tryParse(parts[0]) ?? 0;
    final mm = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    return DateTime(base.year, base.month, base.day, hh, mm);
  }

  void goToUserCoachReservePage({
    required String coachId,
    required String classTime,
    required String coachName,
    String? classTheme,
  }) {
    final classDate = selectedDate.value.toString().split(' ')[0];
    Get.toNamed('/user/coach/reserve', arguments: {
      'coach_id': coachId,
      'class_date': classDate,
      'class_time': classTime,
      'coach_name': coachName,
      'class_theme': classTheme ?? 'Clase',
    });
  }

  void _scheduleMidnightTimer() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final difference = nextMidnight.difference(now);

    _midnightTimer = Timer(difference, () {
      final oldBase = baseDate.value;
      baseDate.value = DateTime.now();

      if (_isSameDate(selectedDate.value, oldBase)) {
        selectedDate.value = baseDate.value;
        _filterCoachesByDate(selectedDate.value);
      }

      loadCoaches();
      _scheduleMidnightTimer();
    });
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  void onClose() {
    _midnightTimer?.cancel();
    super.onClose();
  }

  // ✅ NUEVO: obtiene y guarda bicicletas ocupadas en el mapa reactivo
  Future<void> fetchOccupiedCount({
    required String coachId,
    required String date,
    required String time,
  }) async {
    final key = '$coachId-$date-$time';
    final reservations = await ClassReservationProvider().getReservationsForSlot(
      classDate: date,
      classTime: time,
    );
    occupiedBikeMap[key] = reservations.length;
  }
}

class ScheduleDataSource extends CalendarDataSource {
  ScheduleDataSource(List<Schedule> source) {
    appointments = source.map((s) => null).toList();
  }

  ScheduleDataSource.fromAppointments(List<Appointment> appointmentsList) {
    appointments = appointmentsList;
  }
}
