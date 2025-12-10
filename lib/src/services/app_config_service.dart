import 'dart:convert';
import 'package:http/http.dart' as http;

// =====================================
// 🌟 Consulta directa al endpoint de configuración
// devuelve un Map con keys:
// { maintenance: bool, title: String, message: String, estimated_time: String }
// Si hay error retorna maintenance: false
// =====================================
Future<Map<String, dynamic>> fetchRemoteAppConfig() async {
  const String endpoint = 'https://apiv1.pruebasinventario.com/api/app-config';
  try {
    final resp = await http
        .get(Uri.parse(endpoint))
        .timeout(const Duration(seconds: 6));
    if (resp.statusCode == 200) {
      final body = json.decode(resp.body);
      Map<String, dynamic> cfg = {};
      if (body is Map<String, dynamic>) {
        if (body.containsKey('appConfig') && body['appConfig'] is Map) {
          cfg = Map<String, dynamic>.from(body['appConfig']);
        } else {
          cfg = Map<String, dynamic>.from(body);
        }
      }
      return {
        'maintenance': cfg['maintenance'] ?? false,
        'title': cfg['title'] ?? 'Mantenimiento',
        'message': cfg['message'] ??
            cfg['message'] ??
            'Estamos trabajando en la app. Vuelve pronto.',
        'estimated_time': cfg['estimated_time'] ?? cfg['estimatedTime'] ?? '',
      };
    }
  } catch (_) {
    // ignore errors
  }
  return {
    'maintenance': false,
    'title': 'Mantenimiento',
    'message': 'Estamos trabajando en la app. Vuelve pronto.',
    'estimated_time': '',
  };
}
