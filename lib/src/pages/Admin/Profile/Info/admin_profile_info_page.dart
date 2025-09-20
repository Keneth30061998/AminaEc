import 'package:amina_ec/src/pages/Admin/Profile/Info/admin_profile_info_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminProfileInfoPage extends StatelessWidget {
  final AdminProfileInfoController con = Get.put(AdminProfileInfoController());

  AdminProfileInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteLight,
        foregroundColor: darkGrey,
        title: Text(
          'Perfil Administrador',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: () => con.signOut(),
            icon: const Icon(
              Icons.exit_to_app,
              color: whiteGrey,
            ),
          ),
        ],
      ),
      backgroundColor: whiteLight,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          children: [
            _profileHeader(context),
            SizedBox(height: 50),
            _textTitleScaffold(),
            _textSubtitleScaffold(),
            SizedBox(height: 10),
            _infoCard(
              icon: Icons.assignment_ind,
              title: con.user.ci ?? '',
              subtitle: 'Cédula',
            ),
            SizedBox(height: 15),
            _infoCard(
              icon: Icons.phone_android,
              title: con.user.phone ?? '',
              subtitle: 'Teléfono',
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _textSubtitleScaffold() {
    return Text(
      '*Los datos de administrador no se pueden editar',
      style: TextStyle(fontSize: 12, color: whiteGrey),
    );
  }

  Widget _textTitleScaffold() {
    return Text(
      'Datos del administrador',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: darkGrey,
      ),
    );
  }

  Widget _profileHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _userPhoto(),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${con.user.name ?? ''} ${con.user.lastname ?? ''}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: whiteGrey,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                con.user.email ?? '',
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
        child: GetBuilder<AdminProfileInfoController>(
          builder: (_) => con.user.photo_url != null
              ? Image.network(
                  con.user.photo_url!,
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
      elevation: 4,
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
}
