import 'package:amina_ec/src/pages/user/Plan/Buy/AddCard/user_plan_buy_addCard_webview_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../../models/plan.dart';
import '../../../../../models/user.dart';

class UserPlanBuyAddCardController extends GetxController {

  // Variables observables del formulario de tarjeta
  var cardNumber = ''.obs;
  var expiryDate = ''.obs;
  var cvvCode = ''.obs;
  var cardHolderName = ''.obs;
  var isCvvFocused = false.obs;

  final GlobalKey<FormState> keyForm = GlobalKey<FormState>();

  late Plan plan;  // Plan recibido desde la pantalla anterior
  late User user;  // Usuario obtenido desde local storage

  @override
  void onInit() {
    super.onInit();

    print("🟦 [AddCardController] onInit()");
    print("📦 Plan recibido: ${Get.arguments}");
    print("📦 Usuario cargado: ${GetStorage().read('user')}");

    plan = Get.arguments as Plan;
    user = User.fromJson(GetStorage().read('user') ?? {});
  }

  void onCreditCardModelChange(CreditCardModel model) {
    print("✏️ onCreditCardModelChange()");
    print("• Número: ${model.cardNumber}");
    print("• Expira: ${model.expiryDate}");
    print("• CVV: ${model.cvvCode}");
    print("• Holder: ${model.cardHolderName}");
    print("• CVV Focado: ${model.isCvvFocused}");

    cardNumber.value = model.cardNumber;
    expiryDate.value = model.expiryDate;
    cvvCode.value = model.cvvCode;
    cardHolderName.value = model.cardHolderName;
    isCvvFocused.value = model.isCvvFocused;
  }

  Future<void> acquirePlan(BuildContext context) async {
    print("\n🟪 ===== INICIANDO TOKENIZACIÓN VIA WEBVIEW =====");
    print("➡️ userId=${user.id}, email=${user.email}");

    final result = await Get.to<bool>(
          () => AddCardWebViewPage(),
      arguments: {
        'userId': user.id.toString(),
        'email': user.email!,
      },
    );

    print("⬅️ Resultado retorno del WebView: $result");

    if (result == true) {
      print("🟩 Tokenización exitosa, regresando a pantalla anterior");
      Get.back(result: true);
    }
  }
}
