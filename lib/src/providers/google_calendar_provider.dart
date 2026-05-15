import 'dart:convert';
import 'dart:io';

import 'package:amina_ec/src/environment/environment.dart';
import 'package:amina_ec/src/models/response_api.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';

class GoogleCalendarProvider {
  final String _baseUrl = Environment.API_URL;
  Map<String, dynamic> get _user => GetStorage().read('user') ?? {};

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': (_user['session_token'] ?? '').toString(),
  };

  static const List<String> _scopes = <String>[
    'https://www.googleapis.com/auth/calendar.events',
  ];

  void _logHeader(String title) {
    print("\n====================================================");
    print("🟦 GoogleCalendarProvider :: $title");
    print("====================================================");
  }

  void _log(String msg) => print("🟦 $msg");
  void _logError(String msg) => print("🟥 $msg");

  Future<ResponseApi> status() async {
    final url = '${_baseUrl}api/google-calendar/status';

    try {
      final res = await http.get(Uri.parse(url), headers: _headers);
      return ResponseApi.fromJson(json.decode(res.body));
    } catch (e) {
      return ResponseApi(success: false, message: 'Error: $e');
    }
  }

  /// ============================================================
  /// CONNECT (ANDROID OK + FIX REAL iOS)
  /// ============================================================
  Future<ResponseApi> connect() async {
    _logHeader("connect()");

    try {
      final GoogleSignIn signIn = GoogleSignIn.instance;

      _log(
          "✅ initialize(...) serverClientId=${Environment.GOOGLE_WEB_CLIENT_ID}");

      await signIn.initialize(
        serverClientId: Environment.GOOGLE_WEB_CLIENT_ID,
      );

      /// 🔥 FIX REAL PARA iOS
      /// iOS reutiliza grants OAuth aunque cierres sesión normal.
      /// Debemos forzar logout ANTES del authenticate.
      if (Platform.isIOS) {
        _log("🍏 iOS detected — forcing fresh OAuth consent");

        try {
          await signIn.disconnect();
          await Future.delayed(const Duration(milliseconds: 700));
        } catch (e) {
          _log("disconnect ignored: $e");
        }
      }

      /// LOGIN
      _log("👤 authenticate()...");
      final GoogleSignInAccount account =
      await signIn.authenticate(scopeHint: _scopes);

      _log("✅ account.email=${account.email}");

      /// SERVER AUTH CODE (OFFLINE ACCESS)
      _log("🔎 authorizeServer(scopes)...");
      final GoogleSignInServerAuthorization? serverAuth =
      await account.authorizationClient.authorizeServer(_scopes);

      _log("📌 serverAuth null? ${serverAuth == null}");

      if (serverAuth == null || serverAuth.serverAuthCode.isEmpty) {
        _logError("❌ Google no entregó authorization code");

        return ResponseApi(
          success: false,
          message:
          "Google no entregó authorization code. Reintenta conectar.",
        );
      }

      final authCode = serverAuth.serverAuthCode;

      _log("✅ serverAuthCode length=${authCode.length}");

      /// BACKEND EXCHANGE
      final url = '${_baseUrl}api/google-calendar/connect';

      final res = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: json.encode({'authCode': authCode}),
      );

      _log("🌐 Backend StatusCode: ${res.statusCode}");
      _log("🌐 Backend Raw response: ${res.body}");

      if (res.body.isEmpty) {
        return ResponseApi(
            success: false, message: "Respuesta vacía del backend");
      }

      final decoded = json.decode(res.body);

      /// Limpieza local (NO revoca permisos Google)
      try {
        await signIn.signOut();
      } catch (_) {}

      return ResponseApi.fromJson(decoded);
    } on GoogleSignInException catch (e) {
      final codeStr = e.code.toString();

      _logError("❌ GoogleSignInException: $codeStr");

      return ResponseApi(
        success: false,
        message: "Google Sign-In falló: $codeStr",
      );
    } catch (e) {
      _logError("❌ Error general connect(): $e");

      return ResponseApi(
        success: false,
        message: "Error conectando Google Calendar",
      );
    }
  }

  /// ============================================================
  /// FORCE CONSENT
  /// ============================================================
  Future<ResponseApi> connectForceConsent() async {
    _logHeader("connectForceConsent()");

    try {
      final GoogleSignIn signIn = GoogleSignIn.instance;

      await signIn.initialize(
        serverClientId: Environment.GOOGLE_WEB_CLIENT_ID,
      );

      await signIn.disconnect();
      await Future.delayed(const Duration(milliseconds: 700));

      final account =
      await signIn.authenticate(scopeHint: _scopes);

      final serverAuth =
      await account.authorizationClient.authorizeServer(_scopes);

      if (serverAuth == null || serverAuth.serverAuthCode.isEmpty) {
        return ResponseApi(
            success: false, message: "No se obtuvo serverAuthCode");
      }

      final res = await http.post(
        Uri.parse('${_baseUrl}api/google-calendar/connect'),
        headers: _headers,
        body: json.encode({'authCode': serverAuth.serverAuthCode}),
      );

      return ResponseApi.fromJson(json.decode(res.body));
    } catch (e) {
      return ResponseApi(
          success: false, message: "Error connectForceConsent: $e");
    }
  }

  Future<ResponseApi> disconnect() async {
    final url = '${_baseUrl}api/google-calendar/disconnect';

    try {
      final res = await http.delete(Uri.parse(url), headers: _headers);
      return ResponseApi.fromJson(json.decode(res.body));
    } catch (e) {
      return ResponseApi(success: false, message: 'Error: $e');
    }
  }
}