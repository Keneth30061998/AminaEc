import 'package:amina_ec/src/pages/Admin/Plan/List/admin_plan_list_page.dart';
import 'package:amina_ec/src/pages/Admin/Plan/Register/admin_plan_register_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../../../utils/iconos.dart';

class AdminPlanRegisterPage extends StatelessWidget {
  AdminPlanRegisterController con = Get.put(AdminPlanRegisterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteLight,
        foregroundColor: darkGrey,
        title: _texttitleAppbar(),
      ),
      body: AdminPlanListPage(),
      floatingActionButton: _buttonAddPlan(context),
    );
  }

  Widget _texttitleAppbar() {
    return Text(
      'Planes de pago',
      style: GoogleFonts.montserrat(
        fontSize: 22,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buttonAddPlan(BuildContext context) {
    return FloatingActionButton.extended(
      label: Text('Añadir plan'),
      icon: Icon(icon_add),
      backgroundColor: limeGreen,
      onPressed: () {
        showMaterialModalBottomSheet(
            context: context, builder: (context) => _formAddPlan(context));
      },
    );
  }

  Widget _formAddPlan(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: MediaQuery.of(context)
            .viewInsets, // esto ajusta el padding con respecto al teclado
        child: SingleChildScrollView(
          controller: ModalScrollController.of(
              context), // importante para scroll correcto
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _textTitle(context),
                _textSubtitle(context),
                _cardImage(context),
                _textFieldName(),
                _textFieldDescription(),
                _textFieldRides(),
                _textFieldPrice(),
                _textFieldDurationDays(),
                const SizedBox(
                  height: 10,
                ),
                _buttonSave(context),
                const SizedBox(
                    height: 30), // espacio extra para no estar justo al borde
              ],
            ),
          ),
        ),
      ),
    );
  }

  //Widgets form modal bottom
  Widget _textTitle(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 10),
      child: Text(
        'Registro de planes',
        style: GoogleFonts.montserrat(
          color: almostBlack,
          fontSize: 26,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _textSubtitle(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: Text(
        '*Ingrese los campos correspondientes',
        style: GoogleFonts.roboto(
          color: darkGrey,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _cardImage(BuildContext context) {
    return GestureDetector(
      onTap: () {
        return con.showAlertDialog(context);
      },
      child: Obx(
        () => Card(
          elevation: 2,
          child: Container(
              color: Colors.transparent,
              height: 100,
              width: MediaQuery.of(context).size.width * 0.3,
              padding: EdgeInsets.all(2),
              child: con.imageFile.value != null
                  ? Image.file(
                      con.imageFile.value!,
                      fit: BoxFit.cover,
                    )
                  : Image.asset('assets/img/addImage.png')),
        ),
      ),
    );
  }

  Widget _textFieldName() {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 5),
      child: TextField(
        controller: con.nameController,
        keyboardType: TextInputType.name,
        decoration: InputDecoration(
          floatingLabelStyle: TextStyle(color: darkGrey),
          labelText: "Nombre",
          hintText: "Nombre",
          prefixIcon: Icon(icon_plan),
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
      margin: EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: con.descriptionController,
        keyboardType: TextInputType.name,
        maxLines: 2,
        decoration: InputDecoration(
          floatingLabelStyle: TextStyle(color: darkGrey),
          labelText: "Descripción",
          hintText: "Descripción",
          prefixIcon: Icon(icon_description),
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

  Widget _textFieldRides() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: con.ridesController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          floatingLabelStyle: TextStyle(color: darkGrey),
          labelText: "Rides",
          hintText: "Rides",
          prefixIcon: Icon(icon_rides),
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

  Widget _textFieldPrice() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: con.priceController,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\,?\d{0,2}')),
        ],
        decoration: InputDecoration(
          floatingLabelStyle: TextStyle(color: darkGrey),
          labelText: "Precio",
          hintText: "Precio",
          prefixIcon: Icon(icon_money),
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

  Widget _textFieldDurationDays() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: con.durationDaysController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          floatingLabelStyle: TextStyle(color: darkGrey),
          labelText: "Duración en días",
          hintText: "Duración en días",
          prefixIcon: Icon(icon_schedule),
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

  Widget _buttonSave(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      width: MediaQuery.of(context).size.width * 0.77,
      height: 50,
      child: FloatingActionButton.extended(
        onPressed: () => con.registerPlan(context),
        label: Text(
          'Guardar',
          style: TextStyle(
            fontSize: 16,
            color: whiteLight,
            fontWeight: FontWeight.w700,
          ),
        ),
        icon: Icon(
          icon_save,
          color: whiteLight,
        ),
        backgroundColor: almostBlack,
      ),
    );
  }
}
