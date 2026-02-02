import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../pages/Admin/Start/admin_start_controller.dart';
import '../models/student_inscription.dart';

class StudentAttendanceTile extends StatelessWidget {
  final StudentInscription student;
  final RxBool isPresent;

  const StudentAttendanceTile({
    super.key,
    required this.student,
    required this.isPresent,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final photo = (student.photo_url ?? '').trim();

      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: CircleAvatar(
          radius: 24,

          backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
          child: photo.isEmpty ? const Icon(Icons.person) : null,
        ),
        title: Text(
          student.studentName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Hora: ${student.classTime.substring(0, 5)}  | Máquina: ${student.bicycle} | Rides Completados: ${student.ridesCompleted}',
          style: const TextStyle(fontSize: 13),
        ),


        trailing: Checkbox(
          value: isPresent.value,
          onChanged: (value) => isPresent.value = value ?? false,
        ),
      );
    });
  }
}

class StudentAttendanceCard extends StatelessWidget {
  final AdminStartController con = Get.find();
  final String coachId;
  final DateTime date;

  StudentAttendanceCard({
    super.key,
    required this.coachId,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ PUNTO 5: envolver el contenido en Obx para que se reconstruya
    // cuando cambie studentMap[coachId] / list.refresh() / loadStudents()
    return Obx(() {
      // 👇 Esto “ancla” la dependencia reactiva al RxList del coach
      // (si el coach todavía no existe en el mapa, solo será 0 y no rompe)
      final _ = con.studentMap[coachId]?.length ?? 0;

      final groupedStudents = con.groupStudentsByTime(coachId, date);

      if (groupedStudents.isEmpty) {
        return const Center(
          child: Text('No hay estudiantes para esta fecha'),
        );
      }

      return ListView(
        children: groupedStudents.entries.map((entry) {
          final classTime = entry.key;
          final students = entry.value;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: Column(
              children: [
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    'Hora: $classTime',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: almostBlack,
                    ),
                  ),
                ),
                ...students.map((s) {
                  // Obtenemos el RxBool observable para este estudiante
                  final key = con.getStudentKey(s);
                  final isPresent =
                  con.attendanceMap.putIfAbsent(key, () => false.obs);

                  return StudentAttendanceTile(
                    student: s,
                    isPresent: isPresent,
                  );
                }).toList(),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: ElevatedButton(
                    style: const ButtonStyle(
                      backgroundColor:
                      WidgetStatePropertyAll<Color>(almostBlack),
                    ),
                    onPressed: () =>
                        con.confirmRegisterGroup(coachId, date, classTime),
                    child: Text(
                      'Registrar asistencia $classTime',
                      style: TextStyle(color: whiteLight),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    });
  }
}
