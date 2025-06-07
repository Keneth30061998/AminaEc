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
  String url = Environment.API_URL + 'api/coachs';

  Future<Stream> registerCoach({
    required User user,
    required Coach coach,
    required List<Schedule> schedule,
    required File image,
  }) async {
    Uri uri = Uri.http(Environment.API_URL_OLD, '/api/coachs/createWithImage');
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

  Future<List<Coach>> getAll() async {
    final response = await get('$url/getAll', headers: {
      'Content-Type': 'application/json',
      'Authorization': userSession.session_token ?? ''
    });

    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}');

    if (response.statusCode == 401) {
      return [];
    }

    // El endpoint envuelve la lista real en la clave "data"
    final Map<String, dynamic> body = response.body;
    final List<dynamic> list = body['data'] ?? [];

    return Coach.fromJsonList(list);
  }
}
