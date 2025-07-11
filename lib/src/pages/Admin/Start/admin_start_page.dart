import 'package:amina_ec/src/pages/Admin/Start/admin_start_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:amina_ec/src/utils/iconos.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/student_inscription.dart';
import '../../../widgets/no_data_widget.dart';

class AdminStartPage extends StatelessWidget {
  final AdminStartController con = Get.put(AdminStartController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => DefaultTabController(
          length: con.coaches.length,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Estudiantes por Coach'),
              bottom: TabBar(
                isScrollable: true,
                indicatorColor: almostBlack,
                labelColor: almostBlack,
                unselectedLabelColor: Colors.black,
                tabs: List<Widget>.generate(con.coaches.length, (index) {
                  return Tab(
                    child: Text(con.coaches[index].user?.name ?? ''),
                  );
                }),
              ),
            ),
            body: TabBarView(
              children: con.coaches.map((coach) {
                return FutureBuilder(
                    future: con.getStudents(coach.id!),
                    builder:
                        (_, AsyncSnapshot<List<StudentInscription>> snapshot) {
                      if (snapshot.hasData) {
                        final students = snapshot.data!;
                        if (students.isEmpty) {
                          return NoDataWidget(
                              text: 'No hay estudiantes inscritos');
                        }

                        // Agrupar por fecha y hora
                        final grouped = <String, List<StudentInscription>>{};
                        for (var s in students) {
                          final key = '${s.classDate} • ${s.classTime}';
                          grouped.putIfAbsent(key, () => []).add(s);
                        }

                        return ListView(
                          children: grouped.entries.map((entry) {
                            final parts = entry.key.split('•');
                            final rawDate = parts[0].trim();
                            final rawTime =
                                parts.length > 1 ? parts[1].trim() : '';

                            // ✅ Formato de fecha y hora
                            final formattedDate = DateTime.tryParse(rawDate);
                            final formattedTime = rawTime.length >= 5
                                ? rawTime.substring(0, 5)
                                : rawTime;

                            final readableDate = formattedDate != null
                                ? '${formattedDate.day.toString().padLeft(2, '0')}/${formattedDate.month.toString().padLeft(2, '0')}/${formattedDate.year}'
                                : rawDate;

                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Encabezado visual de fecha y hora
                                    Row(
                                      children: [
                                        const Icon(icon_schedule,
                                            size: 18, color: Colors.grey),
                                        const SizedBox(width: 6),
                                        Text(
                                          '$readableDate • $formattedTime',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    ...entry.value.map((student) {
                                      return ListTile(
                                        leading: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              student.photo_url ?? ''),
                                          radius: 22,
                                        ),
                                        title: Text(student.studentName),
                                        subtitle:
                                            Text('Máquina: ${student.bicycle}'),
                                        trailing: Checkbox(
                                          value: false,
                                          onChanged: (_) {},
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    });
              }).toList(),
            ),
          ),
        ));
  }
}
