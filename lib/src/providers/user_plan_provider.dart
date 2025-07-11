import 'dart:convert';

import 'package:amina_ec/src/environment/environment.dart';
import 'package:amina_ec/src/models/response_api.dart';
import 'package:amina_ec/src/models/user_plan.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserPlanProvider {
  final String _url = '${Environment.API_URL}api/acquire/plans';
  final BuildContext context;

  UserPlanProvider({required this.context});

  Future<ResponseApi?> acquire(UserPlan plan, String sessionToken) async {
    try {
      final uri = Uri.parse(_url);
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': sessionToken,
      };

      final body = json.encode(plan.toJson());

      final res = await http.post(uri, headers: headers, body: body);

      if (res.statusCode == 201) {
        return ResponseApi.fromJson(json.decode(res.body));
      } else {
        return ResponseApi(success: false, message: 'Error: ${res.body}');
      }
    } catch (e) {
      return ResponseApi(success: false, message: 'Exception: $e');
    }
  }

  Future<int> getTotalActiveRides(String token) async {
    try {
      final uri = Uri.parse('$_url/active/rides');

      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['total_rides'] ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }
}
