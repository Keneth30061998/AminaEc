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

  static const _icons = [
    Icons.check_circle_outline,
    Icons.calendar_month_outlined,
    Icons.people_outline,
    Icons.bar_chart,
    Icons.grid_view_rounded,
  ];
  static const _labels = [
    'Asistencia', 'Clases', 'Usuarios', 'Reportes', 'Gestión',
  ];

  @override
  void initState() {
    super.initState();
    con = Get.isRegistered<AdminHomeController>()
        ? Get.find<AdminHomeController>()
        : Get.put(AdminHomeController());
    // Las instancias y su posición en el árbol permanecen estables.
    pages = [
      AdminStartPage(),
      AdminCoachSchedulePage(),
      AdminReportsAppUsersPage(),
      AdminReportsPage(key: reportsKey),
      const AdminManagementPage(),
    ];
  }

  @override
  Widget build(BuildContext context) => AdminStyled(
    child: Obx(() {
      final selected = con.indexTab.value;
      final reduceMotion = MediaQuery.disableAnimationsOf(context);
      final menuDuration = reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 200);

      return PopScope(
        canPop: selected == 0,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (selected == 3 && reportsKey.currentState?.showingReport == true) {
            reportsKey.currentState!.showHub();
          } else {
            con.changeTab(0);
          }
        },
        child: Scaffold(
          body: _AdminTabTransition(index: selected, pages: pages),
          bottomNavigationBar: Material(
            color: AdminUi.surface,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    for (int i = 0; i < pages.length; i++)
                      Expanded(
                        child: Semantics(
                          selected: i == selected,
                          button: true,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              if (i != con.indexTab.value) con.changeTab(i);
                            },
                            child: AnimatedContainer(
                              duration: menuDuration,
                              curve: Curves.easeOutCubic,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
                              decoration: BoxDecoration(
                                color: i == selected ? AdminUi.ink : Colors.transparent,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TweenAnimationBuilder<Color?>(
                                    duration: menuDuration,
                                    curve: Curves.easeOutCubic,
                                    tween: ColorTween(
                                      end: i == selected ? Colors.white : AdminUi.muted,
                                    ),
                                    builder: (_, color, __) => Icon(_icons[i], color: color),
                                  ),
                                  const SizedBox(height: 6),
                                  AnimatedDefaultTextStyle(
                                    duration: menuDuration,
                                    curve: Curves.easeOutCubic,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: i == selected ? Colors.white : AdminUi.muted,
                                    ),
                                    child: Text(_labels[i], textAlign: TextAlign.center),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }),
  );
}

// Anima la entrada de la sección visible sin retirar ninguna página del árbol.
// No asignar una ValueKey(index) a este widget ni al IndexedStack.
class _AdminTabTransition extends StatefulWidget {
  final int index;
  final List<Widget> pages;

  const _AdminTabTransition({required this.index, required this.pages});

  @override
  State<_AdminTabTransition> createState() => _AdminTabTransitionState();
}

class _AdminTabTransitionState extends State<_AdminTabTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _curve;
  late final Animation<double> _opacity;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
      value: 1,
    );
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _opacity = Tween<double>(begin: 0.65, end: 1).animate(_curve);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion) _controller.value = 1;
  }

  @override
  void didUpdateWidget(covariant _AdminTabTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      if (_reduceMotion) {
        _controller.value = 1;
      } else {
        // Reinicia sobre la última sección elegida, sin encolar transiciones.
        _controller.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ClipRect(
    child: FadeTransition(
      opacity: _opacity,
      child: AnimatedBuilder(
        animation: _curve,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, 8 * (1 - _curve.value)),
          child: child,
        ),
        child: IndexedStack(
          index: widget.index,
          sizing: StackFit.expand,
          children: [
            for (int i = 0; i < widget.pages.length; i++)
              TickerMode(enabled: i == widget.index, child: widget.pages[i]),
          ],
        ),
      ),
    ),
  );
}
