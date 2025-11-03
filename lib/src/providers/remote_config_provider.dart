import 'dart:convert';
import 'package:http/http.dart' as http;

class RemoteConfigService {
  static const String _endpoint = 'https://api.pruebasinventario.com/api/app-config';

  static Future<Map<String, dynamic>> fetchConfig() async {
    try {
      final resp = await http.get(Uri.parse(_endpoint)).timeout(const Duration(seconds: 6));

      if (resp.statusCode == 200) {
        final body = json.decode(resp.body);

        final cfg = (body is Map && body['appConfig'] is Map)
            ? Map<String, dynamic>.from(body['appConfig'])
            : Map<String, dynamic>.from(body);

        return {
          'maintenance': cfg['maintenance'] ?? false,
          'title': cfg['title'] ?? 'Mantenimiento',
          'message': cfg['message'] ?? 'Estamos trabajando en la app.',
          'estimated_time': cfg['estimated_time'] ?? '',
        };
      }
    } catch (_) {}

    return {
      'maintenance': false,
      'title': 'Mantenimiento',
      'message': 'Estamos trabajando en la app.',
      'estimated_time': '',
    };
  }
}
