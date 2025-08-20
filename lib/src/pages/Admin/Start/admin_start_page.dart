import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../widgets/no_data_widget.dart';
import 'admin_start_controller.dart';

class AdminStartPage extends StatelessWidget {
  final AdminStartController con = Get.put(AdminStartController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (con.coaches.isEmpty) {
        return Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NoDataWidget(text: 'No hay Horarios disponibles'),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 125),
                child: LinearProgressIndicator(
                  color: almostBlack,
                  backgroundColor: color_background_box,
                ),
              ),
            ],
          ),
        );
      }

      return DefaultTabController(
        length: con.coaches.length,
        child: Scaffold(
          appBar: AppBar(
            title: _appBarTitle(),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: TabBar(
                isScrollable: true,
                indicatorColor: almostBlack,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.black54,
                tabs: List.generate(
                  con.coaches.length,
                  (index) => Tab(
                    child: Text(con.coaches[index].user?.name ?? ''),
                  ),
                ),
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: TabBarView(
              children: con.coaches.map((coach) {
                final coachId = coach.id!;
                final selectedDate =
                    con.selectedDatePerCoach[coachId]?.value ?? con.today;
                final students =
                    con.getStudentsByCoachAndDate(coachId, selectedDate);

                return Column(
                  children: [
                    _dateSelector(con, coachId),
                    Expanded(
                      child: students.isEmpty
                          ? NoDataWidget(text: 'No hay estudiantes inscritos')
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 20),
                              itemCount: students.length,
                              itemBuilder: (_, index) {
                                final s = students[index];
                                final timeFormatted =
                                    s.classTime.substring(0, 5);
                                final key = con.getStudentKey(s);

                                return Obx(() {
                                  final isPresent =
                                      con.attendanceMap[key]?.value ?? false;

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(s.photo_url ?? ''),
                                        radius: 22,
                                      ),
                                      title: Text(s.studentName),
                                      subtitle: Text(
                                          'Hora: $timeFormatted\nMáquina: ${s.bicycle}'),
                                      trailing: Checkbox(
                                        value: isPresent,
                                        onChanged: (value) {
                                          con.attendanceMap[key]?.value =
                                              value!;
                                        },
                                      ),
                                    ),
                                  );
                                });
                              },
                            ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          floatingActionButton: _buttonRegister(),
        ),
      );
    });
  }

  Widget _appBarTitle() {
    return Text(
      'Administrador',
      style: GoogleFonts.montserrat(
        fontSize: 22,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _dateSelector(AdminStartController con, String coachId) {
    final dates = con.generateDateRange();

    return Obx(() {
      final selectedDate =
          (con.selectedDatePerCoach[coachId])?.value ?? con.today;

      return SizedBox(
        height: 72,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: dates.length,
          itemBuilder: (_, index) {
            final date = dates[index];
            final isSelected = DateFormat('yyyy-MM-dd').format(date) ==
                DateFormat('yyyy-MM-dd').format(selectedDate);

            return GestureDetector(
              onTap: () => con.selectDateForCoach(coachId, date),
              child: Container(
                width: 80,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected ? almostBlack : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat.E('es_ES').format(date),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      date.day.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buttonRegister() {
    return FloatingActionButton.extended(
      label: Text('Registrar'),
      backgroundColor: almostBlack,
      foregroundColor: whiteLight,
      onPressed: () {
        con.registerAllAttendances();
      },
    );
  }
}
