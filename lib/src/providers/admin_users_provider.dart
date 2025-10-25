import 'package:amina_ec/src/models/response_api.dart';
import 'package:amina_ec/src/models/user.dart';
import 'package:http/http.dart' as http;

import '../environment/environment.dart';

class AdminUsersProvider {
  // URL base
  final String _baseUrl = Environment.API_URL_OLD; // producción
  final String _api = '/api/admin/users';

  // =======================
  // Obtener todos los usuarios
  // =======================
  Future<List<User>> getAllUsers(String token) async {
    try {
      Uri url = Uri.parse('$_baseUrl$_api');
      final res = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      });

      if (res.statusCode == 200) {
        final data = responseApiFromJson(res.body);
        return data.data != null
            ? List<User>.from(data.data.map((u) => User.fromJson(u)))
            : [];
      } else {
        print('❌ Error getAllUsers: ${res.statusCode} ${res.body}');
        return [];
      }
    } catch (e) {
      print('❌ Exception getAllUsers: $e');
      return [];
    }
  }

  // =======================
  // Extender días del plan de un usuario
  // =======================
  Future<ResponseApi> extendPlan(String userId, int days, String token) async {
    try {
      Uri url = Uri.parse('$_baseUrl$_api/$userId/extend-expiration');
      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: '{"days": $days}',
      );

      return responseApiFromJson(res.body);
    } catch (e) {
      print('❌ Exception extendPlan: $e');
      return ResponseApi(success: false, message: 'Error extendiendo plan');
    }
  }

  // =======================
  // Devolver rides a un usuario
  // =======================
  Future<ResponseApi> returnRides(String userId, int rides, String token) async {
    try {
      Uri url = Uri.parse('$_baseUrl$_api/$userId/return-rides');
      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: '{"rides": $rides}',
      );

      return responseApiFromJson(res.body);
    } catch (e) {
      print('❌ Exception returnRides: $e');
      return ResponseApi(success: false, message: 'Error devolviendo rides');
    }
  }
}
