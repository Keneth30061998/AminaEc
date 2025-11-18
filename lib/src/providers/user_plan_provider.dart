import 'dart:convert';

import 'package:amina_ec/src/environment/environment.dart';
import 'package:amina_ec/src/models/response_api.dart';
import 'package:amina_ec/src/models/user_plan.dart';
import 'package:http/http.dart' as http;

class UserPlanProvider {
  final String _url = '${Environment.API_URL}api/acquire/plans';

  // Adquirir un plan
  Future<ResponseApi?> acquire(UserPlan plan, String sessionToken) async {
    try {
      final uri = Uri.parse(_url);
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': sessionToken,
      };
      final body = json.encode(plan.toJson());

      //print('🔹 [UserPlanProvider] Enviando petición acquire');
      //print('🌍 URL: $uri');
      //print('📦 Headers: $headers');
      //print('📤 Body: $body');

      final res = await http.post(uri, headers: headers, body: body);

      //print('📡 STATUS acquire: ${res.statusCode}');
      //print('📥 Response body: ${res.body}');

      if (res.statusCode == 201) {
        final responseApi = ResponseApi.fromJson(json.decode(res.body));
        //print('✅ Acquire exitoso: ${responseApi.toJson()}');
        return responseApi;
      } else {
        //print('❌ Error en acquire: ${res.body}');
        return ResponseApi(success: false, message: 'Error: ${res.body}');
      }
    } catch (e) {
      //print('⚠️ Exception en acquire: $e');
      return ResponseApi(success: false, message: 'Exception: $e');
    }
  }

  // Obtener total de rides activos
  Future<int> getTotalActiveRides(String token) async {
    try {
      final uri = Uri.parse('$_url/active/rides');

      //print('🔹 [UserPlanProvider] Consultando rides activos');
      //print('🌍 URL: $uri');
      //print('🔑 Token: $token');

      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      });

      //print('📡 STATUS activeRides: ${response.statusCode}');
      //print('📥 Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final total = data['total_rides'] ?? 0;
        //print('✅ Total rides activos: $total');
        return total;
      } else {
        //print('❌ Error obteniendo rides activos: ${response.body}');
        return 0;
      }
    } catch (e) {
      //print('⚠️ Exception en getTotalActiveRides: $e');
      return 0;
    }
  }

  Future<List<UserPlan>> getAllPlansWithRides(String token) async {
    try {
      final uri = Uri.parse('${Environment.API_URL}api/acquire/plans/active/rides');
      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> plansJson = data['plans'] ?? [];
        return UserPlan.fromJsonList(plansJson);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
  Future<List<Map<String, dynamic>>> getUserPlansSummary(String userId, String token) async {
    final url = Uri.parse('${Environment.API_URL}api/users/$userId/plans/summary');

    //print('===============');
    //print('📡 Consultando planes del usuario: $userId');
    //print('➡️ URL: $url');
    //print('🔑 TOKEN: $token');
    //print('===============');

    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': token,
    });

    //print('📥 STATUS: ${response.statusCode}');
    //print('📥 BODY: ${response.body}');

    try {
      final data = json.decode(response.body);
      //print('📦 Data decodificada: $data');

      final List<dynamic> rawList = data['plans'] ?? [];
      //print('📋 Lista encontrada: $rawList');

      final list = List<Map<String, dynamic>>.from(rawList);
      //print('✅ Retornando lista de planes: $list');
      //print('===============');

      return list;
    } catch (e) {
      //print('❌ Error parseando JSON: $e');
      return [];
    }
  }

  // ------------------------------------------------------
// 🟩 RECUPERAR PLAN PAGADO PERO NO ACREDITADO
// ------------------------------------------------------
  Future<ResponseApi> recoverPlan({
    required String transactionId,
    required String token,
  }) async {
    final uri = Uri.parse('${Environment.API_URL}api/acquire/recover');

    final body = {
      "transaction_id": transactionId,
    };

    print("\n🟦 ===== API RECOVER PLAN =====");
    print("➡️ POST: $uri");
    print("🆔 transactionId: $transactionId");
    print("🔑 Token: $token");

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      },
      body: json.encode(body),
    );

    print("📥 STATUS recover: ${response.statusCode}");
    print("📦 BODY recover: ${response.body}");

    return ResponseApi.fromJson(json.decode(response.body));
  }

}
