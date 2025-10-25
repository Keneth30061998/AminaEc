import 'package:amina_ec/src/pages/user/Profile/Info/user_profile_info_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:amina_ec/src/utils/iconos.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class UserProfileInfoPage extends StatelessWidget {
  final UserProfileInfoController con = Get.put(UserProfileInfoController());

  UserProfileInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteLight,
      appBar: AppBar(
        backgroundColor: whiteLight,
        foregroundColor: darkGrey,
        title: _textTitleAppBar(),
        actions: [
          _buttonLogout(),
        ],
      ),
      body: Obx(() => SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              children: [
                _profileHeader(context),
                SizedBox(height: 30),
                _textTitleScaffold(),
                SizedBox(height: 10),
                _infoCard(
                  icon: Icons.assignment_ind,
                  title: con.user.value.ci ?? '',
                  subtitle: 'Cédula',
                ),
                //SizedBox(height: 4),
                _infoCard(
                  icon: Icons.phone_android,
                  title: con.user.value.phone ?? '',
                  subtitle: 'Teléfono',
                ),
                //SizedBox(height: 4),
                _infoCard(
                  icon: iconBirthDate,
                  title: con.user.value.birthDate?.split('T').first.split('-').reversed.join('/') ?? '',
                  subtitle: 'Fecha de Nacimiento',
                ),
                SizedBox(height: 40),
                _updateButton(context),
              ],
            ),
          )),
    );
  }

  Widget _textTitleAppBar() {
    return Text(
      'Perfil de usuario',
      style: GoogleFonts.montserrat(
        fontSize: 22,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buttonLogout() {
    return IconButton(
      icon: Icon(iconCloseSession, color: whiteGrey),
      onPressed: () => con.signOut(),
    );
  }

  Widget _textTitleScaffold() {
    return Text(
      'Datos de usuario',
      style: GoogleFonts.roboto(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        color: darkGrey,
      ),
    );
  }

  Widget _profileHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 5),
        _userPhoto(),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${con.user.value.name ?? ''} ${con.user.value.lastname ?? ''}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: darkGrey,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                con.user.value.email ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black45,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _userPhoto() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: darkGrey, width: 2),
      ),
      child: ClipOval(
        child: GetBuilder<UserProfileInfoController>(
          builder: (_) => con.user.value.photo_url != null
              ? Image.network(
                  con.user.value.photo_url!,
                  fit: BoxFit.cover,
                )
              : Image.asset(
                  'assets/img/user_photo1.png',
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: darkGrey),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
      ),
    );
  }

  Widget _updateButton(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => con.goToProfileUpdate(),
            style: ElevatedButton.styleFrom(
              backgroundColor: almostBlack,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            icon: Icon(Icons.edit, color: Colors.white),
            label: Text(
              'Actualizar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: whiteLight,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => con.confirmDeleteAccount(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.delete_forever, color: Colors.white),
            label: const Text(
              'Eliminar cuenta',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
