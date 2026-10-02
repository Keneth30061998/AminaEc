import 'dart:convert';

import 'package:amina_ec/src/environment/environment.dart';
import 'package:amina_ec/src/models/response_api.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class ReservationQueueProvider {
  final String _baseUrl = Environment.API_URL;

  Map<String, dynamic> get _user => GetStorage().read('user') ?? {};

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': (_user['session_token'] ?? '').toString(),
      };

  // =====================================================
  // INGRESAR A LISTA DE ESPERA
  // =====================================================

  Future<ResponseApi> joinQueue({
    required String coachId,
    required String classDate,
    required String classTime,
  }) async {
    final url = '${_baseUrl}api/reservation-queue';

    final body = {
      "coach_id": coachId,

      "class_date": classDate,

      "class_time": classTime.split('.').first,

      // importante:
      // no se asigna bicicleta todavía

      "bicycle": null,
    };

    print("🚴 JOIN QUEUE");

    print(url);

    print(body);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: json.encode(body),
      );

      print(response.body);

      return _response(response);
    } catch (e) {
      print("❌ Error joinQueue $e");

      return ResponseApi(
        success: false,
        message: "No se pudo ingresar a lista de espera",
      );
    }
  }

  // =====================================================
  // ACEPTAR OFERTA
  // =====================================================

  Future<ResponseApi> acceptOffer(String queueId) async {
    final url = '${_baseUrl}api/reservation-queue/$queueId/accept';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
      );

      return _response(response);
    } catch (e) {
      return ResponseApi(
        success: false,
        message: "Error aceptando bicicleta",
      );
    }
  }

  ResponseApi _response(http.Response response) {
    if (response.body.isEmpty) {
      return ResponseApi(
        success: false,
        message: "Respuesta vacía",
      );
    }

    try {
      return ResponseApi.fromJson(json.decode(response.body));
    } catch (e) {
      return ResponseApi(
        success: false,
        message: "Respuesta inválida",
      );
    }
  }
}
