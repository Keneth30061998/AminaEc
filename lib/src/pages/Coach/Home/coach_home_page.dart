import 'package:amina_ec/src/pages/Coach/Home/coach_home_controller.dart';
import 'package:amina_ec/src/pages/Coach/Profile/Info/coach_profile_info_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../../../utils/color.dart';
import '../Class/coach_class_page.dart';

class CoachHomePage extends StatelessWidget {
  final CoachHomeController con = Get.put(CoachHomeController());
  // Considera hacer estas páginas más significativas o incluso widgets separados si crecen en complejidad.
  final List<Widget> _pageViews = [
    CoachClassPage(),
    CoachProfileInfoPage(),
  ];

  // Constantes para el BottomNavigationBar
  //static const double _bottomNavBorderRadius = 20.0;
  static const EdgeInsets _bottomNavPadding =
      EdgeInsets.symmetric(horizontal: 100, vertical: 14);
  static const EdgeInsets _gNavButtonPadding =
      EdgeInsets.symmetric(horizontal: 15, vertical: 10);
  static const double _gNavIconSize = 26.5;
  static const double _gNavGap = 10.0;
  static const int _gNavAnimationMillis = 460;
  static const double _gNavTabBorderRadius = 15.0;

  CoachHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
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
        ));
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
            icon: Icons.calendar_month,
            text: 'Agenda',
            backgroundGradient: LinearGradient(
              colors: [almostBlack, darkGrey],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
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
