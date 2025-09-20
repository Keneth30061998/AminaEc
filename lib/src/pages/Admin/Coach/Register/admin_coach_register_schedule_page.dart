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
      Get.put(AdminCoachRegisterController());

  AdminCoachRegisterSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteLight,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: _titleAppBar(),
        backgroundColor: whiteLight,
        foregroundColor: almostBlack,
        elevation: 0,
      ),
      body: Column(
        children: [
          Obx(() => SfCalendar(
                view: CalendarView.month,
                minDate: DateTime.now(),
                onTap: (details) => con
                    .selectDateAndPromptTime(details.date), // ✔ Solo DateTime
                initialSelectedDate: DateTime.now(),
                showNavigationArrow: true,
                todayHighlightColor: indigoAmina,
                dataSource: con.calendarDataSource.value,
                selectionDecoration: BoxDecoration(
                  color: darkGrey
                      .withAlpha(25), // ✔ Reemplaza deprecated withOpacity
                  border: Border.all(color: darkGrey, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                headerStyle: CalendarHeaderStyle(
                  textAlign: TextAlign.center,
                  backgroundColor: indigoAmina,
                  textStyle: const TextStyle(color: Colors.white),
                ),
                appointmentBuilder:
                    (context, CalendarAppointmentDetails details) {
                  final appointment = details.appointments.first;
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
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
                monthViewSettings: MonthViewSettings(
                  appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
                  showTrailingAndLeadingDates: false,
                  dayFormat: 'EEE',
                  numberOfWeeksInView: 6,
                  monthCellStyle: MonthCellStyle(
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                    trailingDatesTextStyle:
                        TextStyle(color: Colors.grey.shade300),
                  ),
                ),
              )),
          const SizedBox(height: 10),
          Expanded(
            child: Obx(() {
              final sorted = con.selectedSchedules.toList()
                ..sort((a, b) => a.date!.compareTo(b.date!));

              final grouped = <String, List<Schedule>>{};
              for (var item in sorted) {
                final date = DateTime.parse(item.date!);
                final key = DateFormat.yMMMM('es_ES').format(date);
                grouped.putIfAbsent(key, () => []).add(item);
              }

              if (grouped.isEmpty) {
                return const Center(
                    child: Text('No hay horarios seleccionados'));
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: grouped.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      ...entry.value.map((item) {
                        return Card(
                          elevation: 2,
                          color: colorBackgroundBox,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(
                              DateFormat.yMMMd('es_ES')
                                  .format(DateTime.parse(item.date!)),
                            ),
                            subtitle: Text(
                              '${formatTime(item.start_time!)} - ${formatTime(item.end_time!)}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.redAccent),
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
      bottomNavigationBar: _buttonSave(), // ✔ No context necesario
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
        onPressed: () => con.registerCoach(), // ✔ Sin context
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
