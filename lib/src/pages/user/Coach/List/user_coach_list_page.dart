import 'package:amina_ec/src/pages/user/Coach/List/user_coach_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../models/coach.dart';
import '../../../../utils/color.dart';
import '../../../../widgets/no_data_widget.dart';

class UserCoachSchedulePage extends StatelessWidget {
  final UserCoachScheduleController con =
      Get.put(UserCoachScheduleController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteLight,
      appBar: AppBar(
        title: _textTitleAppBar(),
        backgroundColor: whiteLight,
        foregroundColor: almostBlack,
      ),
      body: Column(
        children: [
          _dateSelector(),
          Expanded(
            child: Obx(() {
              if (con.filteredCoaches.isEmpty) {
                return Center(
                    child:
                        NoDataWidget(text: 'No hay entrenadores disponibles'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: con.filteredCoaches.length,
                itemBuilder: (_, index) {
                  final coach = con.filteredCoaches[index];
                  return _coachCard(coach, con.selectedDate.value);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _textTitleAppBar() {
    return Text(
      'Agendar Ride',
      style: GoogleFonts.montserrat(
        fontSize: 22,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  // Este widget utiliza la base para generar siempre la lista desde el día real (actual)
  Widget _dateSelector() {
    // Calculamos el rango de días basado en la base (día real).
    final bd = con.baseDate.value;
    final dates = List.generate(con.daysToShow,
        (i) => DateTime(bd.year, bd.month, bd.day).add(Duration(days: i)));
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (_, index) {
          final date = dates[index];
          // Envolver cada tile en un Obx para que reconozca los cambios de selectedDate.
          return Obx(() {
            final selected = con.selectedDate.value;
            final isSelected = date.day == selected.day &&
                date.month == selected.month &&
                date.year == selected.year;
            return GestureDetector(
              onTap: () => con.selectDate(date),
              child: Container(
                width: 80,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected ? darkGrey : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat.E('es_ES').format(date),
                      style: TextStyle(
                        color: isSelected ? whiteLight : whiteGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      date.day.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? whiteLight : whiteGrey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _coachCard(Coach coach, DateTime date) {
    final schedules = coach.schedules?.where((s) {
      final day = DateFormat('EEEE', 'es_ES').format(date);
      return s.day?.toLowerCase().trim() == day.toLowerCase();
    }).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
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
                child: Text(
                  '${coach.user?.name ?? ''} ${coach.user?.lastname ?? ''}',
                  style: GoogleFonts.roboto(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: almostBlack),
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
                    Get.snackbar('Id: coach: ${coach.id}',
                        'Time: schedule: ${s.start_time}');
                    return con.goToUserCoachReservePage();
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
