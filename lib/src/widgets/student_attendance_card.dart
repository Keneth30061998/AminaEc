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
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(student.photo_url ?? ''),
        ),
        title: Text(
          student.studentName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Hora: ${student.classTime.substring(0, 5)}  | Máquina: ${student.bicycle}',
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
    final groupedStudents = con.groupStudentsByTime(coachId, date);

    return ListView(
      children: groupedStudents.entries.map((entry) {
        final classTime = entry.key;
        final students = entry.value;

        return Card(
          margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  'Hora: $classTime',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: almostBlack),
                ),
              ),
              ...students.map((s) {
                // Obtenemos el RxBool observable para este estudiante
                final key = con.getStudentKey(s);
                final isPresent = con.attendanceMap.putIfAbsent(key, () => false.obs);

                return StudentAttendanceTile(
                  student: s,
                  isPresent: isPresent,
                );
              }).toList(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll<Color>(almostBlack)
                  ),
                  onPressed: () => con.confirmRegisterGroup(coachId, date, classTime),
                  child: Text('Registrar asistencia $classTime', style: TextStyle(color: whiteLight),),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
