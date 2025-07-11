import 'package:amina_ec/src/pages/user/Coach/List/user_coach_list_page.dart';
import 'package:amina_ec/src/pages/user/Home/user_home_controller.dart';
import 'package:amina_ec/src/pages/user/Plan/List/user_plan_list_page.dart';
import 'package:amina_ec/src/pages/user/Profile/Info/user_profile_info_page.dart';
import 'package:amina_ec/src/utils/color.dart'; // Asumo que darkGrey, limeGreen, almostBlack están aquí
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../../../utils/iconos.dart';
import '../Start/user_start_page.dart';

class UserHomePage extends StatelessWidget {
  final UserHomeController con = Get.put(UserHomeController());

  final List<Widget> _pageViews = [
    UserStartPage(),
    UserPlanListPage(),
    UserCoachSchedulePage(),
    //UserProfileUpdatePage(),
    UserProfileInfoPage(),
  ];

  // Constantes para el BottomNavigationBar
  static const double _bottomNavBorderRadius = 20.0;
  static const EdgeInsets _bottomNavPadding =
      EdgeInsets.symmetric(horizontal: 20, vertical: 14);
  static const EdgeInsets _gNavButtonPadding =
      EdgeInsets.symmetric(horizontal: 15, vertical: 10);
  static const double _gNavIconSize = 26.5;
  static const double _gNavGap = 10.0;
  static const int _gNavAnimationMillis = 460;
  static const double _gNavTabBorderRadius = 15.0;

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
        color: color_background_box,
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
            icon: icon_home,
            text: 'Inicio',
            backgroundGradient: LinearGradient(
              colors: [almostBlack, darkGrey],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          const GButton(
            icon: icon_plan,
            text: 'Planes',
          ),
          const GButton(
            icon: icon_schedule,
            text: 'Agenda',
          ),
          const GButton(
            icon: icon_profile,
            text: 'Perfil',
          ),
        ],
      ),
    );
  }
}
