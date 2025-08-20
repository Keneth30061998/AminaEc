import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewController extends GetxController {
  late final WebViewController webController;

  final loading = true.obs;
  final url = 'https://flutter.dev'.obs; // Puedes cambiar este link luego

  @override
  void onInit() {
    super.onInit();
    webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url.value))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            loading.value = true;
          },
          onPageFinished: (url) {
            loading.value = false;
          },
        ),
      );
  }

  void updateUrl(String newUrl) {
    url.value = newUrl;
    webController.loadRequest(Uri.parse(newUrl));
  }
}
