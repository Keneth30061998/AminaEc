import 'package:amina_ec/src/pages/user/Plan/List/user_plan_list_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../models/plan.dart';
import '../../../../widgets/no_data_widget.dart';

class UserPlanListPage extends StatelessWidget {
  final UserPlanListController con = Get.put(UserPlanListController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (con.plans.isEmpty) {
        return NoDataWidget(text: 'No hay planes disponibles');
      } else {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: whiteLight,
            foregroundColor: darkGrey,
            title: _textTitleAppbar(),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    'Adquiere tu plan y pedalea con tu coach favorito',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: whiteGrey,
                    ),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isLandscape = MediaQuery.of(context).orientation ==
                          Orientation.landscape;
                      final screenWidth = constraints.maxWidth;

                      final crossAxisExtent = isLandscape ? 320.0 : 270.0;
                      final childAspectRatio = isLandscape ? 0.95 : 0.65;
                      final imageHeight = isLandscape
                          ? MediaQuery.of(context).size.height * 0.3
                          : MediaQuery.of(context).size.height * 0.14;

                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: crossAxisExtent,
                          mainAxisSpacing: 15,
                          crossAxisSpacing: 15,
                          childAspectRatio: childAspectRatio,
                        ),
                        itemCount: con.plans.length,
                        itemBuilder: (context, index) {
                          final plan = con.plans[index];
                          return _planTile(plan, imageHeight);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }
    });
  }

  Widget _textTitleAppbar() {
    return Text(
      'Planes de pago',
      style: GoogleFonts.montserrat(
        fontSize: 22,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _planTile(Plan plan, double imageHeight) {
    return Transform.scale(
      scale: 0.9, // Reducción visual del 10%
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: color_background_box,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                    12), // 🔹 Aplica a la imagen directamente
                child: plan.image != null
                    ? Image.network(
                        plan.image!,
                        height: imageHeight,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: imageHeight,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 40),
                      ),
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(right: 15, left: 15, top: 10),
                child: SizedBox(
                  height: 130,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.name?.toUpperCase() ?? 'Sin nombre',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: almostBlack,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${plan.rides ?? '0'} Rides',
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '\$${plan.price?.toStringAsFixed(2) ?? '0.00'}',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => con.goToPlanBuyResume(plan),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: almostBlack,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                            child: Text(
                              'Comprar',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
