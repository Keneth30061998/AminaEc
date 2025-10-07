import 'dart:convert';
import 'dart:io';

import 'package:amina_ec/src/environment/environment.dart';
import 'package:amina_ec/src/models/coach.dart';
import 'package:amina_ec/src/models/schedule.dart';
import 'package:amina_ec/src/models/user.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class CoachProvider extends GetConnect {
  User userSession = User.fromJson(GetStorage().read('user') ?? {});
  String url = '${Environment.API_URL}api/coachs';

  // Registrar coach con imagen y horarios
  Future<Stream> registerCoach({
    required User user,
    required Coach coach,
    required List<Schedule> schedule,
    required File image,
  }) async {
    //print('📌 [CoachProvider] → Iniciando registerCoach()');
    //print('📤 User: ${user.toJson()}');
    //print('📤 Coach: ${coach.toJson()}');
    //print('📤 Schedule: ${schedule.map((s) => s.toJson()).toList()}');
    //print('🖼 Imagen: ${image.path}');
    //print('🔑 Token: ${userSession.session_token}');

    Uri uri =
    Uri.parse('${Environment.API_URL_OLD}/api/coachs/createWithImage');
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = userSession.session_token ?? '';

    request.files.add(http.MultipartFile(
      'image',
      http.ByteStream(image.openRead().cast()),
      await image.length(),
      filename: basename(image.path),
    ));

    request.fields['user'] = json.encode(user.toJson());
    request.fields['coach'] = json.encode(coach.toJson());
    request.fields['schedule'] =
        json.encode(schedule.map((s) => s.toJson()).toList());

    final response = await request.send();
    //print('📥 Respuesta recibida en registerCoach(), statusCode=${response.statusCode}');
    return response.stream.transform(utf8.decoder);
  }

  // Obtener todos los coaches
  Future<List<Coach>> getAll() async {
    //print('📌 [CoachProvider] → Iniciando getAll()');
    final response = await get('$url/getAll', headers: {
      'Content-Type': 'application/json',
      'Authorization': userSession.session_token ?? ''
    });

    //print('📥 Respuesta cruda en getAll(): status=${response.statusCode}, body=${response.body}');

    if (response.statusCode == 401) {
      //print('❌ No autorizado en getAll()');
      return [];
    }

    try {
      final coaches = await compute(_parseCoaches, response.body);
      //print('📊 Coaches obtenidos: ${coaches.length}');
      return coaches;
    } catch (e) {
      //print('❌ Error parsing coaches: $e');
      return [];
    }
  }

  // Función para parsear en background
  static List<Coach> _parseCoaches(dynamic responseBody) {
    //print('🔄 Parseando coaches en _parseCoaches()');
    Map<String, dynamic> body;
    if (responseBody is Map<String, dynamic>) {
      body = responseBody;
    } else if (responseBody is String) {
      body = json.decode(responseBody);
    } else {
      body = {};
    }

    final List<dynamic> list = body['data'] ?? [];
    //print('📊 Cantidad de coaches en JSON: ${list.length}');
    return Coach.fromJsonList(list);
  }

  // Eliminar coach
  Future<http.Response> deleteCoach(String id) async {
    //print('📌 [CoachProvider] → Iniciando deleteCoach($id)');
    final res = await http.delete(
      Uri.parse('$url/delete/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': userSession.session_token ?? ''
      },
    );

    //print('📥 Respuesta deleteCoach: status=${res.statusCode}, body=${res.body}');
    return res;
  }

  // Actualizar coach sin imagen
  Future<http.Response> updateWithoutImage({
    required User user,
    required Coach coach,
    required List<Schedule> schedules,
  }) async {
    //print('📌 [CoachProvider] → Iniciando updateWithoutImage()');
    final body = {
      'user': user.toJson(),
      'coach': coach.toJson(),
      'schedule': schedules.map((s) => s.toJson()).toList(),
    };

    //print('📤 Body enviado: $body');

    final response = await http.put(
      Uri.parse('$url/updateWithoutImage'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': userSession.session_token ?? '',
      },
      body: json.encode(body),
    );

    //print('📥 Respuesta updateWithoutImage: status=${response.statusCode}, body=${response.body}');
    return response;
  }

  // Actualizar coach con imagen
  Future<Stream> updateWithImage({
    required User user,
    required Coach coach,
    required List<Schedule> schedules,
    required File image,
  }) async {
    //print('📌 [CoachProvider] → Iniciando updateWithImage()');
    //print('📤 User: ${user.toJson()}');
    //print('📤 Coach: ${coach.toJson()}');
    //print('📤 Schedule: ${schedules.map((s) => s.toJson()).toList()}');
    //print('🖼 Imagen: ${image.path}');

    Uri uri =
    Uri.parse('${Environment.API_URL_OLD}/api/coachs/updateWithImage');
    final request = http.MultipartRequest('PUT', uri);

    request.headers['Authorization'] = userSession.session_token ?? '';

    request.files.add(http.MultipartFile(
      'image',
      http.ByteStream(image.openRead().cast()),
      await image.length(),
      filename: basename(image.path),
    ));

    request.fields['user'] = json.encode(user.toJson());
    request.fields['coach'] = json.encode(coach.toJson());
    request.fields['schedule'] =
        json.encode(schedules.map((s) => s.toJson()).toList());

    final response = await request.send();
    //print('📥 Respuesta updateWithImage: statusCode=${response.statusCode}');
    return response.stream.transform(utf8.decoder);
  }

  // Actualizar horarios
  Future<http.Response> updateSchedule(
      String coachId, List<Schedule> schedules) async {
    //print('📌 [CoachProvider] → Iniciando updateSchedule($coachId)');
    final body = {
      'id_user': coachId,
      'schedule': schedules.map((e) => e.toJson()).toList(),
    };

    //print('📤 Body enviado: $body');

    final response = await http.put(
      Uri.parse('$url/updateSchedule'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': userSession.session_token ?? '',
      },
      body: json.encode(body),
    );

    //print('📥 Respuesta updateSchedule: status=${response.statusCode}, body=${response.body}');
    return response;
  }

  Future<http.Response> setState(String id, int state) async {
    final response = await http.put(
      Uri.parse('$url/setState/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': userSession.session_token ?? ''
      },
      body: json.encode({'state': state}),
    );
    return response;
  }
}
