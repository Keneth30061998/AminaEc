import 'package:amina_ec/src/pages/user/Plan/Buy/AddCard/user_plan_buy_addCard_webview_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../../models/plan.dart';
import '../../../../../models/user.dart';

class UserPlanBuyAddCardController extends GetxController {
  var cardNumber = ''.obs;
  var expiryDate = ''.obs;
  var cvvCode = ''.obs;
  var cardHolderName = ''.obs;
  var isCvvFocused = false.obs;

  final GlobalKey<FormState> keyForm = GlobalKey<FormState>();

  late Plan plan;
  late User user;

  @override
  void onInit() {
    super.onInit();
    // 1) Recibe el plan como argumento
    plan = Get.arguments as Plan;
    // 2) Carga usuario desde storage
    user = User.fromJson(GetStorage().read('user') ?? {});
  }

  void onCreditCardModelChange(CreditCardModel model) {
    cardNumber.value = model.cardNumber;
    expiryDate.value = model.expiryDate;
    cvvCode.value = model.cvvCode;
    cardHolderName.value = model.cardHolderName;
    isCvvFocused.value = model.isCvvFocused;
  }

  /// Con Opción A: abre el WebView de Nuvei para tokenizar
  Future<void> acquirePlan(BuildContext context) async {
    final result = await Get.to<bool>(
      () => AddCardWebViewPage(),
      arguments: {
        'userId': user.id.toString(),
        'email': user.email!,
      },
    );

    // Si el WebView cierra con éxito (window.close → about:blank)
    if (result == true) {
      Get.back(result: true); // retornamos al caller (ResumePage)
    }
  }
}
