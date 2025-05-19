import 'package:amina_ec/src/pages/user/Register/register_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/color.dart';

class RegisterPageImage extends StatelessWidget {
  RegisterController con = Get.put(RegisterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _boxFormData(context),
          ],
        ),
      ),
    );
  }

  Widget _boxFormData(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.08,
        vertical: MediaQuery.of(context).size.height * 0.25,
      ),
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: color_background_box,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: limeGreen,
            blurRadius: 5,
            offset: Offset(0, 0.5),
          ),
        ],
      ),
      child: Column(
        children: [
          _boxPhoto(context),
          _textTitle(context),
          _textSubtitle(context),
          _buttonRegister(context),
        ],
      ),
    );
  }

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
      decoration: BoxDecoration(
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

  //widgets
  Widget _textTitle(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 1,
      margin: EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        'Foto de Perfil',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: almostBlack,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
      ),
    );
  }

  Widget _textSubtitle(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 1,
      margin: EdgeInsets.only(top: 5, bottom: 30),
      child: Text(
        'Escoja una foto para su perfil',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: darkGrey,
          fontWeight: FontWeight.w500,
          fontSize: 14,
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
          //seleccion de imagen creando al usuario
          return con.register(context);
        },
        label: Text(
          'Registrarse',
          style: TextStyle(fontSize: 16, color: almostBlack),
        ),
        backgroundColor: limeGreen,
      ),
    );
  }
}
