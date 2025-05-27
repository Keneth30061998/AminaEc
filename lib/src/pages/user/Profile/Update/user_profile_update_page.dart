import 'package:amina_ec/src/pages/user/Profile/Update/user_update_profile_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserProfileUpdatePage extends StatelessWidget {
  UserProfileUpdateController con = Get.put(UserProfileUpdateController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: almostBlack,
        foregroundColor: limeGreen,
        title: _textTitle(context),
      ),
      backgroundColor: almostBlack,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _boxPhoto(context),
            _boxForm(context),
          ],
        ),
      ),
    );
  }

  //widgets
  Widget _textTitle(BuildContext context) {
    return Text(
      'Actualizar perfil',
      style: TextStyle(
        color: limeGreen,
        fontWeight: FontWeight.w600,
        fontSize: 26,
      ),
    );
  }

  //Widget BoxForm
  Widget _boxForm(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10, right: 20, left: 20),
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(35),
        ),
      ),
      child: Column(
        children: [
          _textIndications(context),
          _textFieldName(),
          _textFieldLastName(),
          _textFieldPhone(),
          _textFieldCI(),
          _buttonUpdate(context)
        ],
      ),
    );
  }

  //Widgets internos del BoxForm

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

  Widget _buttonUpdate(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      width: MediaQuery.of(context).size.width * 0.77,
      height: 50,
      child: FloatingActionButton.extended(
        onPressed: () {
          return con.updateProfile(context);
        },
        label: Text(
          'Guardar',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        icon: Icon(Icons.save, color: Colors.white),
        backgroundColor: almostBlack,
      ),
    );
  }

  //Foto de usuario
  Widget _boxPhoto(BuildContext context) {
    return Container(
      height: 110,
      width: 110,
      margin: const EdgeInsets.only(top: 40),
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
      child: GetBuilder<UserProfileUpdateController>(
        builder: (_) => CircleAvatar(
          backgroundColor: darkGrey,
          backgroundImage: con.imageFile != null
              ? FileImage(con.imageFile!)
              : con.user.photo_url != null
                  ? NetworkImage(con.user.photo_url!)
                  : const AssetImage('assets/img/user_photo1.png')
                      as ImageProvider,
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

  Widget _textIndications(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 1,
      margin: EdgeInsets.only(top: 10, left: 40),
      child: Text(
        'Actualiza tus datos',
        style: TextStyle(
          color: darkGrey,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
