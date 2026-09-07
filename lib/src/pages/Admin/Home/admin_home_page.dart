import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'admin_home_controller.dart';
import '../Start/admin_start_page.dart';
import '../Reports/Class/Schedule/admin_edit_schedule_class_page.dart';
import '../Reports/AppUsers/admin_reports_app_users_page.dart';
import '../Reports/admin_reports_page.dart';
import '../Management/admin_management_page.dart';
import '../Shared/admin_ui.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});
  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  late final AdminHomeController con;
  late final List<Widget> pages;
  final reportsKey = GlobalKey<AdminReportsPageState>();
  @override
  void initState() {
    super.initState();
    con = Get.isRegistered<AdminHomeController>()
        ? Get.find<AdminHomeController>()
        : Get.put(AdminHomeController());
    // Instancias estables durante la vida de /admin/home.
    pages = [
      AdminStartPage(),
      AdminCoachSchedulePage(),
      AdminReportsAppUsersPage(),
      AdminReportsPage(key: reportsKey),
      const AdminManagementPage()
    ];
  }

  @override
  Widget build(BuildContext context) => AdminStyled(child: Obx(() {
        final selected = con.indexTab.value;
        return PopScope(
            canPop: selected == 0,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              if (selected == 3 &&
                  reportsKey.currentState?.showingReport == true) {
                reportsKey.currentState!.showHub();
              } else {
                con.changeTab(0);
              }
            },
            child: Scaffold(
              body: IndexedStack(
                  index: selected,
                  sizing: StackFit.expand,
                  children: [
                    for (int i = 0; i < pages.length; i++)
                      TickerMode(enabled: i == selected, child: pages[i])
                  ]),
              bottomNavigationBar: Material(
                color: AdminUi.surface,
                child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      child: Row(children: [
                        for (int i = 0; i < 5; i++)
                          Expanded(
                              child: Semantics(
                            selected: i == selected,
                            button: true,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () => con.changeTab(i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 2),
                                decoration: BoxDecoration(
                                    color: i == selected
                                        ? AdminUi.ink
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(18)),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                          const [
                                            Icons.check_circle_outline,
                                            Icons.calendar_month_outlined,
                                            Icons.people_outline,
                                            Icons.bar_chart,
                                            Icons.grid_view_rounded
                                          ][i],
                                          color: i == selected
                                              ? Colors.white
                                              : AdminUi.muted),
                                      const SizedBox(height: 6),
                                      Text(
                                          const [
                                            'Asistencia',
                                            'Clases',
                                            'Usuarios',
                                            'Reportes',
                                            'Gestión'
                                          ][i],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w600,
                                              color: i == selected
                                                  ? Colors.white
                                                  : AdminUi.muted)),
                                    ]),
                              ),
                            ),
                          )),
                      ]),
                    )),
              ),
            ));
      }));
}
