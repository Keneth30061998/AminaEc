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

  final selectedDate = DateTime.now().obs;
  final allCoaches = <Coach>[].obs;
  final filteredCoaches = <Coach>[].obs;

  // DataSource reactivo para el calendario
  final calendarDataSource = Rx<ScheduleDataSource>(ScheduleDataSource([]));

  // Trigger para forzar rebuild si hace falta (mantengo tu lógica)
  final calendarRefreshTrigger = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadCoaches();

    ever(CoachEvents.to.coachUpdated, (_) => loadCoaches());

    SocketService()
        .on('coach:new', (_) => CoachEvents.to.notifyCoachesUpdated());
    SocketService().on('coach:update', (_) {
      CoachEvents.to.notifyCoachesUpdated();
      _updateCalendar();
    });
    SocketService()
        .on('coach:delete', (_) => CoachEvents.to.notifyCoachesUpdated());
  }

  Future<void> loadCoaches() async {
    try {
      final list = await _provider.getAll();
      allCoaches.value = list;
      _filterByDate(selectedDate.value);
      _updateCalendar();
    } catch (_) {
      // Mantengo tu comportamiento silencioso (sin romper funcionalidad).
      // Si quieres, aquí puedes loguear el error.
    }
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    _filterByDate(date);
  }

  void _filterByDate(DateTime date) {
    filteredCoaches.value = allCoaches.where((coach) {
      return coach.schedules.any((s) {
        final d = DateTime.tryParse(s.date ?? '');
        return d != null &&
            d.year == date.year &&
            d.month == date.month &&
            d.day == date.day;
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

        final theme = (s.class_theme?.trim().isNotEmpty == true)
            ? s.class_theme!.trim()
            : 'Clase';

        appointments.add(
          Appointment(
            startTime: start,
            endTime: end,
            subject: "${coach.user?.name ?? 'Coach'} - $theme",
            color: color,
          ),
        );
      }
    }

    calendarDataSource.value =
        ScheduleDataSource.fromAppointments(appointments);
    calendarRefreshTrigger.value++;
    // Notifica a Obx/GetX que calendarDataSource cambió (mantengo tu intención)
    calendarDataSource.refresh();
  }

  DateTime _parse(DateTime base, String? t) {
    final raw = (t ?? '00:00').trim();
    final parts = raw.split(':');

    final h = (parts.isNotEmpty ? int.tryParse(parts[0]) : 0) ?? 0;
    final m = (parts.length > 1 ? int.tryParse(parts[1]) : 0) ?? 0;

    return DateTime(base.year, base.month, base.day, h, m);
  }
}

class ScheduleDataSource extends CalendarDataSource {
  /// Mantengo compatibilidad:
  /// - Si le pasas []: queda vacío.
  /// - Si le pasas List<Appointment>: lo usa.
  /// - Si le pasas List<Schedule>: intenta convertirlos (subject = theme o "Clase").
  ScheduleDataSource(List source) {
    if (source.isEmpty) {
      appointments = <Appointment>[];
      return;
    }

    final first = source.first;

    if (first is Appointment) {
      appointments = source.cast<Appointment>();
      return;
    }

    if (first is Schedule) {
      appointments = _appointmentsFromSchedules(source.cast<Schedule>());
      return;
    }

    appointments = <Appointment>[];
  }

  ScheduleDataSource.fromAppointments(List<Appointment> list) {
    appointments = list;
  }

  List<Appointment> _appointmentsFromSchedules(List<Schedule> schedules) {
    final list = <Appointment>[];
    for (final s in schedules) {
      final date = DateTime.tryParse(s.date ?? '');
      if (date == null) continue;

      final start = _parse(date, s.start_time);
      final end = _parse(date, s.end_time);
      final theme = (s.class_theme?.trim().isNotEmpty == true)
          ? s.class_theme!.trim()
          : 'Clase';

      list.add(
        Appointment(
          startTime: start,
          endTime: end,
          subject: theme,
          color: Colors.indigo,
        ),
      );
    }
    return list;
  }

  DateTime _parse(DateTime base, String? t) {
    final raw = (t ?? '00:00').trim();
    final parts = raw.split(':');

    final h = (parts.isNotEmpty ? int.tryParse(parts[0]) : 0) ?? 0;
    final m = (parts.length > 1 ? int.tryParse(parts[1]) : 0) ?? 0;

    return DateTime(base.year, base.month, base.day, h, m);
  }
}
