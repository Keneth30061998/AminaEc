import 'dart:convert';
import 'package:amina_ec/src/environment/environment.dart';
import 'package:amina_ec/src/models/attendance_result.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/attendance.dart';
import '../models/response_api.dart';
import '../models/user.dart';

class AttendanceProvider extends GetConnect {
  final String url = '${Environment.API_URL}api/attendance';
  final User userSession = User.fromJson(GetStorage().read('user') ?? {});

  Future<ResponseApi> registerAttendance(Attendance attendance) async {
    final response = await post('$url/record', attendance.toJson(), headers: {
      'Content-Type': 'application/json',
      'Authorization': userSession.session_token ?? ''
    });

    if (response.body == null) return ResponseApi(success: false, message: 'Sin respuesta del servidor');

    dynamic body = response.body;
    if (body is String) body = json.decode(body);

    final responseApi = ResponseApi.fromJson(body);
    if (responseApi.success == true) {
      Get.snackbar('✅ Éxito', responseApi.message ?? 'Asistencia registrada');
    } else {
      Get.snackbar('❌ Error', responseApi.message ?? 'Falló el registro');
    }
    return responseApi;
  }

  Future<List<AttendanceResult>> findByFilters({
    String? username,
    String? year,
    String? month,
    String? day,
    String? startHour,
    String? endHour,
  }) async {
    final Map<String, String> queryParams = {};

    if (username != null && username.trim().isNotEmpty) queryParams['username'] = username.trim();
    if (year != null && year.trim().isNotEmpty) queryParams['class_year'] = year.trim();
    if (month != null && month.trim().isNotEmpty) queryParams['class_month'] = month.trim();
    if (day != null && day.trim().isNotEmpty) queryParams['class_day'] = day.trim();
    if (startHour != null && startHour.trim().isNotEmpty) queryParams['start_hour'] = startHour.trim();
    if (endHour != null && endHour.trim().isNotEmpty) queryParams['end_hour'] = endHour.trim();

    final response = await get('$url/users', query: queryParams, headers: {
      'Content-Type': 'application/json',
      'Authorization': userSession.session_token ?? ''
    });

    if (response.statusCode != 200 && response.statusCode != 201) return [];

    dynamic body = response.body;
    if (body is String) body = json.decode(body);

    final List<dynamic> data = body['data'] ?? [];
    return data.map((e) => AttendanceResult.fromJson(e)).toList();
  }
}
