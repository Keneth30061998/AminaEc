import 'package:amina_ec/src/pages/Roles/roles_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/rol.dart';

class RolesPage extends StatelessWidget {
  final RolesController con = Get.put(RolesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteLight,
      appBar: AppBar(
        backgroundColor: whiteLight,
        foregroundColor: darkGrey,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Seleccione un rol',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: ListView.builder(
          itemCount: con.user.roles?.length ?? 0,
          itemBuilder: (context, index) {
            final rol = con.user.roles![index];
            return _cardRol(rol);
          },
        ),
      ),
    );
  }

  Widget _cardRol(Rol rol) {
    return GestureDetector(
      onTap: () => con.goToPage(rol),
      child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: color_background_box,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: _photoAndName(rol)),
    );
  }

  Widget _photoAndName(Rol rol) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: FadeInImage.assetNetwork(
            placeholder: 'assets/img/noImage.jpg',
            image: rol.image ?? '',
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            fadeInDuration: Duration(milliseconds: 200),
            imageErrorBuilder: (context, error, stackTrace) {
              return Image.asset('assets/img/noImage.jpg',
                  width: 60, height: 60, fit: BoxFit.cover);
            },
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Text(
            rol.name ?? '',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: almostBlack,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
