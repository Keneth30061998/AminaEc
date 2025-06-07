import 'package:amina_ec/src/pages/user/Plan/List/user_plan_list_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../models/plan.dart';
import '../../../../widgets/no_data_widget.dart';

class UserPlanListPage extends StatelessWidget {
  UserPlanListController con = Get.put(UserPlanListController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (con.plans.isEmpty) {
        return Center(child: NoDataWidget(text: 'No hay planes disponibles'));
      } else {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: darkGrey,
            foregroundColor: limeGreen,
            title: _texttitleAppbar(),
          ),
          body: ListView.builder(
            itemCount: con.plans.length,
            itemBuilder: (context, index) {
              final plan = con.plans[index];
              return _cardPlan(plan);
            },
          ),
        );
      }
    });
  }

  Widget _texttitleAppbar() {
    return Text(
      'Planes de pago',
      style: GoogleFonts.montserrat(
        fontSize: 22,
        fontWeight: FontWeight.w800,
      ),
    );
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plan.description ?? ''),
            const SizedBox(height: 4),
            Text(
              '${plan.rides ?? 0} Rides',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        trailing: Text('\$${plan.price?.toStringAsFixed(2) ?? '0.00'}'),
      ),
    );
  }
}
