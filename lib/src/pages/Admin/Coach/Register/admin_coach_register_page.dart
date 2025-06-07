import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/color.dart';
import 'admin_coach_register_controller.dart';

class AdminCoachRegisterPage extends StatelessWidget {
  AdminCoachRegisterController con = Get.put(AdminCoachRegisterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: limeGreen,
        appBar: AppBar(
          backgroundColor: limeGreen,
          title: _textTitle(context),
        ),
        body: _boxForm(context));
  }

  //widgets
  Widget _textTitle(BuildContext context) {
    return Text(
      'Registro de Coach',
      style: TextStyle(
        color: almostBlack,
        fontWeight: FontWeight.w700,
        fontSize: 24,
      ),
    );
  }

  Widget _subTitle(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 1,
      margin: EdgeInsets.only(top: 10, left: 35, bottom: 10),
      child: Text(
        '*Registre todos los campos solicitados',
        style: TextStyle(
          color: Colors.black45,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  //Widget BoxForm
  Widget _boxForm(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 1,
      height: MediaQuery.of(context).size.height * 0.9,
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
      padding: EdgeInsets.only(top: 20, left: 10, right: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _subTitle(context),
            _textFieldEmail(),
            _textFieldName(),
            _textFieldLastName(),
            _textFieldCI(),
            _textFieldPhone(),
            _textFieldPassword(),
            _textFieldConfirmPassword(),
            _buttonRegister(context)
          ],
        ),
      ),
    );
  }

  //Widgets internos del BoxForm
  Widget _textFieldEmail() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: TextField(
        controller: con.emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          floatingLabelStyle: TextStyle(color: darkGrey),
          labelText: "Correo Electronico",
          hintText: "Correo Electrónico",
          prefixIcon: Icon(Icons.alternate_email),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: darkGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: darkGrey),
          ),
        ),
      ),
    );
  }

  Widget _textFieldName() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
      child: TextField(
        controller: con.nameController,
        keyboardType: TextInputType.name,
        decoration: InputDecoration(
          floatingLabelStyle: TextStyle(color: darkGrey),
          labelText: "Nombre",
          hintText: "Nombre",
          prefixIcon: Icon(Icons.person_2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: darkGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: darkGrey),
          ),
        ),
      ),
    );
  }

  Widget _textFieldLastName() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
      child: TextField(
        controller: con.lastnameController,
        keyboardType: TextInputType.name,
        decoration: InputDecoration(
          floatingLabelStyle: TextStyle(color: darkGrey),
          labelText: "Apellido",
          hintText: "Apellido",
          prefixIcon: Icon(Icons.person_2_outlined),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: darkGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: darkGrey),
          ),
        ),
      ),
    );
  }

  Widget _textFieldCI() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
      child: TextField(
        controller: con.ciController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          floatingLabelStyle: TextStyle(color: darkGrey),
          labelText: "Cédula",
          hintText: "Cédula",
          prefixIcon: Icon(Icons.assignment_ind),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: darkGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: darkGrey),
          ),
        ),
      ),
    );
  }

  Widget _textFieldPhone() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
      child: TextField(
        controller: con.phoneController,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          floatingLabelStyle: TextStyle(color: darkGrey),
          labelText: "Telefono",
          hintText: "Telefono",
          prefixIcon: Icon(Icons.phone_android),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: darkGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: darkGrey),
          ),
        ),
      ),
    );
  }

  Widget _textFieldPassword() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
      child: TextField(
        controller: con.passwordController,
        keyboardType: TextInputType.visiblePassword,
        obscureText: true,
        decoration: InputDecoration(
          floatingLabelStyle: TextStyle(color: darkGrey),
          labelText: "Contraseña",
          hintText: "Contraseña",
          prefixIcon: Icon(Icons.password),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: darkGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: darkGrey),
          ),
        ),
      ),
    );
  }

  Widget _textFieldConfirmPassword() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
      child: TextField(
        controller: con.confirmPasswordController,
        keyboardType: TextInputType.visiblePassword,
        obscureText: true,
        decoration: InputDecoration(
          floatingLabelStyle: TextStyle(color: darkGrey),
          labelText: "Confirmar Contraseña",
          hintText: "Confirmar Contraseña",
          prefixIcon: Icon(Icons.password_outlined),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: darkGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: darkGrey),
          ),
        ),
      ),
    );
  }

  Widget _buttonRegister(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 5),
      width: MediaQuery.of(context).size.width * 0.77,
      height: 50,
      child: FloatingActionButton.extended(
        onPressed: () {
          return con.goToRegisterAdminCoachImage();
        },
        label: Text(
          'Siguiente',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        icon: Icon(
          Icons.arrow_forward_ios,
          color: Colors.white,
        ),
        backgroundColor: almostBlack,
      ),
    );
  }
}
