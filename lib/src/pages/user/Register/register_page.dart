import 'package:amina_ec/src/pages/user/Register/register_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/color.dart';

class RegisterPage extends StatelessWidget {
  RegisterController con = Get.put(RegisterController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: limeGreen,
        body: Stack(
          children: [
            _boxForm(context),
            Column(
              children: [
                _textTitle(context),
                _subTitle(context),
              ],
            ),
          ],
        ));
  }

  //widgets
  Widget _textTitle(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 1,
      margin: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.22, left: 35),
      child: Text(
        'Registro de Usuario',
        style: TextStyle(
          color: almostBlack,
          fontWeight: FontWeight.w800,
          fontSize: 30,
        ),
      ),
    );
  }

  Widget _subTitle(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 1,
      margin: EdgeInsets.only(top: 10, left: 35),
      child: Text(
        'Escribe tu informacion personal',
        style: TextStyle(
          color: darkGrey,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  //Widget BoxForm
  Widget _boxForm(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 1,
      height: MediaQuery.of(context).size.height * 0.65,
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.35),
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
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
            //_boxPhoto(context),
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
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
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
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
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
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
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
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
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
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
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
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
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
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      width: MediaQuery.of(context).size.width * 0.77,
      height: 50,
      child: FloatingActionButton.extended(
        onPressed: () {
          return con.goToRegisterImage();
        },
        label: Text(
          'Siguiente',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        backgroundColor: almostBlack,
      ),
    );
  }

  //Foto de usuario
  Widget _boxPhoto(BuildContext context) {
    return Container(
      height: 110,
      width: 110,
      margin: const EdgeInsets.only(top: 10),
      child: Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: [
          _userPhoto(),
          _editPhoto(context),
        ],
      ),
    );
  }

  Widget _userPhoto() {
    return Container(
      width: 110,
      height: 110,
      decoration: const BoxDecoration(
        color: darkGrey,
        shape: BoxShape.circle,
      ),
      child: GetBuilder<RegisterController>(
        builder: (_) => CircleAvatar(
          backgroundColor: darkGrey,
          backgroundImage: con.imageFile != null
              ? FileImage(con.imageFile!)
              : const AssetImage('assets/img/user_photo1.png') as ImageProvider,
        ),
      ),
    );
  }

  Widget _editPhoto(BuildContext context) {
    return IconButton.filled(
      onPressed: () => con.showAlertDialog(context),
      icon: const Icon(Icons.edit),
    );
  }
}
