import '../../Shared/admin_ui.dart';
import '../AppUsers/admin_reports_app_users_controller.dart';

import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'admin_user_plans_controller.dart';

class AdminUserPlansPage extends StatelessWidget {
  final AdminUserPlansController con = Get.put(AdminUserPlansController());

  AdminUserPlansPage({super.key});

  AdminReportsAppUsersController get clients => Get.find<AdminReportsAppUsersController>();

  Future<void> _showActions(BuildContext context) async {
    final action = await showModalBottomSheet<String>(context: context,
        showDragHandle: true, useSafeArea: true, isScrollControlled: true,
        builder: (sheet) => SingleChildScrollView(padding: const EdgeInsets.all(20),
            child: AdminGroup(label: '${con.user.name ?? 'Cliente'}', children: [
              AdminActionTile(icon: Icons.info_outline, title: 'Información de planes',
                  onTap: () => Navigator.pop(sheet, 'info')),
              AdminActionTile(icon: Icons.calendar_month_outlined, title: 'Extender días',
                  onTap: () => Navigator.pop(sheet, 'days')),
              AdminActionTile(icon: Icons.add, title: 'Agregar rides',
                  onTap: () => Navigator.pop(sheet, 'rides')),
              AdminActionTile(icon: Icons.edit_outlined, title: 'Corregir rides completados',
                  onTap: () => Navigator.pop(sheet, 'completed')),
              AdminActionTile(icon: Icons.history, title: 'Histórico',
                  onTap: () => Navigator.pop(sheet, 'history')),
            ])));
    if (action == null || !context.mounted) return;
    final user = clients.users.firstWhereOrNull((u) => u.id == con.user.id) ?? con.user;
    switch (action) {
      case 'info': await clients.showUserPlansInfo(user); break;
      case 'days': await clients.showExtendDialog(user); break;
      case 'rides': await clients.showRidesDialog(user); break;
      case 'completed': await clients.showEditCompletedRidesDialog(user); break;
      case 'history': await Get.toNamed('/admin/users/history', arguments: user); break;
    }
    if (context.mounted) await con.loadUserPlans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff9f9f9),
      appBar: AppBar(
        actions: [IconButton(tooltip: 'Actualizar planes', onPressed: con.loadAll, icon: const Icon(Icons.refresh))],
        title: Text('Ficha del cliente', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        centerTitle: true,
        backgroundColor: whiteLight,
        surfaceTintColor: whiteLight,
        forceMaterialTransparency: true,
      ),
      body: Obx(() {
        if (con.loading.value) return const Center(child: CircularProgressIndicator());
        if (con.loadError.value != null) return Center(child: Padding(padding: const EdgeInsets.all(20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [Text(con.loadError.value!),
              TextButton(onPressed: con.loadAll, child: const Text('Reintentar'))])));

        return CustomScrollView(
          key: PageStorageKey('client-${con.user.id}'),
          slivers: [
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(16), child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              CircleAvatar(radius: 28, backgroundColor: AdminUi.surface,
                  backgroundImage: (con.user.photo_url ?? '').isNotEmpty ? NetworkImage(con.user.photo_url!) : null,
                  child: (con.user.photo_url ?? '').isEmpty ? const Icon(Icons.person_outline) : null),
              const SizedBox(height: 10),
              Text('${con.user.name ?? ''} ${con.user.lastname ?? ''}'.trim(),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(con.user.email ?? '', style: const TextStyle(color: AdminUi.muted)),
              Text('Cédula: ${con.user.ci ?? '—'} · Teléfono: ${con.user.phone ?? '—'}',
                  style: const TextStyle(color: AdminUi.muted)),
              const SizedBox(height: 8),
              Obx(() {
                final current = clients.users.firstWhereOrNull((u) => u.id == con.user.id) ?? con.user;
                return Text('Rides: ${current.totalRides ?? 0} · Completados: ${current.ridesCompleted ?? 0}',
                    style: const TextStyle(fontWeight: FontWeight.w600));
              }),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                FilledButton.icon(onPressed: con.openAssignPlanSheet,
                    icon: const Icon(Icons.add), label: const Text('Asignar plan')),
                OutlinedButton.icon(onPressed: () => _showActions(context),
                    icon: const Icon(Icons.tune), label: const Text('Acciones del cliente')),
              ]),
              const SizedBox(height: 16),
              const Text('Planes asignados', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            ]))),

            // LISTA DE PLANES
            if (con.plans.isEmpty)
              const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(20), child: Text('No hay planes asignados')))
            else SliverPadding(padding: const EdgeInsets.all(12),
              sliver: SliverList(delegate: SliverChildBuilderDelegate((_, i) {
                final p = con.plans[i];
                // fechas en dd/mm/yyyy segun user input
                String formatDate(String? raw) {
                  if (raw == null) return 'No definida';
                  var s = raw;
                  if (s.contains('T')) s = s.split('T').first;
                  final parts = s.split('-');
                  if (parts.length == 3) return '${parts[2]}/${parts[1]}/${parts[0]}';
                  return raw;
                }

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(p['plan_name'] ?? 'Plan', style: GoogleFonts.poppins(fontWeight: FontWeight.w700,color: almostBlack,),),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(p['status'] ?? '', style: GoogleFonts.poppins(fontSize: 12,color: almostBlack,),),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Rides restantes: ${p['remaining_rides']}', style: GoogleFonts.poppins(color: almostBlack,),),
                        const SizedBox(height: 6),
                        Text('Inicio: ${formatDate(p['start_date'])}', style: GoogleFonts.poppins(color: almostBlack,),),
                        Text('Fin: ${formatDate(p['end_date'])}', style: GoogleFonts.poppins(color: almostBlack,),),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => con.openEditPlanSheet(p),
                              icon: const Icon(Icons.edit, size: 18, color: indigoAmina,),
                              label: Text('Editar', style: GoogleFonts.poppins(color: indigoAmina,),),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () => con.deleteUserPlan(p['id'].toString()),
                              icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                              label: Text('Eliminar', style: GoogleFonts.poppins(color: Colors.red)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }, childCount: con.plans.length)),
            ),
          ],
        );
      }),
    );
  }
}

