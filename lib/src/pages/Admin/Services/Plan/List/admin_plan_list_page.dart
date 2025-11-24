
import 'package:amina_ec/src/pages/Admin/Services/Plan/List/admin_plan_list_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../models/plan.dart';
import '../../../../../utils/iconos.dart';
import '../../../../../widgets/no_data_widget.dart';

class AdminPlanListPage extends StatelessWidget {
  final AdminPlanListController con = Get.put(AdminPlanListController());

  AdminPlanListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (con.plans.isEmpty) {
        return Center(child: NoDataWidget(text: 'No hay planes disponibles'));
      } else {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Dismissible(
          key: Key(plan.id.toString()),
          background: _slideActionLeft(),
          secondaryBackground: _slideActionRight(),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              Get.toNamed('/admin/plans/update', arguments: {'plan': plan});
              return false;
            } else if (direction == DismissDirection.endToStart) {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Confirmar eliminación'),
                  content: const Text(
                    '¿Deseas eliminar este plan?',
                    style: TextStyle(color: almostBlack),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar')),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Eliminar')),
                  ],
                ),
              );
              if (confirm == true) {
                con.deletePlan(plan.id!);
                return true;
              }
              return false;
            }
            return false;
          },
          child: Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            shadowColor: Color.fromARGB((0.2 * 255).toInt(), 128, 128, 128),
            child: Container(
              decoration: BoxDecoration(
                color: colorBackgroundBox,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: plan.image != null
                        ? Image.network(
                            plan.image!,
                            width: 75,
                            height: 75,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 75,
                            height: 75,
                            color: Colors.grey[300],
                            child:
                                const Icon(Icons.image_not_supported, size: 40),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.name ?? 'Sin nombre',
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
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
                        const SizedBox(height: 4),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _slideActionLeft() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      color: indigoAmina,
      child: const Row(
        children: [
          Icon(iconEdit, color: Colors.white),
          SizedBox(width: 8),
          Text('Editar',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _slideActionRight() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      color: darkGrey,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(iconEraser, color: Colors.white),
          SizedBox(width: 8),
          Text('Eliminar',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
