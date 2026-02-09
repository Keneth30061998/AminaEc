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
    print("🟩 [onInit] user.id=${user.id} email=${user.email} tokenLen=${(user.session_token ?? '').length}");
    print("🟩 [onInit] plan.id=${plan.id} plan.name=${plan.name} price=${plan.price} is_new_user_only=${plan.is_new_user_only}");
    loadCards();
  }

  Future<void> loadCards() async {
    print("🟦 [loadCards] start...");
    isLoading.value = true;
    cards.value = await _cardProvider.listByUser();
    isLoading.value = false;
    print("🟦 [loadCards] done. cards=${cards.length}");
  }

  double calculateSubtotal() => plan.price! / 1.15;
  double calculateIVA() => plan.price! - calculateSubtotal();
  double calculateTotal() => plan.price!;

  Future<void> payWithToken(CardModel card, {bool isRetrySingle = false}) async {
    print("\n==================== 🧾 FLOW payWithToken ====================");
    print("🧾 [payWithToken] isRetrySingle=$isRetrySingle");
    print("🧾 [payWithToken] plan.id=${plan.id} plan.name=${plan.name} price=${plan.price} is_new_user_only=${plan.is_new_user_only}");
    print("💳 [payWithToken] card.token=${card.token} last4=${card.last4} type=${card.type} bank=${card.bank} bin=${card.bin}");

    // VALIDACIÓN PLAN NUEVO USUARIO
    if (plan.is_new_user_only == 1) {
      final user = User.fromJson(GetStorage().read('user') ?? {});
      final userPlanProvider = UserPlanProvider();

      print("🔒 [new_user_only] consultando resumen de planes para user=${user.id}");
      final summary = await userPlanProvider.getUserPlansSummary(
        user.id.toString(),
        user.session_token ?? '',
      );
      print("🔒 [new_user_only] summary.length=${summary.length}");

      if (summary.isNotEmpty) {
        Get.snackbar(
          'Este plan es exclusivo',
          'Este plan es solo para usuarios nuevos y tú ya cuentas con historial de planes.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }
    }

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
      int installmentsCount = 1;

      // 1) Selección de cuotas
      if (!isRetrySingle) {
        try {
          print("🟦 [payWithToken] consultando payment options para token=${card.token}");
          final opts = await _cardProvider.getPaymentOptions(card.token!);
          print("🟦 [payWithToken] paymentOptions raw: $opts");

          final supports = opts["supports_installments"] == true;
          print("🟦 [payWithToken] supports_installments=$supports");

          List<int> options = [];
          if (opts["installment_options"] is List) {
            options = opts["installment_options"]
                .map<int>((e) => int.tryParse(e.toString()) ?? 1)
                .toList();
          }
          print("🟦 [payWithToken] installment_options parsed=$options");

          if (supports && options.isNotEmpty) {
            final chosen = await _showInstallmentDialog(options);
            print("🟦 [payWithToken] user chosen installments=$chosen");

            if (chosen == null) {
              pd.close();
              Get.snackbar(
                'Pago cancelado',
                'No seleccionaste cuotas',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
              return;
            }
            installmentsCount = chosen;
          } else {
            installmentsCount = 1;
          }
        } catch (err) {
          print("⚠️ [payWithToken] getPaymentOptions ERROR: $err");
          installmentsCount = 1;
        }
      } else {
        installmentsCount = 1;
      }

      print("🧾 [payWithToken] installmentsCount FINAL=$installmentsCount");
      final parsedPlanId = int.tryParse(plan.id!.toString());
      print("🧾 [payWithToken] planId parsed=$parsedPlanId");

      // 2) Enviar pago
      print("🚀 [payWithToken] calling backend /pay/token ...");
      ResponseApi payResp = await _cardProvider.payWithToken(
        token: card.token!,
        amount: plan.price!,
        taxPct: 15.0,
        description: plan.name!,
        installmentsCount: installmentsCount,
        planId: parsedPlanId,
      );

      print("📩 [payWithToken] payResp.success=${payResp.success} requiresConfirmation=${payResp.requiresConfirmation} txId=${payResp.transactionId} msg=${payResp.message}");
      print("📩 [payWithToken] payResp.data=${payResp.data}");

      // 3) Manejo OTP
      if (payResp.requiresConfirmation == true) {
        pd.close();
        print("🔐 [OTP] requiresConfirmation=true");

        final otp = await _showOtpDialog();
        print("🔐 [OTP] otp received? ${otp != null && otp.isNotEmpty} length=${otp?.length ?? 0}");

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
        print("🔐 [OTP] transactionId from payResp=$transactionId");

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

        print("🚀 [confirmPayment] calling backend /pay/confirm ...");
        final confirmResp = await _cardProvider.confirmPayment(
          token: card.token!,
          transactionId: transactionId,
          confirmCode: otp,
          planId: parsedPlanId,
        );

        pd.close();

        print("📩 [confirmPayment] confirmResp.success=${confirmResp.success} txId=${confirmResp.transactionId} msg=${confirmResp.message}");
        print("📩 [confirmPayment] confirmResp.data=${confirmResp.data}");

        if (confirmResp.success == true) {
          print("✅ [confirmPayment] approved -> calling _onPaymentApprovedDirect($transactionId)");
          await _onPaymentApprovedDirect(transactionId);
        } else {
          final msg = (confirmResp.message ?? '').toString().toLowerCase();
          final likelyDiffReject = msg.contains('difer') || msg.contains('diff') || msg.contains('install');
          print("❌ [confirmPayment] rejected. likelyDiffReject=$likelyDiffReject installmentsCount=$installmentsCount");

          if (likelyDiffReject && installmentsCount > 1) {
            final retry = await _askRetrySingle();
            print("🔁 [confirmPayment] retrySingle? $retry");

            if (retry == true) {
              await payWithToken(card, isRetrySingle: true);
              return;
            }
          }

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

      // 4) Respuesta directa (sin OTP)
      if (payResp.success == true) {
        final transactionId = payResp.transactionId ?? "";
        print("✅ [payWithToken] approved direct -> _onPaymentApprovedDirect($transactionId)");
        await _onPaymentApprovedDirect(transactionId);
      } else {
        final message = (payResp.message ?? '').toString().toLowerCase();
        final likelyDiffReject = message.contains('difer') ||
            message.contains('no permite pagos diferidos') ||
            message.contains('diff') ||
            message.contains('install');

        print("❌ [payWithToken] not approved. likelyDiffReject=$likelyDiffReject installmentsCount=$installmentsCount msg=${payResp.message}");

        if (likelyDiffReject && installmentsCount > 1) {
          final retry = await _askRetrySingleCustomMessage(payResp.message);
          print("🔁 [payWithToken] retrySingle? $retry");

          if (retry == true) {
            await payWithToken(card, isRetrySingle: true);
            return;
          } else {
            Get.snackbar(
              'Pago cancelado',
              'No se realizó el pago diferido',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
            return;
          }
        }

        Get.snackbar(
          'Error en pago',
          payResp.message ?? 'Falló el pago',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e, st) {
      pd.close();
      print("💥 [payWithToken] EXCEPTION: $e");
      print("💥 [payWithToken] STACK: $st");
      Get.snackbar(
        'Error inesperado',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      print("==================== ✅ END FLOW payWithToken ====================\n");
    }
  }

  // =============================================================
  // Acreditación plan
  // =============================================================
  Future<void> _onPaymentApprovedDirect(String transactionId) async {
    final box = GetStorage();
    final user = User.fromJson(box.read('user') ?? {});
    final token = user.session_token ?? '';

    print("\n🟩 [_onPaymentApprovedDirect] START");
    print("🟩 user.id=${user.id} email=${user.email} tokenLen=${token.length}");
    print("🟩 plan.id=${plan.id} plan.name=${plan.name}");
    print("🟩 transactionId=$transactionId");

    final userPlan = UserPlan(
      userId: user.id!,
      planId: plan.id!,
      transactionId: transactionId.isNotEmpty ? transactionId : null,
    );
    print("📦 [_onPaymentApprovedDirect] userPlan.toJson=${userPlan.toJson()}");

    final planProvider = UserPlanProvider();
    ResponseApi? planResp = await planProvider.acquire(userPlan, token);

    print("📩 [_onPaymentApprovedDirect] acquire response:");
    print("📩 success=${planResp?.success} message=${planResp?.message}");
    print("📩 data=${planResp?.data}");
    print("🟩 [_onPaymentApprovedDirect] END\n");

    if (planResp?.success == true) {
      Get.snackbar(
        'Plan adquirido',
        planResp!.message ?? 'Tu plan y rides han sido acreditados',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.offAllNamed('/user/home');
    } else {
      Get.snackbar(
        'Error acreditación',
        planResp?.message ?? 'Pago ok, pero no se acreditó el plan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
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
            Text('Ingresa el código enviado por tu banco',
                style: TextStyle(color: almostBlack)),
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

  Future<int?> _showInstallmentDialog(List<int> options) {
    final opts = options.toSet().toList()..sort();
    if (!opts.contains(1)) opts.insert(0, 1);

    return Get.defaultDialog<int?>(
      title: 'Selecciona cuotas',
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Text('Elige la cantidad de cuotas',
                style: TextStyle(color: almostBlack)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: opts.map((c) {
                final label = c == 1 ? 'Pagar de contado' : '$c cuotas';
                return ElevatedButton(
                  onPressed: () => Get.back(result: c),
                  child: Text(label),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: almostBlack,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Get.back(result: 1),
              child: Text('Cancelar y pagar contado',
                  style: TextStyle(color: darkGrey)),
            )
          ],
        ),
      ),
      barrierDismissible: true,
    );
  }

  Future<bool?> _askRetrySingle() {
    return Get.defaultDialog<bool?>(
      title: 'Reintentar en 1 cuota',
      middleText:
      'La tarjeta no permite pagos diferidos. ¿Deseas reintentar el pago en 1 cuota (contado)?',
      textConfirm: 'Sí, reintentar',
      textCancel: 'No, cancelar',
      onConfirm: () => Get.back(result: true),
      onCancel: () => Get.back(result: false),
      barrierDismissible: false,
    );
  }

  Future<bool?> _askRetrySingleCustomMessage(String? backendMessage) {
    final display = backendMessage ?? 'La tarjeta no permite pagos diferidos.';
    return Get.defaultDialog<bool?>(
      title: 'Pago diferido no permitido',
      middleText: '$display\n\n¿Deseas reintentar el pago en 1 cuota (contado)?',
      textConfirm: 'Sí, reintentar',
      textCancel: 'No, cancelar',
      onConfirm: () => Get.back(result: true),
      onCancel: () => Get.back(result: false),
      barrierDismissible: false,
    );
  }

  Future<void> deleteCard(String token) async {
    print("🗑️ [deleteCard] token=$token");
    final resp = await _cardProvider.deleteCard(token);
    print("🗑️ [deleteCard] resp.success=${resp.success} msg=${resp.message}");
    if (resp.success == true) {
      await loadCards();
      Get.snackbar('Tarjeta eliminada', resp.message ?? '');
    } else {
      Get.snackbar('Error', resp.message ?? '');
    }
  }
}
