// lib/src/pages/Roles/roles_page.dart

import 'package:amina_ec/src/models/rol.dart';
import 'package:amina_ec/src/pages/Roles/roles_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:amina_ec/src/utils/textos.dart';

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
                  mainAxisSpacing: 30,
                  crossAxisSpacing: 30,
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
      borderRadius: BorderRadius.circular(16),
      onTap: () => con.goToPage(rol),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: whiteLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícono genérico (opcional, puedes cambiar por otro)
            Icon(
              Icons.settings_accessibility,
              size: 60,
              color: almostBlack,
            ),

            const SizedBox(height: 16),

            // Nombre del rol
            Text(
              rol.name ?? '',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: almostBlack,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

