import 'package:amina_ec/src/pages/Admin/Plan/List/admin_plan_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../models/plan.dart';
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
          itemCount: con.plans.length,
          itemBuilder: (context, index) {
            final plan = con.plans[index];
            return _cardPlan(plan);
          },
        );
      }
    });
  }

  Widget _cardPlan(Plan plan) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 5,
      child: ListTile(
        leading: plan.image != null
            ? Image.network(plan.image!,
                width: 60, height: 60, fit: BoxFit.cover)
            : const Icon(Icons.image_not_supported),
        title: Text(plan.name ?? 'Sin nombre'),
        subtitle: Text('\$${plan.price?.toStringAsFixed(2) ?? '0.00'}'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              // Ir a la página de edición
              // Navigator.pushNamed(context, '/admin/plan/edit', arguments: plan);
              print('Editando plan');
            } else if (value == 'delete') {
              con.deletePlan(plan.id!);
              print('Eliminando plan: ${plan.id}');
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Text('Editar'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Eliminar'),
            ),
          ],
        ),
      ),
    );
  }
}
