import 'package:amina_ec/src/pages/LoginOrRegister/login_or_register_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/color.dart';

class LoginOrRegisterPage extends StatelessWidget {
  LoginOrRegisterController con = Get.put(LoginOrRegisterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkGrey,
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
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.15),
      child: Text(
        'Bienvenido a',
        textAlign: TextAlign.center,
        style: GoogleFonts.montserrat(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          color: limeGreen,
        ),
      ),
    );
  }

  //Widget BoxForm
  Widget _boxForm(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.5,
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
        '¡Hora de pedalear con estilo!',
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
        'Registrate o incia sesión',
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
        heroTag: 'registrar usuario',
        onPressed: () {
          return con.goToRegisterPage();
        },
        label: Text(
          'Crear nueva cuenta',
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
          'Iniciar Sesión',
          style: TextStyle(fontSize: 16),
        ),
        backgroundColor: limeGreen, //
      ),
    );
  }
}
