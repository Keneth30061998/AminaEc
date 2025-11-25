import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/student_inscription.dart';


class StudentAttendanceTile extends StatelessWidget {
  final RxBool isPresent;
  final StudentInscription student;

  const StudentAttendanceTile({
    super.key,
    required this.isPresent,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(student.photo_url ?? ''),
      ),
      title: Text(
        student.studentName,
        style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        'Hora: ${student.classTime.substring(0, 5)}  | Máquina: ${student.bicycle}',
        style: const TextStyle(fontSize: 13),
      ),
      trailing: Checkbox(
        value: isPresent.value,
        onChanged: (val) => isPresent.value = val ?? false,
      ),
    ));
  }
}
