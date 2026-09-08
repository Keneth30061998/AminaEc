import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'admin_start_controller.dart';
import '../Shared/admin_ui.dart';
import '../../../widgets/student_attendance_card.dart';

class AdminStartPage extends StatelessWidget {
  final AdminStartController con = Get.isRegistered<AdminStartController>()
      ? Get.find<AdminStartController>()
      : Get.put(AdminStartController());
  AdminStartPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar:
            const AdminHeader(title: 'Asistencia', subtitle: 'Administrador'),
        body: Obx(() {
          final coaches = con.coaches;
          final selectedId = con.selectedCoachId.value;
          if (coaches.isEmpty) {
            return Center(
                child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      if (con.isLoading.value)
                        const CircularProgressIndicator()
                      else ...[
                        Text(
                            con.loadError.value ??
                                'No hay horarios disponibles.',
                            textAlign: TextAlign.center),
                        TextButton(
                            onPressed: con.refreshAll,
                            child: const Text('Actualizar')),
                      ],
                    ])));
          }
          final coachIndex = coaches.indexWhere((c) => c.id == selectedId);
          final active = coachIndex < 0 ? 0 : coachIndex;
          return Column(children: [
            if (con.loadError.value != null)
              MaterialBanner(content: Text(con.loadError.value!), actions: [
                TextButton(
                    onPressed: con.refreshAll, child: const Text('Reintentar'))
              ]),
            SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                    children: coaches
                        .map((coach) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                  label: Text(coach.user?.name ?? 'Coach'),
                                  selected: coach.id == coaches[active].id,
                                  selectedColor: AdminUi.surface,
                                  showCheckmark: false,
                                  onSelected: (_) {
                                    if (coach.id != null)
                                      con.selectCoach(coach.id!);
                                  }),
                            ))
                        .toList())),
            const SizedBox(height: 12),
            Expanded(
                child: IndexedStack(
                    index: active,
                    sizing: StackFit.expand,
                    children: coaches.map((coach) {
                      final id = coach.id;
                      if (id == null) return const SizedBox.shrink();
                      return Column(key: ValueKey('attendance-$id'), children: [
                        _dates(id),
                        const SizedBox(height: 8),
                        Expanded(
                            child: RefreshIndicator(
                                onRefresh: con.refreshAll,
                                child: Obx(() => StudentAttendanceCard(
                                    key: PageStorageKey(
                                        'attendance-$id-${con.selectedDatePerCoach[id]?.value}'),
                                    coachId: id,
                                    date: con.selectedDatePerCoach[id]?.value ??
                                        con.today)))),
                      ]);
                    }).toList())),
          ]);
        }),
      );

  Widget _dates(String coachId) => Obx(() {
        final selected = con.selectedDatePerCoach[coachId]?.value ?? con.today;
        final dates = con.generateDateRange();
        return SizedBox(
            height: 80,
            child: ListView.separated(
              key: PageStorageKey('dates-$coachId'),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: dates.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final date = dates[i];
                final active = DateUtils.isSameDay(date, selected);
                return Semantics(
                  selected: active,
                  button: true,
                  label: DateFormat('EEEE d MMMM', 'es_ES').format(date),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => con.selectDateForCoach(coachId, date),
                    child: Container(
                      width: 66,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: active ? AdminUi.ink : AdminUi.surface,
                          borderRadius: BorderRadius.circular(14)),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                DateFormat.E('es_ES')
                                    .format(date)
                                    .toUpperCase(),
                                style: TextStyle(
                                    fontSize: 11,
                                    color: active
                                        ? Colors.white70
                                        : AdminUi.muted)),
                            const SizedBox(height: 4),
                            Text(date.day.toString().padLeft(2, '0'),
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color:
                                        active ? Colors.white : AdminUi.ink)),
                          ]),
                    ),
                  ),
                );
              },
            ));
      });
}
