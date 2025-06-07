import 'dart:convert';
import 'dart:io';

import 'package:amina_ec/src/environment/environment.dart';
import 'package:amina_ec/src/models/user.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

import '../models/plan.dart';

class PlanProvider extends GetConnect {
  //Para añadir el jwt
  User userSession = User.fromJson(GetStorage().read('user') ?? {});

  //URL
  String url = Environment.API_URL + 'api/plans';

  // registrar un plan - con imagen
  Future<Stream> createWithImage(Plan plan, File image) async {
    Uri uri = Uri.http(Environment.API_URL_OLD, '/api/plans/registerWithImage');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = userSession.session_token ?? '';
    request.files.add(http.MultipartFile(
      'image',
      http.ByteStream(image.openRead().cast()),
      await image.length(),
      filename: basename(image.path),
    ));
    request.fields['plan'] = json.encode(plan);
    final response = await request.send();
    return response.stream.transform(utf8.decoder);
  }

  //Listar los planes
  Future<List<Plan>> getAll() async {
    final response = await get('$url/getAll', headers: {
      'Content-Type': 'application/json',
      'Authorization': userSession.session_token ?? ''
    });

    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}');

    if (response.statusCode == 401) {
      Get.snackbar('Error', 'No autorizado');
      return [];
    }
    List<Plan> plans = Plan.fromJsonList(response.body);
    return plans;
  }

  // ✅ Renombrado para evitar conflicto con GetConnect.delete()
  Future<http.Response> deletePlan(String id) async {
    final res = await http.delete(
      Uri.parse('$url/delete/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': userSession.session_token ?? ''
      },
    );

    print('❌ PLAN DELETE: ${res.statusCode}');
    return res;
  }
}
