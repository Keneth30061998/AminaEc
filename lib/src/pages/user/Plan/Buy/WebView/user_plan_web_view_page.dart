import 'package:amina_ec/src/pages/user/Plan/Buy/WebView/user_plan_web_view_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../../utils/color.dart';

class WebviewPage extends StatelessWidget {
  WebviewController con = Get.put(WebviewController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _appBarTitle(),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => con.webController.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: con.webController),
          Obx(() => con.loading.value
              ? const Center(child: CircularProgressIndicator())
              : const SizedBox()),
        ],
      ),
    );
  }

  Widget _appBarTitle() {
    return Text(
      'Agregar Targeta',
      style: GoogleFonts.montserrat(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        color: almostBlack,
      ),
    );
  }
}
