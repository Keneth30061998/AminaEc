import 'package:amina_ec/src/pages/Admin/Reports/admin_reports_controller.dart';

import 'package:amina_ec/src/utils/iconos.dart';
import 'package:amina_ec/src/utils/textos.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/color.dart';
import '../Transactions/admin_transactions_page.dart';
import 'admin_reports_classes_page.dart';

final con = Get.put(AdminReportsController());

class AdminReportsPage extends StatelessWidget {
  const AdminReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Clases y Transacciones
      child: Scaffold(
        appBar: AppBar(
          title: _appBarTitle(),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Clases'),
              Tab(text: 'Transacciones'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // Tab 1: Clases (tu UI actual)
            AdminClassesTab(),
            // Tab 2: Transacciones
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
