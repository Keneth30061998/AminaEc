import 'dart:convert';
import 'package:amina_ec/src/environment/environment.dart';
import 'package:http/http.dart' as http;

class NotificationsProvider {
  final String _url = Environment.API_URL_OLD; // Usa tu URL de backend

  Future<Map<String, dynamic>> sendGlobalNotification(
      String title,
      String body,
      ) async {
    try {
      final Uri uri = Uri.parse("$_url/api/notifications/global");

      final res = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "title": title,
          "body": body,
        }),
      );

      return jsonDecode(res.body);
    } catch (e) {
      return {
        "success": false,
        "message": "Error enviando notificación",
        "error": e.toString()
      };
    }
  }
}
