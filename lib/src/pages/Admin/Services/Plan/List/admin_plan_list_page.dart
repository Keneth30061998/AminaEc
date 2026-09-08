import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../models/plan.dart';
import '../../../Shared/admin_ui.dart';
import 'admin_plan_list_controller.dart';

class AdminPlanListPage extends StatelessWidget {
  final AdminPlanListController con =
      Get.isRegistered<AdminPlanListController>()
          ? Get.find<AdminPlanListController>()
          : Get.put(AdminPlanListController());

  AdminPlanListPage({super.key});

  static const _ink = Color(0xFF191B24);
  static const _indigo = Color(0xFF4F46E5);
  static const _indigoLight = Color(0xFFEEF0FF);
  static const _danger = Color(0xFFB42335);
  static const _soft = Color(0xFFF5F6F9);
  final NumberFormat _currency = NumberFormat.currency(
    locale: 'es_EC',
    symbol: '\$',
    decimalDigits: 2,
  );

  Future<void> _edit(Plan plan) async {
    await Get.toNamed('/admin/plans/update', arguments: {'plan': plan});
    await con.getPlans();
  }

  Future<void> _delete(BuildContext context, Plan plan) async {
    if (plan.id == null || con.deleting.contains(plan.id)) return;
    final yes = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon:
            const Icon(Icons.delete_outline_rounded, color: _danger, size: 30),
        title: const Text('¿Eliminar este plan?',
            style: TextStyle(fontWeight: FontWeight.w800, color: _ink)),
        content: Text(
            'Vas a eliminar “${plan.name ?? 'Plan'}”.\n¿Deseas continuar?',
            textAlign: TextAlign.center,
            style: const TextStyle(height: 1.5, color: AdminUi.muted)),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialog, false),
              child: const Text('Cancelar',
                  style: TextStyle(color: AdminUi.muted))),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialog, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _danger,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Eliminar plan'),
          ),
        ],
      ),
    );
    if (yes == true && !con.deleting.contains(plan.id)) {
      await con.deletePlan(plan.id!);
    }
  }

  @override
  Widget build(BuildContext context) => Obx(() {
        // Leer también deleting aquí permite actualizar las tarjetas construidas
        // de forma diferida cuando cambia el estado de una eliminación.
        final plans = con.plans.toList();
        final deleting = con.deleting.toSet();
        final loading = con.loading.value;
        final error = con.error.value;

        if (loading && plans.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: _indigo));
        }

        return LayoutBuilder(builder: (context, constraints) {
          final width =
              (constraints.maxWidth - 32).clamp(0.0, 880.0).toDouble();
          final side = (constraints.maxWidth - width) / 2;
          return RefreshIndicator(
            color: _indigo,
            onRefresh: con.getPlans,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              key: const PageStorageKey<String>('admin-plan-catalog'),
              padding: EdgeInsets.fromLTRB(
                  side, 10, side, 100 + MediaQuery.paddingOf(context).bottom),
              itemCount: plans.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (plans.isNotEmpty) ...[
                        _summary(plans.length,
                            plans.where((p) => p.isCourse).length),
                        const SizedBox(height: 12),
                      ],
                      if (loading) ...[
                        const LinearProgressIndicator(
                            color: _indigo,
                            backgroundColor: _indigoLight,
                            minHeight: 2),
                        const SizedBox(height: 14),
                      ],
                      if (error != null) ...[
                        _errorPanel(error),
                        const SizedBox(height: 16),
                      ],
                      if (plans.isEmpty && error == null) _emptyState(),
                    ],
                  );
                }
                final plan = plans[index - 1];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _card(context, plan, deleting.contains(plan.id)),
                );
              },
            ),
          );
        });
      });

  Widget _summary(int total, int courses) => Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _badge(
              '$total ${total == 1 ? 'plan disponible' : 'planes disponibles'}',
              Icons.view_agenda_outlined,
              _ink,
              _soft),
          if (courses > 0)
            _badge('$courses ${courses == 1 ? 'curso' : 'cursos'}',
                Icons.school_outlined, _indigo, _indigoLight),
        ],
      );

  Widget _card(BuildContext context, Plan plan, bool deleting) {
    final course = plan.isCourse;
    final name = (plan.name ?? '').trim();
    final description = (plan.description ?? '').trim();
    final rides = plan.rides ?? 0;
    final days = plan.duration_days ?? 0;

    return Material(
      color: AdminUi.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: course ? const Color(0xFFDCD9FC) : AdminUi.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(spacing: 6, runSpacing: 6, children: [
              _badge(
                  course ? 'Curso' : 'Plan regular',
                  course ? Icons.school_outlined : Icons.pedal_bike_outlined,
                  course ? _indigo : AdminUi.muted,
                  course ? _indigoLight : _soft),
              if (plan.is_new_user_only == 1)
                _badge('Nuevos riders', Icons.auto_awesome_outlined,
                    const Color(0xFF865214), const Color(0xFFFFF4DF)),
            ]),
            const SizedBox(height: 10),
            LayoutBuilder(builder: (context, constraints) {
              final details = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name.isEmpty ? 'Plan' : name,
                      style: const TextStyle(
                          fontSize: 16,
                          height: 1.3,
                          fontWeight: FontWeight.w800,
                          color: _ink)),
                  const SizedBox(height: 4),
                  Text(_currency.format(plan.price ?? 0),
                      style: const TextStyle(
                          fontSize: 21,
                          height: 1.2,
                          letterSpacing: -0.3,
                          fontWeight: FontWeight.w800,
                          color: _ink)),
                ],
              );
              // Conserva el tamaño de letra elegido por el usuario.
              final compact = constraints.maxWidth < 240 ||
                  MediaQuery.textScalerOf(context).scale(16) > 24;
              if (compact) {
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _image(plan),
                      const SizedBox(height: 8),
                      details
                    ]);
              }
              return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _image(plan),
                    const SizedBox(width: 10),
                    Expanded(child: details),
                  ]);
            }),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                  color: _soft, borderRadius: BorderRadius.circular(12)),
              child: Wrap(spacing: 12, runSpacing: 6, children: [
                _inline(Icons.pedal_bike_outlined,
                    '$rides ${rides == 1 ? 'ride' : 'rides'}'),
                _inline(Icons.calendar_today_outlined,
                    '$days ${days == 1 ? 'día' : 'días'} de vigencia'),
              ]),
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(description,
                  style: const TextStyle(
                      fontSize: 13, height: 1.4, color: AdminUi.muted)),
            ],
            if (course) ...[
              const SizedBox(height: 8),
              const Text('Exclusivo para clases de curso.',
                  style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: _indigo,
                      fontWeight: FontWeight.w500)),
            ],
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(height: 1, color: AdminUi.border)),
            LayoutBuilder(builder: (context, constraints) {
              final edit = OutlinedButton.icon(
                onPressed: deleting ? null : () => _edit(plan),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Editar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _ink,
                  side: const BorderSide(color: AdminUi.border),
                  minimumSize: const Size(0, 40),
                  tapTargetSize: MaterialTapTargetSize.padded,
                  visualDensity: VisualDensity.standard,
                  textStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
              final remove = TextButton.icon(
                onPressed: deleting || plan.id == null
                    ? null
                    : () => _delete(context, plan),
                icon: deleting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AdminUi.muted))
                    : const Icon(Icons.delete_outline_rounded, size: 18),
                label: Text(deleting ? 'Eliminando…' : 'Eliminar'),
                style: TextButton.styleFrom(
                  foregroundColor: _danger,
                  minimumSize: const Size(0, 40),
                  tapTargetSize: MaterialTapTargetSize.padded,
                  visualDensity: VisualDensity.standard,
                  textStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
              if (constraints.maxWidth < 290 ||
                  MediaQuery.textScalerOf(context).scale(14) > 21) {
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [edit, const SizedBox(height: 6), remove]);
              }
              return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [edit, const SizedBox(width: 8), remove]);
            }),
          ],
        ),
      ),
    );
  }

  Widget _image(Plan plan) {
    final url = (plan.image ?? '').trim();
    final fallback = Image.asset('assets/img/bicicleta.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(Icons.directions_bike_outlined,
            size: 28, color: AdminUi.muted));
    return Container(
      width: 64,
      height: 68,
      padding: const EdgeInsets.all(6),
      decoration:
          BoxDecoration(color: _soft, borderRadius: BorderRadius.circular(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: ExcludeSemantics(
            child: url.isEmpty
                ? fallback
                : Image.network(
                    url,
                    fit: BoxFit.contain,
                    frameBuilder: (_, child, frame, synchronous) =>
                        synchronous || frame != null ? child : fallback,
                    errorBuilder: (_, __, ___) => fallback,
                  )),
      ),
    );
  }

  Widget _inline(IconData icon, String text, {Color color = AdminUi.muted}) =>
      Text.rich(
        TextSpan(children: [
          WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: Icon(icon, size: 14, color: color))),
          TextSpan(text: text),
        ]),
        style: TextStyle(
            fontSize: 12,
            height: 1.35,
            fontWeight: FontWeight.w600,
            color: color),
      );

  Widget _badge(String text, IconData icon, Color color, Color background) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: background, borderRadius: BorderRadius.circular(8)),
        child: _inline(icon, text, color: color),
      );

  Widget _errorPanel(String message) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: const Color(0xFFFFF1F2),
            borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _inline(Icons.error_outline, 'No se pudo actualizar el catálogo',
              color: _danger),
          const SizedBox(height: 8),
          Text(message,
              style: const TextStyle(color: AdminUi.muted, height: 1.5)),
          const SizedBox(height: 8),
          TextButton.icon(
              onPressed: con.getPlans,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: TextButton.styleFrom(foregroundColor: _danger)),
        ]),
      );

  Widget _emptyState() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
        child: Column(children: [
          Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                  color: _indigoLight, shape: BoxShape.circle),
              child: const Icon(Icons.inventory_2_outlined,
                  size: 32, color: _indigo)),
          const SizedBox(height: 12),
          const Text('Aún no hay planes',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800, color: _ink)),
          const SizedBox(height: 8),
          const Text(
              'Los planes que crees aparecerán aquí.\nDesliza hacia abajo para actualizar.',
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.6, color: AdminUi.muted)),
        ]),
      );
}
