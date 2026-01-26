import 'dart:convert';
import 'package:amina_ec/src/environment/environment.dart';
import 'package:amina_ec/src/models/plan_usage_event.dart';
import 'package:http/http.dart' as http;

class PlanUsageReportProvider {
  Future<List<PlanUsageEvent>> getUserHistory({
    required String userId,
    required String token,
  }) async {
    try {
      final uri = Uri.parse(
        '${Environment.API_URL}api/admin/reports/plan-usage/$userId',
      );

      final res = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      });

      if (res.statusCode != 200) return [];

      final body = json.decode(res.body);
      final List<dynamic> data = body['data'] ?? [];

      final events = data
          .map((e) => PlanUsageEvent.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      // Por si acaso: orden desc por occurred_at
      events.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
      return events;
    } catch (_) {
      return [];
    }
  }
}
