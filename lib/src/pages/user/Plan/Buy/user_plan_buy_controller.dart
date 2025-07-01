import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../models/plan.dart';
import '../../../../models/response_api.dart';
import '../../../../models/user.dart';
import '../../../../models/user_plan.dart';
import '../../../../providers/user_plan_provider.dart';

class UserPlanBuyController extends GetxController {
  var cardNumber = ''.obs;
  var expiryDate = ''.obs;
  var cvvCode = ''.obs;
  var cardHolderName = ''.obs;
  var isCvvFocused = false.obs;
  GlobalKey<FormState> keyForm = GlobalKey();

  late Plan plan;
  late User user;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    // 🧠 Lee el argumento pasado a la pantalla
    plan = Get.arguments as Plan;
    // 📦 Carga el usuario almacenado localmente
    user = User.fromJson(GetStorage().read('user') ?? {});
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    cardNumber.value = creditCardModel.cardNumber;
    expiryDate.value = creditCardModel.expiryDate;
    cvvCode.value = creditCardModel.cvvCode;
    cardHolderName.value = creditCardModel.cardHolderName;
    isCvvFocused.value = creditCardModel.isCvvFocused;
  }

  Future<void> acquirePlan(BuildContext context) async {
    User myUser = User.fromJson(GetStorage().read('user') ?? {});

    if (myUser.id == null || myUser.session_token == null || plan.id == null) {
      Get.snackbar(
        'Datos incompletos',
        'No se pudo adquirir el plan. Verifica tu sesión o plan seleccionado',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final userPlan = UserPlan(userId: myUser.id!, planId: plan.id!);
    print('user_id: ${myUser.id}');
    print('plan_id: ${plan.id}');
    final provider = UserPlanProvider(context: context);
    print('token_usuario_compra: ${myUser.session_token}');

    ResponseApi? response =
        await provider.acquire(userPlan, myUser.session_token!);
    print(response);
    if (response != null && response.success == true) {
      Get.snackbar(
        '¡Éxito!',
        response.message ?? 'Plan adquirido correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.offAllNamed('/user/home');
    } else {
      Get.snackbar(
        'Error',
        response?.message ?? 'No se pudo registrar el plan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}
