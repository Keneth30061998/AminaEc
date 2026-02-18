import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../../../utils/color.dart';
import 'admin_coach_update_schedule_controller.dart';

class AdminCoachUpdateSchedulePage extends StatelessWidget {
  final con = Get.put(AdminCoachUpdateScheduleController(), tag: 'admin_coach');

  AdminCoachUpdateSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: whiteLight,
          appBar: AppBar(
            backgroundColor: whiteLight,
            elevation: 0,
            centerTitle: true,
            foregroundColor: almostBlack,
            title: Text(
              'Editar Disponibilidad',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w800,
                color: almostBlack,
                fontSize: 18,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Reporte de clases',
                icon: const Icon(Icons.bar_chart_rounded, color: darkGrey),
                onPressed: () => _openReportSheet(context),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // ✅ Progress indicator elegante (renombrar tema + guardar)
                Obx(() {
                  final show = con.isRenamingTheme.value || con.isSaving.value;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    height: show ? 3.5 : 0,
                    child: show
                        ? LinearProgressIndicator(
                      minHeight: 3.5,
                      backgroundColor: Colors.grey.shade200,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(indigoAmina),
                    )
                        : const SizedBox.shrink(),
                  );
                }),

                // ✅ CALENDARIO (SIN Obx) -> evita rebuild y GlobalKey duplicate
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                  child: Material(
                    elevation: 0,
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 14,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: SfCalendar(
                          view: CalendarView.month,
                          allowedViews: const [
                            CalendarView.month,
                            CalendarView.timelineDay
                          ],
                          dataSource: con.calendarDataSource,
                          onTap: (details) =>
                              con.selectDateAndPromptTime(details.date),

                          // ✅ detectar mes visible (Febrero -> lista Febrero)
                          onViewChanged: (ViewChangedDetails details) {
                            if (details.visibleDates.isEmpty) return;
                            final mid = details.visibleDates[
                            details.visibleDates.length ~/ 2];
                            con.setVisibleMonth(mid);
                          },

                          monthViewSettings: const MonthViewSettings(
                            showAgenda: false,
                            appointmentDisplayMode:
                            MonthAppointmentDisplayMode.indicator,
                          ),
                          todayHighlightColor: indigoAmina,
                          showNavigationArrow: true,
                          headerStyle: CalendarHeaderStyle(
                            textAlign: TextAlign.center,
                            backgroundColor: Colors.white,
                            textStyle: GoogleFonts.poppins(
                              color: almostBlack,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          viewHeaderStyle: ViewHeaderStyle(
                            backgroundColor: Colors.white,
                            dayTextStyle: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                            dateTextStyle: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          selectionDecoration: BoxDecoration(
                            color: indigoAmina.withOpacity(0.10),
                            border:
                            Border.all(color: indigoAmina, width: 1.6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // LISTA FILTRADA POR MES VISIBLE
                Expanded(
                  child: Obx(() {
                    final monthBase = con.visibleMonth.value;
                    final monthTitle =
                    DateFormat.yMMMM('es_ES').format(monthBase);

                    final monthItems = con.selectedSchedules.where((s) {
                      if (s.date == null) return false;
                      final d = DateTime.tryParse(s.date!);
                      if (d == null) return false;
                      return d.year == monthBase.year &&
                          d.month == monthBase.month;
                    }).toList();

                    // orden por fecha y hora
                    monthItems.sort((a, b) {
                      final da = a.date ?? '';
                      final db = b.date ?? '';
                      final cmp = da.compareTo(db);
                      if (cmp != 0) return cmp;
                      return _timeToMinutes(a.start_time)
                          .compareTo(_timeToMinutes(b.start_time));
                    });

                    // agrupar por día
                    final Map<String, List<dynamic>> daysMap = {};
                    for (final s in monthItems) {
                      final dt = DateTime.parse(s.date!);
                      final key = DateFormat('yyyy-MM-dd').format(dt);
                      daysMap.putIfAbsent(key, () => []);
                      daysMap[key]!.add(s);
                    }

                    if (daysMap.isEmpty) {
                      return Center(
                        child: Text(
                          'No hay clases en $monthTitle',
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }

                    final sortedDays = daysMap.keys.toList()..sort();

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      children: [
                        _SectionHeader(title: monthTitle),
                        ...sortedDays.expand((dayKey) {
                          final dayItems = daysMap[dayKey] ?? [];
                          dayItems.sort((a, b) => _timeToMinutes(a.start_time)
                              .compareTo(_timeToMinutes(b.start_time)));

                          final dayDt = DateTime.parse(dayKey);
                          final dayTitle = DateFormat("EEEE dd/MM/yyyy", 'es_ES')
                              .format(dayDt);

                          return [
                            _DayHeader(
                              title: _capitalize(dayTitle),
                              count: dayItems.length,
                            ),
                            ...dayItems.map((item) => _ScheduleCard(
                              schedule: item,
                              onEditTheme: () => con.editClassTheme(
                                con.selectedSchedules.indexOf(item),
                              ),
                              onEditSecondCoach: () =>
                                  con.openSecondCoachSelector(
                                    con.selectedSchedules.indexOf(item),
                                  ),
                              onDelete: () => con.removeSchedule(
                                con.selectedSchedules.indexOf(item),
                              ),
                              secondCoachName:
                              _secondCoachNameForSchedule(item),
                            )),
                          ];
                        }),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _BottomBar(
            onSave: () => con.updateSchedule(context),
            isSaving: con.isSaving,
          ),
        ),

        // ✅ Overlay elegante cuando se está guardando
        Obx(() => _SavingOverlay(visible: con.isSaving.value)),
      ],
    );
  }

  // =======================
  // Report Bottom Sheet
  // =======================
  void _openReportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.92,
          minChildSize: 0.60,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 46,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Reporte de Clases',
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: almostBlack,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Exportar PDF',
                          icon: const Icon(Icons.picture_as_pdf,
                              color: darkGrey),
                          onPressed: () => con.exportReportPDF(context),
                        ),
                        IconButton(
                          tooltip: 'Exportar Excel',
                          icon: const Icon(Icons.grid_on, color: darkGrey),
                          onPressed: () => con.exportReportExcel(context),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _reportFilterCard(context),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _reportTableCard(scrollController),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                    child: _reportFooter(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _reportFilterCard(BuildContext context) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _modernSelector(
                    context: context,
                    label: "Año",
                    value: con.reportSelectedYear,
                    icon: Icons.calendar_today_outlined,
                    items: con.reportYears,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _modernSelector(
                    context: context,
                    label: "Mes",
                    value: con.reportSelectedMonth,
                    icon: Icons.event_note_outlined,
                    items: con.reportMonths,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: 300,
              child: ElevatedButton.icon(
                onPressed: con.buscarReporte,
                icon: const Icon(Icons.search, color: whiteLight),
                label: Text(
                  'Buscar',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: almostBlack,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modernSelector({
    required BuildContext context,
    required String label,
    required RxString value,
    required IconData icon,
    required List<String> items,
  }) {
    return InkWell(
      onTap: () async {
        final selected = await showDialog<String>(
          context: context,
          builder: (_) => _simpleListDialog(
            title: "Seleccionar $label",
            items: items,
            selected: value.value,
          ),
        );
        if (selected != null) value.value = selected;
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[700], size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.montserrat(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      )),
                  Obx(() => Text(
                    value.value.isEmpty ? "Seleccionar" : value.value,
                    style: GoogleFonts.poppins(
                      color: almostBlack,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  )),
                ],
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _simpleListDialog({
    required String title,
    required List<String> items,
    required String selected,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: almostBlack,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final item = items[i];
                  final isSelected = item == selected;
                  return ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    title: Text(
                      item,
                      style: GoogleFonts.montserrat(
                        fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? almostBlack : Colors.grey[800],
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: almostBlack)
                        : null,
                    onTap: () => Get.back(result: item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reportTableCard(ScrollController scrollController) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Obx(() {
          if (con.reportRows.isEmpty) {
            return Center(
              child: Text(
                'No hay resultados',
                style: GoogleFonts.montserrat(
                  color: Colors.grey[700],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SingleChildScrollView(
              controller: scrollController,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(almostBlack),
                  headingTextStyle: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  dataTextStyle: GoogleFonts.montserrat(
                    color: Colors.black87,
                    fontSize: 12,
                  ),
                  columnSpacing: 14,
                  columns: const [
                    DataColumn(label: Text('Fecha')),
                    DataColumn(label: Text('Inicio')),
                    DataColumn(label: Text('Fin')),
                    DataColumn(label: Text('Tema')),
                    DataColumn(label: Text('Tipo')),
                  ],
                  rows: con.reportRows.map((s) {
                    final dateStr = s.date != null
                        ? DateFormat('dd/MM/yyyy')
                        .format(DateTime.parse(s.date!))
                        : '';
                    final start = (s.start_time ?? '').isNotEmpty
                        ? DateFormat.Hm().format(
                      DateTime.parse('2000-01-01 ${s.start_time}'),
                    )
                        : '';
                    final end = (s.end_time ?? '').isNotEmpty
                        ? DateFormat.Hm().format(
                      DateTime.parse('2000-01-01 ${s.end_time}'),
                    )
                        : '';
                    final theme = (s.class_theme ?? 'Clase').toString();
                    final type = (s.coaches != null && s.coaches!.length == 2)
                        ? 'Dual'
                        : 'Single';

                    return DataRow(
                      cells: [
                        DataCell(Text(dateStr)),
                        DataCell(Text(start)),
                        DataCell(Text(end)),
                        DataCell(Text(theme)),
                        DataCell(Text(type)),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _reportFooter() {
    return Obx(() => Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: almostBlack,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Total de clases: ${con.reportTotal.value}',
        style: GoogleFonts.montserrat(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    ));
  }

  String? _secondCoachNameForSchedule(dynamic schedule) {
    if (schedule.coaches != null &&
        schedule.coaches is List &&
        schedule.coaches.length >= 2) {
      final id = schedule.coaches[1] as int?;
      final name = con.coachesNameById[id];
      return name ?? 'Coach #$id';
    }
    return null;
  }

  static int _timeToMinutes(String? time) {
    if (time == null || time.isEmpty) return 0;
    final parts = time.split(':');
    final h = int.tryParse(parts.isNotEmpty ? parts[0] : '0') ?? 0;
    final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    return (h * 60) + m;
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

class _SavingOverlay extends StatelessWidget {
  final bool visible;
  const _SavingOverlay({required this.visible});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        child: visible
            ? Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  color: Colors.black.withOpacity(0.18),
                ),
              ),
            ),
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 22),
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.6),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Guardando cambios...\nEsto puede tardar unos segundos.',
                        style: GoogleFonts.poppins(
                          fontSize: 12.8,
                          fontWeight: FontWeight.w700,
                          color: almostBlack,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
            : const SizedBox.shrink(),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 10),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: indigoAmina,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: almostBlack,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: Colors.grey.shade300,
              thickness: 1,
              indent: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  final String title;
  final int count;

  const _DayHeader({
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12.8,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: indigoAmina.withOpacity(0.10),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: indigoAmina.withOpacity(0.18)),
            ),
            child: Text(
              '$count clases',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: indigoAmina,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final dynamic schedule;
  final VoidCallback onEditTheme;
  final VoidCallback onEditSecondCoach;
  final VoidCallback onDelete;
  final String? secondCoachName;

  const _ScheduleCard({
    required this.schedule,
    required this.onEditTheme,
    required this.onEditSecondCoach,
    required this.onDelete,
    required this.secondCoachName,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(schedule.date!);
    final dateStr = DateFormat('EEE dd/MM/yyyy', 'es_ES').format(date);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onEditTheme,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 5,
                  height: secondCoachName != null ? 86 : 68,
                  decoration: BoxDecoration(
                    color: indigoAmina.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              dateStr,
                              style: GoogleFonts.poppins(
                                fontSize: 12.5,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        (schedule.class_theme ?? 'Clase').toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: almostBlack,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.schedule,
                              size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Text(
                            '${_formatTime(schedule.start_time!)} — ${_formatTime(schedule.end_time!)}',
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (secondCoachName != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.people_outline,
                                size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Segundo coach: $secondCoachName',
                                style: GoogleFonts.poppins(
                                  fontSize: 12.3,
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _ActionPill(
                            icon: Icons.edit_outlined,
                            label: 'Editar tema',
                            color: Colors.orange,
                            onTap: onEditTheme,
                          ),
                          _ActionPill(
                            icon: Icons.person_add_alt_1_outlined,
                            label: 'Segundo coach',
                            color: Colors.blue,
                            onTap: onEditSecondCoach,
                          ),
                          _ActionPill(
                            icon: Icons.delete_outline,
                            label: 'Eliminar',
                            color: Colors.red,
                            onTap: onDelete,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatTime(String timeStr) {
    final fullDateTime = DateTime.parse('2000-01-01 $timeStr');
    return DateFormat.Hm().format(fullDateTime);
  }
}

class _ActionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionPill({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final VoidCallback onSave;
  final RxBool isSaving;
  const _BottomBar({required this.onSave, required this.isSaving});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, -8),
          )
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 50,
          child: Obx(() {
            final saving = isSaving.value;
            return ElevatedButton(
              onPressed: saving ? null : onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: almostBlack,
                foregroundColor: whiteLight,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (saving) ...[
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor:
                        AlwaysStoppedAnimation<Color>(whiteLight),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Guardando...',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ] else ...[
                    const Icon(Icons.save_outlined, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Guardar cambios',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
