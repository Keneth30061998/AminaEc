import 'package:amina_ec/src/pages/Admin/Coach/List/admin_coach_list_page.dart';
import 'package:amina_ec/src/pages/Admin/Home/admin_home_controller.dart';
import 'package:amina_ec/src/pages/Admin/Services/admin_services_page.dart';

import 'package:amina_ec/src/utils/color.dart';
import 'package:amina_ec/src/utils/iconos.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../Profile/Info/admin_profile_info_page.dart';
import '../Reports/admin_reports_page.dart';
import '../Start/admin_start_page.dart';

class AdminHomePage extends StatelessWidget {
  // Es buena práctica marcar como 'final' si no se reasignará.
  final AdminHomeController con = Get.put(AdminHomeController());

  // Considera hacer estas páginas más significativas o incluso widgets separados si crecen en complejidad.
  final List<Widget> _pageViews = [
    AdminStartPage(),
    AdminServicesPage(),
    AdminCoachListPage(),
    AdminReportsPage(),
    AdminProfileInfoPage(),
  ];

  // Constantes para el BottomNavigationBar
  //static const double _bottomNavBorderRadius = 20.0;
  static const EdgeInsets _bottomNavPadding =
      EdgeInsets.symmetric(horizontal: 20, vertical: 14);
  static const EdgeInsets _gNavButtonPadding =
      EdgeInsets.symmetric(horizontal: 8, vertical: 10);
  static const double _gNavIconSize = 26.5;
  static const double _gNavGap = 10.0;
  static const int _gNavAnimationMillis = 460;
  static const double _gNavTabBorderRadius = 15.0;

  AdminHomePage({super.key}); // Añadir constructor con key

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: _pageViews[con.indexTab.value],
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      // width: MediaQuery.of(context).size.width, // Ocupa el ancho completo por defecto en BottomNavigationBar
      padding: _bottomNavPadding,
      decoration: const BoxDecoration(
        color: colorBackgroundBox,
      ),
      child: GNav(
        rippleColor: darkGrey,
        hoverColor: darkGrey,
        haptic: true,
        tabBorderRadius: _gNavTabBorderRadius,
        curve: Curves.easeOutExpo,
        duration: const Duration(milliseconds: _gNavAnimationMillis),
        gap: _gNavGap,
        color: whiteGrey, // Considera definir este color
        activeColor: whiteLight,
        iconSize: _gNavIconSize,
        tabBackgroundColor: almostBlack,
        padding: _gNavButtonPadding,
        selectedIndex: con.indexTab.value,
        onTabChange: con.changeTab,
        tabs: [
          const GButton(
            // Usar const si los parámetros no cambian
            icon: iconHome,
            text: 'Inicio',
            backgroundGradient: LinearGradient(
              colors: [almostBlack, darkGrey],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          const GButton(
            icon: iconPlan,
            text: 'Servicios',
          ),
          const GButton(
            icon: Icons.directions_bike_outlined,
            text: 'Coachs',
          ),
          const GButton(
            icon: Icons.stacked_bar_chart_rounded,
            text: 'Reportes',
          ),
          const GButton(
            icon: iconProfile,
            text: 'Perfil',
          ),
        ],
      ),
    );
  }
}
