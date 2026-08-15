import 'dart:convert';

import 'package:amina_ec/src/environment/environment.dart';
import 'package:amina_ec/src/models/class_reservation.dart';
import 'package:amina_ec/src/models/response_api.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../models/student_inscription.dart';

class ClassReservationProvider {
  final String _baseUrl = Environment.API_URL;

  /// Usuario autenticado guardado en GetStorage.
  Map<String, dynamic> get _user => GetStorage().read('user') ?? {};

  // ============================================================
  // DEBUG
  // ============================================================

  void _debugPrintHeader(String title) {
    print('\n====================================================');
    print('🔍 $title');
    print('====================================================');
  }

  // ============================================================
  // AGENDAR CLASE
  // ============================================================

  /// Agenda una clase utilizando el mismo endpoint para usuario y admin.
  ///
  /// Usuario normal:
  /// - No envía [targetUserId].
  /// - Se utiliza automáticamente el usuario autenticado.
  ///
  /// Administrador:
  /// - Envía el ID del usuario seleccionado en [targetUserId].
  /// - El backend valida que quien agenda para otra persona sea admin.
  Future<ResponseApi> scheduleClass({
    required String coachId,
    required int bicycle,
    required String classDate,
    required String classTime,
    String? targetUserId,
  }) async {
    _debugPrintHeader('API: scheduleClass');

    final headers = _headers;
    final url = '${_baseUrl}api/class-reservations/schedule';

    final selectedUserId =
    targetUserId != null && targetUserId.trim().isNotEmpty
        ? targetUserId.trim()
        : (_user['id'] ?? '').toString();

    final body = {
      'user_id': selectedUserId,
      'coach_id': coachId,
      'bicycle': bicycle,
      'class_date': classDate,
      'class_time': _normalizeTime(classTime),
    };

    print('➡️ POST: $url');
    print('📦 Body enviado: $body');
    print('📨 Headers: $headers');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      print('🌐 StatusCode: ${response.statusCode}');
      print('🌐 Raw response: ${response.body}');

      return _responseApiFromHttp(
        response,
        emptyMessage: 'El servidor no devolvió información al agendar.',
      );
    } catch (error) {
      print('❌ ERROR scheduleClass: $error');

      return ResponseApi(
        success: false,
        message: 'Error al agendar la clase: $error',
      );
    }
  }

  // ============================================================
  // RESERVACIONES POR HORARIO
  // ============================================================

  /// Obtiene las bicicletas ocupadas y bloqueadas de una clase.
  ///
  /// Si el token pertenece a un administrador, el backend también devuelve
  /// nombre, correo, foto, user_id y plan_id del usuario asignado.
  Future<List<ClassReservation>> getReservationsForSlot({
    required String classDate,
    required String classTime,
  }) async {
    _debugPrintHeader('API: getReservationsForSlot');

    final headers = _headers;
    final url = '${_baseUrl}api/class-reservations/by-slot';
    final body = {
      'class_date': classDate,
      'class_time': _normalizeTime(classTime),
    };

    print('➡️ POST: $url');
    print('📦 Body enviado: $body');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      print('🌐 StatusCode: ${response.statusCode}');
      print('🌐 Respuesta: ${response.body}');

      if (response.body.isEmpty) {
        print('⚠️ Body vacío');
        return [];
      }

      final dynamic decoded = json.decode(response.body);

      if (decoded is! Map<String, dynamic>) {
        print('⚠️ Respuesta inesperada');
        return [];
      }

      if (decoded['success'] == true && decoded['data'] is List) {
        return (decoded['data'] as List)
            .whereType<Map>()
            .map(
              (item) => ClassReservation.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
            .toList();
      }
    } catch (error) {
      print('❌ ERROR getReservationsForSlot: $error');
    }

    print('⚠️ Retornando lista vacía');
    return [];
  }

  // ============================================================
  // ESTUDIANTES POR COACH
  // ============================================================

  Future<List<StudentInscription>> getStudentsByCoach(
      String coachId,
      ) async {
    _debugPrintHeader('API: getStudentsByCoach');

    final headers = _headers;
    final url = '${_baseUrl}api/class-reservations/coach/$coachId';

    print('➡️ GET: $url');
    print('📨 Headers: $headers');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('🌐 StatusCode: ${response.statusCode}');
      print('🌐 Body RAW: ${response.body}');

      if (response.body.isEmpty) {
        print('❌ ERROR: Body vacío');
        return [];
      }

      final dynamic decoded = json.decode(response.body);

      if (decoded is! Map<String, dynamic> || decoded['success'] != true) {
        print('⚠️ success=false o respuesta inesperada');
        return [];
      }

      final data = decoded['data'];

      if (data is! List) {
        return [];
      }

      return data
          .whereType<Map>()
          .map(
            (item) => StudentInscription.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();
    } catch (error) {
      print('❌ ERROR getStudentsByCoach: $error');
      return [];
    }
  }

  // ============================================================
  // REAGENDAR CLASE
  // ============================================================

  Future<ResponseApi> rescheduleClass({
    required String reservationId,
    required String newDate,
    required String newTime,
    required String newCoachId,
    required int newBicycle,
  }) async {
    _debugPrintHeader('API: rescheduleClass');

    final url =
        '${_baseUrl}api/class-reservations/$reservationId/reschedule';

    final body = {
      'new_date': newDate,
      'new_time': _normalizeTime(newTime),
      'new_coach_id': newCoachId,
      'new_bicycle': newBicycle,
    };

    print('➡️ PUT: $url');
    print('📦 Body: $body');

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: _headers,
        body: json.encode(body),
      );

      print('🌐 Respuesta: ${response.body}');

      return _responseApiFromHttp(
        response,
        emptyMessage: 'El servidor no devolvió información al reagendar.',
      );
    } catch (error) {
      print('❌ ERROR rescheduleClass: $error');

      return ResponseApi(
        success: false,
        message: 'Error al reagendar clase: $error',
      );
    }
  }

  // ============================================================
  // DISPONIBILIDAD: FECHAS
  // ============================================================

  Future<List<String>> getAvailableDates({
    required String coachId,
  }) async {
    _debugPrintHeader('API: getAvailableDates');

    final url =
        '${_baseUrl}api/class-reservations/availability/dates/$coachId';

    print('➡️ GET: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );

      print('🌐 Response: ${response.body}');

      if (response.statusCode != 200 || response.body.isEmpty) {
        return [];
      }

      final dynamic decoded = json.decode(response.body);

      if (decoded is Map<String, dynamic> && decoded['data'] is List) {
        return List<String>.from(decoded['data']);
      }
    } catch (error) {
      print('❌ ERROR getAvailableDates: $error');
    }

    return [];
  }

  // ============================================================
  // DISPONIBILIDAD: HORAS
  // ============================================================

  Future<List<String>> getAvailableTimes({
    required String coachId,
    required String date,
  }) async {
    _debugPrintHeader('API: getAvailableTimes');

    final url =
        '${_baseUrl}api/class-reservations/availability/times/$coachId/$date';

    print('➡️ GET: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );

      print('🌐 Response: ${response.body}');

      if (response.statusCode != 200 || response.body.isEmpty) {
        return [];
      }

      final dynamic decoded = json.decode(response.body);

      if (decoded is Map<String, dynamic> && decoded['data'] is List) {
        return List<String>.from(decoded['data']);
      }
    } catch (error) {
      print('❌ ERROR getAvailableTimes: $error');
    }

    return [];
  }

  // ============================================================
  // DISPONIBILIDAD: BICICLETAS
  // ============================================================

  Future<List<int>> getAvailableBikes({
    required String coachId,
    required String date,
    required String time,
  }) async {
    _debugPrintHeader('API: getAvailableBikes');

    final cleanedTime = _normalizeTime(time);
    final url =
        '${_baseUrl}api/class-reservations/availability/bikes/'
        '$coachId/$date/$cleanedTime';

    print('➡️ GET: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );

      print('🌐 Response: ${response.body}');

      if (response.statusCode != 200 || response.body.isEmpty) {
        return [];
      }

      final dynamic decoded = json.decode(response.body);

      if (decoded is Map<String, dynamic> && decoded['data'] is List) {
        return (decoded['data'] as List)
            .map((item) => int.tryParse(item.toString()))
            .whereType<int>()
            .toList();
      }
    } catch (error) {
      print('❌ ERROR getAvailableBikes: $error');
    }

    return [];
  }

  // ============================================================
  // CANCELAR O REMOVER RESERVA
  // ============================================================

  /// Cancela una reserva utilizando el endpoint existente.
  ///
  /// Usuario normal:
  /// - No envía [returnRide].
  /// - El backend devuelve el ride automáticamente y aplica la regla de 12 h.
  ///
  /// Administrador:
  /// - Envía [returnRide] en true o false.
  /// - El backend omite la regla de 12 h y aplica la decisión indicada.
  Future<ResponseApi> cancelClass(
      String reservationId, {
        bool? returnRide,
      }) async {
    _debugPrintHeader('API: cancelClass');

    final url =
        '${_baseUrl}api/class-reservations/$reservationId/cancel';

    final Map<String, dynamic> body = {};

    if (returnRide != null) {
      body['return_ride'] = returnRide;
    }

    print('➡️ DELETE: $url');
    print('📦 Body: $body');

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: _headers,
        body: json.encode(body),
      );

      print('🌐 StatusCode: ${response.statusCode}');
      print('🌐 Response: ${response.body}');

      return _responseApiFromHttp(
        response,
        emptyMessage: 'El servidor no devolvió información al cancelar.',
      );
    } catch (error) {
      print('❌ ERROR cancelClass: $error');

      return ResponseApi(
        success: false,
        message: 'Error cancelando clase: $error',
      );
    }
  }

  // ============================================================
  // BLOQUEAR BICICLETA
  // ============================================================

  Future<ResponseApi> blockBike({
    required String coachId,
    required int bicycle,
    required String classDate,
    required String classTime,
  }) async {
    _debugPrintHeader('API: blockBike');

    final url = Uri.parse(
      '${_baseUrl}api/admin/class-reservations/block',
    );

    final body = {
      'coach_id': coachId,
      'bicycle': bicycle,
      'class_date': classDate,
      'class_time': _normalizeTime(classTime),
    };

    print('➡️ POST: $url');
    print('📦 Body: $body');

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: json.encode(body),
      );

      print('🌐 Response: ${response.body}');

      return _responseApiFromHttp(
        response,
        emptyMessage: 'El servidor no devolvió información al bloquear.',
      );
    } catch (error) {
      print('❌ ERROR blockBike: $error');

      return ResponseApi(
        success: false,
        message: 'Error al bloquear bicicleta: $error',
      );
    }
  }

  // ============================================================
  // DESBLOQUEAR BICICLETA
  // ============================================================

  Future<ResponseApi> unblockBike({
    required String coachId,
    required int bicycle,
    required String classDate,
    required String classTime,
  }) async {
    _debugPrintHeader('API: unblockBike');

    final cleanedTime = _normalizeTime(classTime);

    final url = Uri.parse(
      '${_baseUrl}api/admin/class-reservations/block'
          '?coach_id=$coachId'
          '&bicycle=$bicycle'
          '&class_date=$classDate'
          '&class_time=$cleanedTime',
    );

    print('➡️ DELETE: $url');

    try {
      final response = await http.delete(
        url,
        headers: _headers,
      );

      print('🌐 Response: ${response.body}');

      return _responseApiFromHttp(
        response,
        emptyMessage: 'El servidor no devolvió información al desbloquear.',
      );
    } catch (error) {
      print('❌ ERROR unblockBike: $error');

      return ResponseApi(
        success: false,
        message: 'Error al desbloquear bicicleta: $error',
      );
    }
  }

  // ============================================================
  // REASIGNAR COACH
  // ============================================================

  Future<ResponseApi> reassignCoach({
    required String oldCoachId,
    required String newCoachId,
    required String date,
    required String startTime,
    required String endTime,
  }) async {
    _debugPrintHeader('API: reassignCoach');

    final url =
        '${_baseUrl}api/admin/class-reservations/reassign-coach';

    final body = {
      'old_coach_id': oldCoachId,
      'new_coach_id': newCoachId,
      'date': date,
      'start_time': _normalizeTime(startTime),
      'end_time': _normalizeTime(endTime),
    };

    print('➡️ POST: $url');
    print('📦 Body: $body');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: json.encode(body),
      );

      print('🌐 Response: ${response.body}');

      return _responseApiFromHttp(
        response,
        emptyMessage: 'El servidor no devolvió información al reasignar.',
      );
    } catch (error) {
      print('❌ ERROR reassignCoach: $error');

      return ResponseApi(
        success: false,
        message: 'Error al reasignar coach: $error',
      );
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': (_user['session_token'] ?? '').toString(),
  };

  String _normalizeTime(String value) {
    return value.split('.').first;
  }

  ResponseApi _responseApiFromHttp(
      http.Response response, {
        required String emptyMessage,
      }) {
    if (response.body.isEmpty) {
      return ResponseApi(
        success: false,
        message: emptyMessage,
      );
    }

    try {
      final dynamic decoded = json.decode(response.body);

      if (decoded is Map<String, dynamic>) {
        return ResponseApi.fromJson(decoded);
      }

      return ResponseApi(
        success: false,
        message: 'Respuesta inesperada del servidor.',
      );
    } catch (error) {
      return ResponseApi(
        success: false,
        message: 'No se pudo interpretar la respuesta del servidor: $error',
      );
    }
  }
}
