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

    print('📤 Scheduling class...');
    print('🔗 POST -> $_url');
    print('📦 Headers: $headers');
    print('📦 Body: $body');

    try {
      final res = await http.post(
        Uri.parse(_url),
        headers: headers,
        body: json.encode(body),
      );

      print('📝 Response status: ${res.statusCode}, body: ${res.body}');
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
      print('❌ scheduleClass error: $e');
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

    print('🔍 Getting reservations for slot...');
    print('🔗 POST -> $url');
    print('📦 Headers: $headers');
    print('📦 Body: $body');

    try {
      final res = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );
      print('📝 Response status: ${res.statusCode}, body: ${res.body}');
      final data = json.decode(res.body);
      if (data['success'] == true && data['data'] != null) {
        final List<dynamic> reservations = data['data'];
        print('✅ ${reservations.length} reservations found');
        return reservations.map((r) => ClassReservation.fromJson(r)).toList();
      }
    } catch (e) {
      print('❌ getReservationsForSlot error: $e');
    }
    return [];
  }

  Future<List<StudentInscription>> getStudentsByCoach(String coachId) async {
    final url = '${Environment.API_URL}api/class-reservations/coach/$coachId';
    final headers = {
      'Authorization': (_user['session_token'] ?? '').toString(),
      'Content-Type': 'application/json',
    };

    print('👨‍🏫 Getting students for coach $coachId');
    print('🔗 GET -> $url');
    print('📦 Headers: $headers');

    try {
      final res = await http.get(Uri.parse(url), headers: headers);
      print('📝 Response status: ${res.statusCode}, body: ${res.body}');
      final data = json.decode(res.body);
      if (data['success'] == true) {
        final List<dynamic> list = data['data'];
        print('✅ ${list.length} students found');
        return list.map((e) => StudentInscription.fromJson(e)).toList();
      }
    } catch (e) {
      print('❌ getStudentsByCoach error: $e');
    }
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

    print('🔄 Rescheduling reservation $reservationId');
    print('📅 New Date: $newDate, ⏰ New Time: $newTime');
    print('👨‍🏫 New Coach ID: $newCoachId, 🚲 New Bicycle: $newBicycle');
    print('🔗 PUT -> $url');
    print('📦 Headers: $headers');
    print('📦 Body: $body');

    try {
      final res = await http.put(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      print('📝 Response status: ${res.statusCode}, body: ${res.body}');
      final data = json.decode(res.body);

      if (res.statusCode == 400 && data['message'] != null) {
        print('❌ Bad request: ${data['message']}');
      } else if (res.statusCode == 403) {
        print('🚫 Forbidden: ${data['message']}');
      } else if (res.statusCode == 404) {
        print('🔍 Not found: ${data['message']}');
      } else if (res.statusCode == 409) {
        print('⚠️ Conflict: ${data['message']}');
      }

      return ResponseApi.fromJson(data);
    } catch (e) {
      print('❌ Error during reschedule: $e');
      return ResponseApi(success: false, message: 'Error: $e');
    }
  }

  Future<List<String>> getAvailableDates({
    required String coachId,
  }) async {
    final url =
        '${Environment.API_URL}api/class-reservations/availability/dates/$coachId';

    print('📅 Getting available dates for coach $coachId');
    print('🔗 GET -> $url');

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
        print('✅ ${body['data'].length} dates found');
        return List<String>.from(body['data'] as List);
      }
    } catch (e) {
      print('❌ dates error: $e');
    }
    return [];
  }

  Future<List<String>> getAvailableTimes({
    required String coachId,
    required String date,
  }) async {
    final url =
        '${Environment.API_URL}api/class-reservations/availability/times/$coachId/$date';

    print('⏰ Getting available times for coach $coachId on $date');
    print('🔗 GET -> $url');

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
        print('✅ ${body['data'].length} times found');
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
