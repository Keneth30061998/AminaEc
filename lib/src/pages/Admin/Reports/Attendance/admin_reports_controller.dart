import 'package:amina_ec/src/models/attendance_result.dart';
import 'package:amina_ec/src/providers/attendance_provider.dart';
import 'package:get/get.dart';

class AdminReportsController extends GetxController {
  final name = ''.obs;
  final selectedYear = ''.obs;
  final selectedMonth = ''.obs;
  final selectedDay = ''.obs;
  final startHour = ''.obs;
  final endHour = ''.obs;

  final List<String> years = List.generate(6, (i) => (2025 + i).toString());
  final List<String> months = ['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];
  final List<String> days = List.generate(31, (i) => (i + 1).toString());
  final List<String> hours = List.generate(24, (i) => i.toString().padLeft(2,'0') + ':00');

  final attendanceResults = <AttendanceResult>[].obs;
  final presentCount = 0.obs;
  final absentCount = 0.obs;

  final AttendanceProvider _provider = AttendanceProvider();

  void buscar() async {
    final results = await _provider.findByFilters(
      username: name.value.trim().isNotEmpty ? name.value.trim() : null,
      year: selectedYear.value.isNotEmpty ? selectedYear.value : null,
      month: selectedMonth.value.isNotEmpty ? (months.indexOf(selectedMonth.value)+1).toString() : null,
      day: selectedDay.value.isNotEmpty ? selectedDay.value : null,
      startHour: startHour.value.isNotEmpty ? startHour.value : null,
      endHour: endHour.value.isNotEmpty ? endHour.value : null,
    );

    attendanceResults.value = results;
    presentCount.value = results.where((r) => r.status == 'present').length;
    absentCount.value = results.where((r) => r.status == 'absent').length;
  }
}
