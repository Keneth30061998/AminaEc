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

  /// payWithToken
  /// - card: tarjeta seleccionada
  /// - isRetrySingle: bandera interna para indicar que esta invocación es un reintento forzado en 1 cuota
  ///    (evita volver a ofrecer cuotas y previene bucles)
  Future<void> payWithToken(CardModel card, {bool isRetrySingle = false}) async {
    // VALIDACIÓN PLAN NUEVO USUARIO (Tu lógica original)
    if (plan.is_new_user_only == 1) {
      final user = User.fromJson(GetStorage().read('user') ?? {});
      final userPlanProvider = UserPlanProvider();

      final summary = await userPlanProvider.getUserPlansSummary(
        user.id.toString(),
        user.session_token ?? '',
      );

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
      // =============================================================
      // 1) Si es reintento forzado (isRetrySingle=true) -> no consultamos opciones
      // =============================================================
      int installmentsCount = 1;

      if (!isRetrySingle) {
        // =============================================================
        // 2) CONSULTAR SI LA TARJETA SOPORTA DIFERIDO Y OPCIONES
        // (backend ya provee supports_installments e installment_options)
        // =============================================================
        try {
          final opts = await _cardProvider.getPaymentOptions(card.token!);

          final supports = opts["supports_installments"] == true;

          List<int> options = [];
          if (opts["installment_options"] is List) {
            options = opts["installment_options"]
                .map<int>((e) => int.tryParse(e.toString()) ?? 1)
                .toList();
          }

          if (supports && options.isNotEmpty) {
            final chosen = await _showInstallmentDialog(options);
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
            // Si backend indica que NO soporta cuotas -> 1 cuota
            installmentsCount = 1;
          }
        } catch (err) {
          // En caso de error en la consulta -> fallback seguro 1 cuota
          installmentsCount = 1;
        }
      } else {
        // isRetrySingle == true => forzamos 1 cuota
        installmentsCount = 1;
      }

      // =============================================================
      // 3) ENVIAR PAGO AL BACKEND
      // =============================================================
      ResponseApi payResp = await _cardProvider.payWithToken(
        token: card.token!,
        amount: plan.price!,
        taxPct: 15.0,
        description: plan.name!,
        installmentsCount: installmentsCount,
        planId: int.tryParse(plan.id!.toString()), // <-- pasa plan.id
      );


      // =============================
      // 4) MANEJO OTP (igual que antes)
      // =============================
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
          planId: int.tryParse(plan.id!.toString()), // <-- pasa plan.id
        );


        pd.close();

        if (confirmResp.success == true) {
          await _onPaymentApprovedDirect(transactionId);
        } else {
          // Si el confirmResp indica que fue rechazado por diferido (en caso de reintentos)
          final msg = (confirmResp.message ?? '').toString().toLowerCase();
          final likelyDiffReject = msg.contains('difer') || msg.contains('diff') || msg.contains('install');
          if (likelyDiffReject && installmentsCount > 1) {
            // Ofrecer reintento en 1 cuota
            final retry = await _askRetrySingle();
            if (retry == true) {
              // Reintentar forzando 1 cuota (isRetrySingle = true evita volver a mostrar dialog de cuotas)
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

      // =============================
      // 5) RESPUESTA DIRECTA
      // =============================
      if (payResp.success == true) {
        final transactionId = payResp.transactionId ?? "";
        await _onPaymentApprovedDirect(transactionId);
      } else {
        // =============================
        // 6) MANEJO ESPECIAL: RECHAZO POR DIFERIDO (TARJETA DÉBITO)
        // =============================
        final message = (payResp.message ?? '').toString().toLowerCase();

        // heurística para detectar rechazo por diferido (mejorar con códigos reales si los tienes)
        final likelyDiffReject = message.contains('difer') ||
            message.contains('no permite pagos diferidos') ||
            message.contains('diff') ||
            message.contains('install');

        if (likelyDiffReject && installmentsCount > 1) {
          // Mostrar mensaje y ofrecer reintentar en 1 cuota
          final retry = await _askRetrySingleCustomMessage(payResp.message);
          if (retry == true) {
            // Reintentar en 1 cuota
            await payWithToken(card, isRetrySingle: true);
            return;
          } else {
            // Usuario decidió no reintentar
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

        // Rechazo genérico (no es un rechazo por diferido)
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
      Get.snackbar(
        'Error inesperado',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  // =============================================================
  // Confirmación plan y redirección — mantiene la lógica original
  // =============================================================
  Future<void> _onPaymentApprovedDirect(String transactionId) async {
    final box = GetStorage();
    final user = User.fromJson(box.read('user') ?? {});
    final userPlan = UserPlan(
      userId: user.id!,
      planId: plan.id!,
      transactionId: transactionId.isNotEmpty ? transactionId : null,
    );

    final planProvider = UserPlanProvider();
    ResponseApi? planResp =
    await planProvider.acquire(userPlan, user.session_token ?? '');

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

  // =============================================================
  // DIALOGO OTP (igual que antes)
  // =============================================================
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

  // =============================================================
  // DIALOGO DINÁMICO DE CUOTAS (igual que antes)
  // =============================================================
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

  // =============================================================
  // DIALOGO: Preguntar si desea reintentar en 1 cuota (para rechazo por diferido)
  // =============================================================
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

  // Variante que muestra mensaje del backend (si existe)
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
    final resp = await _cardProvider.deleteCard(token);
    if (resp.success == true) {
      await loadCards();
      Get.snackbar('Tarjeta eliminada', resp.message ?? '');
    } else {
      Get.snackbar('Error', resp.message ?? '');
    }
  }
}
