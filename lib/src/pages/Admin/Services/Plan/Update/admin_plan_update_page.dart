import 'package:amina_ec/src/utils/iconos.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../utils/color.dart';
import 'admin_plan_update_controller.dart';

class AdminPlanUpdatePage extends StatelessWidget {
  final AdminPlanUpdateController con = Get.put(AdminPlanUpdateController());

  AdminPlanUpdatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _appBarTitle(),
      ),
      body: GetBuilder<AdminPlanUpdateController>(
        builder: (_) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 30),
          child: Column(
            children: [
              GestureDetector(
                onTap: con.pickImage,
                child: con.imageFile != null
                    ? Image.file(con.imageFile!, height: 150)
                    : con.plan.image != null
                        ? Image.network(con.plan.image!, height: 150)
                        : Container(
                            height: 150,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 50),
                          ),
              ),
              const SizedBox(height: 16),
              _textFieldName(),
              _textFieldDescription(),
              _textFieldPrice(),
              _textFieldRides(),
              _textFieldDurationDays(),
              _switchNewUserOnly(),
              const SizedBox(height: 20),
              _buttonUpdate(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appBarTitle() {
    return Text(
      'Editar plan',
      style: GoogleFonts.montserrat(
        fontSize: 22,
        fontWeight: FontWeight.w900,
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
          prefixIcon: Icon(iconPlan),
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
          prefixIcon: Icon(iconDescription),
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
          prefixIcon: Icon(iconMoney),
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
          prefixIcon: Icon(iconRides),
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
        controller: con.durationController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          floatingLabelStyle: TextStyle(color: darkGrey),
          labelText: "Duración en días",
          hintText: "Duración en días",
          prefixIcon: Icon(iconSchedule),
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

  Widget _switchNewUserOnly() {
    return Obx(() => SwitchListTile(
      title: Text(
        "Solo para nuevos usuarios",
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      activeColor: almostBlack,
      value: con.isNewUserOnly.value,
      onChanged: (value) => con.isNewUserOnly.value = value,
    ));
  }


  Widget _buttonUpdate(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      width: double.infinity,
      height: 50,
      child: FloatingActionButton.extended(
        onPressed: () => con.updatePlan(),
        label: Text(
          'Actualizar',
          style: TextStyle(
            fontSize: 16,
            color: whiteLight,
            fontWeight: FontWeight.w700,
          ),
        ),
        icon: Icon(
          iconSave,
          color: whiteLight,
        ),
        backgroundColor: almostBlack,
      ),
    );
  }
}
