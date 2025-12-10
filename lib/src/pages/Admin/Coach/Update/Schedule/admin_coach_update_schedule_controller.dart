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

  final availableCoaches = <Coach>[].obs;
  final Map<int, String> coachesNameById = {};

  @override
  void onInit() {
    super.onInit();
    coach = Get.arguments as Coach;
    _loadSchedules();
    _loadAvailableCoaches();
    ever<List<Schedule>>(selectedSchedules, (_) => _actualizarCalendario());
  }

  void _loadSchedules() {
    final current = coach.schedules;
    if (current.isNotEmpty) {
      final normalized = current.map((s) {
        if (s.coaches == null || s.coaches!.isEmpty) {
          s.coaches = [int.tryParse(coach.id ?? '') ?? 0];
        }
        return s;
      }).toList();

      selectedSchedules.assignAll(normalized);
      _actualizarCalendario();
    }
  }

  Future<void> _loadAvailableCoaches() async {
    try {
      final list = await _coachProvider.getAll();
      final others = list.where((c) => c.id != coach.id).toList();
      availableCoaches.assignAll(others);

      coachesNameById.clear();
      for (final c in list) {
        final idInt = int.tryParse(c.id ?? '');
        if (idInt != null) {
          final full = ((c.user?.name ?? '') +
              (c.user?.lastname != null ? ' ${c.user!.lastname}' : ''))
              .trim();
          coachesNameById[idInt] = full.isNotEmpty ? full : 'Coach #$idInt';
        }
      }
    } catch (e) {
      print('Error cargando coaches disponibles: $e');
    }
  }

  String? _coachNameForId(int? id) {
    if (id == null) return null;
    return coachesNameById[id];
  }

  Future<String?> _askClassTheme() async {
    final controller = TextEditingController(text: "Clase");

    return await Get.defaultDialog<String>(
      title: "Tema de la clase",
      content: Column(
        children: [
          Text("Ej: Feid, Shakira, ...",
              style: GoogleFonts.poppins(color: almostBlack)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: TextField(
              autofocus: true,
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Ej: Shakira',
                labelText: 'Tema de clase',
                labelStyle: GoogleFonts.poppins(color: Colors.black54),
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black)),
                contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
      Get.snackbar('Fecha inválida',
          'No puedes registrar horarios en el pasado',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    final start = await showTimePicker(
        context: Get.context!, initialTime: TimeOfDay.now());
    if (start == null) return;

    final end =
    await showTimePicker(context: Get.context!, initialTime: start);
    if (end == null) return;

    if (_compare(start, end) >= 0) {
      Get.snackbar('Rango inválido',
          'La hora de fin debe ser mayor que la de inicio',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    final theme = await _askClassTheme() ?? "Clase";

    final schedule = Schedule(
      date: DateFormat('yyyy-MM-dd').format(date),
      start_time: _format(start),
      end_time: _format(end),
      class_theme: theme,
      coaches: [int.tryParse(coach.id ?? '') ?? 0],
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
  Future<void> openSecondCoachSelector(int scheduleIndex) async {
    if (scheduleIndex < 0 || scheduleIndex >= selectedSchedules.length) return;

    final schedule = selectedSchedules[scheduleIndex];

    int? currentSecond;
    if (schedule.coaches != null && schedule.coaches!.length >= 2) {
      currentSecond = schedule.coaches![1];
    }

    final chosen = await showDialog<int?>(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Seleccionar segundo coach',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: almostBlack,
                  ),
                ),

                const SizedBox(height: 20),

                Obx(() {
                  if (availableCoaches.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No hay otros coaches disponibles'),
                    );
                  }

                  return SizedBox(
                    height: 300,
                    child: ListView.builder(
                      itemCount: availableCoaches.length + 1,
                      itemBuilder: (context, idx) {
                        if (idx == 0) {
                          return RadioListTile<int?>(
                            value: -1,
                            groupValue: currentSecond ?? -1,
                            onChanged: (v) => Navigator.pop(context, -1),
                            title: const Text('Sin segundo coach (solo el principal)'),
                          );
                        }

                        final c = availableCoaches[idx - 1];
                        final idInt = int.tryParse(c.id ?? '') ?? 0;
                        final name = ((c.user?.name ?? '') +
                            (c.user?.lastname != null ? ' ${c.user!.lastname}' : ''))
                            .trim();

                        return RadioListTile<int>(
                          value: idInt,
                          groupValue: currentSecond ?? -1,
                          onChanged: (v) => Navigator.pop(context, v),
                          title: Text(name.isNotEmpty ? name : 'Coach #$idInt'),
                        );
                      },
                    ),
                  );
                }),

                const SizedBox(height: 20),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, null),
                    child: const Text('Cancelar'),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );

    if (chosen == null) return;

    if (chosen == -1) {
      schedule.coaches = [int.tryParse(coach.id ?? '') ?? 0];
    } else {
      schedule.coaches = [
        int.tryParse(coach.id ?? '') ?? 0,
        chosen,
      ];
    }

    selectedSchedules[scheduleIndex] = schedule;
    _actualizarCalendario();
  }

  void removeSchedule(int index) {
    selectedSchedules.removeAt(index);
    _actualizarCalendario();
  }

  String _format(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';

  int _compare(TimeOfDay a, TimeOfDay b) =>
      (a.hour * 60 + a.minute) - (b.hour * 60 + b.minute);

  /// FINAL — evita crear objetos nuevos, conserva el id
  Future<void> updateSchedule(BuildContext context) async {
    if (selectedSchedules.isEmpty) {
      Get.snackbar('Vacío', 'Debes agregar al menos un horario');
      return;
    }

    final principalId = int.tryParse(coach.id ?? '') ?? 0;

    final validSchedules = selectedSchedules
        .where((s) =>
    s.date != null && s.start_time != null && s.end_time != null)
        .map((s) {
      if (s.coaches == null || s.coaches!.isEmpty) {
        s.coaches = [principalId];
      } else {
        if (!s.coaches!.contains(principalId)) {
          s.coaches = [principalId, ...s.coaches!];
        } else {
          s.coaches!.remove(principalId);
          s.coaches = [principalId, ...s.coaches!];
        }
      }
      return s; // ← YA NO SE CREA OTRO Schedule
    }).toList();

    final res = await _coachProvider.updateSchedule(coach.id!, validSchedules);

    if (res.statusCode == 200 || res.statusCode == 201) {
      await _refreshCoach();
      Get.back();
      Get.snackbar('Éxito', 'Horarios actualizados correctamente');
    } else {
      String message = 'No se pudo actualizar los horarios';
      try {
        message = res.body ?? message;
      } catch (_) {}
      Get.snackbar('Error', message);
    }
  }

  Future<void> _refreshCoach() async {
    final list = await _coachProvider.getAll();
    final updated = list.firstWhereOrNull((c) => c.id == coach.id);

    if (updated != null) {
      coach = updated;
      selectedSchedules.assignAll(coach.schedules.map((s) {
        if (s.coaches == null || s.coaches!.isEmpty) {
          s.coaches = [int.tryParse(coach.id ?? '') ?? 0];
        }
        return s;
      }).toList());

      _actualizarCalendario();
      update();
    }

    await _loadAvailableCoaches();
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
        subject:
        s.class_theme?.isNotEmpty == true ? s.class_theme! : 'Clase',
        color: Colors.green.shade400,
        isAllDay: false,
      );
    }).toList();
  }

  DateTime _parseTime(DateTime base, String time) {
    try {
      final parsed = DateFormat.Hms().parse(time);
      return DateTime(
          base.year, base.month, base.day, parsed.hour, parsed.minute);
    } catch (_) {
      final parts = time.split(':');
      return DateTime(base.year, base.month, base.day,
          int.tryParse(parts[0]) ?? 0, int.tryParse(parts[1]) ?? 0);
    }
  }
}
