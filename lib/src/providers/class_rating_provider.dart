import 'dart:convert';
import 'package:amina_ec/src/environment/environment.dart';
import 'package:amina_ec/src/models/class_rating.dart';
import 'package:amina_ec/src/models/response_api.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class ClassRatingProvider {
  final String _baseUrl = Environment.API_URL;
  Map<String, dynamic> get _user => GetStorage().read('user') ?? {};

  void _debugPrintHeader(String title) {
    print("\n====================================================");
    print("🔍 $title");
    print("====================================================");
  }

  // providers/class_rating_provider.dart
  Future<ResponseApi> submitRating(ClassRating classRating) async {
    final url = '${_baseUrl}api/class-ratings';
    final body = classRating.toJson();

    try {
      final res = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: json.encode(body),
      );

      final data = json.decode(res.body);
      return ResponseApi.fromJson(data);
    } catch (e) {
      return ResponseApi(
        success: false,
        message: 'Error enviando valoración: $e',
      );
    }
  }

  Future<ResponseApi> skipRating({
    required String userId,
    required String attendanceId,
  }) async {
    final url = '${_baseUrl}api/class-ratings/skip';

    final body = {
      'userId': userId,
      'attendanceId': attendanceId,
    };

    try {
      final res = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: json.encode(body),
      );

      final data = json.decode(res.body);
      return ResponseApi.fromJson(data);
    } catch (e) {
      return ResponseApi(
        success: false,
        message: 'Error al omitir valoración: $e',
      );
    }
  }

  // providers/class_rating_provider.dart
  Future<ResponseApi> checkPendingRating(String userId) async {
    final url = '${_baseUrl}api/check-pending-rating'; // URL para verificar clase pendiente

    final body = {
      'userId': userId,
    };

    try {
      final res = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: json.encode(body),
      );

      final data = json.decode(res.body);
      return ResponseApi.fromJson(data);
    } catch (e) {
      return ResponseApi(
        success: false,
        message: 'Error al verificar clases pendientes: $e',
      );
    }
  }

  Future<ResponseApi> findRatingsReport({
    String? studentName,
    String? coachName,
    String? year,
    String? month,
    String? day,
    String? startHour,
    String? endHour,
    String? rating,
    String? hasComment, // "true" | "false" | null
  }) async {
    final queryParams = <String, String>{};

    void addParam(String key, String? value) {
      if (value != null && value.trim().isNotEmpty) {
        queryParams[key] = value.trim();
      }
    }

    addParam('student_name', studentName);
    addParam('coach_name', coachName);
    addParam('class_year', year);
    addParam('class_month', month);
    addParam('class_day', day);
    addParam('start_hour', startHour);
    addParam('end_hour', endHour);
    addParam('rating', rating);
    addParam('has_comment', hasComment);

    final uri = Uri.parse('${_baseUrl}api/class-ratings/report')
        .replace(queryParameters: queryParams);

    try {
      final res = await http.get(uri, headers: _headers);
      final data = json.decode(res.body);
      return ResponseApi.fromJson(data);
    } catch (e) {
      return ResponseApi(
        success: false,
        message: 'Error obteniendo reporte de calificaciones: $e',
      );
    }
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': (_user['session_token'] ?? '').toString(),
  };
}