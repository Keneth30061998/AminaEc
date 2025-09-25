// lib/src/providers/class_reservation_provider.dart

import 'dart:convert';

import 'package:amina_ec/src/environment/environment.dart';
import 'package:amina_ec/src/models/class_reservation.dart';
import 'package:amina_ec/src/models/response_api.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../models/student_inscription.dart';

class ClassReservationProvider {
  final String _url = '${Environment.API_URL}api/class-reservations/schedule';
  final Map<String, dynamic> _user = GetStorage().read('user');

  Future<ResponseApi> scheduleClass({
    required String coachId,
    required int bicycle,
    required String classDate,
    required String classTime,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': (_user['session_token'] ?? '').toString(),
    };
    final body = {
      'user_id': _user['id'],
      'coach_id': coachId,
      'bicycle': bicycle,
      'class_date': classDate,
      'class_time': classTime,
    };

    try {
      final res = await http.post(
        Uri.parse(_url),
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

      return ResponseApi(
        success: success,
        message: message,
        data: reservation,
      );
    } catch (e) {
      return ResponseApi(success: false, message: 'Error: $e');
    }
  }

  Future<List<ClassReservation>> getReservationsForSlot({
    required String classDate,
    required String classTime,
  }) async {
    final String url = '${Environment.API_URL}api/class-reservations/by-slot';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': (_user['session_token'] ?? '').toString(),
    };
    final body = {'class_date': classDate, 'class_time': classTime};

    try {
      final res = await http.post(
        Uri.parse(url),
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

  Future<List<StudentInscription>> getStudentsByCoach(String coachId) async {
    final url = '${Environment.API_URL}api/class-reservations/coach/$coachId';
    final headers = {
      'Authorization': (_user['session_token'] ?? '').toString(),
      'Content-Type': 'application/json',
    };

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

  Future<ResponseApi> rescheduleClass({
    required String reservationId,
    required String newDate,
    required String newTime,
    required String newCoachId,
    required int newBicycle,
  }) async {
    final url =
        '${Environment.API_URL}api/class-reservations/$reservationId/reschedule';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': (_user['session_token'] ?? '').toString(),
    };
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
      final data = json.decode(res.body);
      return ResponseApi.fromJson(data);
    } catch (e) {
      return ResponseApi(success: false, message: 'Error: $e');
    }
  }

  // GET available dates for a coach
  Future<List<String>> getAvailableDates({
    required String coachId, // ahora named
  }) async {
    final url =
        '${Environment.API_URL}api/class-reservations/availability/dates/$coachId';

    print('🔗 GET dates -> $url');
    try {
      final res = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': (_user['session_token'] ?? '').toString(),
        },
      );
      print('🗓️ dates status: ${res.statusCode}, body: ${res.body}');
      if (res.statusCode != 200) return [];
      final body = json.decode(res.body);
      if (body['success'] == true) {
        return List<String>.from(body['data'] as List);
      }
    } catch (e) {
      print('❌ dates error: $e');
    }
    return [];
  }

  // GET available start times for a coach on a date
  Future<List<String>> getAvailableTimes({
    required String coachId,
    required String date,
  }) async {
    final url =
        '${Environment.API_URL}api/class-reservations/availability/times/$coachId/$date';

    print('🔗 GET times -> $url');
    try {
      final res = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': (_user['session_token'] ?? '').toString(),
        },
      );
      print('⏰ times status: ${res.statusCode}, body: ${res.body}');
      if (res.statusCode != 200) return [];
      final body = json.decode(res.body);
      if (body['success'] == true) {
        return List<String>.from(body['data'] as List);
      }
    } catch (e) {
      print('❌ times error: $e');
    }
    return [];
  }

  // GET available bikes for a coach on a date and start time
  Future<List<int>> getAvailableBikes({
    required String coachId,
    required String date,
    required String time,
  }) async {
    final url =
        '${Environment.API_URL}api/class-reservations/availability/bikes'
        '/$coachId/$date/$time';

    print('🔗 GET bikes -> $url');
    try {
      final res = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': (_user['session_token'] ?? '').toString(),
        },
      );
      print('🚲 bikes status: ${res.statusCode}, body: ${res.body}');
      if (res.statusCode != 200) return [];
      final body = json.decode(res.body);
      if (body['success'] == true) {
        return List<int>.from(body['data'] as List);
      }
    } catch (e) {
      print('❌ bikes error: $e');
    }
    return [];
  }
}
