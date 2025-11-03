import 'package:amina_ec/src/pages/Coach/Class/coach_class_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../widgets/no_data_widget.dart';

class CoachClassPage extends StatelessWidget {
  final CoachClassController con = Get.put(CoachClassController());

  CoachClassPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: _appBarTitle()),
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          children: [
            _dateSelector(con),
            Expanded(
              child: Obx(() {
                final students = con.getStudentsByDate(con.selectedDate.value);

                // 🔄 Agregamos RefreshIndicator para todos los casos
                return RefreshIndicator(
                  onRefresh: () async {
                    await con.loadStudents();
                    await Future.delayed(const Duration(milliseconds: 400));
                  },
                  color: almostBlack,
                  backgroundColor: Colors.white,
                  child: students.isEmpty
                      ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                          height:
                          MediaQuery.of(context).size.height * 0.3),
                      NoDataWidget(text: 'No hay estudiantes inscritos'),
                    ],
                  )
                      : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 20),
                    itemCount: students.length,
                    itemBuilder: (_, index) {
                      final s = students[index];
                      final timeFormatted = s.classTime.substring(0, 5);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                            NetworkImage(s.photo_url ?? ''),
                            radius: 22,
                          ),
                          title: Text(s.studentName),
                          subtitle: Text(
                            'Hora: $timeFormatted\nMáquina: ${s.bicycle}',
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _appBarTitle() {
    return Text(
      'Riders',
      style: GoogleFonts.montserrat(
        fontSize: 22,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _dateSelector(CoachClassController con) {
    final dates = con.generateDateRange();

    return Obx(() {
      final selectedDate = con.selectedDate.value;

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
              onTap: () => con.selectDate(date),
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
}
