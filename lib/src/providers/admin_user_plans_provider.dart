import 'dart:convert';
import 'package:amina_ec/src/environment/environment.dart';
import 'package:amina_ec/src/models/plan.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AdminUserPlansProvider {
  final String _base = Environment.API_URL_OLD; // Ej: https://.../api

  // Obtener planes del usuario
  Future<List<Map<String, dynamic>>> getUserPlans(String userId, String token) async {
    final uri = Uri.parse('$_base/api/admin/users/$userId/plans');

    debugPrint('📡 [Provider] GET USER PLANS');
    debugPrint('➡️ URL: $uri');
    debugPrint('🔑 TOKEN: $token');

    final res = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': token,
    });

    debugPrint('📥 STATUS: ${res.statusCode}');
    debugPrint('📥 RAW BODY: ${res.body}');

    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final List<dynamic> raw = data['plans'] ?? data['data'] ?? [];
      debugPrint('✅ PARSED PLANS COUNT: ${raw.length}');
      return List<Map<String, dynamic>>.from(raw);
    }

    debugPrint('❌ ERROR GETTING PLANS, returning empty list');
    return [];
  }

  // Asignar plan manual
  Future<Map<String, dynamic>> assignPlan({
    required String userId,
    required String token,
    required String planId,
    String? startDate,
    String? endDate,
    int? remainingRides,
  }) async {
    final uri = Uri.parse('$_base/api/admin/users/$userId/plans');

    final body = {
      'plan_id': planId,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (remainingRides != null) 'remaining_rides': remainingRides,
    };

    debugPrint('📡 [Provider] ASSIGN PLAN MANUAL');
    debugPrint('➡️ URL: $uri');
    debugPrint('🔑 TOKEN: $token');
    debugPrint('📤 BODY: $body');

    final res = await http.post(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': token,
    }, body: json.encode(body));

    debugPrint('📥 STATUS: ${res.statusCode}');
    debugPrint('📥 RAW BODY: ${res.body}');

    if (res.statusCode == 201 || res.statusCode == 200) {
      return json.decode(res.body);
    } else {
      return {'success': false, 'message': res.body};
    }
  }

  // Editar plan del usuario
  Future<Map<String, dynamic>> updateUserPlan({
    required String userPlanId,
    required String token,
    String? startDate,
    String? endDate,
    int? remainingRides,
  }) async {
    final uri = Uri.parse('$_base/api/admin/user-plans/$userPlanId');

    final body = {
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (remainingRides != null) 'remaining_rides': remainingRides,
    };

    debugPrint('📡 [Provider] UPDATE USER PLAN');
    debugPrint('➡️ URL: $uri');
    debugPrint('🔑 TOKEN: $token');
    debugPrint('📤 BODY: $body');

    final res = await http.put(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': token,
    }, body: json.encode(body));

    debugPrint('📥 STATUS: ${res.statusCode}');
    debugPrint('📥 RAW BODY: ${res.body}');

    if (res.statusCode == 200) {
      return json.decode(res.body);
    } else {
      return {'success': false, 'message': res.body};
    }
  }

  // Eliminar plan del usuario
  Future<Map<String, dynamic>> deleteUserPlan({
    required String userPlanId,
    required String token,
  }) async {
    final uri = Uri.parse('$_base/api/admin/user-plans/$userPlanId');

    debugPrint('📡 [Provider] DELETE USER PLAN');
    debugPrint('➡️ URL: $uri');
    debugPrint('🔑 TOKEN: $token');

    final res = await http.delete(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': token,
    });

    debugPrint('📥 STATUS: ${res.statusCode}');
    debugPrint('📥 RAW BODY: ${res.body}');

    if (res.statusCode == 200) {
      return json.decode(res.body);
    } else {
      return {'success': false, 'message': res.body};
    }
  }

  // Obtener todos los planes globales para dropdown
  Future<List<Plan>> getAllPlans(String token) async {
    final uri = Uri.parse('$_base/api/plans/getAll');

    debugPrint('📡 [Provider] GET ALL PLANS');
    debugPrint('➡️ URL: $uri');
    debugPrint('🔑 TOKEN: $token');

    final res = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': token,
    });

    debugPrint('📥 STATUS: ${res.statusCode}');
    debugPrint('📥 RAW BODY: ${res.body}');

    if (res.statusCode == 201) {
      final data = json.decode(res.body);
      final List<dynamic> list = data['data'] ?? [];
      debugPrint('✅ TOTAL PLANS: ${list.length}');
      return Plan.fromJsonList(list);
    } else {
      debugPrint('❌ ERROR GETTING PLANS');
      return [];
    }
  }
}
