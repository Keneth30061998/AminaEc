import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../../components/Socket/socket_service.dart';
import '../../../../models/coach.dart';
import '../../../../models/schedule.dart';
import '../../../../providers/coachs_provider.dart';

class UserCoachScheduleController extends GetxController {
  final CoachProvider _provider = CoachProvider();

  var baseDate = DateTime.now().obs;
  var selectedDate = DateTime.now().obs;
  var allCoaches = <Coach>[].obs;
  var filteredCoaches = <Coach>[].obs;

  final calendarDataSource = Rx<ScheduleDataSource>(ScheduleDataSource([]));

  Timer? _midnightTimer;

  @override
  void onInit() {
    super.onInit();
    loadCoaches();
    _scheduleMidnightTimer();

    SocketService().on('coach:new', (_) => loadCoaches());
    SocketService().on('coach:delete', (_) => loadCoaches());
    SocketService().on('coach:update', (_) => loadCoaches());
  }

  void goToUserCoachReservePage() {
    Get.toNamed('/user/coach/reserve');
  }

  void loadCoaches() async {
    final list = await _provider.getAll();
    allCoaches.value = list;
    _filterCoachesByDate(selectedDate.value);
    _actualizarCalendario();
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    _filterCoachesByDate(date);
  }

  void _filterCoachesByDate(DateTime date) {
    final filtered = allCoaches.where((coach) {
      return coach.schedules?.any((s) {
            final sDate = DateTime.tryParse(s.date ?? '');
            return sDate != null &&
                sDate.year == date.year &&
                sDate.month == date.month &&
                sDate.day == date.day;
          }) ??
          false;
    }).toList();
    filteredCoaches.value = filtered;
  }

  void _actualizarCalendario() {
    final allSchedules = allCoaches
        .expand((c) => c.schedules ?? [])
        .whereType<Schedule>()
        .toList();
    calendarDataSource.value = ScheduleDataSource(allSchedules);
  }

  void _scheduleMidnightTimer() {
    final now = DateTime.now();
    final nextMidnight =
        DateTime(now.year, now.month, now.day).add(Duration(days: 1));
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
    appointments = source
        .map((s) {
          final date = DateTime.tryParse(s.date ?? '');
          if (date == null) return null;

          final start = _parseTime(date, s.start_time);
          final end = _parseTime(date, s.end_time);

          return Appointment(
            startTime: start,
            endTime: end,
            subject: 'Disponible',
            color: const Color(0xFF4CAF50), // verde elegante
            isAllDay: false,
          );
        })
        .whereType<Appointment>()
        .toList();
  }

  DateTime _parseTime(DateTime base, String? time) {
    final parts = (time ?? '00:00').split(':');
    return DateTime(base.year, base.month, base.day, int.parse(parts[0]),
        int.parse(parts[1]));
  }
}
