import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../environment/environment.dart';
import '../models/scheduled_class.dart';
import '../models/user.dart';

class ScheduledClassProvider extends GetConnect {
  User userSession = User.fromJson(GetStorage().read('user') ?? {});

  final String url = '${Environment.API_URL}api/class-reservations';

  Future<List<ScheduledClass>> getByUser() async {
    final Response response = await get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': userSession.session_token ?? '',
      },
    );

    //print('📡 STATUS ClassReservadas: ${response.statusCode}');
    //print('📦 BODY: ${response.body}');
    if (response.statusCode != 200 ||
        response.body == null ||
        response.body is! Map) {
      //print('❌ ERROR de conexión o respuesta inválida');
      return [];
    }

    if (response.statusCode == 401 || response.body == null) return [];

    final List<dynamic> list = response.body['data'] ?? [];
    return ScheduledClass.fromJsonList(list);
  }
}
