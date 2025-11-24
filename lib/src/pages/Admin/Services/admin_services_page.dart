import 'package:amina_ec/src/pages/Admin/Services/Plan/List/admin_plan_list_page.dart';
import 'package:amina_ec/src/pages/Admin/Services/Plan/Register/admin_plan_register_page.dart';
import 'package:amina_ec/src/pages/Admin/Services/Sponsor/List/admin_sponsor_list_page.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/iconos.dart';

class AdminServicesPage extends StatelessWidget {
  const AdminServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Usuarios, Clases y Transacciones
      child: Scaffold(
        appBar: AppBar(
          title: _appBarTitle(),
          bottom: TabBar(
            indicatorColor: almostBlack,
            labelColor: almostBlack,

            tabs: [
              Tab(icon:Icon(iconPlan),text: 'Planes'),
              Tab(icon:Icon(iconGift),text: 'Beneficios'),

            ],
          ),
        ),
        body: TabBarView(
          children: [
            //AdminPlanListPage(),
            AdminPlanRegisterPage(),
            AdminSponsorListPage()
          ],
        ),
      ),
    );
  }

  Widget _appBarTitle() {
    return Text(
      'Servicios',
      style: GoogleFonts.montserrat(
        fontSize: 22,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}
