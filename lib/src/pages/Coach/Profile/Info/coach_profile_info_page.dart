import 'package:amina_ec/src/pages/Coach/Profile/Info/coach_profile_info_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CoachProfileInfoPage extends StatelessWidget {
  CoachProfileInfoController con = Get.put(CoachProfileInfoController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkGrey,
        foregroundColor: limeGreen,
        title: const Text(
          'Perfil Coach',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton.filled(
            onPressed: () => con.signOut(),
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      backgroundColor: darkGrey,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _photoNameEmail(context),
            _boxFormData(context),
            _boxFormDataAditional(context),
          ],
        ),
      ),
    );
  }

  Widget _photoNameEmail(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 30),
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
                  style: TextStyle(
                      color: limeGreen,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis, // Por si acaso
                ),
                SizedBox(height: 4),
                Text(
                  '${con.user.email}',
                  style: TextStyle(color: Colors.white60, fontSize: 13.5),
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
        color: darkGrey,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Colors.black87,
            blurRadius: 10,
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
    return const Text(
      'Datos del Coach',
      style: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.bold,
        color: Colors.white70,
      ),
    );
  }

  Widget _textSubtitle() {
    return Text(
      '*Los datos del coach no se pueden editar',
      style: TextStyle(fontSize: 12, color: Colors.white30),
    );
  }

  Widget _textCI() {
    return Container(
      margin: const EdgeInsets.only(top: 30, left: 40, right: 40),
      decoration: BoxDecoration(
        color: color_background_box,
        border: Border.all(
          color: darkGrey,
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
        color: color_background_box,
        border: Border.all(
          color: darkGrey,
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

  //Box form datos adicionales
  Widget _boxFormDataAditional(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: darkGrey,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Colors.black87,
            blurRadius: 10,
            offset: Offset(0.10, 0.85),
          ),
        ],
      ),
      child: Column(
        children: [
          _textTitleAditional(),
          _textHobby(),
          _textDescription(),
          _textPresentation(),
        ],
      ),
    );
  }

  Widget _textTitleAditional() {
    return const Text(
      'Datos adicionales',
      style: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.bold,
        color: Colors.white70,
      ),
    );
  }

  Widget _textHobby() {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 40, right: 40),
      decoration: BoxDecoration(
        color: color_background_box,
        border: Border.all(
          color: darkGrey,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(Icons.gamepad),
        title: Text(
          'Hobby',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Jugar Futbol'),
      ),
    );
  }

  Widget _textDescription() {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 40, right: 40),
      decoration: BoxDecoration(
        color: color_background_box,
        border: Border.all(
          color: darkGrey,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(Icons.person_search),
        title: Text(
          'Description',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Jugar Futbol'),
      ),
    );
  }

  Widget _textPresentation() {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 40, right: 40),
      decoration: BoxDecoration(
        color: color_background_box,
        border: Border.all(
          color: darkGrey,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(Icons.description),
        title: Text(
          'Presentation',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Jugar Futbol'),
      ),
    );
  }
}
