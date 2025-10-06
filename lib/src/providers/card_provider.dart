import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../environment/environment.dart';
import '../models/card.dart';
import '../models/response_api.dart';
import '../models/user.dart';

class CardProvider {
  final String _baseUrl = Environment.API_URL_SOCKET;
  final GetStorage _box = GetStorage();

  User userSession = User.fromJson(GetStorage().read('user') ?? {});

  String? get _userId => _box.read('user')?['id']?.toString();
  String? get _email => _box.read('user')?['email']?.toString();
  //String? get _token => _box.read('user')?['session_token']; //  JWT

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': userSession.session_token ?? ''
      };

  Future<List<CardModel>> listByUser() async {
    final uri = Uri.parse("$_baseUrl/cards/$_userId");
    //print('🟢 listByUser: GET $uri');

    final resp = await http.get(uri, headers: _headers);
    //print('🟢 listByUser: statusCode = ${resp.statusCode}');
    //print('🟢 listByUser: body = ${resp.body}');

    if (resp.statusCode == 200) {
      final body = json.decode(resp.body);
      return cardModelFromJson(json.encode(body['data']));
    }
    return [];
  }

  Future<ResponseApi> deleteCard(String token) async {
    final uri = Uri.parse("$_baseUrl/cards/$_userId/$token");
    //print('🟢 deleteCard: DELETE $uri');

    final resp = await http.delete(uri, headers: _headers);
    //print('🟢 deleteCard: statusCode = ${resp.statusCode}');
    //print('🟢 deleteCard: body = ${resp.body}');

    return responseApiFromJson(resp.body);
  }

  Future<ResponseApi> payWithNewCard({
    required Map<String, dynamic> card,
    required double amount,
    required double taxPct,
    required String description,
  }) async {
    final uri = Uri.parse("$_baseUrl/pay");
    final body = {
      "userId": _userId,
      "email": _email,
      "card": card,
      "amount": amount,
      "tax_percentage": taxPct,
      "description": description,
    };

    //print('🟢 payWithNewCard: POST $uri');
    //print('🟢 payWithNewCard: body → ${json.encode(body)}');

    final resp =
        await http.post(uri, headers: _headers, body: json.encode(body));
    //print('🟢 payWithNewCard: statusCode = ${resp.statusCode}');
    //print('🟢 payWithNewCard: body = ${resp.body}');

    return responseApiFromJson(resp.body);
  }

  Future<ResponseApi> payWithToken({
    required String token,
    required double amount,
    required double taxPct,
    required String description,
    String? confirmCode,
  }) async {
    final uri = Uri.parse("$_baseUrl/pay/token");
    final body = {
      "userId": _userId,
      "email": _email,
      "token": token,
      "amount": amount,
      "tax_percentage": taxPct,
      "description": description,
    };
    if (confirmCode != null && confirmCode.isNotEmpty) {
      body["confirm_code"] = confirmCode;
    }

    //print('🟢 payWithToken: POST $uri');
    //print('🟢 payWithToken: body → ${json.encode(body)}');

    final resp =
        await http.post(uri, headers: _headers, body: json.encode(body));
    //print('🟢 payWithToken: statusCode = ${resp.statusCode}');
    //print('🟢 payWithToken: body = ${resp.body}');

    return responseApiFromJson(resp.body);
  }

  Future<ResponseApi> confirmPayment({
    required String token,
    required String transactionId,
    required String confirmCode,
  }) async {
    final uri = Uri.parse("$_baseUrl/pay/confirm");
    final body = {
      "userId": _userId,
      "email": _email,
      "token": token,
      "transaction_id": transactionId,
      "confirm_code": confirmCode,
    };

    //print('🟢 confirmPayment: POST $uri');
    //print('🟢 confirmPayment: body → ${json.encode(body)}');

    final resp =
        await http.post(uri, headers: _headers, body: json.encode(body));
    //print('🟢 confirmPayment: statusCode = ${resp.statusCode}');
    //print('🟢 confirmPayment: body = ${resp.body}');

    return responseApiFromJson(resp.body);
  }

  Future<ResponseApi> getTransactionStatus(String txId) async {
    final uri = Uri.parse("$_baseUrl/transaction/status/$txId");
    //print('🟢 getTransactionStatus: GET $uri');

    final resp = await http.get(uri, headers: _headers);
    //print('🟢 getTransactionStatus: statusCode = ${resp.statusCode}');
    //print('🟢 getTransactionStatus: body = ${resp.body}');

    return responseApiFromJson(resp.body);
  }
}
