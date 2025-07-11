import 'package:amina_ec/src/pages/LoginOrRegister/login_or_register_controller.dart';
import 'package:amina_ec/src/utils/textos.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/color.dart';

class LoginOrRegisterPage extends StatelessWidget {
  LoginOrRegisterController con = Get.put(LoginOrRegisterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteLight,
      body: Stack(
        children: [
          _textTitle(context),
          _boxForm(context),
        ],
      ),
    );
  }

  // --Widgets componentes--
  // Widget Titulo
  Widget _textTitle(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 1,
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2),
      child: Text(
        txt_bienvenida,
        textAlign: TextAlign.center,
        style: GoogleFonts.montserrat(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          color: almostBlack,
        ),
      ),
    );
  }

  //Widget BoxForm
  Widget _boxForm(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.6,
      ),
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.50,
      decoration: BoxDecoration(
        color: color_background_box,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _titleBoxForm(context),
            _subTitleBoxForm(context),
            _buttonCreateAccount(context),
            _buttonStartSession(context),
          ],
        ),
      ),
    );
  }

  // Widgets internos del BoxForm
  Widget _titleBoxForm(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 1,
      padding: EdgeInsets.only(top: 60),
      child: Text(
        txt_bienvenida_2,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: almostBlack,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _subTitleBoxForm(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 1,
      padding: EdgeInsets.only(left: 45, top: 20),
      child: Text(
        txt_regiter_or_login,
        style: GoogleFonts.robotoCondensed(
          color: darkGrey,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buttonCreateAccount(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 60,
      margin: EdgeInsets.only(top: 35),
      child: FloatingActionButton.extended(
        heroTag: 'registrar-usuario',
        onPressed: () {
          return con.goToRegisterPage();
        },
        label: Text(
          txt_crear_cuenta,
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        backgroundColor: almostBlack, //
      ),
    );
  }

  Widget _buttonStartSession(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 60,
      margin: EdgeInsets.only(top: 20),
      decoration: BoxDecoration(),
      child: FloatingActionButton.extended(
        heroTag: 'iniciar-sesion',
        onPressed: () {
          return con.goToLoginPage();
        },
        label: Text(
          txt_iniciar_sesion,
          style: TextStyle(fontSize: 16),
        ),
        backgroundColor: limeGreen, //
      ),
    );
  }
}
