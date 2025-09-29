import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../environment/environment.dart';
import '../models/scheduled_class.dart';
import '../models/user.dart';

class ScheduledClassProvider extends GetConnect {
  User userSession = User.fromJson(GetStorage().read('user') ?? {});

  final String url = '${Environment.API_URL}api/class-reservations';

  Future<List<ScheduledClass>> getByUser() async {
    print('🔹 [ScheduledClassProvider] Iniciando petición getByUser');
    print('🌍 URL: $url');
    print('🔑 Token: ${userSession.session_token}');

    final Response response = await get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': userSession.session_token ?? '',
      },
    );

    print('📡 STATUS ClassReservadas: ${response.statusCode}');
    print('📦 BODY: ${response.body}');

    if (response.statusCode != 200 ||
        response.body == null ||
        response.body is! Map) {
      print('❌ ERROR: conexión fallida o respuesta inválida');
      return [];
    }

    if (response.statusCode == 401 || response.body == null) {
      print('⚠️ Usuario no autorizado o sesión expirada');
      return [];
    }

    final List<dynamic> list = response.body['data'] ?? [];
    print('📊 Total clases reservadas recibidas: ${list.length}');

    final scheduledClasses = ScheduledClass.fromJsonList(list);
    print('✅ Clases parseadas correctamente: ${scheduledClasses.length}');
    return scheduledClasses;
  }
}
