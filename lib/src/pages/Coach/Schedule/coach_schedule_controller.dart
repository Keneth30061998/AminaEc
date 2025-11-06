import 'package:amina_ec/src/models/coach.dart';
import 'package:amina_ec/src/models/schedule.dart';
import 'package:amina_ec/src/models/user.dart';
import 'package:amina_ec/src/utils/color.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../providers/coachs_provider.dart';

class CoachScheduleController extends GetxController {
  final CoachProvider coachProvider = CoachProvider();
  final User userSession = User.fromJson(GetStorage().read('user') ?? {});

  Rx<Coach?> coach = Rx<Coach?>(null);

  Rx<DateTime> selectedDate = DateTime.now().obs;
  RxInt calendarRefreshTrigger = 0.obs;
  Rx<CoachScheduleDataSource> calendarDataSource = CoachScheduleDataSource([]).obs;

  @override
  void onInit() {
    super.onInit();
    loadCoachSchedules();
  }

  Future<void> loadCoachSchedules() async {
    final coaches = await coachProvider.getAll();
    coach.value = coaches.firstWhereOrNull((c) => c.id == userSession.id);

    if (coach.value != null) {
      _buildCalendarEvents();
    }
  }

  void _buildCalendarEvents() {
    final List<Appointment> appointments = [];

    for (final s in coach.value!.schedules) {
      if (s.date == null || s.start_time == null || s.end_time == null) continue;

      final start = DateTime.parse('${s.date} ${s.start_time}');
      final end = DateTime.parse('${s.date} ${s.end_time}');

      appointments.add(Appointment(
        startTime: start,
        endTime: end,
        subject: s.class_theme ?? 'Clase',
        color: indigoAmina, // Indigo
      ));
    }

    calendarDataSource.value = CoachScheduleDataSource(appointments);
    calendarRefreshTrigger.value++;
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
  }

  List<Schedule> get schedulesForSelectedDay {
    if (coach.value == null) return [];
    return coach.value!.schedules.where((s) {
      final d = DateTime.tryParse(s.date ?? '');
      final sel = selectedDate.value;
      return d != null && d.year == sel.year && d.month == sel.month && d.day == sel.day;
    }).toList()
      ..sort((a, b) =>
          DateTime.parse('${a.date} ${a.start_time}')
              .compareTo(DateTime.parse('${b.date} ${b.start_time}')));
  }
}

class CoachScheduleDataSource extends CalendarDataSource {
  CoachScheduleDataSource(List<Appointment> source) {
    appointments = source;
  }
}
