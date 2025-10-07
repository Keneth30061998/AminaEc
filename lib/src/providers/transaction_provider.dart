import 'dart:convert';
import 'package:get/get.dart';
import 'package:amina_ec/src/environment/environment.dart';
import 'package:get_storage/get_storage.dart';
import '../models/transaction_report.dart';
import '../models/user.dart';

class TransactionProvider extends GetConnect {
  final String url = '${Environment.API_URL}pay/report';
  // Sesión del usuario
  User userSession = User.fromJson(GetStorage().read('user') ?? {});

  Future<List<TransactionReport>> getReport({
    String? month,
    String? year,
  }) async {
    final Map<String, String> query = {};
    if (month != null) query['month'] = month;
    if (year != null) query['year'] = year;

    try {
      final response = await get(
        url,
        query: query,
        headers: {'Authorization': userSession.session_token ?? ''},
      );

      if (response.statusCode == 200 && response.body != null) {
        final List data = response.body is List
            ? response.body
            : json.decode(response.body);
        return data.map((e) => TransactionReport.fromJson(e)).toList();
      }
    } catch (e) {
      //print('❌ Error TransactionProvider.getReport: $e');
    }

    return [];
  }
}
