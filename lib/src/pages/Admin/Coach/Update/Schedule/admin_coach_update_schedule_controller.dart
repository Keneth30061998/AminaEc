import 'package:amina_ec/src/models/coach.dart';
import 'package:amina_ec/src/models/schedule.dart';
import 'package:amina_ec/src/providers/coachs_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../../../components/Socket/socket_service.dart';

class AdminCoachUpdateScheduleController extends GetxController {
  final CoachProvider _coachProvider = CoachProvider();

  late Coach coach;
  final selectedSchedules = <Schedule>[].obs;
  final calendarDataSource = Rx<ScheduleDataSource>(ScheduleDataSource([]));

  @override
  void onInit() {
    super.onInit();
    coach = Get.arguments as Coach;
    _loadSchedules();
    ever<List<Schedule>>(selectedSchedules, (_) => _actualizarCalendario());
  }

  void _loadSchedules() {
    final current = coach.schedules;
    if (current.isNotEmpty) {
      selectedSchedules.assignAll(current);
      _actualizarCalendario();
    }
  }

  Future<void> selectDateAndPromptTime(DateTime? date) async {
    if (date == null) return;

    final now = DateTime.now();
    if (date.isBefore(DateTime(now.year, now.month, now.day))) {
      Get.snackbar(
        'Fecha inválida',
        'No puedes registrar horarios en el pasado',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    // Mostrar selector de hora de inicio
    final start = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay.now(),
    );
    if (start == null) return;

    // Mostrar selector de hora de fin
    final end = await showTimePicker(
      context: Get.context!,
      initialTime: start,
    );
    if (end == null) return;

    // Validar rango de horas
    if (_compare(start, end) >= 0) {
      Get.snackbar(
        'Rango inválido',
        'La hora de fin debe ser mayor que la de inicio',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    final schedule = Schedule(
      date: DateFormat('yyyy-MM-dd').format(date),
      start_time: _format(start),
      end_time: _format(end),
    );

    // Evitar duplicados
    if (selectedSchedules.any((s) =>
        s.date == schedule.date &&
        s.start_time == schedule.start_time &&
        s.end_time == schedule.end_time)) {
      Get.snackbar(
        'Duplicado',
        'Ese horario ya fue agregado',
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      return;
    }

    selectedSchedules.add(schedule);
  }

  void removeSchedule(int index) {
    selectedSchedules.removeAt(index);
  }

  String _format(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';

  int _compare(TimeOfDay a, TimeOfDay b) =>
      (a.hour * 60 + a.minute) - (b.hour * 60 + b.minute);

  Future<void> updateSchedule(BuildContext context) async {
    if (selectedSchedules.isEmpty) {
      Get.snackbar('Vacío', 'Debes agregar al menos un horario');
      return;
    }

    final res =
        await _coachProvider.updateSchedule(coach.id!, selectedSchedules);
    if (res.statusCode == 201) {
      SocketService()
          .emit('coach:update', {'id': coach.id, 'type': 'schedule'});
      Get.back();
      Get.snackbar('Éxito', 'Horarios actualizados correctamente');
    } else {
      Get.snackbar('Error', 'No se pudo actualizar los horarios');
    }
  }

  void _actualizarCalendario() {
    calendarDataSource.value = ScheduleDataSource(selectedSchedules);
  }
}

class ScheduleDataSource extends CalendarDataSource {
  ScheduleDataSource(List<Schedule> source) {
    appointments = source.map((s) {
      final date = DateTime.parse(s.date!);
      final start = _parseTime(date, s.start_time!);
      final end = _parseTime(date, s.end_time!);

      return Appointment(
        startTime: start,
        endTime: end,
        subject: 'Disponible',
        color: Colors.green.shade400,
        isAllDay: false,
      );
    }).toList();
  }

  DateTime _parseTime(DateTime base, String time) {
    final parts = time.split(':');
    return DateTime(base.year, base.month, base.day, int.parse(parts[0]),
        int.parse(parts[1]));
  }
}
