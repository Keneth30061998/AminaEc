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
          'Bloquear Bicicletas',
          style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w800),
        ),
      ),

      // ✅ AQUÍ: body SIN Obx envolviendo todo
        body: SafeArea(
          child: RefreshIndicator(
            color: indigoAmina,
            onRefresh: () async {
              await con.loadState(); // recarga estado desde el servidor
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  _infoHeader(),
                  const SizedBox(height: 30),
                  _legend(),
                  const SizedBox(height: 30),
                  _buildBigSeat(),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _buildSeatRow(2, 4)),
                      const SizedBox(width: 24),
                      Expanded(child: _buildSeatRow(6, 4)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildSeatRow(10, 10),
                  const SizedBox(height: 16),
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
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: con.applyUnblock,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            backgroundColor: indigoAmina,
                          ),
                          child: const Text(
                            "Desbloquear selección",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: whiteLight),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        )

    );
  }

  // ========= HEADER COMO EL USUARIO =========
  Widget _infoHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _infoBox(Icons.date_range, "Hora", _formatHora(con.classTime)),
        const SizedBox(width: 15),
        _infoBox(Icons.person, "Instructor", con.coachName),
      ],
    );
  }

  Widget _infoBox(IconData icon, String title, String value) {
    return Container(
      height: 70,
      width: 120,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 3, offset: const Offset(2, 2)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          Text(title,
              style: GoogleFonts.roboto(
                  color: almostBlack, fontSize: 13, fontWeight: FontWeight.w700)),
          Text(
            value,
            style: GoogleFonts.kodchasan(color: darkGrey, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatHora(String rawTime) {
    final parts = rawTime.split(":");
    return "${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}";
  }

  // ========= LEYENDA =========
  Widget _legend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _indicator(Colors.grey[300]!, "Disponible"),
        _indicator(indigoAmina, "Ocupada"),
        _indicator(Colors.grey.shade600, "Bloqueada"),
        _indicator(limeGreen, "Selección"),
      ],
    );
  }

  Widget _indicator(Color color, String text) {
    return Row(
      children: [
        Container(width: 15, height: 15, color: color),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.robotoCondensed(color: almostBlack)),
        const SizedBox(width: 20),
      ],
    );
  }

  Widget _buildBigSeat() {
    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          border: Border.all(color: Colors.grey, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text("Coach",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        ),
      ),
    );
  }

  // ========= MAPA DE BICICLETAS =========
  Widget _buildSeatRow(int start, int count) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double availableWidth = constraints.maxWidth;
        double seatSize = (availableWidth - (count * 8)) / count;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(count, (i) {
            int seat = start + i;

            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: Obx(() {
                final isOccupied = con.occupiedEquipos.contains(seat);
                final isBlocked = con.blockedEquipos.contains(seat);
                final isSelected = con.selectedEquipos.contains(seat);

                Color color = Colors.grey[300]!;
                if (isOccupied) color = indigoAmina;
                else if (isBlocked) color = Colors.grey.shade600;
                if (isSelected) color = limeGreen;

                return GestureDetector(
                  onTap: () => con.toggleSeat(seat),
                  child: Container(
                    width: seatSize,
                    height: seatSize,
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(color: Colors.black26, width: 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        "$seat",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: seatSize * 0.3,
                          color: isSelected ? darkGrey : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
        );
      },
    );
  }
}
