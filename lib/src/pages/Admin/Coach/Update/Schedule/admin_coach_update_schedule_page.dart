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
    return Scaffold(
      backgroundColor: whiteLight,
      appBar: AppBar(
        title: _titleAppBar(),
        backgroundColor: whiteLight,
        foregroundColor: almostBlack,
        elevation: 0,
      ),
      body: Column(
        children: [
          Obx(() => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SfCalendar(
                  view: CalendarView.month,
                  allowedViews: [CalendarView.month, CalendarView.timelineDay],
                  dataSource: con.calendarDataSource.value,
                  onTap: (details) => con.selectDateAndPromptTime(details.date),
                  monthViewSettings: const MonthViewSettings(
                    showAgenda: false,
                    appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
                  ),
                  todayHighlightColor: indigoAmina,
                  showNavigationArrow: true,
                  headerStyle: const CalendarHeaderStyle(
                    textAlign: TextAlign.center,
                    backgroundColor: indigoAmina,
                    textStyle: TextStyle(color: whiteLight),
                  ),
                  selectionDecoration: BoxDecoration(
                    color: darkGrey.withAlpha((0.2 * 255).round()),
                    border: Border.all(color: darkGrey, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          )),
          Expanded(
            child: Obx(() {
              final sorted = con.selectedSchedules.toList()
                ..sort((a, b) => a.date!.compareTo(b.date!));

              final grouped = <String, List<dynamic>>{};
              for (var item in sorted) {
                final date = DateTime.parse(item.date!);
                final key = DateFormat.yMMMM('es_ES').format(date);
                grouped.putIfAbsent(key, () => []).add(item);
              }

              if (grouped.isEmpty) {
                return const Center(child: Text('No hay horarios registrados aún'));
              }

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: grouped.entries.expand((entry) {
                  return [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: almostBlack,
                        ),
                      ),
                    ),
                    ...entry.value.map((item) => _ScheduleCard(
                      schedule: item,
                      onDelete: () =>
                          con.removeSchedule(con.selectedSchedules.indexOf(item)),
                      onEditSecondCoach: () =>
                          con.openSecondCoachSelector(con.selectedSchedules.indexOf(item)),
                      secondCoachName: _secondCoachNameForSchedule(item, con),
                    )),
                  ];
                }).toList(),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: _buttonSave(context),
    );
  }

  Widget _titleAppBar() {
    return Text(
      'Editar Disponibilidad',
      style: GoogleFonts.montserrat(
        fontWeight: FontWeight.w800,
        color: almostBlack,
      ),
    );
  }

  Widget _buttonSave(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      child: FloatingActionButton.extended(
        onPressed: () => con.updateSchedule(context),
        label: const Text(
          'Guardar Cambios',
          style: TextStyle(
            fontSize: 14,
            color: whiteLight,
          ),
        ),
        icon: const Icon(Icons.save, color: whiteLight),
        backgroundColor: almostBlack,
      ),
    );
  }

  String formatTime(String timeStr) {
    final fullDateTime = DateTime.parse('2000-01-01 $timeStr');
    return DateFormat.Hm().format(fullDateTime);
  }

  // obtiene el nombre del segundo coach (si existe)
  String? _secondCoachNameForSchedule(dynamic schedule, AdminCoachUpdateScheduleController con) {
    if (schedule.coaches != null && schedule.coaches is List && schedule.coaches.length >= 2) {
      final id = schedule.coaches[1] as int?;
      final name = con.coachesNameById[id];
      return name ?? 'Coach #$id';
    }
    return null;
  }
}

class _ScheduleCard extends StatelessWidget {
  final dynamic schedule;
  final VoidCallback onDelete;
  final VoidCallback onEditSecondCoach;
  final String? secondCoachName;

  const _ScheduleCard({
    super.key,
    required this.schedule,
    required this.onDelete,
    required this.onEditSecondCoach,
    required this.secondCoachName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 3,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('dd/MM/yyyy').format(DateTime.parse(schedule.date!)),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      schedule.class_theme ?? 'Clase',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: almostBlack,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${formatTime(schedule.start_time!)} — ${formatTime(schedule.end_time!)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.person_add_alt_1_outlined, color: Colors.blueAccent),
                    tooltip: 'Agregar/Editar segundo coach',
                    onPressed: onEditSecondCoach,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
          // Si tiene segundo coach mostrar su nombre debajo de la fila principal
          if (secondCoachName != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.people, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Segundo coach: $secondCoachName',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade800, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            )
          ],
        ],
      ),
    );
  }

  String formatTime(String timeStr) {
    final fullDateTime = DateTime.parse('2000-01-01 $timeStr');
    return DateFormat.Hm().format(fullDateTime);
  }
}
