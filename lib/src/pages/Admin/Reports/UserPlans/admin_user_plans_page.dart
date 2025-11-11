
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'admin_user_plans_controller.dart';

class AdminUserPlansPage extends StatelessWidget {
  final AdminUserPlansController con = Get.put(AdminUserPlansController());

  AdminUserPlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff9f9f9),
      appBar: AppBar(
        title: Text('Planes del usuario', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        centerTitle: true,
        backgroundColor: whiteLight,
        surfaceTintColor: whiteLight,
        forceMaterialTransparency: true,
      ),
      body: Obx(() {
        if (con.loading.value) return const Center(child: CircularProgressIndicator());

        return Column(
          children: [
            // HEADER USUARIO
            Padding(
              padding: const EdgeInsets.all(12),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: con.user.photo_url != null && con.user.photo_url!.isNotEmpty
                            ? NetworkImage(con.user.photo_url!)
                            : const AssetImage('assets/img/user_placeholder.png') as ImageProvider,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(con.user.name ?? '', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16, color: almostBlack)),
                            const SizedBox(height: 6),
                            Text('Rides: ${con.user.totalRides ?? 0}', style: GoogleFonts.poppins(fontSize: 13, color: almostBlack)),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: con.openAssignPlanSheet,
                        icon: const Icon(Icons.add, color: whiteLight,),
                        label: Text('Asignar plan', style: GoogleFonts.poppins(color: whiteLight)),
                        style: ElevatedButton.styleFrom(backgroundColor: indigoAmina),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // LISTA DE PLANES
            Expanded(
              child: con.plans.isEmpty
                  ? Center(child: Text('No hay planes asignados', style: GoogleFonts.poppins(color: Colors.grey)))
                  : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: con.plans.length,
                itemBuilder: (_, i) {
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
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
