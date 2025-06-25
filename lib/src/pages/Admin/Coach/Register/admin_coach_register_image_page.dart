import 'package:amina_ec/src/pages/Admin/Coach/Register/admin_coach_register_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/color.dart';

class AdminCoachRegisterImagePage extends StatelessWidget {
  AdminCoachRegisterController con = Get.put(AdminCoachRegisterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: limeGreen,
        foregroundColor: almostBlack,
      ),
      resizeToAvoidBottomInset: true,
      backgroundColor: limeGreen,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _boxPhoto(context),
              _boxForm(context),
            ],
          ),
        ),
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
      decoration: BoxDecoration(
        color: darkGrey,
        shape: BoxShape.circle,
      ),
      child: GetBuilder<AdminCoachRegisterController>(
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

  //Widget BoxForm
  Widget _boxForm(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 20, left: 25, right: 25),
      padding: EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, 0.75),
          ),
        ],
        borderRadius: BorderRadius.all(
          Radius.circular(30),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            //_subTitle(context),
            _textFieldHobby(),
            _textFieldDescription(),
            _textFieldPresentation(),
            _buttonRegister(context),
          ],
        ),
      ),
    );
  }

  //Widgets internos del BoxForm
  Widget _textFieldHobby() {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 10),
      child: TextField(
        controller: con.hobbyController,
        keyboardType: TextInputType.name,
        decoration: InputDecoration(
          floatingLabelStyle: TextStyle(color: darkGrey),
          labelText: "Hobby",
          hintText: "Hobby",
          prefixIcon: Icon(Icons.gamepad),
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

  Widget _textFieldDescription() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: con.descriptionController,
        keyboardType: TextInputType.name,
        maxLines: 3,
        decoration: InputDecoration(
          floatingLabelStyle: TextStyle(color: darkGrey),
          labelText: "Descripción",
          hintText: "Descripción",
          prefixIcon: Icon(Icons.person_search),
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

  Widget _textFieldPresentation() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: con.presentationController,
        keyboardType: TextInputType.name,
        maxLines: 5,
        decoration: InputDecoration(
          floatingLabelStyle: TextStyle(color: darkGrey),
          labelText: "Presentación",
          hintText: "Presentación",
          prefixIcon: Icon(Icons.description),
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
      margin: EdgeInsets.symmetric(vertical: 15),
      width: double.infinity,
      child: FloatingActionButton.extended(
        onPressed: () {
          con.goToRegisterAdminCoachSchedule();
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
