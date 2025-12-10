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

  // ==========================================================
  // REGISTER COACH WITH IMAGE
  // ==========================================================
  Future<Stream> registerCoach({
    required User user,
    required Coach coach,
    required List<Schedule> schedule,
    required File image,
  }) async {

    print("\n==============================================");
    print("🟦 [registerCoach] Iniciando registro de coach");
    print("==============================================");

    Uri uri = Uri.parse('${Environment.API_URL_OLD}/api/coachs/createWithImage');
    print("📡 URL: $uri");

    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = userSession.session_token ?? '';

    print("📋 Headers enviados:");
    print(request.headers);

    // Imagen
    print("🖼 Imagen adjunta: ${image.path}");
    request.files.add(http.MultipartFile(
      'image',
      http.ByteStream(image.openRead().cast()),
      await image.length(),
      filename: basename(image.path),
    ));

    // Body
    request.fields['user'] = json.encode(user.toJson());
    request.fields['coach'] = json.encode(coach.toJson());

    print("📤 Schedules enviados:");
    for (var s in schedule) {
      print("  → ${s.toJson()}");
    }

    request.fields['schedule'] =
        json.encode(schedule.map((s) => s.toJson()).toList());

    print("📦 Campos enviados en Multipart:");
    request.fields.forEach((k, v) => print("  $k: $v"));

    final response = await request.send();

    print("📥 Respuesta received statusCode=${response.statusCode}");

    return response.stream.transform(utf8.decoder);
  }

  // ==========================================================
  // GET ALL COACHS
  // ==========================================================
  Future<List<Coach>> getAll() async {
    print("\n==============================================");
    print("🟧 [getAll] Cargando coaches desde API");
    print("==============================================");

    final endpoint = '$url/getAll';
    print("📡 URL: $endpoint");

    final response = await get(endpoint, headers: {
      'Content-Type': 'application/json',
      'Authorization': userSession.session_token ?? ''
    });

    print("📥 StatusCode: ${response.statusCode}");
    print("📥 Body crudo: ${response.body}");

    if (response.statusCode == 401) {
      print("❌ No autorizado para obtener coaches");
      return [];
    }

    try {
      final coaches = await compute(_parseCoaches, response.body);
      print("📌 Coaches parseados: ${coaches.length}");
      return coaches;
    } catch (e) {
      print("❌ Error parseando coaches: $e");
      return [];
    }
  }

  static List<Coach> _parseCoaches(dynamic responseBody) {
    print("🔄 [parseCoaches] Procesando coaches...");

    Map<String, dynamic> body;

    try {
      if (responseBody is Map<String, dynamic>) {
        body = responseBody;
      } else if (responseBody is String) {
        body = json.decode(responseBody);
      } else {
        body = {};
      }
    } catch (e) {
      print("❌ Error en JSON decode: $e");
      return [];
    }

    final List<dynamic> list = body['data'] ?? [];
    print("📊 Total coaches encontrados: ${list.length}");

    return Coach.fromJsonList(list);
  }

  // ==========================================================
  // DELETE COACH
  // ==========================================================
  Future<http.Response> deleteCoach(String id) async {
    print("\n==============================================");
    print("🟥 [deleteCoach] Eliminando coach ID: $id");
    print("==============================================");

    final endpoint = '$url/delete/$id';
    print("📡 URL: $endpoint");

    final res = await http.delete(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': userSession.session_token ?? ''
      },
    );

    print("📥 StatusCode: ${res.statusCode}");
    print("📥 Respuesta: ${res.body}");

    return res;
  }

  // ==========================================================
  // UPDATE COACH WITHOUT IMAGE
  // ==========================================================
  Future<http.Response> updateWithoutImage({
    required User user,
    required Coach coach,
    required List<Schedule> schedules,
  }) async {

    print("\n=======================================================");
    print("🟪 [updateWithoutImage] Actualizando coach SIN imagen");
    print("=======================================================\n");

    final endpoint = '$url/updateWithoutImage';
    print("📡 URL: $endpoint");

    final body = {
      'user': user.toJson(),
      'coach': coach.toJson(),
      'schedule': schedules.map((s) => s.toJson()).toList(),
    };

    print("📤 Body JSON enviado:");
    print(json.encode(body));

    final response = await http.put(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': userSession.session_token ?? '',
      },
      body: json.encode(body),
    );

    print("📥 StatusCode: ${response.statusCode}");
    print("📥 Body recibido: ${response.body}");

    return response;
  }

  // ==========================================================
  // UPDATE COACH WITH IMAGE
  // ==========================================================
  Future<Stream> updateWithImage({
    required User user,
    required Coach coach,
    required List<Schedule> schedules,
    required File image,
  }) async {

    print("\n=======================================================");
    print("🟦 [updateWithImage] Actualizando coach CON imagen");
    print("=======================================================\n");

    Uri uri = Uri.parse('${Environment.API_URL_OLD}/api/coachs/updateWithImage');
    print("📡 URL: $uri");

    final request = http.MultipartRequest('PUT', uri);
    request.headers['Authorization'] = userSession.session_token ?? '';

    print("📋 Headers:");
    print(request.headers);

    print("🖼 Imagen: ${image.path}");
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

    print("📤 Campos enviados:");
    request.fields.forEach((k, v) => print("  $k: $v"));

    final response = await request.send();

    print("📥 StatusCode: ${response.statusCode}");

    return response.stream.transform(utf8.decoder);
  }

  // ==========================================================
  // UPDATE SCHEDULE
  // ==========================================================
  Future<http.Response> updateSchedule(
      String coachId, List<Schedule> schedules) async {

    print("\n==============================================");
    print("🟩 [updateSchedule] Actualizando horario");
    print("==============================================");

    final endpoint = '$url/updateSchedule';
    print("📡 URL: $endpoint");

    final body = {
      'id_user': coachId,
      'schedule': schedules.map((e) => e.toJson()).toList(),
    };

    print("📤 Body enviado a backend:");
    print(json.encode(body));

    final response = await http.put(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': userSession.session_token ?? '',
      },
      body: json.encode(body),
    );

    print("📥 StatusCode: ${response.statusCode}");
    print("📥 Body: ${response.body}");

    return response;
  }

  // ==========================================================
  // CHANGE STATE
  // ==========================================================
  Future<http.Response> setState(String id, int state) async {
    print("\n==============================================");
    print("🟦 [setState] Cambiando estado del coach");
    print("==============================================");

    final endpoint = '$url/setState/$id';
    print("📡 URL: $endpoint");

    final response = await http.put(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': userSession.session_token ?? ''
      },
      body: json.encode({'state': state}),
    );

    print("📥 StatusCode: ${response.statusCode}");
    print("📥 Body: ${response.body}");

    return response;
  }
}
