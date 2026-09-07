import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../../../../models/coach.dart';
import '../../../../../models/schedule.dart';
import '../../../Shared/admin_ui.dart';
import '../Block/admin_edit_class_page.dart';
import 'admin_edit_schedule_class_controller.dart';

class AdminCoachSchedulePage extends StatelessWidget {
  AdminCoachSchedulePage({super.key});
  final AdminCoachScheduleController con =
      Get.isRegistered<AdminCoachScheduleController>()
          ? Get.find<AdminCoachScheduleController>()
          : Get.put(AdminCoachScheduleController());

  Map<String, dynamic> _arguments(Coach coach, Schedule s) => {
        'coach_id': coach.id,
        'coach_name': coach.user?.name,
        'class_date': s.date,
        'class_time': s.start_time,
        'schedule_id': s.id,
        'class_theme': s.class_theme,
      };
  Future<void> _open(Coach coach, Schedule s) async {
    await Get.to(() => AdminStyled(child: AdminCoachBlockPage()),
        routeName: '/admin/classes/detail', arguments: _arguments(coach, s));
    await con.loadCoaches();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const AdminHeader(
            title: 'Clases', subtitle: 'Elige una fecha y abre una clase'),
        body: RefreshIndicator(
            onRefresh: con.loadCoaches,
            child: ListView(
                key: const PageStorageKey('admin-calendar-list'),
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: SizedBox(
                          height: 340,
                          child: Obx(() => SfCalendar(
                                controller: con.calendarController,
                                view: CalendarView.month,
                                firstDayOfWeek: 1,
                                dataSource: con.calendarDataSource.value,
                                onTap: (details) {
                                  if (details.date != null)
                                    con.selectDate(details.date!);
                                },
                                todayHighlightColor: AdminUi.indigo,
                                headerStyle: const CalendarHeaderStyle(
                                    textAlign: TextAlign.center,
                                    backgroundColor: AdminUi.indigo,
                                    textStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700)),
                              )))),
                  const SizedBox(height: 18),
                  Obx(() => Text(
                      DateFormat('EEEE, d MMMM', 'es_ES')
                          .format(con.selectedDate.value),
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w800))),
                  const SizedBox(height: 12),
                  Obx(() {
                    if (con.loading.value && con.allCoaches.isEmpty)
                      return const Center(child: CircularProgressIndicator());
                    if (con.error.value != null)
                      return Column(children: [
                        Text(con.error.value!),
                        TextButton(
                            onPressed: con.loadCoaches,
                            child: const Text('Reintentar'))
                      ]);
                    final entries = <({Coach coach, Schedule schedule})>[];
                    for (final coach in con.filteredCoaches) {
                      for (final s in coach.schedules) {
                        if (DateUtils.isSameDay(DateTime.tryParse(s.date ?? ''),
                            con.selectedDate.value)) {
                          entries.add((coach: coach, schedule: s));
                        }
                      }
                    }
                    entries.sort((a, b) => (a.schedule.start_time ?? '')
                        .compareTo(b.schedule.start_time ?? ''));
                    if (entries.isEmpty)
                      return const Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('No hay clases ese día.'));
                    return Column(
                        children: entries
                            .map((e) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Material(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: const BorderSide(
                                          color: AdminUi.border)),
                                  child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                      leading: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                              color: AdminUi.surface,
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          child: Text(
                                              _time(e.schedule.start_time),
                                              style: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.w800))),
                                      title: Text(
                                          'Rueda con ${e.coach.user?.name ?? 'Coach'}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700)),
                                      subtitle: Text(
                                          '${e.schedule.class_theme ?? 'Clase'} · Ver detalle'),
                                      trailing: const Icon(Icons.chevron_right),
                                      onTap: () => _open(e.coach, e.schedule)),
                                )))
                            .toList());
                  }),
                ])),
      );
}

String _time(String? value) {
  final raw = value ?? '--:--';
  return raw.length > 5 ? raw.substring(0, 5) : raw;
}
