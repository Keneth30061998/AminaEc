import 'dart:convert';
import 'package:amina_ec/src/environment/environment.dart';
import 'package:amina_ec/src/models/class_reservation.dart';
import 'package:amina_ec/src/models/response_api.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../models/student_inscription.dart';

class ClassReservationProvider {
  final String _baseUrl = Environment.API_URL;
  Map<String, dynamic> get _user => GetStorage().read('user') ?? {};

  // ============================================================
  // 🔵 DEBUG FUNCTION → Imprime cabecera completa
  void _debugPrintHeader(String title) {
    print("\n====================================================");
    print("🔍 $title");
    print("====================================================");
  }

  // ============================================================
  // 🔵 SCHEDULE CLASS
  Future<ResponseApi> scheduleClass({
    required String coachId,
    required int bicycle,
    required String classDate,
    required String classTime,
  }) async {

    _debugPrintHeader("API: scheduleClass");

    final headers = _headers;
    final url = '${_baseUrl}api/class-reservations/schedule';
    final body = {
      'user_id': _user['id'],
      'coach_id': coachId,
      'bicycle': bicycle,
      'class_date': classDate,
      'class_time': classTime,
    };

    print("➡️ POST: $url");
    print("📦 Body enviado: $body");
    print("📨 Headers: $headers");

    try {
      final res = await http.post(Uri.parse(url),
          headers: headers, body: json.encode(body));

      print("🌐 StatusCode: ${res.statusCode}");
      print("🌐 Raw response: ${res.body}");

      final data = json.decode(res.body);

      return ResponseApi.fromJson(data);

    } catch (e) {
      print("❌ ERROR scheduleClass: $e");
      return ResponseApi(success: false, message: 'Error: $e');
    }
  }

  // ============================================================
  // 🔵 GET RESERVATIONS FOR SLOT
  Future<List<ClassReservation>> getReservationsForSlot({
    required String classDate,
    required String classTime,
  }) async {

    _debugPrintHeader("API: getReservationsForSlot");

    final headers = _headers;
    final url = '${_baseUrl}api/class-reservations/by-slot';
    final body = {'class_date': classDate, 'class_time': classTime};

    print("➡️ POST: $url");
    print("📦 Body enviado: $body");

    try {
      final res = await http.post(Uri.parse(url),
          headers: headers, body: json.encode(body));

      print("🌐 StatusCode: ${res.statusCode}");
      print("🌐 Respuesta: ${res.body}");

      final data = json.decode(res.body);

      if (data['success'] == true && data['data'] != null) {
        return List<ClassReservation>.from(
            data['data'].map((r) => ClassReservation.fromJson(r)));
      }

    } catch (e) {
      print("❌ ERROR getReservationsForSlot: $e");
    }

    print("⚠️ Retornando lista vacía");
    return [];
  }

  // ============================================================
  // 🔥🔥 GET STUDENTS BY COACH — PRINCIPAL PARA DEBUG 🔥🔥
  Future<List<StudentInscription>> getStudentsByCoach(String coachId) async {

    _debugPrintHeader("API: getStudentsByCoach");

    final headers = _headers;
    final url = '${_baseUrl}api/class-reservations/coach/$coachId';

    print("➡️ GET: $url");
    print("📨 Headers: $headers");

    try {
      final res = await http.get(Uri.parse(url), headers: headers);

      print("🌐 StatusCode: ${res.statusCode}");
      print("🌐 Body RAW: ${res.body}");

      if (res.body.isEmpty) {
        print("❌ ERROR: Body vacío");
        return [];
      }

      dynamic data;

      try {
        data = json.decode(res.body);
      } catch (e) {
        print("❌ ERROR decodificando JSON: $e");
        return [];
      }

      print("📌 Parsed JSON: $data");

      if (data['success'] != true) {
        print("⚠️ success=false → devolviendo vacío");
        return [];
      }

      print("📥 Cantidad de estudiantes recibidos: ${data['data'].length}");

      return List<StudentInscription>.from(
        data['data'].map((e) {
          print("  ➕ Parseando estudiante: $e");
          return StudentInscription.fromJson(e);
        }),
      );

    } catch (e) {
      print("❌ ERROR getStudentsByCoach: $e");
      return [];
    }
  }

  // ============================================================
  // 🔵 RESCHEDULE CLASS
  Future<ResponseApi> rescheduleClass({
    required String reservationId,
    required String newDate,
    required String newTime,
    required String newCoachId,
    required int newBicycle,
  }) async {

    _debugPrintHeader("API: rescheduleClass");

    final url =
        '${_baseUrl}api/class-reservations/$reservationId/reschedule';
    final headers = _headers;
    final body = {
      'new_date': newDate,
      'new_time': newTime,
      'new_coach_id': newCoachId,
      'new_bicycle': newBicycle,
    };

    print("➡️ PUT: $url");
    print("📦 Body: $body");

    try {
      final res = await http.put(Uri.parse(url),
          headers: headers, body: json.encode(body));

      print("🌐 Respuesta: ${res.body}");

      return ResponseApi.fromJson(json.decode(res.body));

    } catch (e) {
      print("❌ ERROR rescheduleClass: $e");
      return ResponseApi(success: false, message: 'Error al reagendar clase');
    }
  }

  // ============================================================
  // 🔵 AVAILABLE DATES
  Future<List<String>> getAvailableDates({required String coachId}) async {

    _debugPrintHeader("API: getAvailableDates");

    final url =
        '${_baseUrl}api/class-reservations/availability/dates/$coachId';
    final headers = _headers;

    print("➡️ GET: $url");

    try {
      final res = await http.get(Uri.parse(url), headers: headers);
      print("🌐 Response: ${res.body}");

      if (res.statusCode != 200) return [];

      final body = json.decode(res.body);

      return List<String>.from(body['data'] ?? []);

    } catch (e) {
      print("❌ ERROR getAvailableDates: $e");
      return [];
    }
  }

  // ============================================================
  // 🔵 AVAILABLE TIMES
  Future<List<String>> getAvailableTimes({
    required String coachId,
    required String date,
  }) async {

    _debugPrintHeader("API: getAvailableTimes");

    final url =
        '${_baseUrl}api/class-reservations/availability/times/$coachId/$date';
    final headers = _headers;

    print("➡️ GET: $url");

    try {
      final res = await http.get(Uri.parse(url), headers: headers);

      print("🌐 Response: ${res.body}");

      if (res.statusCode != 200) return [];

      final body = json.decode(res.body);

      return List<String>.from(body['data'] ?? []);

    } catch (e) {
      print("❌ ERROR getAvailableTimes: $e");
      return [];
    }
  }

  // ============================================================
  // 🔵 AVAILABLE BIKES
  Future<List<int>> getAvailableBikes({
    required String coachId,
    required String date,
    required String time,
  }) async {

    _debugPrintHeader("API: getAvailableBikes");

    final url =
        '${_baseUrl}api/class-reservations/availability/bikes/$coachId/$date/$time';
    final headers = _headers;

    print("➡️ GET: $url");

    try {
      final res = await http.get(Uri.parse(url), headers: headers);

      print("🌐 Response: ${res.body}");

      if (res.statusCode != 200) return [];

      final body = json.decode(res.body);

      return List<int>.from(body['data'] ?? []);

    } catch (e) {
      print("❌ ERROR getAvailableBikes: $e");
      return [];
    }
  }

  // ============================================================
  // 🔵 CANCEL CLASS
  Future<ResponseApi> cancelClass(String reservationId) async {

    _debugPrintHeader("API: cancelClass");

    final url =
        '${_baseUrl}api/class-reservations/$reservationId/cancel';
    final headers = _headers;

    print("➡️ DELETE: $url");

    try {
      final res = await http.delete(Uri.parse(url), headers: headers);

      print("🌐 Response: ${res.body}");

      return ResponseApi.fromJson(json.decode(res.body));

    } catch (e) {
      print("❌ ERROR cancelClass: $e");
      return ResponseApi(success: false, message: 'Error cancelando clase');
    }
  }

  // ============================================================
  // 🔵 BLOCK BIKE
  Future<ResponseApi> blockBike({
    required String coachId,
    required int bicycle,
    required String classDate,
    required String classTime,
  }) async {

    _debugPrintHeader("API: blockBike");

    final url =
    Uri.parse('${_baseUrl}api/admin/class-reservations/block');
    final headers = _headers;
    final body = {
      'coach_id': coachId,
      'bicycle': bicycle.toString(),
      'class_date': classDate,
      'class_time': classTime,
    };

    print("➡️ POST: $url");
    print("📦 Body: $body");

    try {
      final res = await http.post(url,
          headers: headers, body: json.encode(body));

      print("🌐 Response: ${res.body}");

      return ResponseApi.fromJson(json.decode(res.body));

    } catch (e) {
      print("❌ ERROR blockBike: $e");
      return ResponseApi(success: false, message: 'Error al bloquear bicicleta: $e');
    }
  }

  // ============================================================
  // 🔵 UNBLOCK BIKE
  Future<ResponseApi> unblockBike({
    required String coachId,
    required int bicycle,
    required String classDate,
    required String classTime,
  }) async {

    _debugPrintHeader("API: unblockBike");

    final cleanedTime = classTime.split(".")[0];

    final url = Uri.parse(
      '${_baseUrl}api/admin/class-reservations/block'
          '?coach_id=$coachId&bicycle=$bicycle&class_date=$classDate&class_time=$cleanedTime',
    );
    final headers = _headers;

    print("➡️ DELETE: $url");

    try {
      final res = await http.delete(url, headers: headers);

      print("🌐 Response: ${res.body}");

      return ResponseApi.fromJson(json.decode(res.body));

    } catch (e) {
      print("❌ ERROR unblockBike: $e");
      return ResponseApi(success: false, message: 'Error al desbloquear bicicleta: $e');
    }
  }

  // ============================================================
  // 🔵 REASSIGN COACH
  Future<ResponseApi> reassignCoach({
    required String oldCoachId,
    required String newCoachId,
    required String date,
    required String startTime,
    required String endTime,
  }) async {

    _debugPrintHeader("API: reassignCoach");

    final url =
        '${_baseUrl}api/admin/class-reservations/reassign-coach';
    final headers = _headers;
    final body = {
      'old_coach_id': oldCoachId,
      'new_coach_id': newCoachId,
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
    };

    print("➡️ POST: $url");
    print("📦 Body: $body");

    try {
      final res = await http.post(Uri.parse(url),
          headers: headers, body: json.encode(body));

      print("🌐 Response: ${res.body}");

      return ResponseApi.fromJson(json.decode(res.body));

    } catch (e) {
      print("❌ ERROR reassignCoach: $e");
      return ResponseApi(success: false, message: 'Error al reasignar coach: $e');
    }
  }

  // ============================================================
  // 🔵 Headers helper
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': (_user['session_token'] ?? '').toString(),
  };

}
