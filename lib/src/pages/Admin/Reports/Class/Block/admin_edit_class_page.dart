import 'package:amina_ec/src/pages/Admin/Reports/Class/Block/admin_edit_class_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminCoachBlockPage extends StatelessWidget {
  final AdminCoachBlockController con = Get.put(AdminCoachBlockController());

  AdminCoachBlockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteLight,
        foregroundColor: almostBlack,
        title: Text(
          "Bloquear Bicicletas",
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Obx(() {
        // ✅ FIX GetX: este Obx ahora SÍ depende de variables Rx
        // (no cambia UI, solo evita el "improper use of Obx")
        final selectedCount = con.selectedEquipos.length;

        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Igual que el diseño original (cajitas)
                SingleChildScrollView(child: _containerCount(selectedCount)),

                const SizedBox(height: 30),

                // Indicadores estilo original (sin overflow)
                _simbolIndicator(),

                const SizedBox(height: 30),

                _buildBigSeat(),
                const SizedBox(height: 20),

                // Primera fila dividida (2-5) y (6-9)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: _buildSeatRow(context, 2, 4)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildSeatRow(context, 6, 4)),
                  ],
                ),

                const SizedBox(height: 10),

                // Segunda fila (10-19) responsiva, sin overflow
                _buildSeatRow(context, 10, 10),

                const SizedBox(height: 16),

                // Botones (misma funcionalidad)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: con.applyBlock,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          backgroundColor: almostBlack,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          "Bloquear selección",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: con.applyUnblock,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          foregroundColor: almostBlack,
                        ),
                        child: const Text(
                          "Desbloquear selección",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ====== TOP BOXES (estilo original) ======

  Widget _containerCount(int selectedCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _boxDate(),
        const SizedBox(width: 15),
        _boxCoach(),
      ],
    );
  }

  Widget _boxDate() {
    return _boxTemplate(
      icon: Icons.date_range,
      title: 'Hora',
      subtitle: formatHora(con.classTime),
      color: Colors.blueGrey.shade50,
    );
  }

  Widget _boxCoach() {
    return _boxTemplate(
      icon: Icons.person,
      title: 'Instructor',
      subtitle: con.coachName,
      color: Colors.blueGrey.shade50,
    );
  }

  Widget _boxTemplate({
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      height: 80,
      width: 110,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 3,
            offset: Offset(3, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          Text(
            title,
            style: GoogleFonts.roboto(
              color: almostBlack,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.kodchasan(
              color: darkGrey,
              fontSize: 15,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ====== INDICATORS (estilo original, pero con bloqueada) ======
  // Uso Wrap para que en pantallas pequeñas NO desborde.
  Widget _simbolIndicator() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 20,
      runSpacing: 10,
      children: [
        _legendItem(limeGreen, 'Tu selección'),
        _legendItem(Colors.black12, 'Disponible'),
        _legendItem(indigoAmina, 'Ocupada'),
        _legendItem(Colors.grey.shade600, 'Bloqueada'),
      ],
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 15, height: 15, color: color),
        Text(
          ' $text',
          style: GoogleFonts.robotoCondensed(color: almostBlack),
        ),
      ],
    );
  }

  // ====== BIG SEAT (igual al original) ======
  Widget _buildBigSeat() {
    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          border: Border.all(
            color: Colors.grey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            "Coach",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  // ====== SEAT ROW (misma responsividad del original con LayoutBuilder) ======
  Widget _buildSeatRow(BuildContext context, int start, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;
          final seatWidth = (availableWidth - (count * 8)) / count;

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(count, (index) {
              final seatNumber = start + index;

              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: Obx(() {
                  final bool isSelected =
                      con.selectedEquipos.contains(seatNumber);
                  final bool isOccupied =
                      con.occupiedEquipos.contains(seatNumber);
                  final bool isBlocked =
                      con.blockedEquipos.contains(seatNumber);

                  Color seatColor;
                  if (isSelected) {
                    seatColor = limeGreen;
                  } else if (isOccupied) {
                    seatColor = indigoAmina;
                  } else if (isBlocked) {
                    seatColor = Colors.grey.shade600;
                  } else {
                    seatColor = Colors.grey[300]!;
                  }

                  return GestureDetector(
                    onTap: () {
                      if (isOccupied) {
                        // Admin: igual que tu lógica, ocupadas no se tocan
                        Get.snackbar(
                          'Máquina ocupada',
                          'Esta bicicleta ya está reservada',
                        );
                        return;
                      }
                      con.toggleSeat(seatNumber);
                    },
                    child: Container(
                      width: seatWidth,
                      height: seatWidth,
                      decoration: BoxDecoration(
                        color: seatColor,
                        border: Border.all(
                          color: isSelected ? Colors.black12 : Colors.black26,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          "$seatNumber",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: seatWidth * 0.3,
                            color: isSelected ? darkGrey : Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }),
              );
            }),
          );
        },
      ),
    );
  }
}

// Utilidad igual a tu ejemplo, pero soporta "18:00:00" también.
String formatHora(String rawTime) {
  final parts = rawTime.split(":");
  if (parts.length < 2) return rawTime;

  final hour = parts[0].padLeft(2, '0');
  final minute = parts[1].padLeft(2, '0');
  return "$hour:$minute";
}
