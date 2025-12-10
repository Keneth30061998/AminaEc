// File: coach_schedule_page.dart

import 'package:amina_ec/src/pages/coach/Schedule/coach_schedule_controller.dart';
import 'package:amina_ec/src/utils/iconos.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../models/coach.dart';
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
          style: GoogleFonts.montserrat(
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
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
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ========================================================
              //                CALENDARIO PREMIUM
              // ========================================================
              Padding(
                padding: const EdgeInsets.all(16),
                child: Material(
                  elevation: 3,
                  borderRadius: BorderRadius.circular(18),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: SfCalendar(
                      key: ValueKey(refreshKey),
                      view: CalendarView.month,

                      // SOLO EL HEADER TIENE COLOR
                      headerHeight: 55,
                      headerStyle: CalendarHeaderStyle(
                        backgroundColor: indigoAmina,
                        textAlign: TextAlign.center,
                        textStyle: GoogleFonts.montserrat(
                          fontSize: 17,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      // LOS DÍAS QUEDAN BLANCOS
                      backgroundColor: Colors.white,

                      onTap: (details) {
                        if (details.date != null) con.selectDate(details.date!);
                      },
                      initialSelectedDate: con.selectedDate.value,
                      dataSource: con.calendarDataSource.value,

                      todayHighlightColor: indigoAmina,

                      selectionDecoration: BoxDecoration(
                        color: indigoAmina.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: indigoAmina, width: 2),
                      ),

                      monthViewSettings: MonthViewSettings(
                        showAgenda: false,
                        dayFormat: 'EEE',
                        appointmentDisplayMode:
                        MonthAppointmentDisplayMode.indicator,
                        monthCellStyle: MonthCellStyle(
                          textStyle: GoogleFonts.montserrat(
                            fontSize: 13,
                            color: almostBlack,
                            fontWeight: FontWeight.w600,
                          ),
                          leadingDatesTextStyle: TextStyle(
                              color: Colors.grey.shade400, fontSize: 12),
                          trailingDatesTextStyle: TextStyle(
                              color: Colors.grey.shade400, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ========================================================
              //                    TÍTULO
              // ========================================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Horarios del día',
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: almostBlack,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ========================================================
              //               LISTA DE HORARIOS DEL DÍA
              // ========================================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: con.schedulesForSelectedDay.isEmpty
                      ? Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Center(
                      child: Text(
                        'No hay clases este día.',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  )
                      : Column(
                    children: con.schedulesForSelectedDay.map((s) {
                      final start = s.start_time?.substring(0, 5) ?? '';
                      final end = s.end_time?.substring(0, 5) ?? '';
                      final theme = s.class_theme ?? 'Clase';

                      // ===============================
                      // BUSCAR EL OTRO COACH SI ES DUAL
                      // ===============================
                      String? otherCoachId;
                      if (s.coaches != null && (s.coaches is List) && s.coaches!.length > 1) {
                        final loggedCoachId = con.coach.value!.id.toString();
                        final ids = (s.coaches as List).map((e) => e.toString()).toList();
                        otherCoachId = ids.firstWhere((id) => id != loggedCoachId, orElse: () => '');
                        if (otherCoachId.isEmpty) otherCoachId = null;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.black12.withOpacity(0.05),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: const Offset(1, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ICONO
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: darkGrey,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                iconRides,
                                size: 26,
                                color: whiteLight,
                              ),
                            ),

                            const SizedBox(width: 16),

                            // CONTENIDO
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // TÍTULO DE LA CLASE
                                  Text(
                                    theme,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: almostBlack,
                                      height: 1.2,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  // HORARIO Y UBICACIÓN LIGERA
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          '$start — $end',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 10),

                                  // BADGE DE CLASE COMPARTIDA (INTENTA RESOLVER NOMBRE DEL OTRO COACH)
                                  if (otherCoachId != null)
                                    FutureBuilder(
                                      future: con.coachProvider.getAll().then((list) {
                                        try {
                                          return (list ?? []).firstWhere(
                                                (c) => (c.id?.toString() ?? '') == otherCoachId,
                                            orElse: () => Coach(id: '', user: null),
                                          );
                                        } catch (_) {
                                          return Coach(id: '', user: null);
                                        }
                                      }),
                                      builder: (context, snap) {
                                        String label;

                                        if (snap.connectionState == ConnectionState.waiting) {
                                          label = 'Dúo';
                                        } else if (snap.hasData && snap.data != null) {
                                          final Coach? c = snap.data;
                                          final String? name =
                                              c!.user?.name ?? c.user?.lastname ?? null;

                                          label = 'Dúo con ${name ?? 'Coach invitado'}';
                                        } else {
                                          label = 'Dúo con Coach invitado';
                                        }

                                        return Container(
                                          margin: const EdgeInsets.only(top: 6),
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            color: Colors.indigo.shade100,
                                            border: Border.all(color: indigoAmina, width: 1),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.people_alt, size: 14, color: indigoAmina),
                                              const SizedBox(width: 8),
                                              Text(
                                                label,
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color: indigoAmina,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    )


                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
