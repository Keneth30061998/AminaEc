import 'dart:io';
import 'dart:convert';
import 'package:amina_ec/src/models/coach.dart';
import 'package:amina_ec/src/models/schedule.dart';
import 'package:amina_ec/src/providers/coachs_provider.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:pdf/widgets.dart' as pw;

class AdminCoachUpdateScheduleController extends GetxController {
  final CoachProvider _coachProvider = CoachProvider();

  late Coach coach;
  final selectedSchedules = <Schedule>[].obs;

  /// ✅ DataSource FIJO (NO Rx) -> evita rebuild del SfCalendar y evita GlobalKey duplicate
  late final ScheduleDataSource calendarDataSource;

  /// ✅ Mes visible del calendario (para filtrar lista)
  final visibleMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1).obs;

  /// ✅ Progress elegante cuando se renombra el tema
  final isRenamingTheme = false.obs;

  /// ✅ NUEVO: Progress cuando se guardan cambios (evita impresión de “no pasó nada”)
  final isSaving = false.obs;

  /// ✅ Reporte
  final reportSelectedYear = ''.obs;
  final reportSelectedMonth = ''.obs;

  final List<String> reportYears = List.generate(6, (i) => (2025 + i).toString());
  final List<String> reportMonths = const [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  final reportRows = <Schedule>[].obs;
  final reportTotal = 0.obs;

  final availableCoaches = <Coach>[].obs;
  final Map<int, String> coachesNameById = {};

  @override
  void onInit() {
    super.onInit();
    coach = Get.arguments as Coach;

    calendarDataSource = ScheduleDataSource([]);
    _loadSchedules();
    _loadAvailableCoaches();

    ever<List<Schedule>>(selectedSchedules, (_) {
      _actualizarCalendario();
      _refreshReportRows();
    });

    _refreshReportRows();
  }

  /// ✅ IMPORTANT: Evita Rx update durante build del calendar
  void setVisibleMonth(DateTime dateInView) {
    final normalized = DateTime(dateInView.year, dateInView.month, 1);

    if (visibleMonth.value.year == normalized.year &&
        visibleMonth.value.month == normalized.month) {
      return;
    }

    final phase = SchedulerBinding.instance.schedulerPhase;
    final isBuildingLike = phase == SchedulerPhase.persistentCallbacks ||
        phase == SchedulerPhase.midFrameMicrotasks ||
        phase == SchedulerPhase.transientCallbacks;

    if (isBuildingLike) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        visibleMonth.value = normalized;
      });
    } else {
      visibleMonth.value = normalized;
    }
  }

  void _loadSchedules() {
    selectedSchedules.assignAll(
      coach.schedules.map(_copySchedule).toList(),
    );

    _actualizarCalendario();
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

  Future<String?> _askClassTheme({String initialTheme = "Clase"}) async {
    final controller = TextEditingController(text: initialTheme);

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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black),
                ),
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

  /// ✅ Editar tema con progress elegante
  Future<void> editClassTheme(int scheduleIndex) async {
    if (scheduleIndex < 0 || scheduleIndex >= selectedSchedules.length) return;

    final schedule = selectedSchedules[scheduleIndex];

    final currentTheme = (schedule.class_theme?.trim().isNotEmpty == true)
        ? schedule.class_theme!.trim()
        : "Clase";

    final newThemeRaw = await _askClassTheme(initialTheme: currentTheme);
    if (newThemeRaw == null) return;

    final newTheme = newThemeRaw.trim().isNotEmpty ? newThemeRaw.trim() : "Clase";

    isRenamingTheme.value = true;

    schedule.class_theme = newTheme;
    selectedSchedules[scheduleIndex] = schedule;

    await Future.delayed(const Duration(milliseconds: 420));
    isRenamingTheme.value = false;
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
      context: Get.context!,
      initialTime: TimeOfDay.now(),
    );
    if (start == null) return;

    final end = await showTimePicker(context: Get.context!, initialTime: start);
    if (end == null) return;

    if (_compare(start, end) >= 0) {
      Get.snackbar('Rango inválido',
          'La hora de fin debe ser mayor que la de inicio',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    final themeRaw = await _askClassTheme(initialTheme: "Clase");
    final theme =
    (themeRaw?.trim().isNotEmpty == true) ? themeRaw!.trim() : "Clase";

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
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                            title: const Text(
                                'Sin segundo coach (solo el principal)'),
                          );
                        }

                        final c = availableCoaches[idx - 1];
                        final idInt = int.tryParse(c.id ?? '') ?? 0;
                        final name = ((c.user?.name ?? '') +
                            (c.user?.lastname != null
                                ? ' ${c.user!.lastname}'
                                : ''))
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
  }

  void removeSchedule(int index) {
    selectedSchedules.removeAt(index);
  }

  String _format(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';

  int _compare(TimeOfDay a, TimeOfDay b) =>
      (a.hour * 60 + a.minute) - (b.hour * 60 + b.minute);

  Future<void> updateSchedule(BuildContext context) async {
    if (isSaving.value) return;

    if (selectedSchedules.isEmpty) {
      Get.snackbar('Vacío', 'Debes agregar al menos un horario');
      return;
    }

    isSaving.value = true;

    try {
      // No excluir silenciosamente horarios incompletos:
      // el backend interpreta los horarios omitidos como eliminaciones.
      final hasIncomplete = selectedSchedules.any(
            (s) =>
        (s.date ?? '').trim().isEmpty ||
            (s.start_time ?? '').trim().isEmpty ||
            (s.end_time ?? '').trim().isEmpty,
      );

      if (hasIncomplete) {
        Get.snackbar(
          'Horario incompleto',
          'Completa la fecha y las horas antes de guardar.',
        );
        return;
      }

      final schedulesToSend =
      selectedSchedules.map(_copySchedule).toList();

      // Mantiene el bloqueo de Guardar mientras esta petición está pendiente.
      // Retirar el timeout local NO corrige el bloqueo de MySQL.
      final res = await _coachProvider.updateSchedule(
        coach.id!,
        schedulesToSend,
      );

      Map<String, dynamic>? body;

      try {
        final decoded = jsonDecode(res.body);
        if (decoded is Map) {
          body = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        // Se mostrará un mensaje según el estado HTTP.
      }

      final success =
          (res.statusCode == 200 || res.statusCode == 201) &&
              body?['success'] == true;

      if (!success) {
        Get.snackbar(
          res.statusCode == 409 ? 'Cambio rechazado' : 'Error al guardar',
          body?['message']?.toString() ??
              'El servidor respondió con HTTP ${res.statusCode}.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 6),
        );
        return;
      }

      // El guardado ya fue confirmado. Un fallo al recargar
      // no debe presentarse como un fallo al guardar.
      try {
        await _refreshCoach();
      } catch (e) {
        debugPrint('Guardado confirmado; error al recargar: $e');
      }

      Get.back(result: true);
      Get.snackbar(
        'Éxito',
        'Horarios actualizados correctamente',
      );
    } catch (e) {
      debugPrint('Error updateSchedule: $e');

      Get.snackbar(
        'No se pudo confirmar el guardado',
        'Consulta nuevamente los horarios antes de volver a guardar. '
            'Detalle: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 6),
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> _refreshCoach() async {
    final list = await _coachProvider.getAll();
    final updated = list.firstWhereOrNull((c) => c.id == coach.id);

    if (updated != null) {
      coach = updated;

      selectedSchedules.assignAll(
        coach.schedules.map(_copySchedule).toList(),
      );
    }

    await _loadAvailableCoaches();
  }

  void _actualizarCalendario() {
    calendarDataSource.updateFromSchedules(selectedSchedules);
  }

  // ==========================================================
  // ✅ REPORTE
  // ==========================================================
  void buscarReporte() {
    String? monthParam;
    if (reportSelectedMonth.value.isNotEmpty) {
      final idx = reportMonths.indexOf(reportSelectedMonth.value);
      if (idx >= 0) monthParam = (idx + 1).toString().padLeft(2, '0');
    }

    final String? yearParam =
    reportSelectedYear.value.isNotEmpty ? reportSelectedYear.value : null;

    final filtered = selectedSchedules.where((s) {
      if (s.date == null) return false;
      final d = DateTime.tryParse(s.date!);
      if (d == null) return false;

      if (yearParam != null && d.year.toString() != yearParam) return false;
      if (monthParam != null &&
          d.month.toString().padLeft(2, '0') != monthParam) return false;

      return true;
    }).toList();

    filtered.sort((a, b) {
      final da = a.date ?? '';
      final db = b.date ?? '';
      final cmp = da.compareTo(db);
      if (cmp != 0) return cmp;
      return _timeToMinutes(a.start_time)
          .compareTo(_timeToMinutes(b.start_time));
    });

    reportRows.assignAll(filtered);
    reportTotal.value = filtered.length;
  }

  void _refreshReportRows() {
    if (reportSelectedYear.value.isEmpty && reportSelectedMonth.value.isEmpty) {
      final all = selectedSchedules.toList()
        ..sort((a, b) {
          final da = a.date ?? '';
          final db = b.date ?? '';
          final cmp = da.compareTo(db);
          if (cmp != 0) return cmp;
          return _timeToMinutes(a.start_time)
              .compareTo(_timeToMinutes(b.start_time));
        });
      reportRows.assignAll(all);
      reportTotal.value = all.length;
      return;
    }
    buscarReporte();
  }

  int _timeToMinutes(String? time) {
    if (time == null || time.isEmpty) return 0;
    final parts = time.split(':');
    final h = int.tryParse(parts.isNotEmpty ? parts[0] : '0') ?? 0;
    final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    return (h * 60) + m;
  }

  String _fmtTime(String timeStr) {
    final fullDateTime = DateTime.parse('2000-01-01 $timeStr');
    return DateFormat.Hm().format(fullDateTime);
  }

  Future<File> generateReportPDF() async {
    final pdf = pw.Document();

    final coachName =
    '${coach.user?.name ?? ''} ${coach.user?.lastname ?? ''}'.trim();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Reporte de Clases',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text('Coach: $coachName'),
              pw.SizedBox(height: 10),
              pw.TableHelper.fromTextArray(
                headers: const ['Fecha', 'Inicio', 'Fin', 'Tema', 'Tipo'],
                data: reportRows.map((s) {
                  final dateStr = s.date != null
                      ? DateFormat('dd/MM/yyyy')
                      .format(DateTime.parse(s.date!))
                      : '';
                  final start =
                  s.start_time != null ? _fmtTime(s.start_time!) : '';
                  final end = s.end_time != null ? _fmtTime(s.end_time!) : '';
                  final theme = (s.class_theme ?? 'Clase').toString();
                  final type = (s.coaches != null && s.coaches!.length == 2)
                      ? 'Dual'
                      : 'Single';
                  return [dateStr, start, end, theme, type];
                }).toList(),
              ),
              pw.SizedBox(height: 12),
              pw.Text('Total de clases: ${reportRows.length}'),
            ],
          );
        },
      ),
    );

    Directory dir;
    if (Platform.isAndroid) {
      final status = await Permission.manageExternalStorage.request();
      dir = status.isGranted
          ? Directory('/storage/emulated/0/Download')
          : await getApplicationDocumentsDirectory();
    } else {
      dir = await getApplicationDocumentsDirectory();
    }

    final file = File('${dir.path}/reporte_clases_coach.pdf');
    await file.writeAsBytes(await pdf.save(), flush: true);
    return file;
  }

  Future<void> exportReportPDF(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    final shareRect =
    box != null ? (box.localToGlobal(Offset.zero) & box.size) : null;

    final file = await generateReportPDF();

    final params = ShareParams(
      files: [XFile(file.path)],
      text: 'Reporte de Clases',
      sharePositionOrigin: shareRect,
    );

    try {
      await SharePlus.instance.share(params);
    } catch (_) {
      Get.snackbar('Exportación', 'Archivo guardado en: ${file.path}');
    }
  }

  Future<void> exportReportExcel(BuildContext context) async {
    final excel = Excel.createExcel();
    final sheet = excel['Reporte'];

    sheet.appendRow([
      TextCellValue('Fecha'),
      TextCellValue('Inicio'),
      TextCellValue('Fin'),
      TextCellValue('Tema'),
      TextCellValue('Tipo'),
    ]);

    for (final s in reportRows) {
      final dateStr = s.date != null
          ? DateFormat('dd/MM/yyyy').format(DateTime.parse(s.date!))
          : '';
      final start =
      (s.start_time ?? '').isNotEmpty ? _fmtTime(s.start_time!) : '';
      final end = (s.end_time ?? '').isNotEmpty ? _fmtTime(s.end_time!) : '';
      final theme = (s.class_theme ?? 'Clase').toString();
      final type =
      (s.coaches != null && s.coaches!.length == 2) ? 'Dual' : 'Single';

      sheet.appendRow([
        TextCellValue(dateStr),
        TextCellValue(start),
        TextCellValue(end),
        TextCellValue(theme),
        TextCellValue(type),
      ]);
    }

    final bytes = excel.encode();
    if (bytes == null) return;

    Directory dir;
    if (Platform.isAndroid) {
      final status = await Permission.manageExternalStorage.request();
      dir = status.isGranted
          ? Directory('/storage/emulated/0/Download')
          : await getApplicationDocumentsDirectory();
    } else {
      dir = await getApplicationDocumentsDirectory();
    }

    final file = File('${dir.path}/reporte_clases_coach.xlsx');
    await file.writeAsBytes(bytes, flush: true);

    if (Platform.isIOS) {
      final box = context.findRenderObject() as RenderBox?;
      final shareRect =
      box != null ? (box.localToGlobal(Offset.zero) & box.size) : null;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Reporte de Clases',
          sharePositionOrigin: shareRect,
        ),
      );
    } else {
      Get.snackbar('Excel generado', 'Archivo guardado en: ${file.path}');
    }
  }

  Schedule _copySchedule(Schedule source) {
    final principalId = int.tryParse(coach.id ?? '');

    if (principalId == null || principalId <= 0) {
      throw StateError('El coach principal no es válido.');
    }

    final participants = List<int>.from(source.coaches ?? []);

    // Compatibilidad con horarios antiguos sin lista de participantes.
    if (participants.isEmpty) {
      participants.add(principalId);
    }

    if (!participants.contains(principalId) ||
        participants.length > 2 ||
        participants.any((id) => id <= 0) ||
        participants.toSet().length != participants.length) {
      throw StateError(
        'Participantes inválidos en la clase '
            '${source.id ?? "nueva"} del ${source.date}.',
      );
    }

    // El selector de segundo coach espera al principal en la posición 0.
    final ordered = [
      principalId,
      ...participants.where((id) => id != principalId),
    ];

    return Schedule(
      id: source.id,
      is_course: source.is_course,
      date: source.date,
      start_time: source.start_time,
      end_time: source.end_time,
      class_theme: source.class_theme,
      coaches: ordered,
    );
  }
}

/// ✅ DataSource estable: NO recrear el calendar, solo actualizar appointments
class ScheduleDataSource extends CalendarDataSource {
  ScheduleDataSource(List<Schedule> source) {
    updateFromSchedules(source);
  }

  void updateFromSchedules(List<Schedule> source) {
    final list = source
        .where((s) => s.date != null && s.start_time != null && s.end_time != null)
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

    appointments = list;
    notifyListeners(CalendarDataSourceAction.reset, list);
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
