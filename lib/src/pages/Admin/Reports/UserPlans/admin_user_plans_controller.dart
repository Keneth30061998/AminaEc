import 'package:amina_ec/src/models/plan.dart';
import 'package:amina_ec/src/models/user.dart';
import 'package:amina_ec/src/providers/admin_user_plans_provider.dart';
import 'package:amina_ec/src/providers/plans_provider.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AdminUserPlansController extends GetxController {
  final AdminUserPlansProvider _provider = AdminUserPlansProvider();
  final PlanProvider _planProvider = PlanProvider();

  final User user = Get.arguments as User;
  final storage = GetStorage();

  final token = ''.obs;
  var loading = false.obs;
  var plans = <Map<String, dynamic>>[].obs;
  var availablePlans = <Plan>[].obs;

  var selectedPlan = Rxn<Plan>();
  var startDate = Rxn<DateTime>();
  var endDate = Rxn<DateTime>();
  var rides = 0.obs;

  final dateFormatDisplay = DateFormat('dd/MM/yyyy');
  final dateFormatSend = DateFormat('yyyy-MM-dd');

  @override
  void onInit() {
    super.onInit();
    token.value = user.session_token ?? storage.read('user')?['session_token'] ?? '';
    loadAll();
  }

  Future<void> loadAll() async {
    loading.value = true;
    await loadUserPlans();
    await loadAvailablePlans();
    loading.value = false;
  }

  Future<void> loadUserPlans() async {
    final t = token.value;
    if (t.isEmpty) return;
    plans.value = await _provider.getUserPlans(user.id!, t);
  }

  Future<void> loadAvailablePlans() async {
    final t = token.value;
    availablePlans.value = await _provider.getAllPlans(t);
  }

  String formatSend(DateTime d) => dateFormatSend.format(d);

  void openAssignPlanSheet() {
    selectedPlan.value = null;
    startDate.value = DateTime.now();
    endDate.value = DateTime.now();
    rides.value = 0;
    _openBottomSheet(isEdit: false);
  }

  void openEditPlanSheet(Map<String, dynamic> userPlan) {
    selectedPlan.value = availablePlans.firstWhereOrNull((p) => p.name == (userPlan['plan_name'] ?? ''));

    DateTime? parseDate(String? input) {
      if (input == null) return null;
      try {
        if (input.contains('T')) input = input.split('T').first;
        return DateTime.parse(input);
      } catch (_) {
        return null;
      }
    }

    startDate.value = parseDate(userPlan['start_date']) ?? DateTime.now();
    endDate.value = parseDate(userPlan['end_date']) ?? startDate.value!;
    rides.value = int.tryParse('${userPlan['remaining_rides']}') ?? 0;

    _openBottomSheet(isEdit: true, editingPlan: userPlan);
  }

  void _openBottomSheet({required bool isEdit, Map<String, dynamic>? editingPlan}) {
    Get.bottomSheet(
      StatefulBuilder(builder: (context, setState) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            height: Get.height * 0.75,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isEdit ? 'Editar Plan' : 'Asignar plan manual',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16, color: almostBlack),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        DropdownButtonFormField<Plan>(
                          initialValue: selectedPlan.value,
                          items: availablePlans.map((p) {
                            return DropdownMenuItem<Plan>(
                              value: p,
                              child: Text(
                                p.name ?? 'Seleccione un plan',
                                style: GoogleFonts.poppins(fontSize: 14, color: almostBlack),
                              ),
                            );
                          }).toList(),
                          onChanged: (p) {
                            setState(() {
                              selectedPlan.value = p;
                              if (!isEdit && p != null) {
                                rides.value = p.rides ?? 0;
                                endDate.value = (startDate.value ?? DateTime.now())
                                    .add(Duration(days: p.duration_days ?? 0));
                              }
                            });
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: colorBackgroundBox,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: _buildDateField(
                                label: "Inicio",
                                date: startDate.value,
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: startDate.value ?? DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      startDate.value = picked;
                                      if (!isEdit && selectedPlan.value != null) {
                                        endDate.value = picked.add(
                                          Duration(days: selectedPlan.value?.duration_days ?? 0),
                                        );
                                      }
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildDateField(
                                label: "Fin",
                                date: endDate.value,
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: endDate.value ?? DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) setState(() => endDate.value = picked);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () => setState(() => rides.value = (rides.value > 0) ? rides.value - 1 : 0),
                              icon: Icon(Icons.remove_circle_outline, color: almostBlack),
                            ),
                            Text('${rides.value} rides', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: almostBlack)),
                            IconButton(
                              onPressed: () => setState(() => rides.value++),
                              icon: Icon(Icons.add_circle_outline, color: almostBlack),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: Get.back,
                        child: Text('Cancelar', style: GoogleFonts.poppins(color: almostBlack)),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: almostBlack),
                        onPressed: () async {
                          if (!isEdit && selectedPlan.value == null) {
                            Get.snackbar('Error', 'Seleccione un plan');
                            return;
                          }
                          if (startDate.value == null || endDate.value == null) {
                            Get.snackbar('Error', 'Seleccione fechas válidas');
                            return;
                          }
                          if (endDate.value!.isBefore(startDate.value!)) {
                            Get.snackbar('Error', 'Fecha fin debe ser posterior a inicio');
                            return;
                          }

                          final t = token.value;
                          if (isEdit && editingPlan != null) {
                            final res = await _provider.updateUserPlan(
                              userPlanId: editingPlan['id'].toString(),
                              token: t,
                              startDate: formatSend(startDate.value!),
                              endDate: formatSend(endDate.value!),
                              remainingRides: rides.value,
                            );
                            Get.back();
                            Get.snackbar('Editar plan', res['message'] ?? 'Actualizado');
                          } else {
                            final res = await _provider.assignPlan(
                              userId: user.id!,
                              token: t,
                              planId: selectedPlan.value!.id!,
                              startDate: formatSend(startDate.value!),
                              endDate: formatSend(endDate.value!),
                              remainingRides: rides.value,
                            );
                            Get.back();
                            Get.snackbar('Asignar plan', res['message'] ?? 'Plan asignado');
                          }
                          await loadUserPlans();
                        },
                        child: Text('Guardar', style: GoogleFonts.poppins(color: whiteLight)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
      isScrollControlled: true,
    );
  }

  Widget _buildDateField({required String label, required DateTime? date, required Function() onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: colorBackgroundBox,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: almostBlack),
            const SizedBox(width: 8),
            Text(
              date != null ? dateFormatDisplay.format(date) : label,
              style: GoogleFonts.poppins(fontSize: 13, color: almostBlack),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> deleteUserPlan(String userPlanId) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Confirmar eliminación', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: almostBlack)),
        content: Text('¿Eliminar este plan? Esta acción no se puede deshacer.', style: GoogleFonts.poppins(color: almostBlack)),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: Text('Cancelar', style: TextStyle(color: almostBlack))),
          ElevatedButton(onPressed: () => Get.back(result: true), child: Text('Eliminar', style: TextStyle(color: whiteLight))),
        ],
      ),
    );

    if (confirmed != true) return;
    final res = await _provider.deleteUserPlan(userPlanId: userPlanId, token: token.value);
    Get.snackbar('Eliminar plan', res['message'] ?? 'Eliminado');
    await loadUserPlans();
  }
}
