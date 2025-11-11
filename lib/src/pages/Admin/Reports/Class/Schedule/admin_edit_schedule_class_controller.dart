import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../../../components/Socket/socket_service.dart';
import '../../../../../components/events/coach_events.dart';
import '../../../../../models/coach.dart';
import '../../../../../models/schedule.dart';
import '../../../../../providers/coachs_provider.dart';



class AdminCoachScheduleController extends GetxController {
  final CoachProvider _provider = CoachProvider();

  var selectedDate = DateTime.now().obs;
  var allCoaches = <Coach>[].obs;
  var filteredCoaches = <Coach>[].obs;

  final calendarDataSource = Rx<ScheduleDataSource>(ScheduleDataSource([]));
  final calendarRefreshTrigger = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadCoaches();

    ever(CoachEvents.to.coachUpdated, (_) => loadCoaches());
    SocketService().on('coach:new', (_) => CoachEvents.to.notifyCoachesUpdated());
    SocketService().on('coach:update', (_) {
      CoachEvents.to.notifyCoachesUpdated();
      _updateCalendar();
    });
    SocketService().on('coach:delete', (_) => CoachEvents.to.notifyCoachesUpdated());
  }

  Future<void> loadCoaches() async {
    try {
      final list = await _provider.getAll();
      allCoaches.value = list;
      _filterByDate(selectedDate.value);
      _updateCalendar();
    } catch (_) {}
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    _filterByDate(date);
  }

  void _filterByDate(DateTime date) {
    filteredCoaches.value = allCoaches.where((coach) {
      return coach.schedules.any((s) {
        final d = DateTime.tryParse(s.date ?? '');
        return d != null && d.year == date.year && d.month == date.month && d.day == date.day;
      });
    }).toList();
  }

  void _updateCalendar() {
    final appointments = <Appointment>[];

    for (final coach in allCoaches) {
      final color = Colors.indigo; // Mantiene color amina
      for (final s in coach.schedules) {
        final date = DateTime.tryParse(s.date ?? '');
        if (date == null) continue;

        final start = _parse(date, s.start_time);
        final end = _parse(date, s.end_time);

        final theme = s.class_theme?.trim().isNotEmpty == true ? s.class_theme! : 'Clase';

        appointments.add(Appointment(
          startTime: start,
          endTime: end,
          subject: "${coach.user?.name ?? 'Coach'} - $theme",
          color: color,
        ));
      }
    }

    calendarDataSource.value = ScheduleDataSource.fromAppointments(appointments);
    calendarRefreshTrigger.value++;
    calendarDataSource.refresh();
  }

  DateTime _parse(DateTime base, String? t) {
    final parts = (t ?? '00:00').split(':');
    return DateTime(base.year, base.month, base.day,
        int.parse(parts[0]), int.parse(parts[1]));
  }
}

class ScheduleDataSource extends CalendarDataSource {
  ScheduleDataSource(List<Schedule> source) {
    appointments = source.map((_) => null).toList();
  }

  ScheduleDataSource.fromAppointments(List<Appointment> list) {
    appointments = list;
  }
}
