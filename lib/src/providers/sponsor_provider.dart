// lib/src/providers/sponsor_provider.dart
import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

import '../environment/environment.dart';
import '../models/sponsor.dart';
import '../models/user.dart';

class SponsorProvider extends GetConnect {
  User userSession = User.fromJson(GetStorage().read('user') ?? {});
  String url = '${Environment.API_URL}api/sponsors';

  // Listar todos los sponsors
  Future<List<Sponsor>> getAll() async {
    final response = await get('$url/getAll', headers: {
      'Content-Type': 'application/json',
      'Authorization': userSession.session_token ?? ''
    });

    if (response.statusCode == 401) {
      return [];
    }

    try {
      final List<dynamic> list = response.body['data'] ?? [];
      return Sponsor.fromJsonList(list);
    } catch (e) {
      return [];
    }
  }

  // Crear sponsor con imagen (multipart/form-data)
  Future<Stream<String>> createWithImage(Sponsor sponsor, File image) async {
    Uri uri = Uri.parse('$url/createWithImage');
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = userSession.session_token ?? '';
    request.fields['sponsor'] = json.encode(sponsor.toJson());

    request.files.add(http.MultipartFile(
      'image',
      http.ByteStream(image.openRead().cast()),
      await image.length(),
      filename: basename(image.path),
    ));

    final response = await request.send();

    if (response.statusCode != 200 && response.statusCode != 201) {
      // intentar leer el body por si viene HTML o error legible
      final bodyStr = await response.stream.bytesToString();
      throw Exception(
          'Error creando sponsor: status=${response.statusCode}, body=$bodyStr');
    }

    return response.stream.transform(utf8.decoder);
  }

  // Actualizar sponsor con imagen
  Future<Stream<String>> updateWithImage(Sponsor sponsor, File image) async {
    Uri uri = Uri.parse('$url/updateWithImage');
    final request = http.MultipartRequest('PUT', uri);

    request.headers['Authorization'] = userSession.session_token ?? '';
    request.fields['sponsor'] = json.encode(sponsor.toJson());

    request.files.add(http.MultipartFile(
      'image',
      http.ByteStream(image.openRead().cast()),
      await image.length(),
      filename: basename(image.path),
    ));

    final response = await request.send();

    if (response.statusCode != 200 && response.statusCode != 201) {
      final bodyStr = await response.stream.bytesToString();
      throw Exception(
          'Error actualizando sponsor (imagen): status=${response.statusCode}, body=$bodyStr');
    }

    return response.stream.transform(utf8.decoder);
  }

  // Actualizar sponsor sin imagen (JSON)
  Future<http.Response> updateWithoutImage(Sponsor sponsor) async {
    Uri uri = Uri.parse('$url/update');
    final res = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': userSession.session_token ?? ''
      },
      body: json.encode(sponsor.toJson()),
    );

    return res;
  }

  // Eliminar sponsor
  Future<http.Response> deleteSponsor(String id) async {
    final res = await http.delete(
      Uri.parse('$url/delete/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': userSession.session_token ?? ''
      },
    );

    return res;
  }
}
