import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../../models/schedule.dart';
import '../../../../utils/color.dart';
import 'admin_coach_register_controller.dart';

class AdminCoachRegisterSchedulePage extends StatelessWidget {
  final AdminCoachRegisterController con =
  Get.find<AdminCoachRegisterController>();

  AdminCoachRegisterSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 650;

    return Scaffold(
      backgroundColor: whiteLight,
      appBar: AppBar(
        title: _titleAppBar(),
        backgroundColor: whiteLight,
        foregroundColor: almostBlack,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Calendario con estilo similar a UserCoachSchedulePage
            Obx(() {
              return Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SfCalendar(

                      view: CalendarView.month,
                      minDate: DateTime.now(),
                      initialSelectedDate: DateTime.now(),
                      onTap: (details) =>
                          con.selectDateAndPromptTime(details.date),
                      showNavigationArrow: true,
                      todayHighlightColor: indigoAmina,
                      dataSource: con.calendarDataSource.value,
                      headerStyle: CalendarHeaderStyle(
                        textAlign: TextAlign.center,
                        backgroundColor: indigoAmina,
                        textStyle: const TextStyle(color: whiteLight),
                      ),
                      selectionDecoration: BoxDecoration(
                        color: darkGrey.withAlpha((0.2 * 255).toInt()),
                        border: Border.all(color: darkGrey, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      monthViewSettings: const MonthViewSettings(
                        appointmentDisplayMode:
                        MonthAppointmentDisplayMode.indicator,
                        showAgenda: false,
                      ),
                      appointmentBuilder: (context, details) {
                        final appointment =
                        details.appointments.first as Appointment;
                        return Container(
                          width: details.bounds.width,
                          height: details.bounds.height,
                          decoration: BoxDecoration(
                            color: appointment.color,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Center(
                            child: Text(
                              appointment.subject,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 10),

            // Lista de horarios con estilo de UserCoachSchedulePage
            Obx(() {
              final sorted = con.selectedSchedules.toList()
                ..sort((a, b) => a.date!.compareTo(b.date!));

              if (sorted.isEmpty) {
                return const Center(
                    child: Text('No hay horarios seleccionados'));
              }

              final grouped = <String, List<Schedule>>{};
              for (var item in sorted) {
                final date = DateTime.parse(item.date!);
                final key = DateFormat.yMMMM('es_ES').format(date);
                grouped.putIfAbsent(key, () => []).add(item);
              }

              return ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: grouped.entries.expand((entry) {
                  return [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    ...entry.value.map((schedule) => _ScheduleCard(
                      schedule: schedule,
                      isTablet: isTablet,
                      onDelete: () => con.removeSchedule(
                          con.selectedSchedules.indexOf(schedule)),
                    )),
                  ];
                }).toList(),
              );
            }),
          ],
        ),
      ),
      bottomNavigationBar: _buttonSave(),
    );
  }

  Widget _titleAppBar() {
    return Text(
      'Disponibilidad',
      style: GoogleFonts.montserrat(
        fontWeight: FontWeight.w800,
        color: almostBlack,
      ),
    );
  }

  Widget _buttonSave() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, top: 5, left: 20, right: 20),
      child: FloatingActionButton.extended(
        backgroundColor: almostBlack,
        onPressed: () => con.registerCoach(),
        label: const Text('Guardar y Registrar',
            style: TextStyle(fontSize: 16, color: Colors.white)),
        icon: const Icon(Icons.save, color: Colors.white),
      ),
    );
  }

  String formatTime(String timeStr) {
    final fullDateTime = DateTime.parse('2000-01-01 $timeStr');
    return DateFormat.Hm().format(fullDateTime);
  }
}

class _ScheduleCard extends StatelessWidget {
  final Schedule schedule;
  final bool isTablet;
  final VoidCallback onDelete;

  const _ScheduleCard({
    super.key,
    required this.schedule,
    required this.isTablet,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final width = isTablet ? 640.0 : double.infinity;

    return Container(
      width: width,
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('dd/MM/yyyy')
                      .format(DateTime.parse(schedule.date!)),
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  schedule.class_theme ?? 'Clase',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w800,
                    color: almostBlack,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_formatTime(schedule.start_time!)} — ${_formatTime(schedule.end_time!)}',
                  style: TextStyle(
                    fontSize: isTablet ? 15 : 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  String _formatTime(String timeStr) {
    final fullDateTime = DateTime.parse('2000-01-01 $timeStr');
    return DateFormat.Hm().format(fullDateTime);
  }
}
