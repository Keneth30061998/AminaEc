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
    print('📌 [AttendanceProvider] → Iniciando registerAttendance()');
    print('📤 Datos a enviar: ${attendance.toJson()}');
    print('🔑 Token usado: ${userSession.session_token}');

    final Response response = await post(
      '$url/record',
      attendance.toJson(),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': userSession.session_token ?? ''
      },
    );

    print('📥 Respuesta cruda: status=${response.statusCode}, body=${response.body}');

    if (response.body == null) {
      print('❌ Error: Respuesta nula del servidor');
      Get.snackbar('Error', 'No se pudo registrar la asistencia');
      return ResponseApi(success: false, message: 'Sin respuesta del servidor');
    }

    if (response.statusCode == 401) {
      print('❌ Error: No autorizado');
      Get.snackbar('Error', 'No está autorizado para registrar asistencia');
      return ResponseApi(success: false, message: 'No autorizado');
    }

    // 🔍 Manejo defensivo del tipo de respuesta
    dynamic body = response.body;
    if (body is String) {
      try {
        body = json.decode(body);
        print('✅ JSON decodificado correctamente');
      } catch (e) {
        print('❌ Error al decodificar JSON: $e');
        return ResponseApi(success: false, message: 'Respuesta inválida');
      }
    }

    final responseApi = ResponseApi.fromJson(body);
    print('📊 Respuesta parseada: success=${responseApi.success}, message=${responseApi.message}');

    if (responseApi.success == true) {
      print('✅ Asistencia registrada correctamente');
      Get.snackbar('✅ Éxito', responseApi.message ?? 'Asistencia registrada');
    } else {
      print('❌ Falló el registro: ${responseApi.message}');
      Get.snackbar('❌ Error', responseApi.message ?? 'Falló el registro');
    }

    return responseApi;
  }

  Future<List<AttendanceResult>> findByFilters({
    String? username,
    String? year,
    String? month,
  }) async {
    print('📌 [AttendanceProvider] → Iniciando findByFilters()');
    print('🔎 Filtros recibidos: username=$username, year=$year, month=$month');

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

    print('➡️ GET Request → $url/users con queryParams=$queryParams');

    final response = await get(
      '$url/users',
      query: queryParams,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': userSession.session_token ?? ''
      },
    );

    print('📥 Respuesta cruda: status=${response.statusCode}, body=${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      print('❌ Error: No se pudo obtener los datos');
      Get.snackbar('Error', 'No se pudo obtener los datos');
      return [];
    }

    dynamic body = response.body;
    if (body is String) {
      try {
        body = json.decode(body);
        print('✅ JSON decodificado correctamente en findByFilters');
      } catch (e) {
        print('❌ Error al decodificar JSON en findByFilters: $e');
        return [];
      }
    }

    final List<dynamic> data = body['data'] ?? [];
    print('📊 Cantidad de resultados obtenidos: ${data.length}');

    return data.map((e) {
      print('📌 Procesando registro: $e');
      return AttendanceResult.fromJson(e);
    }).toList();
  }
}
