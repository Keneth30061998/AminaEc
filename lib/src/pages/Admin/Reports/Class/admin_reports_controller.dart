import 'package:amina_ec/src/models/attendance_result.dart';
import 'package:amina_ec/src/providers/attendance_provider.dart';
import 'package:get/get.dart';

class AdminReportsController extends GetxController {
  final name = ''.obs;
  final selectedYear = ''.obs;
  final selectedMonth = ''.obs;

  final List<String> years = List.generate(6, (i) => (2025 + i).toString());
  final List<String> months = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  final attendanceResults = <AttendanceResult>[].obs;
  final presentCount = 0.obs;
  final absentCount = 0.obs;

  final AttendanceProvider _provider = AttendanceProvider();

  void buscar() async {
  String? monthParam;
  if (selectedMonth.value.isNotEmpty) {
    final idx = months.indexOf(selectedMonth.value);
    if (idx >= 0) {
      monthParam = (idx + 1).toString(); // Enero → 1, Febrero → 2...
    }
  }

  String? yearParam =
      selectedYear.value.isNotEmpty ? selectedYear.value : null;
  String? usernameParam =
      name.value.trim().isNotEmpty ? name.value.trim() : null;

  final results = await _provider.findByFilters(
    username: usernameParam,
    year: yearParam,
    month: monthParam,
  );

  attendanceResults.value = results;

  presentCount.value = results.where((r) => r.status == 'present').length;
  absentCount.value = results.where((r) => r.status == 'absent').length;
}

}