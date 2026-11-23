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

class UserCoachScheduleController extends GetxController with WidgetsBindingObserver {
  final CoachProvider _provider = CoachProvider();
  final calendarRefreshTrigger = 0.obs;

  var baseDate = DateTime.now().obs;
  var selectedDate = DateTime.now().obs;
  var allCoaches = <Coach>[].obs;
  var filteredCoaches = <Coach>[].obs;

  final calendarDataSource = Rx<ScheduleDataSource>(ScheduleDataSource([]));

  Timer? _midnightTimer;

  // Contador reactivo de bicicletas ocupadas
  final occupiedBikeMap = <String, int?>{}.obs;
  final List<void Function()> _subscriptions=[];
  final Set<String> _pendingCounts={};
  Worker? _coachWorker;
  void _listen(String event,Function(dynamic) callback){_subscriptions.add(SocketService().subscribe(event,callback));}
  String _hour(String time)=>time.split('.').first.length==5?'${time.split('.').first}:00':time.split('.').first;
  void _refreshCounts([dynamic payload]) {
    final selectedDay = selectedDate.value.toIso8601String().split('T').first;
    for (final coach in filteredCoaches) {
      for (final schedule in coach.schedules) {
        final day = (schedule.date ?? '').split('T').first;
        final time = schedule.start_time ?? '';
        if (day != selectedDay) continue;
        if (payload is Map &&
            (day != '${payload['class_date']}'.split('T').first ||
                _hour(time) != _hour('${payload['class_time']}'))) continue;
        fetchOccupiedCount(
          coachId: coach.id ?? '', date: schedule.date ?? '', time: time,
        );
      }
    }
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state){if(state==AppLifecycleState.resumed)_refreshCounts();}


  // Colores persistentes por coach
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
    WidgetsBinding.instance.addObserver(this);
    loadCoaches();
    _scheduleMidnightTimer();

    _coachWorker=ever(CoachEvents.to.coachUpdated, (_) => loadCoaches());

    _listen('coach:new', (_) => CoachEvents.to.notifyCoachesUpdated());
    _listen('coach:update', (_) {
      CoachEvents.to.notifyCoachesUpdated();
      _updateCalendar();
    });
    _listen('coach:delete', (_) => CoachEvents.to.notifyCoachesUpdated());

    for(final event in ['machine:status:update','waitlist:slot:changed'])_listen(event,_refreshCounts);
    _listen('connect',(_)=>_refreshCounts());
  }

  Future<void> loadCoaches() async {
    try {
      final list = await _provider.getAll();
      allCoaches.value = list;

      _filterCoachesByDate(selectedDate.value);
      _updateCalendar();
      _refreshCounts();
    } catch (e, st) {
      print('❌ Error loadCoaches: $e\n$st');
    }
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    _filterCoachesByDate(date);
    _refreshCounts();
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

  Coach? _findCoachById(String id) {
    try {
      return allCoaches.firstWhere((c) => (c.id ?? '').toString() == id);
    } catch (_) {
      return null;
    }
  }

  // 🔥 Construcción de calendario con soporte para clases de 1 o 2 coaches
  void _updateCalendar() {
    final appointments = <Appointment>[];
    final seenSchedules = <String>{};

    for (final coach in allCoaches) {
      final coachColor = _assignColor(coach.id ?? '');

      for (final s in coach.schedules) {
        final scheduleId = (s.id ?? '').toString();
        if (scheduleId.isNotEmpty && seenSchedules.contains(scheduleId)) continue;
        seenSchedules.add(scheduleId);

        final date = DateTime.tryParse(s.date ?? '');
        if (date == null) continue;

        final start = _parseTime(date, s.start_time);
        final end = _parseTime(date, s.end_time);
        final theme = (s.class_theme?.trim().isNotEmpty == true) ? s.class_theme! : 'Clase';

        // EXTRAER COACHES: (corrección clave) -------------------------------
        final List<dynamic> coachIds =
        List<dynamic>.from(s.coaches ?? []); // <-- 💙 FIX DEFINITIVO

        String subject;
        if (coachIds.isEmpty) {
          subject = "${coach.user?.name ?? 'Coach'} - $theme";
        } else {
          // buscar nombres
          final names = coachIds.map((cid) {
            final c = _findCoachById(cid.toString());
            return c?.user?.name ?? '';
          }).where((n) => n.isNotEmpty).toList();

          if (names.isEmpty) {
            subject = "${coach.user?.name ?? 'Coach'} - $theme";
          } else if (names.length == 1) {
            subject = "${names.first} - $theme";
          } else {
            subject = "${names.join(' & ')} - $theme";
          }
        }
        //------------------------------------------------------------------

        appointments.add(
          Appointment(
            startTime: start,
            endTime: end,
            subject: subject,
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
    String? scheduleId,
  }) {
    final classDate = selectedDate.value.toString().split(' ')[0];
    Get.toNamed('/user/coach/reserve', arguments: {
      'coach_id': coachId,
      'class_date': classDate,
      'class_time': classTime,
      'coach_name': coachName,
      'class_theme': classTheme ?? 'Clase',
      'schedule_id':scheduleId,
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
    _midnightTimer?.cancel();_coachWorker?.dispose();WidgetsBinding.instance.removeObserver(this);
    for(final cancel in _subscriptions){cancel();}
    super.onClose();
  }

  // contador de bicicletas ocupadas
  Future<void> fetchOccupiedCount({
    required String coachId,
    required String date,
    required String time,
  }) async {
    final key = '$coachId-$date-$time';
    if(!_pendingCounts.add(key))return;
    try {
      final reservations=await ClassReservationProvider().getReservationsForSlot(classDate:date,classTime:time);
      if(!isClosed)occupiedBikeMap[key]=reservations.length;
    }catch(_){if(!isClosed)occupiedBikeMap[key]=null;}
    finally{_pendingCounts.remove(key);}

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
