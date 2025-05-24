import 'package:amina_ec/src/pages/Admin/Home/admin_home_controller.dart';
import 'package:amina_ec/src/utils/color.dart'; // Asumo que darkGrey, limeGreen, almostBlack están aquí
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class AdminHomePage extends StatelessWidget {
  // Es buena práctica marcar como 'final' si no se reasignará.
  final AdminHomeController adminHomeController =
      Get.put(AdminHomeController());

  // Considera hacer estas páginas más significativas o incluso widgets separados si crecen en complejidad.
  final List<Widget> _pageViews = [
    const Center(
      // Usar Center para mejor visualización de texto simple
      child: Text(
        'Home',
        style:
            TextStyle(color: Colors.white, fontSize: 24), // Ejemplo de estilo
      ),
    ),
    const Center(
      child: Text(
        'Favorite',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    ),
    const Center(
      child: Text(
        'Search',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    ),
    const Center(
      child: Text(
        'Profile',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    ),
  ];

  // Constantes para el BottomNavigationBar
  static const double _bottomNavBorderRadius = 20.0;
  static const EdgeInsets _bottomNavPadding =
      EdgeInsets.symmetric(horizontal: 20, vertical: 14);
  static const EdgeInsets _gNavButtonPadding =
      EdgeInsets.symmetric(horizontal: 15, vertical: 10);
  static const double _gNavIconSize = 26.5;
  static const double _gNavGap = 10.0;
  static const int _gNavAnimationMillis = 700;
  static const double _gNavTabBorderRadius = 15.0;

  AdminHomePage({super.key}); // Añadir constructor con key

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          appBar: AppBar(
            backgroundColor: darkGrey,
            foregroundColor: limeGreen,
            title: Text(
              'Administrador',
              style: GoogleFonts.gothicA1(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: _pageViews[adminHomeController.indexTab.value],
          bottomNavigationBar: _buildBottomNavigationBar(context),
        ));
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      // width: MediaQuery.of(context).size.width, // Ocupa el ancho completo por defecto en BottomNavigationBar
      padding: _bottomNavPadding,
      decoration: const BoxDecoration(
        color: Colors
            .white10, // Considera definir este color en tu archivo de colores
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(_bottomNavBorderRadius),
          topRight: Radius.circular(_bottomNavBorderRadius),
        ),
      ),
      child: GNav(
        rippleColor: limeGreen,
        hoverColor: limeGreen,
        haptic: true,
        tabBorderRadius: _gNavTabBorderRadius,
        curve: Curves.easeOutExpo,
        duration: const Duration(milliseconds: _gNavAnimationMillis),
        gap: _gNavGap,
        color: Colors.white60, // Considera definir este color
        activeColor: almostBlack,
        iconSize: _gNavIconSize,
        tabBackgroundColor: limeGreen,
        padding: _gNavButtonPadding,
        selectedIndex: adminHomeController.indexTab.value,
        onTabChange: adminHomeController.changeTab,
        tabs: [
          const GButton(
            // Usar const si los parámetros no cambian
            icon: Icons.home,
            text: 'Inicio',
            backgroundGradient: LinearGradient(
              colors: [limeGreen, Colors.lightGreenAccent],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          const GButton(
            icon: Icons.directions_bike_outlined,
            text: 'Coachs',
          ),
          const GButton(
            icon: Icons.local_offer_sharp,
            text: 'Planes',
          ),
          const GButton(
            icon: Icons.person,
            text: 'Perfil',
          ),
        ],
      ),
    );
  }
}
