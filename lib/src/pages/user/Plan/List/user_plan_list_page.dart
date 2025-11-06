import 'package:amina_ec/src/pages/user/Plan/List/user_plan_list_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee/marquee.dart';

import '../../../../models/plan.dart';
import '../../../../widgets/no_data_widget.dart';

class UserPlanListPage extends StatelessWidget {
  final UserPlanListController con = Get.put(UserPlanListController());

  UserPlanListPage({super.key});

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
            elevation: 0,
            title: _textTitleAppbar(),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Text(
                    'Adquiere tu plan y rueda con tu coach favorito',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(builder: (context, constraints) {
                    final width = constraints.maxWidth;

                    int crossAxisCount = 2;
                    if (width >= 1000) {
                      crossAxisCount = 4;
                    } else if (width >= 720) {
                      crossAxisCount = 3;
                    }

                    final childAspectRatio = crossAxisCount >= 4 ? 0.75 : 0.72;

                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 12,
                        childAspectRatio: childAspectRatio,
                      ),
                      itemCount: con.plans.length,
                      itemBuilder: (context, index) {
                        final plan = con.plans[index];
                        return _planTile(plan);
                      },
                    );
                  }),
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

  Widget _planTile(Plan plan) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorBackgroundBox, width: 1.6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Imagen con pequeño margen interior y mayor altura (≈15% más)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 10, // imagen más alta que 16/9
                child: plan.image != null
                    ? Image.network(plan.image!, fit: BoxFit.cover, width: double.infinity)
                    : Container(
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.image_not_supported, size: 36)),
                ),
              ),
            ),
          ),

          // Contenido controlado (sin alturas fijas que provoquen overflow)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Nombre: usa Marquee del paquete solo si es necesario
                  Builder(builder: (context) {
                    final name = plan.name?.toUpperCase() ?? 'SIN NOMBRE';
                    // Umbral de longitud para activar marquee (ajusta si quieres)
                    const marqueeThreshold = 18;
                    if (name.length > marqueeThreshold) {
                      // SizedBox con altura fija para evitar afectar el layout vertical
                      return SizedBox(
                        height: 20,
                        child: Marquee(
                          text: name,
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: almostBlack,
                          ),
                          blankSpace: 40,
                          velocity: 5,
                          pauseAfterRound: const Duration(milliseconds: 500),
                        ),
                      );
                    } else {
                      return Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: almostBlack,
                        ),
                      );
                    }
                  }),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${plan.rides ?? '0'} Rides',
                          style: GoogleFonts.montserrat(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '\$${plan.price?.toStringAsFixed(2) ?? '0.00'}',
                        style: GoogleFonts.roboto(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => con.goToPlanBuyResume(plan),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: almostBlack,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Comprar',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
