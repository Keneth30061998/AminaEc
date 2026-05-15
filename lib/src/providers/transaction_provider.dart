import 'dart:convert';
import 'package:get/get.dart';
import 'package:amina_ec/src/environment/environment.dart';
import 'package:get_storage/get_storage.dart';
import '../models/transaction_report.dart';
import '../models/user.dart';

class TransactionProvider extends GetConnect {
  final String url = '${Environment.API_URL}pay/report';

  User userSession = User.fromJson(GetStorage().read('user') ?? {});

  Future<List<TransactionReport>> getReport({
    String? month,
    String? year,
    String? day,
    String? status,
  }) async {
    final Map<String, String> query = {};

    if (month != null && month.isNotEmpty) query['month'] = month;
    if (year != null && year.isNotEmpty) query['year'] = year;
    if (day != null && day.isNotEmpty) query['day'] = day;
    if (status != null && status.isNotEmpty) query['status'] = status;

    try {
      final response = await get(
        url,
        query: query,
        headers: {
          'Authorization': userSession.session_token ?? '',
        },
      );

      if (response.statusCode == 200 && response.body != null) {
        dynamic body = response.body;

        if (body is String) {
          body = json.decode(body);
        }

        final List data = body is List ? body : body['data'] ?? [];

        return data
            .map(
              (e) => TransactionReport.fromJson(
            Map<String, dynamic>.from(e),
          ),
        )
            .toList();
      }
    } catch (e) {
      print('❌ Error TransactionProvider.getReport: $e');
    }

    return [];
  }
}