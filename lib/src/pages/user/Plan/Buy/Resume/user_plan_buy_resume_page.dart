import 'package:amina_ec/src/pages/user/Plan/Buy/Resume/user_plan_buy_resume_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class UserPlanBuyResumePage extends StatelessWidget {
  UserPlanBuyResumeController con = Get.put(UserPlanBuyResumeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _appBarTitle(),
        backgroundColor: whiteLight,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _textSubtitlePage(),
          _boxBuyData(),
        ],
      ),
    );
  }

  Widget _appBarTitle() {
    return Text(
      'Resumen de la compra',
      style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w800),
    );
  }

  Widget _textSubtitlePage() {
    return Container(
      padding: EdgeInsets.only(left: 20, top: 10),
      child: Text(
        '* Revise que los datos esten correctos',
        style: GoogleFonts.roboto(
          color: darkGrey,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _boxBuyData() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: darkGrey,
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, 0.75),
          ),
        ],
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _textTitlePlan(),
            _textNamePlan(),
            SizedBox(height: 10),
            _textTitleRides(),
            _textRides(),
            SizedBox(height: 20),
            _subTotal(),
            _IVA(),
            Divider(),
            _Total(),
            SizedBox(height: 20),
            _textTitleMetodoPago(),
            _dropDownTagert(),
          ],
        ),
      ),
    );
  }

  Widget _textTitlePlan() {
    return Text(
      'Paquete seleccionado',
      style: GoogleFonts.roboto(
        fontSize: 16,
        color: Colors.white54,
      ),
    );
  }

  Widget _textNamePlan() {
    return Text(
      '${con.plan.name}',
      style: GoogleFonts.roboto(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        color: whiteLight,
      ),
    );
  }

  Widget _textTitleRides() {
    return Text(
      'Rides acreditados',
      style: GoogleFonts.roboto(
        fontSize: 16,
        color: Colors.white54,
      ),
    );
  }

  Widget _textRides() {
    return Text(
      '${con.plan.rides}',
      style: GoogleFonts.roboto(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        color: whiteLight,
      ),
    );
  }

  Widget _subTotal() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Subtotal',
            style: GoogleFonts.roboto(
              fontSize: 16,
              color: Colors.white54,
            ),
          ),
          Text(
            '${con.calculate_subtotal()} USD',
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: whiteLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _IVA() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'IVA (15%)',
            style: GoogleFonts.roboto(
              fontSize: 16,
              color: Colors.white54,
            ),
          ),
          Text(
            '${con.calculate_iva()} USD',
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: whiteLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _Total() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total',
            style: GoogleFonts.roboto(
              fontSize: 16,
              color: whiteLight,
            ),
          ),
          Text(
            '${con.calculate_total()} USD',
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: limeGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _textTitleMetodoPago() {
    return Text(
      'Método de pago',
      style: GoogleFonts.roboto(
        fontSize: 16,
        color: Colors.white54,
      ),
    );
  }

  Widget _dropDownTagert() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: DropdownButton(
        underline: Container(
          alignment: Alignment.centerRight,
          child: const Icon(
            Icons.arrow_drop_down_circle,
            color: limeGreen,
          ),
        ),
        elevation: 3,
        isExpanded: true,
        hint: const Text(
          'Seleccionar tarjeta',
          style: TextStyle(color: limeGreen, fontSize: 16),
        ),
        items: _dropDownItem(),
        value: 1,
        onChanged: (option) {
          print('Opcion seleccionada:  $option');
        },
      ),
    );
  }

  //Listar Categorias
  List<DropdownMenuItem<String?>> _dropDownItem() {
    List<DropdownMenuItem<String>> list = [];
    /*for (var category in categories) {
      list.add(DropdownMenuItem(
        value: category.id,
        child: Text(category.name ?? ''),
      ));
    }*/
    return list;
  }
}
