import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';

import '../../../../../models/card.dart';
import '../../../../../models/plan.dart';
import '../../../../../models/response_api.dart';
import '../../../../../models/user.dart';
import '../../../../../models/user_plan.dart';
import '../../../../../providers/card_provider.dart';
import '../../../../../providers/user_plan_provider.dart';

class UserPlanBuyResumeController extends GetxController {
  late Plan plan;
  late User user;
  final CardProvider _cardProvider = CardProvider();

  var cards = <CardModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    plan = Get.arguments as Plan;
    user = User.fromJson(GetStorage().read('user') ?? {});
    loadCards();
  }

  Future<void> loadCards() async {
    isLoading.value = true;
    cards.value = await _cardProvider.listByUser();
    isLoading.value = false;
  }

  double calculateSubtotal() => plan.price! / 1.15;
  double calculateIVA() => plan.price! - calculateSubtotal();
  double calculateTotal() => plan.price!;

  Future<void> payWithToken(CardModel card) async {
    final context = Get.context!;
    final pd = ProgressDialog(context: context);

    pd.show(
      max: 100,
      msg: 'Procesando pago...',
      progressBgColor: Colors.transparent,
      backgroundColor: Colors.white,
      msgColor: Colors.black87,
      barrierDismissible: false,
    );

    try {
      //print('🟢 payWithToken: iniciando pago token=${card.token}');
      ResponseApi payResp = await _cardProvider.payWithToken(
        token: card.token!,
        amount: plan.price!,
        taxPct: 15.0,
        description: plan.name!,
      );
      //print('🟢 payWithToken: respuesta inicial → ${payResp.toJson()}');

      if (payResp.requiresConfirmation == true) {
        pd.close();
        final otp = await _showOtpDialog();
        if (otp == null || otp.isEmpty) {
          Get.snackbar(
            'Pago cancelado',
            'No ingresaste el código OTP',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          return;
        }

        final transactionId = payResp.transactionId ?? "";
        if (transactionId.isEmpty) {
          Get.snackbar(
            'Error',
            'No se obtuvo transaction_id para confirmar OTP',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
          return;
        }

        pd.show(msg: 'Verificando OTP...', barrierDismissible: false);

        final confirmResp = await _cardProvider.confirmPayment(
          token: card.token!,
          transactionId: transactionId,
          confirmCode: otp,
        );
        //print('🟡 confirmPayment: respuesta → ${confirmResp.toJson()}');
        pd.close();

        if (confirmResp.success == true) {
          await _onPaymentApprovedDirect(
              transactionId); // ✅ enviar transactionId
        } else {
          Get.snackbar(
            'Error en OTP',
            confirmResp.message ?? 'Código OTP inválido o pago rechazado',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        }
        return;
      } else {
        pd.close();
      }

      if (payResp.success == true) {
        final transactionId = payResp.transactionId ?? "";
        await _onPaymentApprovedDirect(transactionId); // ✅ enviar transactionId
      } else {
        Get.snackbar(
          'Error en pago',
          payResp.message ?? 'Falló el pago',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      pd.close();
      //print('❌ payWithToken: error inesperado → $e');
      Get.snackbar(
        'Error inesperado',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _onPaymentApprovedDirect(String transactionId) async {
    final box = GetStorage();
    final user = User.fromJson(box.read('user') ?? {});
    final userPlan = UserPlan(
      userId: user.id!,
      planId: plan.id!,
      transactionId:
          transactionId.isNotEmpty ? transactionId : null, // ✅ solo si existe
    );

    final planProvider = UserPlanProvider();
    ResponseApi? planResp = await planProvider.acquire(
      userPlan,
      user.session_token ?? '',
    );

    if (planResp?.success == true) {
      Get.snackbar('Plan adquirido',
          planResp!.message ?? 'Tu plan y rides han sido acreditados',
          backgroundColor: Colors.green, colorText: Colors.white);
      Get.offAllNamed('/user/home');
    } else {
      Get.snackbar('Error acreditación',
          planResp?.message ?? 'Pago ok, pero no se acreditó el plan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orangeAccent,
          colorText: Colors.white);
    }
  }

  Future<String?> _showOtpDialog() {
    final codeCtrl = TextEditingController();
    return Get.defaultDialog<String?>(
      title: 'Código OTP',
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Text('Ingresa el código enviado por tu banco', style: TextStyle(color: almostBlack),),
            const SizedBox(height: 12),
            TextField(
              controller: codeCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '000000',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      buttonColor: whiteGrey,
      textConfirm: 'Confirmar',
      confirmTextColor: whiteLight,
      textCancel: 'Cancelar',
      cancelTextColor: darkGrey,
      onConfirm: () => Get.back(result: codeCtrl.text.trim()),
      onCancel: () => Get.back(result: null),
    );
  }

  Future<void> deleteCard(String token) async {
    final resp = await _cardProvider.deleteCard(token);
    if (resp.success == true) {
      await loadCards();
      Get.snackbar('Tarjeta eliminada', resp.message ?? '');
    } else {
      Get.snackbar('Error', resp.message ?? '');
    }
  }
}
