import 'package:amina_ec/src/models/coach.dart';
import 'package:amina_ec/src/models/schedule.dart';
import 'package:amina_ec/src/providers/coachs_provider.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

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

  /// ✅ Nuevo: Recargar coach desde backend después de actualizar
  Future<void> _refreshCoach() async {
    final list = await _coachProvider.getAll();
    final updated = list.firstWhereOrNull((c) => c.id == coach.id);
    if (updated != null) {
      coach = updated;
      selectedSchedules.assignAll(coach.schedules);
      _actualizarCalendario();
      update();
    }
  }

  Future<String?> _askClassTheme() async {
    final controller = TextEditingController(text: "Clase");

    return await Get.defaultDialog<String>(
      title: "Tema de la clase",
      content: Column(
        children: [
          Text(
            "Ej: Feid, Shakira, ...",
            style: GoogleFonts.poppins(
              color: almostBlack,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: TextField(
              autofocus: true,
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Ej: Shakira',
                labelText: 'Tema de clase',
                labelStyle: GoogleFonts.poppins(color: Colors.black54),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.black)),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
            ),
          ),
        ],
      ),
      textConfirm: "Aceptar",
      textCancel: "Cancelar",
      onConfirm: () => Get.back(result: controller.text.trim()),
      onCancel: () => Get.back(result: null),
    );
  }

  Future<void> selectDateAndPromptTime(DateTime? date) async {
    if (date == null) return;

    final now = DateTime.now();
    if (date.isBefore(DateTime(now.year, now.month, now.day))) {
      Get.snackbar('Fecha inválida', 'No puedes registrar horarios en el pasado',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    final start = await showTimePicker(
        context: Get.context!, initialTime: TimeOfDay.now());
    if (start == null) return;

    final end = await showTimePicker(context: Get.context!, initialTime: start);
    if (end == null) return;

    if (_compare(start, end) >= 0) {
      Get.snackbar('Rango inválido', 'La hora de fin debe ser mayor que la de inicio',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    final theme = await _askClassTheme() ?? "Clase";

    final schedule = Schedule(
      date: DateFormat('yyyy-MM-dd').format(date),
      start_time: _format(start),
      end_time: _format(end),
      class_theme: theme.isNotEmpty ? theme : "Clase",
    );

    if (selectedSchedules.any((s) =>
    s.date == schedule.date &&
        s.start_time == schedule.start_time &&
        s.end_time == schedule.end_time)) {
      Get.snackbar('Duplicado', 'Ese horario ya fue agregado',
          backgroundColor: Colors.orangeAccent, colorText: Colors.white);
      return;
    }

    selectedSchedules.add(schedule);
  }

  void removeSchedule(int index) {
    selectedSchedules.removeAt(index);
    _actualizarCalendario();
  }

  String _format(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';

  int _compare(TimeOfDay a, TimeOfDay b) =>
      (a.hour * 60 + a.minute) - (b.hour * 60 + b.minute);

  /// ✅ AQUÍ FUE DONDE SE ARREGLÓ TODO
  Future<void> updateSchedule(BuildContext context) async {
    if (selectedSchedules.isEmpty) {
      Get.snackbar('Vacío', 'Debes agregar al menos un horario');
      return;
    }

    final validSchedules = selectedSchedules
        .where((s) =>
    s.date != null && s.start_time != null && s.end_time != null)
        .map((s) => Schedule(
      date: s.date,
      start_time: s.start_time,
      end_time: s.end_time,
      class_theme: s.class_theme?.isNotEmpty == true ? s.class_theme! : "Clase",
    ))
        .toList();

    final res = await _coachProvider.updateSchedule(coach.id!, validSchedules);

    if (res.statusCode == 200 || res.statusCode == 201) {
      await _refreshCoach(); // ✅ se recarga desde backend
      Get.back();
      Get.snackbar('Éxito', 'Horarios actualizados correctamente');
    } else {
      Get.snackbar('Error', 'No se pudo actualizar los horarios');
    }
  }

  void _actualizarCalendario() {
    final dataSource = ScheduleDataSource(selectedSchedules);
    calendarDataSource.value = dataSource;
    calendarDataSource.value
        .notifyListeners(CalendarDataSourceAction.reset, selectedSchedules);
  }
}

class ScheduleDataSource extends CalendarDataSource {
  ScheduleDataSource(List<Schedule> source) {
    appointments = source
        .where((s) =>
    s.date != null && s.start_time != null && s.end_time != null)
        .map((s) {
      final date = DateTime.parse(s.date!);
      final start = _parseTime(date, s.start_time!);
      final end = _parseTime(date, s.end_time!);

      return Appointment(
        startTime: start,
        endTime: end,
        subject: s.class_theme?.isNotEmpty == true ? s.class_theme! : 'Clase',
        color: Colors.green.shade400,
        isAllDay: false,
      );
    }).toList();
  }

  DateTime _parseTime(DateTime base, String time) {
    try {
      final parsed = DateFormat.Hms().parse(time);
      return DateTime(base.year, base.month, base.day, parsed.hour, parsed.minute);
    } catch (_) {
      final parts = time.split(':');
      return DateTime(
        base.year,
        base.month,
        base.day,
        int.tryParse(parts[0]) ?? 0,
        int.tryParse(parts[1]) ?? 0,
      );
    }
  }
}
