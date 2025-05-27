import 'package:amina_ec/src/pages/user/Profile/Info/user_profile_info_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserProfileInfoPage extends StatelessWidget {
  UserProfileInfoController con = Get.put(UserProfileInfoController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkGrey,
        foregroundColor: limeGreen,
        title: _titleAppbar(),
        actions: [
          _actionButtonExit(),
        ],
      ),
      backgroundColor: darkGrey,
      body: Obx(
        () => SingleChildScrollView(
          child: Column(
            children: [
              _photoNameEmail(context),
              _boxFormData(context),
            ],
          ),
        ),
      ),
    );
  }

  //Widgets - AppBar
  Widget _titleAppbar() {
    return Text(
      'Perfil de usuario',
      style: TextStyle(fontWeight: FontWeight.w600),
    );
  }

  Widget _actionButtonExit() {
    return Container(
      margin: EdgeInsets.only(right: 15),
      child: IconButton.filled(
        onPressed: () => con.signOut(),
        icon: const Icon(Icons.exit_to_app),
      ),
    );
  }

  Widget _photoNameEmail(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
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
                  '${con.user.value.name} ${con.user.value.lastname}',
                  style: TextStyle(
                      color: limeGreen,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  '${con.user.value.email}',
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
      margin: EdgeInsets.only(left: 10),
      decoration: const BoxDecoration(
        color: darkGrey,
        shape: BoxShape.circle,
      ),
      child: GetBuilder<UserProfileInfoController>(
        builder: (_) => CircleAvatar(
          backgroundColor: darkGrey,
          backgroundImage: con.user.value.photo_url != null
              ? NetworkImage(con.user.value.photo_url.toString())
              : const AssetImage('assets/img/user_photo1.png') as ImageProvider,
        ),
      ),
    );
  }

  Widget _boxFormData(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
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
          '${con.user.value.ci}',
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
          '${con.user.value.phone}',
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
        onPressed: () {
          con.goToProfileUpdate();
        },
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
