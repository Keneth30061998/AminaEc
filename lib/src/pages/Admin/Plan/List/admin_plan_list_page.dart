import 'package:amina_ec/src/pages/Admin/Plan/List/admin_plan_list_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../models/plan.dart';
import '../../../../utils/iconos.dart';
import '../../../../widgets/no_data_widget.dart';

class AdminPlanListPage extends StatelessWidget {
  final AdminPlanListController con = Get.put(AdminPlanListController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (con.plans.isEmpty) {
        return Center(child: NoDataWidget(text: 'No hay planes disponibles'));
      } else {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          itemCount: con.plans.length,
          itemBuilder: (context, index) {
            final plan = con.plans[index];
            return _cardPlan(context, plan);
          },
        );
      }
    });
  }

  Widget _cardPlan(BuildContext context, Plan plan) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          color: color_background_box,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: plan.image != null
                  ? Image.network(
                      plan.image!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 40),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.name ?? 'Sin nombre',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: almostBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plan.description ?? 'Sin descripción',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${plan.price?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              color: whiteLight,
              icon: Icon(icon_more),
              onSelected: (value) {
                if (value == 'edit') {
                  Get.toNamed('/admin/plans/update', arguments: {'plan': plan});
                } else if (value == 'delete') {
                  con.deletePlan(plan.id!);
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(icon_edit, color: indigoAmina),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(icon_eraser, color: darkGrey),
                      SizedBox(width: 8),
                      Text('Eliminar'),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
