import 'package:amina_ec/src/pages/user/Register/register_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/user.dart';
import '../../../utils/color.dart';
import 'Terms_Conditions/terms_dialog.dart';

class RegisterPageImage extends StatelessWidget {
  final RegisterController con = Get.put(RegisterController());

  RegisterPageImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteLight,
      ),
      backgroundColor: whiteLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 130),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _boxFormData(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _boxFormData(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 20),
      decoration: BoxDecoration(
        color: colorBackgroundBox,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(3, 3)),
        ],
      ),
      child: Column(
        children: [
          _boxPhoto(context),
          const SizedBox(height: 25),
          _textTitle(),
          const SizedBox(height: 10),
          _textSubtitle(),
          const SizedBox(height: 30),
          _buttonRegister(context),
        ],
      ),
    );
  }

  Widget _boxPhoto(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
            ],
          ),
          child: GetBuilder<RegisterController>(
            builder: (_) => CircleAvatar(
              backgroundColor: darkGrey,
              backgroundImage: con.imageFile != null
                  ? FileImage(con.imageFile!)
                  : const AssetImage('assets/img/user_photo1.png') as ImageProvider,
            ),
          ),
        ),
        Positioned(
          bottom: 4,
          right: 4,
          child: InkWell(
            onTap: () => con.showAlertDialog(context),
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: const Icon(Icons.edit, size: 20, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _textTitle() {
    return Text(
      'Foto de Perfil',
      textAlign: TextAlign.center,
      style: GoogleFonts.poppins(color: almostBlack, fontWeight: FontWeight.w700, fontSize: 22),
    );
  }

  Widget _textSubtitle() {
    return Text(
      'Escoja una foto para su perfil',
      textAlign: TextAlign.center,
      style: GoogleFonts.poppins(color: darkGrey, fontWeight: FontWeight.w500, fontSize: 14),
    );
  }

  Widget _buttonRegister(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          showTermsAndConditionsDialog(
            context: context,
            onAccepted: () {
              final user = User(
                email: con.emailController.text.trim(),
                name: con.nameController.text,
                lastname: con.lastnameController.text,
                ci: con.ciController.text,
                phone: con.phoneController.text,
                password: con.passwordController.text.trim(),
              );

              con.goToSignaturePage(user);
            },
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: almostBlack,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 4,
        ),
        child: Text(
          'Registrarse',
          style: GoogleFonts.poppins(fontSize: 16, color: whiteLight, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
