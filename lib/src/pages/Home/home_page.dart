import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../home/home_controller.dart';

class HomePage extends StatelessWidget {
  final HomeController con = Get.put(HomeController());

  HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkGrey,
        foregroundColor: limeGreen,
        title: const Text(
          'Perfil de usuario',
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
          ],
        ),
      ),
    );
  }

  Widget _photoNameEmail(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _boxPhoto(context),
          const SizedBox(width: 16), // Espacio entre foto y texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Keneth Escobar',
                  style: TextStyle(
                      color: limeGreen,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis, // Por si acaso
                ),
                SizedBox(height: 4),
                Text(
                  'kenethescobar1998@espoch.edu.ec',
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
      child: GetBuilder<HomeController>(
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

  Widget _boxFormData(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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
          _textCI(),
          _textPhone(),
          _buttonUpdate(context),
        ],
      ),
    );
  }

  Widget _textTitle() {
    return const Text(
      'Datos de Usuario',
      style: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.bold,
        color: Colors.white70,
      ),
    );
  }

  Widget _textCI() {
    return Container(
      margin: const EdgeInsets.only(top: 30, left: 40, right: 40),
      decoration: BoxDecoration(
        color: colorBackgroundBox,
        border: Border.all(
          color: darkGrey,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const ListTile(
        leading: Icon(Icons.assignment_ind),
        title: Text(
          '0604547448',
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
          color: darkGrey,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const ListTile(
        leading: Icon(Icons.phone_android),
        title: Text(
          '0989108886',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Teléfono'),
      ),
    );
  }

  Widget _buttonUpdate(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      width: MediaQuery.of(context).size.width * 0.77,
      height: 50,
      child: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text(
          'Actualizar',
          style: TextStyle(
              fontSize: 16, color: almostBlack, fontWeight: FontWeight.w700),
        ),
        backgroundColor: limeGreen,
      ),
    );
  }
}
