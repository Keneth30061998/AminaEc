import 'package:amina_ec/src/pages/user/Plan/Buy/AddCard/user_plan_buy_addCard_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class UserPlanBuyAddCardPage extends StatelessWidget {
  final UserPlanBuyAddCardController con =
      Get.put(UserPlanBuyAddCardController());

  UserPlanBuyAddCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: Text(
            'Pagar plan',
            style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: almostBlack,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Tarjeta visual
            CreditCardWidget(
              cardNumber: con.cardNumber.value,
              expiryDate: con.expiryDate.value,
              cardHolderName: con.cardHolderName.value,
              cvvCode: con.cvvCode.value,
              showBackView: con.isCvvFocused.value,
              onCreditCardWidgetChange: (_) {},
              cardBgColor: indigoAmina,
              textStyle: GoogleFonts.roboto(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              width: width,
              obscureCardNumber: true,
              obscureCardCvv: true,
              isHolderNameVisible: true,
              isChipVisible: true,
              isSwipeGestureEnabled: true,
            ),

            const SizedBox(height: 20),

            // Formulario estilizado
            Card(
              elevation: 0,
              color: colorBackgroundBox,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                child: CreditCardForm(
                  formKey: con.keyForm,
                  onCreditCardModelChange: con.onCreditCardModelChange,
                  obscureCvv: true,
                  obscureNumber: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  inputConfiguration: InputConfiguration(
                    cardNumberDecoration: _inputDecoration(
                      label: 'Número de tarjeta',
                      icon: Icons.credit_card,
                    ),
                    expiryDateDecoration: _inputDecoration(
                      label: 'Fecha de expiración',
                      icon: Icons.date_range,
                    ),
                    cvvCodeDecoration: _inputDecoration(
                      label: 'CVV',
                      icon: Icons.lock,
                    ),
                    cardHolderDecoration: _inputDecoration(
                      label: 'Titular de la tarjeta',
                      icon: Icons.person,
                    ),
                  ),
                  cardNumber: '',
                  expiryDate: '',
                  cardHolderName: '',
                  cvvCode: '',
                ),
              ),
            ),
          ],
        ),

        // Botón principal de acción
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(20),
          child: FilledButton.icon(
            onPressed: () => con.acquirePlan(context),
            icon: const Icon(Icons.payment),
            label: const Text("Pagar"),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(55),
              backgroundColor: almostBlack,
              foregroundColor: Colors.white,
              textStyle: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.roboto(fontSize: 14, color: darkGrey),
      prefixIcon: Icon(icon, color: almostBlack),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        //borderSide: BorderSide(color: darkGrey.withOpacity(0.3)),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 16,
      ),
    );
  }
}
