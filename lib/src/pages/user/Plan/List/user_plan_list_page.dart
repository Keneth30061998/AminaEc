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
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: whiteLight,
          foregroundColor: darkGrey,
          elevation: 0,
          title: _textTitleAppbar(),
        ),

        // ✅ refrescable incluso vacío
        body: RefreshIndicator(
          color: almostBlack,
          // ✅ FIX: tu método probablemente retorna void -> lo envolvemos en Future.sync
          onRefresh: () => Future.sync(() => con.getPlans()),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ✅ Header “Activa tu energía”
              SliverToBoxAdapter(child: _sportHeader()),

              if (con.plans.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const NoDataWidget(text: 'No hay planes disponibles'),
                          const SizedBox(height: 10),
                          Text(
                            'Desliza hacia abajo para refrescar.\nSi se publican planes ahora, aparecerán aquí.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Padding(
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
                ),

              if (con.plans.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverLayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.crossAxisExtent;

                      int crossAxisCount = 2;
                      if (width >= 1000) {
                        crossAxisCount = 4;
                      } else if (width >= 720) {
                        crossAxisCount = 3;
                      }

                      // ✅ FIX overflow: un poco más de altura
                      final childAspectRatio = crossAxisCount >= 4 ? 0.78 : 0.66;

                      return SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 12,
                          childAspectRatio: childAspectRatio,
                        ),
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            final plan = con.plans[index];
                            return _planTile(plan);
                          },
                          childCount: con.plans.length,
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      );
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

  // ✅ Header “Activa tu energía”
  Widget _sportHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              decoration: BoxDecoration(
                color: colorBackgroundBox,
                border: Border.all(color: Colors.black.withOpacity(.06)),
              ),
              child: Row(
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black.withOpacity(.06)),
                    ),
                    child: const Icon(
                      Icons.local_fire_department_rounded,
                      color: almostBlack,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Activa tu energía',
                          style: GoogleFonts.poppins(
                            fontSize: 13.8,
                            fontWeight: FontWeight.w800,
                            color: almostBlack,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Compra un plan y rueda con tu coach favorito.',
                          style: GoogleFonts.poppins(
                            fontSize: 12.4,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _headerPill('Rides', icon: Icons.bolt_rounded),
                ],
              ),
            ),
            Positioned(
              right: -40,
              top: -50,
              child: Transform.rotate(
                angle: 0.5,
                child: Container(
                  width: 140,
                  height: 180,
                  decoration: BoxDecoration(
                    color: almostBlack.withOpacity(.07),
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerPill(String text, {required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withOpacity(.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black54),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: almostBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _planTile(Plan plan) {
    final name = (plan.name ?? 'SIN NOMBRE').toUpperCase();

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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: plan.image != null
                        ? Image.network(
                      plan.image!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.image_not_supported, size: 34),
                        ),
                      ),
                    )
                        : Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 34),
                      ),
                    ),
                  ),
                ),
                if (plan.is_new_user_only == 1)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "Nuevos Riders",
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 2, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _planNameMarquee(name),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${plan.rides ?? '0'} Rides',
                          style: GoogleFonts.montserrat(
                            fontSize: 12.2,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '\$${plan.price?.toStringAsFixed(2) ?? '0.00'}',
                          style: GoogleFonts.roboto(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.green[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Duración',
                          style: GoogleFonts.montserrat(
                            fontSize: 11.8,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${plan.duration_days ?? 0} días',
                          style: GoogleFonts.roboto(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            color: indigoAmina,
                          ),
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
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Comprar',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
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

  Widget _planNameMarquee(String name) {
    const marqueeThreshold = 18;

    final textStyle = GoogleFonts.poppins(
      fontSize: 13.2,
      fontWeight: FontWeight.w800,
      color: almostBlack,
    );

    if (name.length > marqueeThreshold) {
      return SizedBox(
        height: 18,
        child: ClipRect(
          child: Marquee(
            text: name,
            style: textStyle,
            blankSpace: 40,
            velocity: 10,
            pauseAfterRound: const Duration(milliseconds: 450),
            startPadding: 6,
          ),
        ),
      );
    }

    return SizedBox(
      height: 18,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textStyle,
        ),
      ),
    );
  }
}
