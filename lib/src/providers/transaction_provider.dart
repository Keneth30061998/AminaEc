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
  }) async {
    final Map<String, String> query = {};
    if (month != null) query['month'] = month;
    if (year != null) query['year'] = year;

    print('📡 [TransactionProvider] → Llamando API: $url');
    print('🧭 Parámetros → month=$month, year=$year');
    print('🔑 Token → ${userSession.session_token}');

    try {
      final response = await get(
        url,
        query: query,
        headers: {'Authorization': userSession.session_token ?? ''},
      );

      print('📥 Respuesta cruda: status=${response.statusCode}');
      print('📦 Body: ${response.body}');

      if (response.statusCode == 200 && response.body != null) {
        final List data = response.body is List
            ? response.body
            : json.decode(response.body);

        print('✅ Decodificado correctamente. Cantidad de registros: ${data.length}');
        print('🔍 Primer registro (preview): ${data.isNotEmpty ? data.first : "vacío"}');

        final result = data.map((e) => TransactionReport.fromJson(e)).toList();

        print('🧾 Primer registro parseado: ${result.isNotEmpty ? result.first : "vacío"}');
        return result;
      } else {
        print('❌ Error en respuesta del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error TransactionProvider.getReport: $e');
    }

    return [];
  }
}
