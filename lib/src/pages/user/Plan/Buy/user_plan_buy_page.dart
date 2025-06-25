import 'package:amina_ec/src/pages/user/Plan/Buy/user_plan_buy_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:get/get.dart';

class UserPlanBuyPage extends StatelessWidget {
  UserPlanBuyController con = Get.put(UserPlanBuyController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          appBar: AppBar(
            backgroundColor: whiteLight,
            title: Text('Pagina de compra'),
          ),
          body: ListView(
            children: [
              CreditCardWidget(
                cardNumber: con.cardNumber.value,
                expiryDate: con.expiryDate.value,
                cardHolderName: con.cardHolderName.value,
                cvvCode: con.cvvCode.value,
                showBackView: con.isCvvFocused.value,
                onCreditCardWidgetChange: (CreditCardBrand brand) {},
                bankName: 'Name of the Bank',
                cardBgColor: darkGrey,
                //glassmorphismConfig: Glassmorphism.defaultConfig(),
                enableFloatingCard: true,
                floatingConfig: FloatingConfig(
                  isGlareEnabled: true,
                  isShadowEnabled: true,
                  shadowConfig: FloatingShadowConfig(),
                ),
                //backgroundImage: 'assets/card_bg.png',
                //backgroundNetworkImage: 'https://www.xyz.com/card_bg.png',
                labelValidThru: 'VALID\nTHRU',
                obscureCardNumber: true,
                obscureInitialCardNumber: false,
                obscureCardCvv: true,
                labelCardHolder: 'CARD HOLDER',
                //labelValidThru: 'VALID\nTHRU',
                cardType: CardType.mastercard,
                isHolderNameVisible: false,
                height: 225,
                textStyle: TextStyle(color: limeGreen),
                width: MediaQuery.of(context).size.width,
                isChipVisible: true,
                isSwipeGestureEnabled: true,
                animationDuration: Duration(milliseconds: 1000),
                frontCardBorder: Border.all(color: Colors.grey),
                backCardBorder: Border.all(color: Colors.grey),
                chipColor: limeGreen,
                padding: 16,
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
              ),
              CreditCardForm(
                formKey: con.keyForm, // Required
                cardNumber: '', // Required
                expiryDate: '', // Required
                cardHolderName: '', // Required
                cvvCode: '', // Required
                //cardNumberKey: cardNumberKey,
                //cvvCodeKey: cvvCodeKey,
                //expiryDateKey: expiryDateKey,
                //cardHolderKey: cardHolderKey,
                onCreditCardModelChange:
                    con.onCreditCardModelChange, // Required
                obscureCvv: true,
                obscureNumber: true,
                isHolderNameVisible: true,
                isCardNumberVisible: true,
                isExpiryDateVisible: true,
                enableCvv: true,
                cvvValidationMessage: 'Please input a valid CVV',
                dateValidationMessage: 'Please input a valid date',
                numberValidationMessage: 'Please input a valid number',
                cardNumberValidator: (String? cardNumber) {},
                expiryDateValidator: (String? expiryDate) {},
                cvvValidator: (String? cvv) {},
                cardHolderValidator: (String? cardHolderName) {},
                isCardHolderNameUpperCase: true,
                onFormComplete: () {
                  // callback to execute at the end of filling card data
                },
                autovalidateMode: AutovalidateMode.always,
                disableCardNumberAutoFillHints: false,
                inputConfiguration: const InputConfiguration(
                  cardNumberDecoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Number',
                    hintText: 'XXXX XXXX XXXX XXXX',
                    suffixIcon: Icon(Icons.credit_card),
                  ),
                  expiryDateDecoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Expired Date',
                    hintText: 'XX/XX',
                    suffixIcon: Icon(Icons.date_range),
                  ),
                  cvvCodeDecoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'CVV',
                    hintText: 'XXX',
                    suffixIcon: Icon(Icons.lock),
                  ),
                  cardHolderDecoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Titular de la tarjeta',
                    suffixIcon: Icon(Icons.person),
                  ),
                  cardNumberTextStyle: TextStyle(
                    fontSize: 10,
                    color: Colors.black,
                  ),
                  cardHolderTextStyle: TextStyle(
                    fontSize: 10,
                    color: Colors.black,
                  ),
                  expiryDateTextStyle: TextStyle(
                    fontSize: 10,
                    color: Colors.black,
                  ),
                  cvvCodeTextStyle: TextStyle(
                    fontSize: 10,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
