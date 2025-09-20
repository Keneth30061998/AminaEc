import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../../../utils/color.dart';
import 'admin_coach_update_schedule_controller.dart';

class AdminCoachUpdateSchedulePage extends StatelessWidget {
  final con = Get.put(AdminCoachUpdateScheduleController());

  AdminCoachUpdateSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteLight,
      appBar: AppBar(
        title: _titleAppBar(),
        backgroundColor: whiteLight,
        foregroundColor: darkGrey,
      ),
      body: Column(
        children: [
          Obx(() => SfCalendar(
                view: CalendarView.month,
                allowedViews: [CalendarView.month, CalendarView.timelineDay],
                dataSource: con.calendarDataSource.value,
                onTap: (details) => con.selectDateAndPromptTime(details.date),
                monthViewSettings: MonthViewSettings(
                  showAgenda: false,
                  appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
                ),
                todayHighlightColor: indigoAmina,
                showNavigationArrow: true,
                headerStyle: CalendarHeaderStyle(
                    textAlign: TextAlign.center,
                    backgroundColor: indigoAmina,
                    textStyle: TextStyle(color: whiteLight)),
                selectionDecoration: BoxDecoration(
                  color: darkGrey.withAlpha((0.2 * 255).round()),
                  border: Border.all(color: darkGrey, width: 2),
                  borderRadius: BorderRadius.circular(8),
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
                return Center(child: Text('No hay horarios registrados aún'));
              }

              return ListView(
                padding: const EdgeInsets.all(20),
                children: grouped.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: almostBlack,
                          ),
                        ),
                      ),
                      ...entry.value.map((item) {
                        return Card(
                          elevation: 3,
                          color: colorBackgroundBox,
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            title: Text(
                              DateFormat.yMMMd('es_ES')
                                  .format(DateTime.parse(item.date!)),
                            ),
                            subtitle: Text(
                              '${formatTime(item.start_time!)} - ${formatTime(item.end_time!)}',
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => con.removeSchedule(
                                  con.selectedSchedules.indexOf(item)),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
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
      ),
    );
  }

  Widget _buttonSave(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      child: FloatingActionButton.extended(
        onPressed: () => con.updateSchedule(context),
        label: Text(
          'Guardar Cambios',
          style: TextStyle(
            fontSize: 14,
            color: whiteLight,
          ),
        ),
        icon: Icon(Icons.save, color: whiteLight),
        backgroundColor: almostBlack,
      ),
    );
  }

  String formatTime(String timeStr) {
    final fullDateTime = DateTime.parse('2000-01-01 $timeStr');
    return DateFormat.Hm().format(fullDateTime);
  }
}
