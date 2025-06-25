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
            backgroundColor: whiteLight,
            foregroundColor: darkGrey,
            title: _texttitleAppbar(),
          ),
          body: Column(
            children: [
              Text(
                'Adquiere planes y pedalea con tu coach favorito!',
                style: GoogleFonts.abel(
                  fontSize: 18,
                  color: darkGrey,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(12),
                  itemCount: con.plans.length,
                  itemBuilder: (context, index) {
                    final plan = con.plans[index];
                    return _cardPlan(context, plan);
                  },
                ),
              ),
            ],
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

  Widget _cardPlan(BuildContext context, Plan plan) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: plan.image != null
                  ? Image.network(
                      plan.image!,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 70,
                      height: 70,
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
                    plan.name?.toUpperCase() ?? 'Sin nombre',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: almostBlack,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '# Rides: ${plan.rides ?? '***'}',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${plan.price?.toStringAsFixed(2) ?? '0.00'}',
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    con.goToPolanBuy();
                  },
                  //icon: const Icon(Icons.shopping_cart_checkout, size: 18),
                  label: const Text('Comprar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: almostBlack,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    textStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
