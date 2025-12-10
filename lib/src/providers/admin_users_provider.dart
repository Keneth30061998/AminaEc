import 'dart:convert';
import 'package:amina_ec/src/models/response_api.dart';
import 'package:amina_ec/src/models/user.dart';
import 'package:http/http.dart' as http;
import '../environment/environment.dart';

class AdminUsersProvider {
  final String _baseUrl = Environment.API_URL_SOCKET;
  final String _api = '/api/admin/users';

  /// Traer **todos** los usuarios, manejando paginación si es necesario
  Future<List<User>> getAllUsers(String token) async {
    List<User> allUsers = [];
    int page = 1;
    int limit = 100; // Ajusta según tu backend
    bool hasMore = true;

    try {
      while (hasMore) {
        Uri url = Uri.parse('$_baseUrl$_api?page=$page&limit=$limit');
        final res = await http.get(url, headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        });

        if (res.statusCode == 200) {
          final data = responseApiFromJson(res.body);
          if (data.data != null && (data.data as List).isNotEmpty) {
            allUsers.addAll(List<User>.from(data.data.map((u) => User.fromJson(u))));
            // Si el número de usuarios recibidos es menor que el límite, es la última página
            hasMore = (data.data as List).length == limit;
            page++;
          } else {
            hasMore = false;
          }
        } else {
          print('❌ Error getAllUsers: ${res.statusCode} ${res.body}');
          hasMore = false;
        }
      }
      return allUsers;
    } catch (e) {
      print('❌ Exception getAllUsers: $e');
      return [];
    }
  }

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

  Future<List<Map<String, dynamic>>> getUserPlansSummary(String userId, String token) async {
    final url = Uri.parse('${Environment.API_URL}api/users/$userId/plans/summary');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': token,
    });

    try {
      final data = json.decode(response.body);
      final List<dynamic> rawList = data['plans'] ?? [];
      return List<Map<String, dynamic>>.from(rawList);
    } catch (e) {
      return [];
    }
  }
}
