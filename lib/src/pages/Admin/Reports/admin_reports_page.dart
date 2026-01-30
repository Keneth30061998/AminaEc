import 'package:amina_ec/src/pages/Admin/Reports/AppUsers/admin_reports_app_users_page.dart';
import 'package:amina_ec/src/pages/Admin/Reports/Attendance/admin_reports_classes_page.dart';
import 'package:amina_ec/src/pages/Admin/Reports/Attendance/admin_reports_controller.dart';
import 'package:amina_ec/src/pages/Admin/Reports/Class/Schedule/admin_edit_schedule_class_page.dart';
import 'package:amina_ec/src/utils/iconos.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/color.dart';
import 'Transactions/admin_transactions_page.dart';

class AdminReportsPage extends StatelessWidget {
  const AdminReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mantiene la funcionalidad de tener el controller disponible para las tabs,
    // pero evita crear instancias en variables globales (y duplicados).
    if (!Get.isRegistered<AdminReportsController>()) {
      Get.put(AdminReportsController());
    }

    return DefaultTabController(
      length: 4, // Usuarios, Clases, Asistencia, Transacciones
      child: Scaffold(
        appBar: AppBar(
          title: _appBarTitle(),
          bottom: TabBar(
            indicatorColor: almostBlack,
            labelColor: almostBlack,
            tabs: const [
              Tab(icon: Icon(iconProfile), text: 'Usuarios'),
              Tab(icon: Icon(iconRides), text: 'Clases'),
              Tab(icon: Icon(iconCheck), text: 'Asistencia'),
              Tab(icon: Icon(iconCard), text: 'Transacciones'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Usuarios
            AdminReportsAppUsersPage(),

            // Tab 2: Clases (Schedule)
            AdminCoachSchedulePage(),

            // Tab 3: Asistencia
            AdminClassesTab(),

            // Tab 4: Transacciones
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
