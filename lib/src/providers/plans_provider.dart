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
  // Para añadir el jwt
  User userSession = User.fromJson(GetStorage().read('user') ?? {});

  // URL base
  String url = '${Environment.API_URL}api/plans';

  // Registrar un plan - con imagen
  Future<Stream> createWithImage(Plan plan, File image) async {
    Uri uri =
        Uri.parse('${Environment.API_URL_OLD}/api/plans/registerWithImage');
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = userSession.session_token ?? '';
    request.files.add(http.MultipartFile(
      'image',
      http.ByteStream(image.openRead().cast()),
      await image.length(),
      filename: basename(image.path),
    ));
    request.fields['plan'] = json.encode(plan.toJson());

    final response = await request.send();
    return response.stream.transform(utf8.decoder);
  }

  // Listar todos los planes
  Future<List<Plan>> getAll() async {
    //print('Token que se envía al backend: ${userSession.session_token}');
    final response = await get('$url/getAll', headers: {
      'Content-Type': 'application/json',
      'Authorization': userSession.session_token ?? ''
    });

    //print('STATUS: ${response.statusCode}');
    //print('BODY: ${response.body}');

    if (response.statusCode == 401) return [];

    final Map<String, dynamic> body = response.body;
    final List<dynamic> list = body['data'] ?? [];

    return Plan.fromJsonList(list);
  }

  // Eliminar plan
  Future<http.Response> deletePlan(String id) async {
    final res = await http.delete(
      Uri.parse('$url/delete/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': userSession.session_token ?? ''
      },
    );

    //print('BODY: ${res.body}');
    //print('❌ PLAN DELETE: ${res.statusCode}');
    return res;
  }

  // Actualizar plan con imagen
  Future<Stream<String>> updateWithImage(Plan plan, File image) async {
    Uri uri = Uri.parse('${Environment.API_URL_OLD}/api/plans/updateWithImage');
    final request = http.MultipartRequest('PUT', uri);

    request.headers['Authorization'] = userSession.session_token ?? '';
    request.files.add(http.MultipartFile(
      'image',
      http.ByteStream(image.openRead().cast()),
      await image.length(),
      filename: basename(image.path),
    ));

    request.fields['plan'] = json.encode(plan.toJson());

    final response = await request.send();
    return response.stream.transform(utf8.decoder);
  }

  // Actualizar plan sin imagen
  Future<http.Response> updateWithoutImage(Plan plan) async {
    Uri uri = Uri.parse('${Environment.API_URL_OLD}/api/plans/update');
    final res = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': userSession.session_token ?? ''
      },
      body: json.encode(plan.toJson()),
    );

    //print('📡 PUT sin imagen: ${res.statusCode}');
    return res;
  }
}
