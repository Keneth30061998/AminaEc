import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../pages/Admin/Start/admin_start_controller.dart';
import '../models/student_inscription.dart';

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
    return Obx(() {
      // anclar dependencia reactiva al RxList del coach
      final _ = con.studentMap[coachId]?.length ?? 0;

      final groupedStudents = con.groupStudentsByTime(coachId, date);

      if (groupedStudents.isEmpty) {
        return Center(
          child: Text(
            'No hay estudiantes para esta fecha',
            style: GoogleFonts.poppins(color: Colors.black54),
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 16),
        itemCount: groupedStudents.entries.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, index) {
          final entry = groupedStudents.entries.elementAt(index);
          final classTime = entry.key;
          final students = entry.value;

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.black.withOpacity(.06)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.04),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorBackgroundBox,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.black.withOpacity(.06)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.schedule_rounded, size: 16, color: almostBlack),
                            const SizedBox(width: 6),
                            Text(
                              classTime,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                color: almostBlack,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.black.withOpacity(.08)),
                        ),
                        child: Text(
                          '${students.length} ${students.length == 1 ? "alumno" : "alumnos"}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(height: 1, color: Colors.black.withOpacity(.06)),

                // Students list
                ...students.map((s) {
                  final key = con.getStudentKey(s, coachId);
                  final isPresent = con.attendanceMap.putIfAbsent(key, () => false.obs);

                  return Column(
                    children: [
                      StudentAttendanceTile(
                        student: s,
                        isPresent: isPresent,
                      ),
                      Divider(height: 1, color: Colors.black.withOpacity(.06)),
                    ],
                  );
                }).toList(),

                // Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: almostBlack,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => con.confirmRegisterGroup(coachId, date, classTime),
                      child: Text(
                        'Registrar asistencia',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}

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
      final hasPhoto = photo.isNotEmpty;

      return ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: colorBackgroundBox,
          backgroundImage: hasPhoto ? NetworkImage(photo) : null,
          child: !hasPhoto
              ? const Icon(Icons.person_rounded, color: Colors.black54)
              : null,
        ),
        title: Text(
          student.studentName,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: almostBlack,
            fontSize: 13.8,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            'Máquina: ${student.bicycle}  •  Rides: ${student.ridesCompleted}',
            style: GoogleFonts.poppins(
              fontSize: 12.2,
              color: Colors.black54,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        trailing: Transform.scale(
          scale: 1.05,
          child: Checkbox(
            value: isPresent.value,
            onChanged: (value) => isPresent.value = value ?? false,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            activeColor: almostBlack,
          ),
        ),
      );
    });
  }
}
