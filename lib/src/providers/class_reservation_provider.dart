import 'dart:convert';
import 'package:amina_ec/src/environment/environment.dart';
import 'package:amina_ec/src/models/class_reservation.dart';
import 'package:amina_ec/src/models/response_api.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../models/student_inscription.dart';

class ClassReservationProvider {
  final String _baseUrl = Environment.API_URL; // 🔹 Siempre usar esta base
  Map<String, dynamic> get _user => GetStorage().read('user') ?? {};

  // ✅ SCHEDULE CLASS
  Future<ResponseApi> scheduleClass({
    required String coachId,
    required int bicycle,
    required String classDate,
    required String classTime,
  }) async {
    final headers = _headers;
    final body = {
      'user_id': _user['id'],
      'coach_id': coachId,
      'bicycle': bicycle,
      'class_date': classDate,
      'class_time': classTime,
    };

    try {
      final res = await http.post(
        Uri.parse('${_baseUrl}api/class-reservations/schedule'),
        headers: headers,
        body: json.encode(body),
      );
      final data = json.decode(res.body);
      final success = data['success'] ?? false;
      final message = data['message'];

      ClassReservation? reservation;
      if (success && data['data'] != null) {
        reservation = ClassReservation.fromJson(data['data']);
      }

      return ResponseApi(success: success, message: message, data: reservation);
    } catch (e) {
      return ResponseApi(success: false, message: 'Error: $e');
    }
  }

  // ✅ GET RESERVATIONS FOR SLOT
  Future<List<ClassReservation>> getReservationsForSlot({
    required String classDate,
    required String classTime,
  }) async {
    final headers = _headers;
    final body = {'class_date': classDate, 'class_time': classTime};

    try {
      final res = await http.post(
        Uri.parse('${_baseUrl}api/class-reservations/by-slot'),
        headers: headers,
        body: json.encode(body),
      );
      final data = json.decode(res.body);
      if (data['success'] == true && data['data'] != null) {
        final List<dynamic> reservations = data['data'];
        return reservations.map((r) => ClassReservation.fromJson(r)).toList();
      }
    } catch (_) {}
    return [];
  }

  // ✅ GET STUDENTS BY COACH
  Future<List<StudentInscription>> getStudentsByCoach(String coachId) async {
    final headers = _headers;
    final url = '${_baseUrl}api/class-reservations/coach/$coachId';

    try {
      final res = await http.get(Uri.parse(url), headers: headers);
      final data = json.decode(res.body);
      if (data['success'] == true) {
        final List<dynamic> list = data['data'];
        return list.map((e) => StudentInscription.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  // ✅ RESCHEDULE CLASS
  Future<ResponseApi> rescheduleClass({
    required String reservationId,
    required String newDate,
    required String newTime,
    required String newCoachId,
    required int newBicycle,
  }) async {
    final url = '${_baseUrl}api/class-reservations/$reservationId/reschedule';
    final headers = _headers;
    final body = {
      'new_date': newDate,
      'new_time': newTime,
      'new_coach_id': newCoachId,
      'new_bicycle': newBicycle,
    };

    try {
      final res = await http.put(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );
      return ResponseApi.fromJson(json.decode(res.body));
    } catch (_) {
      return ResponseApi(success: false, message: 'Error al reagendar clase');
    }
  }

  // ✅ AVAILABLE DATES
  Future<List<String>> getAvailableDates({required String coachId}) async {
    final url = '${_baseUrl}api/class-reservations/availability/dates/$coachId';
    final headers = _headers;

    try {
      final res = await http.get(Uri.parse(url), headers: headers);
      if (res.statusCode != 200) return [];
      final body = json.decode(res.body);
      if (body['success'] == true) {
        return List<String>.from(body['data'] as List);
      }
    } catch (_) {}
    return [];
  }

  // ✅ AVAILABLE TIMES
  Future<List<String>> getAvailableTimes({
    required String coachId,
    required String date,
  }) async {
    final url =
        '${_baseUrl}api/class-reservations/availability/times/$coachId/$date';
    final headers = _headers;

    try {
      final res = await http.get(Uri.parse(url), headers: headers);
      if (res.statusCode != 200) return [];
      final body = json.decode(res.body);
      if (body['success'] == true) {
        return List<String>.from(body['data'] as List);
      }
    } catch (_) {}
    return [];
  }

  // ✅ AVAILABLE BIKES
  Future<List<int>> getAvailableBikes({
    required String coachId,
    required String date,
    required String time,
  }) async {
    final url =
        '${_baseUrl}api/class-reservations/availability/bikes/$coachId/$date/$time';
    final headers = _headers;

    try {
      final res = await http.get(Uri.parse(url), headers: headers);
      if (res.statusCode != 200) return [];
      final body = json.decode(res.body);
      if (body['success'] == true) {
        return List<int>.from(body['data'] as List);
      }
    } catch (_) {}
    return [];
  }

  // ✅ CANCEL CLASS
  Future<ResponseApi> cancelClass(String reservationId) async {
    final url = '${_baseUrl}api/class-reservations/$reservationId/cancel';
    final headers = _headers;

    try {
      final res = await http.delete(Uri.parse(url), headers: headers);
      return ResponseApi.fromJson(json.decode(res.body));
    } catch (_) {
      return ResponseApi(success: false, message: 'Error cancelando clase');
    }
  }

  // ✅ BLOCK BIKE
  Future<ResponseApi> blockBike({
    required String coachId,
    required int bicycle,
    required String classDate,
    required String classTime,
  }) async {
    final url = Uri.parse('${_baseUrl}api/admin/class-reservations/block');
    final headers = _headers;
    final body = {
      'coach_id': coachId,
      'bicycle': bicycle.toString(),
      'class_date': classDate,
      'class_time': classTime,
    };

    try {
      final res = await http.post(url, headers: headers, body: json.encode(body));
      return ResponseApi.fromJson(json.decode(res.body));
    } catch (e) {
      return ResponseApi(success: false, message: 'Error al bloquear bicicleta: $e');
    }
  }

  // ✅ UNBLOCK BIKE
  Future<ResponseApi> unblockBike({
    required String coachId,
    required int bicycle,
    required String classDate,
    required String classTime,
  }) async {
    final cleanedTime = classTime.split(".")[0];
    final url = Uri.parse(
      '${_baseUrl}api/admin/class-reservations/block'
          '?coach_id=$coachId&bicycle=$bicycle&class_date=$classDate&class_time=$cleanedTime',
    );
    final headers = _headers;

    try {
      final res = await http.delete(url, headers: headers);
      return ResponseApi.fromJson(json.decode(res.body));
    } catch (e) {
      return ResponseApi(success: false, message: 'Error al desbloquear bicicleta: $e');
    }
  }

  // ✅ REASSIGN COACH
  Future<ResponseApi> reassignCoach({
    required String oldCoachId,
    required String newCoachId,
    required String date,
    required String startTime,
    required String endTime,
  }) async {
    final url = '${_baseUrl}api/admin/class-reservations/reassign-coach';
    final headers = _headers;
    final body = {
      'old_coach_id': oldCoachId,
      'new_coach_id': newCoachId,
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
    };

    try {
      final res = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );
      return ResponseApi.fromJson(json.decode(res.body));
    } catch (e) {
      return ResponseApi(success: false, message: 'Error al reasignar coach: $e');
    }
  }

  // 🔸 Helper para headers
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': (_user['session_token'] ?? '').toString(),
  };
}
