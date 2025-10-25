import 'package:amina_ec/src/pages/Admin/Reports/AppUsers/admin_reports_app_users_page.dart';
import 'package:amina_ec/src/utils/iconos.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/color.dart';

import 'Class/admin_reports_controller.dart';
import 'Transactions/admin_transactions_page.dart';
import 'Class/admin_reports_classes_page.dart';

final con = Get.put(AdminReportsController());

class AdminReportsPage extends StatelessWidget {
  const AdminReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Usuarios, Clases y Transacciones
      child: Scaffold(
        appBar: AppBar(
          title: _appBarTitle(),
          bottom: TabBar(
            indicatorColor: almostBlack,
            labelColor: almostBlack,

            tabs: [
              Tab(icon:Icon(iconProfile),text: 'Usuarios'),
              Tab(icon:Icon(iconCheck),text: 'Clases'),
              Tab(icon:Icon(iconCard),text: 'Transacciones'),

            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Usuarios 
            AdminReportsAppUsersPage(),
            // Tab 2: Transacciones
            AdminClassesTab(),
            //Tab 3: clases
            AdminTransactionsPage(),
          ],
        ),
      ),
    );
  }

  Widget _appBarTitle() {
    return Text(
      'Reportes',
      style: GoogleFonts.montserrat(
        fontSize: 22,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}
