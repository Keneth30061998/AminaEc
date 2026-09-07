import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Shared/admin_ui.dart';
import 'Attendance/admin_reports_classes_page.dart';
import 'Attendance/admin_reports_controller.dart';
import 'Transactions/admin_transactions_page.dart';
import 'Transactions/admin_transactions_controller.dart';
import 'Ratings/admin_reports_class_ratings_page.dart';
import 'Ratings/admin_reports_class_ratings_controller.dart';

class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key});
  @override
  AdminReportsPageState createState() => AdminReportsPageState();
}

class AdminReportsPageState extends State<AdminReportsPage> {
  int index = 0;
  late final List<Widget> reports;
  bool get showingReport => index != 0;
  void showHub() => setState(() => index = 0);
  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<AdminReportsController>())
      Get.put(AdminReportsController());
    if (!Get.isRegistered<AdminTransactionsController>())
      Get.put(AdminTransactionsController());
    if (!Get.isRegistered<AdminClassRatingsReportController>())
      Get.put(AdminClassRatingsReportController());
    reports = [
      AdminClassesTab(onBack: showHub),
      AdminTransactionsPage(onBack: showHub),
      AdminClassRatingsPage(onBack: showHub)
    ];
  }

  @override
  Widget build(BuildContext context) => IndexedStack(
        index: index,
        sizing: StackFit.expand,
        children: [
          Scaffold(
              appBar: const AdminHeader(
                  title: 'Reportes', subtitle: 'Consultas e históricos'),
              body: ListView(padding: const EdgeInsets.all(20), children: [
                AdminGroup(children: [
                  AdminActionTile(
                      icon: Icons.bar_chart_outlined,
                      title: 'Asistencia histórica',
                      subtitle: 'Consultar y exportar registros',
                      onTap: () => setState(() => index = 1))
                ]),
                const SizedBox(height: 12),
                AdminGroup(children: [
                  AdminActionTile(
                      icon: Icons.receipt_long_outlined,
                      title: 'Transacciones',
                      subtitle: 'Consultar movimientos',
                      onTap: () => setState(() => index = 2))
                ]),
                const SizedBox(height: 12),
                AdminGroup(children: [
                  AdminActionTile(
                      icon: Icons.star_outline,
                      title: 'Valoraciones',
                      subtitle: 'Revisar opiniones de las clases',
                      onTap: () => setState(() => index = 3))
                ]),
              ])),
          ...reports,
        ],
      );
}
