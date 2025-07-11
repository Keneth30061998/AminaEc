import 'dart:convert';

import 'package:amina_ec/src/environment/environment.dart';
import 'package:amina_ec/src/models/class_reservation.dart';
import 'package:amina_ec/src/models/response_api.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

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
      'Authorization': (_user['session_token'] ?? '').toString()
    };

    final body = {
      'user_id': _user['id'],
      'coach_id': coachId,
      'bicycle': bicycle,
      'class_date': classDate,
      'class_time': classTime
    };

    try {
      final res = await http.post(Uri.parse(_url),
          headers: headers, body: json.encode(body));

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
      'Authorization': (_user['session_token'] ?? '').toString()
    };

    final body = {'class_date': classDate, 'class_time': classTime};

    try {
      final res = await http.post(Uri.parse(url),
          headers: headers, body: json.encode(body));

      final data = json.decode(res.body);
      if (data['success'] == true && data['data'] != null) {
        final List<dynamic> reservations = data['data'];
        return reservations.map((r) => ClassReservation.fromJson(r)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
