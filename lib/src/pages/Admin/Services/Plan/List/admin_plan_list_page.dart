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
  Future<void> _edit(Plan plan) async {
    await Get.toNamed('/admin/plans/update', arguments: {'plan': plan});
    await con.getPlans();
  }

  Future<void> _delete(BuildContext context, Plan plan) async {
    if (plan.id == null) return;
    final yes = await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
              title: const Text('Eliminar plan'),
              content: Text('¿Deseas eliminar "${plan.name ?? 'Plan'}"?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialog, false),
                    child: const Text('Cancelar')),
                TextButton(
                    onPressed: () => Navigator.pop(dialog, true),
                    child: const Text('Eliminar',
                        style: TextStyle(color: Colors.red)))
              ],
            ));
    if (yes == true) await con.deletePlan(plan.id!);
  }

  @override
  Widget build(BuildContext context) => Obx(() {
        if (con.loading.value && con.plans.isEmpty)
          return const Center(child: CircularProgressIndicator());
        return RefreshIndicator(
            onRefresh: con.getPlans,
            child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                key: const PageStorageKey('admin-plan-catalog'),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                children: [
                  if (con.error.value != null)
                    Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(children: [
                          Text(con.error.value!),
                          TextButton(
                              onPressed: con.getPlans,
                              child: const Text('Reintentar'))
                        ])),
                  if (con.plans.isEmpty && con.error.value == null)
                    const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('No hay planes disponibles.')),
                  for (final plan in con.plans)
                    Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: AdminUi.surface,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: AdminUi.border)),
                          child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(children: [
                                Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: (plan.image ?? '').isEmpty
                                              ? Image.asset(
                                                  'assets/img/bicicleta.png',
                                                  width: 72,
                                                  height: 82,
                                                  fit: BoxFit.contain)
                                              : Image.network(plan.image!,
                                                  width: 72,
                                                  height: 82,
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (_, __, ___) =>
                                                      const SizedBox(
                                                          width: 72,
                                                          height: 82,
                                                          child: Icon(
                                                              Icons
                                                                  .directions_bike_outlined,
                                                              size: 40)))),
                                      const SizedBox(width: 14),
                                      Expanded(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                            Text(plan.name ?? 'Plan',
                                                style: const TextStyle(
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                            const SizedBox(height: 5),
                                            Text(
                                                '${plan.rides ?? 0} rides · ${plan.duration_days ?? 0} días',
                                                style: const TextStyle(
                                                    color: AdminUi.muted)),
                                            if ((plan.description ?? '')
                                                .isNotEmpty)
                                              Text(plan.description!,
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: AdminUi.muted)),
                                            const SizedBox(height: 6),
                                            Text(
                                                NumberFormat.currency(
                                                        locale: 'es_EC',
                                                        symbol: '\$',
                                                        decimalDigits: 2)
                                                    .format(plan.price ?? 0),
                                                style: const TextStyle(
                                                    fontSize: 19,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                          ])),
                                    ]),
                                const SizedBox(height: 8),
                                Align(
                                    alignment: Alignment.centerRight,
                                    child: Wrap(spacing: 8, children: [
                                      TextButton.icon(
                                          onPressed: () => _edit(plan),
                                          icon: const Icon(Icons.edit_outlined,
                                              size: 19),
                                          label: const Text('Editar')),
                                      TextButton.icon(
                                          onPressed: con.deleting
                                                  .contains(plan.id)
                                              ? null
                                              : () => _delete(context, plan),
                                          icon: const Icon(Icons.delete_outline,
                                              size: 19),
                                          label: const Text('Eliminar')),
                                    ])),
                              ])),
                        )),
                ]));
      });
}
