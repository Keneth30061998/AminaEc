import 'package:amina_ec/src/pages/Roles/roles_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/rol.dart';
import '../../utils/textos.dart';

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
          txt_selecciona_rol,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            vertical: 15, horizontal: MediaQuery.of(context).size.width * 0.28),
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(2, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: FadeInImage.assetNetwork(
                placeholder: 'assets/img/noImage.jpg',
                image: rol.image ?? '',
                height: 160,
                fit: BoxFit.contain,
                imageErrorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/img/noImage.jpg',
                    height: 160,
                    fit: BoxFit.fill,
                  );
                },
              ),
            ),
            // Nombre
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(
                rol.name ?? 'Sin nombre',
                textAlign: TextAlign.center,
                style: GoogleFonts.acme(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: almostBlack,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
