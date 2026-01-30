import 'package:amina_ec/src/pages/Admin/Reports/Class/Block/admin_edit_class_page.dart';
import 'package:amina_ec/src/pages/Admin/Reports/Class/Reassign/admin_change_coach_page.dart';
import 'package:amina_ec/src/pages/Admin/Reports/Class/Schedule/admin_edit_schedule_class_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../../../models/coach.dart';
import '../../../../../utils/color.dart';
import '../../../../../widgets/no_data_widget.dart';

class AdminCoachSchedulePage extends StatelessWidget {
  AdminCoachSchedulePage({super.key});

  final AdminCoachScheduleController con =
      Get.isRegistered<AdminCoachScheduleController>()
          ? Get.find<AdminCoachScheduleController>()
          : Get.put(AdminCoachScheduleController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteLight,
      body: RefreshIndicator(
        color: indigoAmina,
        onRefresh: () async {
          await con.loadCoaches(); // recarga toda la info de clases
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    // ✅ IMPORTANTE:
                    // El calendario usa Rx (trigger + datasource), así que debe estar en Obx.
                    child: Obx(() {
                      return SfCalendar(
                        key: ValueKey(con.calendarRefreshTrigger.value),
                        view: CalendarView.month,
                        dataSource: con.calendarDataSource.value,
                        onTap: (details) {
                          if (details.date != null)
                            con.selectDate(details.date!);
                        },
                        todayHighlightColor: indigoAmina,
                        headerStyle: CalendarHeaderStyle(
                          textAlign: TextAlign.center,
                          backgroundColor: indigoAmina,
                          textStyle: const TextStyle(color: whiteLight),
                        ),
                      );
                    }),
                  ),
                ),
              ),

              // Lista de coaches filtrados por fecha
              Obx(() {
                if (con.filteredCoaches.isEmpty) {
                  return const NoDataWidget(text: "No hay clases ese día");
                }

                return Column(
                  children: con.filteredCoaches
                      .map((coach) => _coachCard(coach))
                      .toList(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _coachCard(Coach coach) {
    final schedules = coach.schedules.where((s) {
      final d = con.selectedDate.value;
      final date = DateTime.tryParse(s.date ?? '');
      return date != null &&
          date.year == d.year &&
          date.month == d.month &&
          date.day == d.day;
    }).toList()
      ..sort((a, b) => (a.start_time ?? '').compareTo(b.start_time ?? ''));

    return Column(
      children: schedules.map((s) {
        final time = s.start_time?.substring(0, 5) ?? '--:--';
        final theme =
            (s.class_theme?.isNotEmpty == true) ? s.class_theme! : 'Clase';

        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
          title: Text(
            'Rueda con ${coach.user?.name ?? ''}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text('$time  |  $theme'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Get.bottomSheet(
              Wrap(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: const Text('Bloquear bicicletas'),
                    onTap: () {
                      Get.back();
                      Get.to(() => AdminCoachBlockPage(), arguments: {
                        'coach_id': coach.id,
                        'coach_name': coach.user?.name,
                        'class_date': s.date,
                        'class_time': s.start_time,
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.swap_horiz),
                    title: const Text('Cambiar coach'),
                    onTap: () {
                      Get.back();
                      Get.to(() => AdminChangeCoachPage(), arguments: {
                        'coach_id': coach.id,
                        'coach_name': coach.user?.name,
                        'class_date': s.date,
                        'class_time': s.start_time,
                      });
                    },
                  ),
                ],
              ),
              backgroundColor: Colors.white,
            );
          },
        );
      }).toList(),
    );
  }
}
