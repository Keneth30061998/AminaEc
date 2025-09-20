import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../../environment/environment.dart';

class AddCardWebViewPage extends StatefulWidget {
  const AddCardWebViewPage({super.key});

  @override
  State<AddCardWebViewPage> createState() => _AddCardWebViewPageState();
}

class _AddCardWebViewPageState extends State<AddCardWebViewPage> {
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();

    // Configura el controller
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            // Detecta cuando el HTML ejecuta window.close() → carga about:blank
            if (request.url == 'about:blank') {
              Navigator.of(context).pop(true);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    // Construye la URL con parámetros de query
    final args = Get.arguments as Map<String, String>;
    final userId = args['userId']!;
    final email = args['email']!;

    final base = Environment.API_URL.replaceAll(RegExp(r'/+$'), '');
    final uri = Uri.parse('$base/cards/tokenize').replace(
      queryParameters: {
        'userId': userId,
        'email': email,
      },
    );

    // Carga la petición
    _webViewController.loadRequest(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarTitle(),
      body: SafeArea(
        child: WebViewWidget(controller: _webViewController),
      ),
    );
  }

  AppBar _appBarTitle() {
    return AppBar(
      title: Text(
        'Agregar Tarjeta',
        style: GoogleFonts.montserrat(fontWeight: FontWeight.w900),
      ),
    );
  }
}
