import 'dart:convert';
import 'dart:io';

import 'package:amina_ec/src/environment/environment.dart';
import 'package:amina_ec/src/models/coach.dart';
import 'package:amina_ec/src/models/schedule.dart';
import 'package:amina_ec/src/models/user.dart';
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
    return response.stream.transform(utf8.decoder);
  }

  // Obtener todos los coaches
  Future<List<Coach>> getAll() async {
    final response = await get('$url/getAll', headers: {
      'Content-Type': 'application/json',
      'Authorization': userSession.session_token ?? ''
    });

    if (response.statusCode == 401) return [];

    final Map<String, dynamic> body = response.body;
    final List<dynamic> list = body['data'] ?? [];

    return Coach.fromJsonList(list);
  }

  // Eliminar coach
  Future<http.Response> deleteCoach(String id) async {
    final res = await http.delete(
      Uri.parse('$url/delete/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': userSession.session_token ?? ''
      },
    );

    //print('COACH DELETE: ${res.statusCode}');
    return res;
  }

  // Actualizar coach sin imagen
  Future<http.Response> updateWithoutImage({
    required User user,
    required Coach coach,
    required List<Schedule> schedules,
  }) async {
    final body = {
      'user': user.toJson(),
      'coach': coach.toJson(),
      'schedule': schedules.map((s) => s.toJson()).toList(),
    };

    final response = await http.put(
      Uri.parse('$url/updateWithoutImage'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': userSession.session_token ?? '',
      },
      body: json.encode(body),
    );

    return response;
  }

  // Actualizar coach con imagen
  Future<Stream> updateWithImage({
    required User user,
    required Coach coach,
    required List<Schedule> schedules,
    required File image,
  }) async {
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
    return response.stream.transform(utf8.decoder);
  }

  // Actualizar horarios
  Future<http.Response> updateSchedule(
      String coachId, List<Schedule> schedules) async {
    final body = {
      'id_user': coachId,
      'schedule': schedules.map((e) => e.toJson()).toList(),
    };
    final response = await http.put(
      Uri.parse('$url/updateSchedule'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': userSession.session_token ?? '',
      },
      body: json.encode(body),
    );
    return response;
  }
}
