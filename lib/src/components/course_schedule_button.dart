import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:amina_ec/src/models/schedule.dart';

class CourseScheduleButton extends StatelessWidget {
  final RxList<Schedule> schedules;
  const CourseScheduleButton({super.key, required this.schedules});
  @override
  Widget build(BuildContext context) => IconButton(
        icon: const Icon(Icons.school_outlined),
        tooltip: 'Tipos de clase: regular o curso',
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          builder: (sheetContext) => SafeArea(
              child: SizedBox(
            height: MediaQuery.of(sheetContext).size.height * .7,
            child: Column(children: [
              ListTile(
                  title: const Text('Clases regulares y cursos'),
                  subtitle: const Text(
                      'Activa Curso en los horarios exclusivos. Los cambios se guardan con el formulario del coach.'),
                  trailing: IconButton(
                      tooltip: 'Cerrar',
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(sheetContext))),
              Expanded(
                  child: Obx(() => schedules.isEmpty
                      ? const Center(child: Text('Primero añade un horario.'))
                      : ListView.builder(
                          key: const PageStorageKey('course-schedule-options'),
                          itemCount: schedules.length,
                          itemBuilder: (_, index) {
                            final schedule = schedules[index];
                            return SwitchListTile(
                              title: Text(
                                  '${schedule.date} · ${schedule.start_time}'),
                              subtitle: Text(
                                  '${schedule.class_theme} · ${schedule.isCourse ? "Curso" : "Regular"}'),
                              value: schedule.isCourse,
                              onChanged: (value) {
                                schedule.is_course = value ? 1 : 0;
                                schedules[index] = schedule;
                              },
                            );
                          },
                        ))),
            ]),
          )),
        ),
      );
}
