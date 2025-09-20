import 'package:amina_ec/src/pages/Coach/Profile/Info/coach_profile_info_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CoachProfileInfoPage extends StatelessWidget {
  final CoachProfileInfoController con = Get.put(CoachProfileInfoController());

  CoachProfileInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteLight,
        foregroundColor: almostBlack,
        title: Text(
          'Perfil Coach',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            color: whiteGrey,
            onPressed: () => con.signOut(),
            icon: Icon(
              Icons.exit_to_app,
              color: darkGrey,
            ),
          ),
        ],
      ),
      backgroundColor: whiteLight,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _photoNameEmail(context),
            SizedBox(
              height: 20,
            ),
            _boxFormData(context),
            //_boxFormDataAditional(context),
          ],
        ),
      ),
    );
  }

  Widget _photoNameEmail(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 25, top: 20, bottom: 25),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _userPhoto(),
          const SizedBox(width: 16), // Espacio entre foto y texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${con.user.name} ${con.user.lastname}',
                  style: GoogleFonts.roboto(
                      color: almostBlack,
                      fontSize: 22,
                      fontWeight: FontWeight.w900),
                  overflow: TextOverflow.ellipsis, // Por si acaso
                ),
                SizedBox(height: 4),
                Text(
                  '${con.user.email}',
                  style: TextStyle(color: Colors.black26, fontSize: 13.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
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
      child: GetBuilder<CoachProfileInfoController>(
        builder: (_) => CircleAvatar(
          backgroundColor: darkGrey,
          backgroundImage: con.user.photo_url != null
              ? NetworkImage('${con.user.photo_url}')
              : const AssetImage('assets/img/user_photo1.png') as ImageProvider,
        ),
      ),
    );
  }

  //Box form datos personales
  Widget _boxFormData(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: whiteLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 5,
            offset: Offset(0.10, 0.85),
          ),
        ],
      ),
      child: Column(
        children: [
          _textTitle(),
          _textSubtitle(),
          _textCI(),
          _textPhone(),
        ],
      ),
    );
  }

  Widget _textTitle() {
    return Text(
      'Datos del Coach',
      style: GoogleFonts.alfaSlabOne(
        fontSize: 24,
        fontWeight: FontWeight.w100,
        color: darkGrey,
      ),
    );
  }

  Widget _textSubtitle() {
    return Text(
      '*Los datos del coach no se pueden editar',
      style: GoogleFonts.roboto(fontSize: 12, color: whiteGrey),
    );
  }

  Widget _textCI() {
    return Container(
      margin: const EdgeInsets.only(top: 25, left: 40, right: 40),
      decoration: BoxDecoration(
        color: colorBackgroundBox,
        border: Border.all(
          color: Colors.black12,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(Icons.assignment_ind),
        title: Text(
          '${con.user.ci}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Cédula'),
      ),
    );
  }

  Widget _textPhone() {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 40, right: 40),
      decoration: BoxDecoration(
        color: colorBackgroundBox,
        border: Border.all(
          color: Colors.black12,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(Icons.phone_android),
        title: Text(
          '${con.user.phone}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Teléfono'),
      ),
    );
  }
}
