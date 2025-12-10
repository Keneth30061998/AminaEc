// File: coach_schedule_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:get_storage/get_storage.dart';

import '../../../models/coach.dart';
import '../../../models/schedule.dart';
import '../../../models/user.dart';
import '../../../providers/coachs_provider.dart';
import '../../../utils/color.dart';

class CoachScheduleController extends GetxController {
  final CoachProvider coachProvider = CoachProvider();
  final User userSession = User.fromJson(GetStorage().read('user') ?? {});

  Rx<Coach?> coach = Rx<Coach?>(null);

  Rx<DateTime> selectedDate = DateTime.now().obs;
  RxInt calendarRefreshTrigger = 0.obs;
  Rx<CoachScheduleDataSource> calendarDataSource = CoachScheduleDataSource([]).obs;

  // schedules donde el coach participa
  final RxList<Schedule> _ownSchedules = <Schedule>[].obs;

  // mapa scheduleId -> lista de coachIds asignados (resuelto desde provider)
  final Map<String, List<String>> _scheduleCoachIds = {};

  // palette / colors
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
    loadCoachSchedules();
  }

  Future<void> loadCoachSchedules() async {
    try {
      final coaches = await coachProvider.getAll();

      // encontrar coach actual (objeto)
      coach.value = coaches.firstWhereOrNull((c) => (c.id ?? '') == (userSession.id ?? ''));

      // limpiar estructuras
      _ownSchedules.clear();
      _scheduleCoachIds.clear();

      final seenScheduleIds = <String>{};

      // Recorremos todos los coaches y sus schedules para:
      //  - resolver la lista de coachIds por schedule (map)
      //  - recoger schedules donde participa el userSession.id
      for (final c in coaches) {
        final cIdStr = (c.id ?? '').toString();

        for (final s in c.schedules) {
          final scheduleId = (s.id ?? '').toString();
          if (scheduleId.isEmpty) continue;

          // 1) agregar c.id a la lista de coachIds para este schedule
          final existing = _scheduleCoachIds[scheduleId] ?? <String>[];
          if (!existing.contains(cIdStr)) {
            existing.add(cIdStr);
            _scheduleCoachIds[scheduleId] = existing;
          }

          // 2) decidir si el schedule pertenece al coach actual (sin usar id_coach)
          if (!seenScheduleIds.contains(scheduleId)) {
            bool assigned = false;

            // Si schedule tiene campo 'coaches' (lista) y contiene userSession.id
            try {
              if (s.coaches is List && (s.coaches as List).isNotEmpty) {
                final List<String> coachIdsInSchedule =
                (s.coaches as List).map((e) => e.toString()).toList();
                if (coachIdsInSchedule.contains((userSession.id ?? '').toString())) {
                  assigned = true;
                }
              }
            } catch (_) {
              // ignore parsing errors
            }

            // Si no está por coaches[], usar la heurística: si el schedule aparece dentro
            // del array del coach 'c' y c.id == userSession.id -> entonces pertenece al coach.
            if (!assigned) {
              if (cIdStr == (userSession.id ?? '').toString()) {
                assigned = true;
              }
            }

            if (assigned) {
              _ownSchedules.add(s);
              seenScheduleIds.add(scheduleId);
            }
          }
        }
      }

      // construir calendario con la info resuelta
      _buildCalendarEventsFromSchedules(coaches);
    } catch (e, st) {
      print('❌ Error loadCoachSchedules: $e\n$st');
    }
  }

  void _buildCalendarEventsFromSchedules(List<Coach> allCoaches) {
    final List<Appointment> appointments = [];
    final seen = <String>{};

    for (final s in _ownSchedules) {
      final scheduleId = (s.id ?? '').toString();
      if (scheduleId.isEmpty) continue;
      if (seen.contains(scheduleId)) continue;
      seen.add(scheduleId);

      if (s.date == null || s.start_time == null || s.end_time == null) continue;

      DateTime start;
      DateTime end;
      try {
        start = DateTime.parse('${s.date} ${s.start_time}');
        end = DateTime.parse('${s.date} ${s.end_time}');
      } catch (e) {
        continue; // skip invalid
      }

      // resolver coachIds del mapa; si no existe, intentar desde s.coaches
      List<String> coachIds = _scheduleCoachIds[scheduleId] ?? [];

      if (coachIds.isEmpty) {
        try {
          if (s.coaches is List && (s.coaches as List).isNotEmpty) {
            coachIds = (s.coaches as List).map((e) => e.toString()).toList();
          }
        } catch (_) {}
      }

      // si sigue vacío, fallback a userSession (mínimo)
      if (coachIds.isEmpty) {
        coachIds = [(userSession.id ?? '').toString()];
      }

      // resolver nombres usando allCoaches
      final names = coachIds.map((cid) {
        final c = allCoaches.firstWhereOrNull((x) => (x.id ?? '').toString() == cid);
        return c?.user?.name ?? '';
      }).where((n) => n.isNotEmpty).toList();

      String subject;
      final theme = (s.class_theme?.trim().isNotEmpty == true) ? s.class_theme! : 'Clase';
      if (names.isEmpty) {
        subject = theme;
      } else if (names.length == 1) {
        subject = '${names.first} - $theme';
      } else {
        subject = '${names.join(' & ')} - $theme';
      }

      final colorKey = coachIds.first;
      final color = _assignColor(colorKey);

      appointments.add(Appointment(
        startTime: start,
        endTime: end,
        subject: subject,
        color: color,
        isAllDay: false,
      ));
    }

    calendarDataSource.value = CoachScheduleDataSource(appointments);
    calendarRefreshTrigger.value++;
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
  }

  List<Schedule> get schedulesForSelectedDay {
    final sel = selectedDate.value;
    final userIdStr = (userSession.id ?? '').toString();

    final result = _ownSchedules.where((s) {
      if (s.date == null) return false;
      final d = DateTime.tryParse(s.date ?? '');
      if (d == null) return false;
      if (d.year != sel.year || d.month != sel.month || d.day != sel.day) return false;

      // confirmar asignación vía mapa o via s.coaches
      final scheduleId = (s.id ?? '').toString();
      bool assigned = false;

      final coachIds = _scheduleCoachIds[scheduleId] ?? [];
      if (coachIds.contains(userIdStr)) assigned = true;

      if (!assigned) {
        try {
          if (s.coaches is List && (s.coaches as List).isNotEmpty) {
            final coachIdsInSchedule = (s.coaches as List).map((e) => e.toString()).toList();
            if (coachIdsInSchedule.contains(userIdStr)) assigned = true;
          }
        } catch (_) {}
      }

      // fallback: if no info, assume it's assigned because it was included earlier
      return assigned || (coachIds.isEmpty && (s.id ?? '').toString().isNotEmpty);
    }).toList();

    result.sort((a, b) {
      final aDt = DateTime.parse('${a.date} ${a.start_time}');
      final bDt = DateTime.parse('${b.date} ${b.start_time}');
      return aDt.compareTo(bDt);
    });

    return result;
  }
}

class CoachScheduleDataSource extends CalendarDataSource {
  CoachScheduleDataSource(List<Appointment> source) {
    appointments = source;
  }
}
