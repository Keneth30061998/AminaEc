import 'package:amina_ec/src/pages/user/Coach/List/user_coach_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../../models/coach.dart';
import '../../../../utils/color.dart';
import '../../../../widgets/no_data_widget.dart';

// imports idénticos
class UserCoachSchedulePage extends StatelessWidget {
  final con = Get.put(UserCoachScheduleController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteLight,
      appBar: AppBar(
        title: Text('Agendar Ride',
            style: GoogleFonts.montserrat(
                fontSize: 22, fontWeight: FontWeight.w800)),
        backgroundColor: whiteLight,
        foregroundColor: almostBlack,
      ),
      body: Column(
        children: [
          Obx(() => SfCalendar(
                minDate: DateTime.now(),
                view: CalendarView.month,
                onTap: (details) {
                  if (details.date != null) con.selectDate(details.date!);
                },
                initialSelectedDate: con.selectedDate.value,
                dataSource: con.calendarDataSource.value,
                headerStyle: CalendarHeaderStyle(
                    textAlign: TextAlign.center,
                    backgroundColor: indigoAmina,
                    textStyle: TextStyle(color: whiteLight)),
                selectionDecoration: BoxDecoration(
                  color: darkGrey.withOpacity(0.2),
                  border: Border.all(color: darkGrey, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                showNavigationArrow: true,
                todayHighlightColor: indigoAmina,
                monthViewSettings: MonthViewSettings(
                  appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
                  showAgenda: false,
                ),
              )),
          Expanded(
            child: Obx(() {
              if (con.filteredCoaches.isEmpty) {
                return Center(
                    child: NoDataWidget(
                        text: 'No hay entrenadores disponibles ese día'));
              }
              return ListView.builder(
                itemCount: con.filteredCoaches.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (_, index) {
                  final coach = con.filteredCoaches[index];
                  return _coachCard(coach, con.selectedDate.value);
                },
              );
            }),
          )
        ],
      ),
    );
  }

  Widget _coachCard(Coach coach, DateTime date) {
    final schedules = coach.schedules?.where((s) {
      final sDate = DateTime.tryParse(s.date ?? '');
      return sDate != null &&
          sDate.year == date.year &&
          sDate.month == date.month &&
          sDate.day == date.day;
    }).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.network(
                  coach.user?.photo_url ?? '',
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(Icons.person, size: 48),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${coach.user?.name ?? ''} ${coach.user?.lastname ?? ''}',
                      style: GoogleFonts.roboto(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          color: almostBlack),
                    ),
                    Text(
                      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (schedules != null && schedules.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: schedules.map((s) {
                return ActionChip(
                  onPressed: () {
                    Get.snackbar(
                        'Coach ID: ${coach.id}', 'Horario: ${s.start_time}');
                    con.goToUserCoachReservePage();
                  },
                  label: Text(
                      '${_formatTime(s.start_time)} - ${_formatTime(s.end_time)}'),
                  backgroundColor: color_background_box,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(String? time) {
    if (time == null) return '';
    final parts = time.split(':');
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }
}
