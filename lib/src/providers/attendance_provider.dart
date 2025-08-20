import 'dart:convert';

import 'package:amina_ec/src/environment/environment.dart';
import 'package:amina_ec/src/models/attendance_result.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../models/attendance.dart';
import '../models/response_api.dart';
import '../models/user.dart';

class AttendanceProvider extends GetConnect {
  final String url =
      Environment.API_URL + 'api/attendance'; // ← usa tu ruta actual
  final User userSession = User.fromJson(GetStorage().read('user') ?? {});

  Future<ResponseApi> registerAttendance(Attendance attendance) async {
    final Response response = await post(
      '${url}/record',
      attendance.toJson(),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': userSession.session_token ?? ''
      },
    );

    if (response.body == null) {
      Get.snackbar('Error', 'No se pudo registrar la asistencia');
      return ResponseApi(success: false, message: 'Sin respuesta del servidor');
    }

    if (response.statusCode == 401) {
      Get.snackbar('Error', 'No está autorizado para registrar asistencia');
      return ResponseApi(success: false, message: 'No autorizado');
    }

    // 🔍 Manejo defensivo del tipo de respuesta
    dynamic body = response.body;
    if (body is String) {
      try {
        body = json.decode(body);
      } catch (_) {
        return ResponseApi(success: false, message: 'Respuesta inválida');
      }
    }

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
}) async {
  final Map<String, String> queryParams = {};

  if (username != null && username.trim().isNotEmpty) {
    queryParams['username'] = username.trim();
  }
  if (year != null && year.trim().isNotEmpty) {
    queryParams['class_year'] = year.trim();
  }
  if (month != null && month.trim().isNotEmpty) {
    queryParams['class_month'] = month.trim();
  }

  print('➡️ GET: $url/users?${Uri(queryParameters: queryParams).query}');

  final response = await get(
    '$url/users',
    query: queryParams,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': userSession.session_token ?? ''
    },
  );

  if (response.statusCode != 200 && response.statusCode != 201) {
    print('❌ Error: ${response.body}');
    Get.snackbar('Error', 'No se pudo obtener los datos');
    return [];
  }

  dynamic body = response.body;
  if (body is String) {
    try {
      body = json.decode(body);
    } catch (e) {
      print('❌ JSON inválido: $e');
      return [];
    }
  }

  final List<dynamic> data = body['data'] ?? [];
  return data.map((e) => AttendanceResult.fromJson(e)).toList();
}


}
