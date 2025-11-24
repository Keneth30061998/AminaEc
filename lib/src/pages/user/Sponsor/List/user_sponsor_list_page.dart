import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../../models/sponsor.dart';
import '../../../../widgets/no_data_widget.dart';
import '../../../../utils/color.dart';
import 'user_sponsor_list_controller.dart';

class UserSponsorListPage extends StatelessWidget {
  final controller = Get.put(UserSponsorListController());

  UserSponsorListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text(
          "Beneficios",
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w800,
            color: almostBlack,
          ),
        ),
        elevation: 0,
        backgroundColor: whiteLight,
        foregroundColor: almostBlack,
      ),
      body: Obx(() {
        if (controller.sponsors.isEmpty) {
          return const NoDataWidget(text: "No hay beneficios disponibles");
        }

        final sorted = controller.sponsors.toList()
          ..sort((a, b) => (a.priority ?? 3).compareTo(b.priority ?? 3));

        return Padding(
          padding: const EdgeInsets.all(14),
          child: MasonryGridView.count(
            crossAxisCount: _getColumnCount(context),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final sponsor = sorted[index];
              return _animatedItem(
                index,
                _tapAnimation(
                  child: _buildMosaicCard(sponsor),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  // Número de columnas responsive
  int _getColumnCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    if (width > 900) return 4;
    if (width > 600) return 3;
    return 2;
  }

  /// Animación elegante de aparición
  Widget _animatedItem(int index, Widget child) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.7, end: 1),
      duration: Duration(milliseconds: 450 + (index * 60)),
      curve: Curves.easeOutBack,
      builder: (_, value, __) {
        final opacity = value.clamp(0.0, 1.0);
        final scale = value.clamp(0.7, 1.0);

        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Transform.translate(
              offset: Offset(0, (1 - value) * 20),
              child: child,
            ),
          ),
        );
      },
    );
  }

  /// Animación al tocar (zoom + rebote + haptic)
  Widget _tapAnimation({required Widget child}) {
    return StatefulBuilder(
      builder: (context, setState) {
        late AnimationController controller;
        late Animation<double> scaleAnimation;

        controller = AnimationController(
          duration: const Duration(milliseconds: 140),
          vsync: Navigator.of(context),
          lowerBound: 0.5, // zoom fuerte y visible
          upperBound: 1.0,
        );

        scaleAnimation = CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutBack,
        );

        return GestureDetector(
          onTapDown: (_) {
            HapticFeedback.lightImpact();
            controller.reverse(); // hace zoom
          },
          onTapUp: (_) async {
            await Future.delayed(const Duration(milliseconds: 60));
            controller.forward(); // regresa
          },
          onTapCancel: () => controller.forward(),
          child: AnimatedBuilder(
            animation: scaleAnimation,
            builder: (context, childWidget) {
              return Transform.scale(
                scale: scaleAnimation.value,
                child: childWidget,
              );
            },
            child: child,
          ),
        );
      },
    );
  }



  /// Card estilo mosaico con alturas variables
  Widget _buildMosaicCard(Sponsor sponsor) {
    int p = sponsor.priority ?? 3;

    double height = p == 1
        ? 280 // Grande
        : p == 2
        ? 220 // Mediano
        : 160; // Pequeño

    return Material(
      color: Colors.transparent,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: whiteLight,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: sponsor.image != null
                  ? Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      sponsor.image!,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.55),
                            Colors.black.withOpacity(0.15),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
                  : Container(
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 40),
              ),
            ),

            /// Texto sobre la imagen
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sponsor.name ?? "",
                    style: GoogleFonts.montserrat(
                      fontSize: p == 1 ? 22 : p == 2 ? 18 : 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (p != 3)
                    Text(
                      sponsor.description ?? "",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.roboto(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
