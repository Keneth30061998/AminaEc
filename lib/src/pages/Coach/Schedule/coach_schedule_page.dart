import 'package:amina_ec/src/pages/coach/Schedule/coach_schedule_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../utils/color.dart';


class CoachSchedulePage extends StatelessWidget {
  final con = Get.put(CoachScheduleController());

  CoachSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteLight,
      appBar: AppBar(
        title: Text(
          'Mi Calendario',
          style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        backgroundColor: whiteLight,
        foregroundColor: almostBlack,
        elevation: 0,
      ),
      body: Obx(() {
        if (con.coach.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final refreshKey = con.calendarRefreshTrigger.value;

        return SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SfCalendar(
                      key: ValueKey(refreshKey),
                      view: CalendarView.month,
                      onTap: (details) {
                        if (details.date != null) con.selectDate(details.date!);
                      },
                      initialSelectedDate: con.selectedDate.value,
                      dataSource: con.calendarDataSource.value,
                      headerStyle: CalendarHeaderStyle(
                        textAlign: TextAlign.center,
                        backgroundColor: indigoAmina,
                        textStyle: const TextStyle(color: Colors.white),
                      ),
                      todayHighlightColor: indigoAmina,
                    ),
                  ),
                ),
              ),

              /// Lista de horarios del día seleccionado
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: con.schedulesForSelectedDay.map((s) {
                    final start = s.start_time?.substring(0,5) ?? '';
                    final end = s.end_time?.substring(0,5) ?? '';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.schedule, color: indigoAmina),
                          const SizedBox(width: 12),
                          Text(s.class_theme ?? 'Clase', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,color: almostBlack)),

                          const Spacer(),
                          Text('$start - $end', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: almostBlack)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
