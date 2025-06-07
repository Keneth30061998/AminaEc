import 'package:amina_ec/src/pages/user/Start/user_start_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/coach.dart';

class UserStartPage extends StatelessWidget {
  UserSatartController con = Get.put(UserSatartController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          foregroundColor: limeGreen,
          backgroundColor: darkGrey,
          title: _appBarTitle(),
        ),
        body: Obx(() {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _textGreeting(),
                _containerCount(),
                _textTitleInfo(),
                _textInfo(),
                _texttitleCoachs(),
                _boxCoachs(context),
              ],
            ),
          );
        }));
  }

  Widget _appBarTitle() {
    return Text(
      'Amina Ec',
      style: GoogleFonts.montserrat(
        fontSize: 30,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _textGreeting() {
    return Container(
      margin: EdgeInsets.only(left: 30, top: 10),
      child: Text(
        'Hola, ${con.user.name}',
        style: TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _containerCount() {
    return Container(
        padding: EdgeInsets.all(25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 30,
          children: [
            _boxBikesComplete(),
            _boxBikesPending(),
          ],
        ));
  }

  Widget _boxBikesComplete() {
    return Container(
      height: 120,
      width: 150,
      decoration: BoxDecoration(
        color: almostBlack,
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
        border: Border.all(
          color: Colors.white24, // Cambia el color aquí si deseas otro
          width: 2.0, // Grosor de la línea
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.white10,
            blurRadius: 8,
            offset: Offset(0.10, 0.85),
          ),
        ],
      ),
      child: _textDataBikesComplete(),
    );
  }

  Widget _boxBikesPending() {
    return Container(
      height: 120,
      width: 150,
      decoration: BoxDecoration(
        color: almostBlack,
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
        border: Border.all(
          color: Colors.white24, // Cambia el color aquí si deseas otro
          width: 2.0, // Grosor de la línea
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.white10,
            blurRadius: 8,
            offset: Offset(0.10, 0.85),
          ),
        ],
      ),
      child: _textDataBikesPending(),
    );
  }

  Widget _textDataBikesPending() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Rides',
          style: GoogleFonts.kodchasan(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        Text(
          '0',
          style: GoogleFonts.kodchasan(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          'Pendientes',
          style: GoogleFonts.kodchasan(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _textDataBikesComplete() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Rides',
          style: GoogleFonts.kodchasan(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        Text(
          '1',
          style: GoogleFonts.kodchasan(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          'Completados',
          style: GoogleFonts.kodchasan(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _textTitleInfo() {
    return Container(
      margin: EdgeInsets.only(left: 35, top: 15),
      child: Text(
        'Rides para hoy (0)',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _textInfo() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      child: Text(
        'No se han reservado rides, agenda un ride para hoy seleccionando uno en el calendario',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _texttitleCoachs() {
    return Container(
      margin: EdgeInsets.only(left: 35, top: 15),
      child: Text(
        'Instructores',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _boxCoachs(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 35,
      ),
      padding: const EdgeInsets.all(10),
      //decoration: BoxDecoration(color: almostBlack),
      height: MediaQuery.of(context).size.height * 0.38,
      child: ListView.builder(
        itemCount: con.coaches.length,
        itemBuilder: (context, index) {
          final coach = con.coaches[index];
          return _cardCoachs(coach, context);
        },
      ),
    );
  }

  Widget _cardCoachs(Coach coach, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: almostBlack,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white54,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white10,
            blurRadius: 8,
            offset: const Offset(0.1, 0.85),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Nombre
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _textCoachName(coach, context),
              _textCoachDescription(coach, context),
            ],
          )),
          const SizedBox(width: 16),
          // Foto
          _photoCoachs(coach),
        ],
      ),
    );
  }

  Widget _textCoachName(Coach coach, BuildContext context) {
    return Text(
      coach.user?.name ?? 'Nombre no disponible',
      style: GoogleFonts.montserrat(
        fontSize: MediaQuery.of(context).size.width > 600 ? 26 : 20,
        fontWeight: FontWeight.w800,
        color: Colors.white,
      ),
      maxLines: 2,
    );
  }

  Widget _textCoachDescription(Coach coach, BuildContext context) {
    return Text(
      coach.description ?? 'Descripción no disponible',
      style: GoogleFonts.roboto(
        fontSize: MediaQuery.of(context).size.width > 600 ? 20 : 14,
        color: Colors.white38,
      ),
      maxLines: 3,
    );
  }

  Widget _photoCoachs(Coach coach) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: coach.user?.photo_url != null
          ? Image.network(
              coach.user!.photo_url!,
              width: 120,
              height: 100,
              fit: BoxFit.fill,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 50, color: Colors.grey),
            )
          : Container(
              width: 100,
              height: 100,
              color: Colors.grey[300],
              child: const Icon(Icons.person, size: 50, color: Colors.white),
            ),
    );
  }
}
