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

  /// Construye URL base respetando si Environment.API_URL ya tiene o no la barra final.
  String _buildBaseUrl(String path) {
    final base = Environment.API_URL ?? '';
    if (base.endsWith('/')) {
      return '$base$path';
    } else {
      return '$base/$path';
    }
  }

  /// Base completa para sponsors (ej: https://apiv1.pruebasinventario.com/api/sponsors)
  String get _baseSponsorsUrl => _buildBaseUrl('api/sponsors');

  /// Mantengo tu método original (para uso admin/listados sin filtro)
  Future<List<Sponsor>> getAll() async {
    final uri = Uri.parse('$_baseSponsorsUrl/getAll');
    final response = await get(uri.toString(), headers: {
      'Content-Type': 'application/json',
      'Authorization': userSession.session_token ?? ''
    });

    if (response.statusCode == 401) return [];

    try {
      final List<dynamic> list = response.body['data'] ?? [];
      return Sponsor.fromJsonList(list);
    } catch (_) {
      return [];
    }
  }

  /// NUEVO: Obtener sponsors dependiendo del rol (target)
  Future<List<Sponsor>> getAllByTarget(String targetRole) async {
    final uri = Uri.parse('$_baseSponsorsUrl/getAll?target=$targetRole');
    final response = await get(uri.toString(), headers: {
      'Content-Type': 'application/json',
      'Authorization': userSession.session_token ?? ''
    });

    if (response.statusCode == 401) return [];

    try {
      final List<dynamic> list = response.body['data'] ?? [];
      return Sponsor.fromJsonList(list);
    } catch (_) {
      return [];
    }
  }

  /// Crear sponsor con imagen (multipart/form-data)
  Future<Stream<String>> createWithImage(Sponsor sponsor, File image) async {
    final uri = Uri.parse('$_baseSponsorsUrl/createWithImage');
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
      final bodyStr = await response.stream.bytesToString();
      throw Exception(
          'Error creando sponsor: status=${response.statusCode}, body=$bodyStr');
    }

    return response.stream.transform(utf8.decoder);
  }

  /// Actualizar sponsor con imagen
  Future<Stream<String>> updateWithImage(Sponsor sponsor, File image) async {
    final uri = Uri.parse('$_baseSponsorsUrl/updateWithImage');
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

  /// Actualizar sponsor sin imagen (JSON)
  Future<http.Response> updateWithoutImage(Sponsor sponsor) async {
    final uri = Uri.parse('$_baseSponsorsUrl/update');
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

  /// Eliminar sponsor
  Future<http.Response> deleteSponsor(String id) async {
    final uri = Uri.parse('$_baseSponsorsUrl/delete/$id');
    final res = await http.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': userSession.session_token ?? ''
      },
    );

    return res;
  }
}
