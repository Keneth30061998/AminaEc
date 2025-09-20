// lib/src/pages/Roles/roles_page.dart

import 'package:amina_ec/src/models/rol.dart';
import 'package:amina_ec/src/pages/Roles/roles_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:amina_ec/src/utils/textos.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

final RolesController con = Get.put(RolesController());

class RolesPage extends StatelessWidget {
  const RolesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Rol> roles = con.user.roles ?? [];

    return Scaffold(
      backgroundColor: whiteLight,

      // AppBar limpio, sin sombras
      appBar: AppBar(
        backgroundColor: whiteLight,
        elevation: 0,
        centerTitle: true,
        title: Text(
          txtSeleccionaRol,
          style: GoogleFonts.montserrat(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: almostBlack,
          ),
        ),
      ),

      // Body
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

        // Si no hay roles, mensaje central
        child: roles.isEmpty
            ? Center(
                child: Text(
                  'No hay roles disponibles',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: darkGrey,
                  ),
                ),
              )

            // Si hay roles, grid minimalista
            : GridView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: roles.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 24,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  final rol = roles[index];
                  return _RoleCard(rol: rol)
                      .animate() // flutter_animate
                      .fadeIn(delay: (index * 100).ms); // animación secuencial
                },
              ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final Rol rol;

  const _RoleCard({required this.rol});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => con.goToPage(rol),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar circular con imagen cacheada
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: almostBlack.withAlpha((0.08 * 255).round()),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 70,
              backgroundColor: whiteLight,
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: rol.image ?? '',
                  width: 140,
                  height: 140,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => CircularProgressIndicator(
                      strokeWidth: 2, color: indigoAmina),
                  errorWidget: (_, __, ___) => Image.asset(
                    'assets/img/noImage.jpg',
                    width: 138,
                    height: 138,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // Nombre del rol
          Text(
            rol.name ?? '',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: almostBlack,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
