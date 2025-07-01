import 'package:amina_ec/src/pages/user/Plan/Buy/user_plan_buy_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class UserPlanBuyPage extends StatelessWidget {
  final UserPlanBuyController con = Get.put(UserPlanBuyController());

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Obx(
      () => Scaffold(
        appBar: AppBar(
          backgroundColor: whiteLight,
          foregroundColor: almostBlack,
          automaticallyImplyLeading: true,
          title: Text(
            'Pagar plan',
            style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          centerTitle: true,
          elevation: 2,
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            CreditCardWidget(
              enableFloatingCard: true,
              cardNumber: con.cardNumber.value,
              expiryDate: con.expiryDate.value,
              cardHolderName: con.cardHolderName.value,
              cvvCode: con.cvvCode.value,
              showBackView: con.isCvvFocused.value,
              onCreditCardWidgetChange: (brand) {},
              cardBgColor: limeGreen,
              height: 220,
              textStyle: GoogleFonts.roboto(
                color: almostBlack,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              width: width,
              isChipVisible: true,
              isSwipeGestureEnabled: true,
              animationDuration: const Duration(milliseconds: 800),
              frontCardBorder: Border.all(color: Colors.grey.shade300),
              backCardBorder: Border.all(color: Colors.grey.shade300),
              chipColor: darkGrey,
              padding: 10,
              customCardTypeIcons: <CustomCardTypeIcon>[
                CustomCardTypeIcon(
                  cardType: CardType.mastercard,
                  cardImage: Image.asset(
                    'assets/img/visa.png',
                    height: 48,
                    width: 48,
                  ),
                ),
              ],
              floatingConfig: const FloatingConfig(
                isGlareEnabled: true,
                isShadowEnabled: true,
              ),
              obscureCardNumber: true,
              obscureInitialCardNumber: false,
              obscureCardCvv: true,
              isHolderNameVisible: true,
              labelValidThru: 'VALID\nTHRU',
              labelCardHolder: 'CARD HOLDER',
              cardType: CardType.visa,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: CreditCardForm(
                formKey: con.keyForm,
                cardNumber: '',
                expiryDate: '',
                cardHolderName: '',
                cvvCode: '',
                onCreditCardModelChange: con.onCreditCardModelChange,
                obscureCvv: true,
                obscureNumber: true,
                isHolderNameVisible: true,
                isCardNumberVisible: true,
                isExpiryDateVisible: true,
                enableCvv: true,
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
                  cardNumberTextStyle: GoogleFonts.roboto(fontSize: 14),
                  expiryDateTextStyle: GoogleFonts.roboto(fontSize: 14),
                  cvvCodeTextStyle: GoogleFonts.roboto(fontSize: 14),
                  cardHolderTextStyle: GoogleFonts.roboto(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(20),
          child: FloatingActionButton.extended(
            onPressed: () async {
              await con.acquirePlan(context);
            },
            label: const Text('Pagar'),
            icon: const Icon(Icons.payment),
            backgroundColor: almostBlack,
            foregroundColor: whiteLight,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  InputDecoration _inputDecoration(
      {required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      prefixIcon: Icon(icon),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
