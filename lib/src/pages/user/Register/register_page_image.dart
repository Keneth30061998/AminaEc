import 'dart:ui';
import 'dart:io';
import 'package:amina_ec/src/pages/user/Register/register_controller.dart';
import 'package:amina_ec/src/utils/iconos.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/user.dart';
import '../../../utils/color.dart';
import 'Terms_Conditions/terms_dialog.dart';

class RegisterPageImage extends StatelessWidget {
  final RegisterController con = Get.put(RegisterController());

  RegisterPageImage({super.key});

  // Rx para controlar el overlay de carga
  final RxBool isLoading = false.obs;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: whiteLight,
            elevation: 0,
            iconTheme: IconThemeData(color: almostBlack),
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
        ),

        // Overlay elegante mientras isLoading == true
        Obx(() => isLoading.value
            ? Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            backgroundBlendMode: BlendMode.darken,
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [indigoAmina, almostBlack],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Creando cuenta...',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
            : const SizedBox.shrink()),
      ],
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
        Obx(() {
          final image = con.imageFile.value;
          return Container(
            width: 110,
            height: 110,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
              ],
            ),
            child: CircleAvatar(
              backgroundColor: darkGrey,
              backgroundImage: image != null
                  ? FileImage(image)
                  : const AssetImage('assets/img/user_photo1.png')
              as ImageProvider,
            ),
          );
        }),
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
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4)
                ],
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
      style: GoogleFonts.poppins(
        color: almostBlack,
        fontWeight: FontWeight.w700,
        fontSize: 22,
      ),
    );
  }

  Widget _textSubtitle() {
    return Text(
      'Escoja una foto para su perfil',
      textAlign: TextAlign.center,
      style: GoogleFonts.poppins(
        color: darkGrey,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    );
  }

  Widget _buttonRegister(BuildContext context) {
    return Obx(() {
      final isButtonEnabled = con.imageFile.value != null;

      return SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton.icon(
          onPressed: isButtonEnabled
              ? () {
            showTermsAndConditionsDialog(
              context: context,
              onAccepted: () async {
                isLoading.value = true;

                final user = User(
                  email: con.emailController.text.trim(),
                  name: con.nameController.text,
                  lastname: con.lastnameController.text,
                  ci: con.ciController.text,
                  phone: con.phoneController.text,
                  password: con.passwordController.text.trim(),
                );

                con.goToSignaturePage(user);

                await Future.delayed(const Duration(milliseconds: 800));
                isLoading.value = false;
              },
            );
          }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor:
            isButtonEnabled ? almostBlack : Colors.grey.shade400,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 4,
          ),
          label: Text(
            'Registrarse',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: whiteLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          icon: Icon(
            iconNext,
            color: whiteLight,
            size: 15,
          ),
        ),
      );
    });
  }
}
