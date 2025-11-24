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

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': userSession.session_token ?? ''
  };

  Future<List<CardModel>> listByUser() async {
    final uri = Uri.parse("$_baseUrl/cards/$_userId");
    final resp = await http.get(uri, headers: _headers);

    if (resp.statusCode == 200) {
      final body = json.decode(resp.body);
      return cardModelFromJson(json.encode(body['data']));
    }
    return [];
  }

  Future<ResponseApi> deleteCard(String token) async {
    final uri = Uri.parse("$_baseUrl/cards/$_userId/$token");
    final resp = await http.delete(uri, headers: _headers);
    return responseApiFromJson(resp.body);
  }

  Future<ResponseApi> payWithNewCard({
    required Map<String, dynamic> card,
    required double amount,
    required double taxPct,
    required String description,
    int installmentsCount = 1,
  }) async {
    final uri = Uri.parse("$_baseUrl/pay");
    final body = {
      "userId": _userId,
      "email": _email,
      "card": card,
      "amount": amount,
      "tax_percentage": taxPct,
      "description": description,
      "installments_count": installmentsCount,
    };

    final resp =
    await http.post(uri, headers: _headers, body: json.encode(body));
    return responseApiFromJson(resp.body);
  }

  Future<ResponseApi> payWithToken({
    required String token,
    required double amount,
    required double taxPct,
    required String description,
    String? confirmCode,
    int installmentsCount = 1,
    int? planId, // <- nuevo
  }) async {
    final uri = Uri.parse("$_baseUrl/pay/token");
    final Map<String, dynamic> body = {
      "userId": _userId,
      "email": _email,
      "token": token,
      "amount": amount,
      "tax_percentage": taxPct,
      "description": description,
      "installments_count": installmentsCount,
    };

    if (confirmCode != null && confirmCode.isNotEmpty) {
      body["confirm_code"] = confirmCode;
    }
    if (planId != null) {
      body["plan_id"] = planId; // <- importante
    }

    final resp =
    await http.post(uri, headers: _headers, body: json.encode(body));
    return responseApiFromJson(resp.body);
  }


  Future<ResponseApi> confirmPayment({
    required String token,
    required String transactionId,
    required String confirmCode,
    int? planId, // <- nuevo
  }) async {
    final uri = Uri.parse("$_baseUrl/pay/confirm");
    final Map<String, dynamic> body = {
      "userId": _userId,
      "email": _email,
      "token": token,
      "transaction_id": transactionId,
      "confirm_code": confirmCode,
    };

    if (planId != null) {
      body["plan_id"] = planId;
    }

    final resp =
    await http.post(uri, headers: _headers, body: json.encode(body));
    return responseApiFromJson(resp.body);
  }


  Future<ResponseApi> getTransactionStatus(String txId) async {
    final uri = Uri.parse("$_baseUrl/transaction/status/$txId");
    final resp = await http.get(uri, headers: _headers);
    return responseApiFromJson(resp.body);
  }

  // ============================================
  // 🔥 NUEVO: Obtiene si la tarjeta soporta diferido y opciones reales del backend
  // ============================================
  Future<Map<String, dynamic>> getPaymentOptions(String token) async {
    final uri = Uri.parse("$_baseUrl/cards/$token/payment-options");

    try {
      final resp = await http.get(uri, headers: _headers);

      if (resp.statusCode == 200) {
        final body = json.decode(resp.body);

        if (body is Map<String, dynamic>) {
          return {
            "success": body["success"] == true,
            "supports_installments":
            body["supports_installments"] == true ||
                body["supportsInstallments"] == true,
            "installment_options":
            body["installment_options"] ??
                body["installmentOptions"] ??
                [],
            ...body,
          };
        }

        return {
          "success": false,
          "supports_installments": false,
          "installment_options": []
        };
      } else {
        return {
          "success": false,
          "supports_installments": false,
          "installment_options": []
        };
      }
    } catch (e) {
      print("❌ ERROR getPaymentOptions: $e");
      return {
        "success": false,
        "supports_installments": false,
        "installment_options": []
      };
    }
  }
}
