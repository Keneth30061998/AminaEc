import 'dart:convert';
import 'dart:io';

import 'package:amina_ec/src/environment/environment.dart';
import 'package:amina_ec/src/models/user.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

import '../models/plan.dart';

class PlanProvider extends GetConnect {
  User userSession = User.fromJson(GetStorage().read('user') ?? {});
  String url = '${Environment.API_URL}api/plans';

  // Registrar un plan - con imagen
  Future<Stream> createWithImage(Plan plan, File image) async {
    print('📌 [PlanProvider] → Iniciando createWithImage()');
    print('📤 Plan: ${plan.toJson()}');
    print('🖼 Imagen: ${image.path}');
    print('🔑 Token: ${userSession.session_token}');

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
    print('📥 Respuesta createWithImage: statusCode=${response.statusCode}');
    return response.stream.transform(utf8.decoder);
  }

  // Listar todos los planes
  Future<List<Plan>> getAll() async {
    print('📌 [PlanProvider] → Iniciando getAll()');
    final response = await get('$url/getAll', headers: {
      'Content-Type': 'application/json',
      'Authorization': userSession.session_token ?? ''
    });

    print('📥 Respuesta cruda en getAll(): status=${response.statusCode}, body=${response.body}');

    if (response.statusCode == 401) {
      print('❌ No autorizado en getAll()');
      return [];
    }

    try {
      final plans = await compute(_parsePlans, response.body);
      print('📊 Planes obtenidos: ${plans.length}');
      return plans;
    } catch (e) {
      print('❌ Error parsing plans: $e');
      return [];
    }
  }

  // Función para parsear en background
  static List<Plan> _parsePlans(dynamic responseBody) {
    print('🔄 Parseando planes en _parsePlans()');
    Map<String, dynamic> body;
    if (responseBody is Map<String, dynamic>) {
      body = responseBody;
    } else if (responseBody is String) {
      body = json.decode(responseBody);
    } else {
      body = {};
    }

    final List<dynamic> list = body['data'] ?? [];
    print('📊 Cantidad de planes en JSON: ${list.length}');
    return Plan.fromJsonList(list);
  }

  // Eliminar plan
  Future<http.Response> deletePlan(String id) async {
    print('📌 [PlanProvider] → Iniciando deletePlan($id)');
    final res = await http.delete(
      Uri.parse('$url/delete/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': userSession.session_token ?? ''
      },
    );

    print('📥 Respuesta deletePlan: status=${res.statusCode}, body=${res.body}');
    return res;
  }

  // Actualizar plan con imagen
  Future<Stream<String>> updateWithImage(Plan plan, File image) async {
    print('📌 [PlanProvider] → Iniciando updateWithImage()');
    print('📤 Plan: ${plan.toJson()}');
    print('🖼 Imagen: ${image.path}');

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
    print('📥 Respuesta updateWithImage: statusCode=${response.statusCode}');
    return response.stream.transform(utf8.decoder);
  }

  // Actualizar plan sin imagen
  Future<http.Response> updateWithoutImage(Plan plan) async {
    print('📌 [PlanProvider] → Iniciando updateWithoutImage()');
    print('📤 Plan: ${plan.toJson()}');

    Uri uri = Uri.parse('${Environment.API_URL_OLD}/api/plans/update');
    final res = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': userSession.session_token ?? ''
      },
      body: json.encode(plan.toJson()),
    );

    print('📥 Respuesta updateWithoutImage: status=${res.statusCode}, body=${res.body}');
    return res;
  }
}
