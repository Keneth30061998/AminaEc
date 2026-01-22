import 'package:amina_ec/src/pages/Admin/Reports/Class/Block/admin_edit_class_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminCoachBlockPage extends StatelessWidget {
  final con = Get.put(AdminCoachBlockController());

  AdminCoachBlockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteLight,
        foregroundColor: almostBlack,
        title: Text("Bloquear Bicicletas",
            style: GoogleFonts.montserrat(
                fontSize: 20, fontWeight: FontWeight.w800)),
      ),
      body: Obx(() {
        return SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 25),
              Text("Clase: ${con.classTime} con ${con.coachName}",
                  style: GoogleFonts.roboto(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 25),
              _legend(),
              const SizedBox(height: 20),
              _coachSeatLayout(),
              const Spacer(),
              _buttons(),
              const SizedBox(height: 20)
            ],
          ),
        );
      }),
    );
  }

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
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 4),
        Text(text),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _coachSeatLayout() {
    return Column(
      children: [
        _bigCoachBox(),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: _seatRow(2, 4)),
            const SizedBox(width: 24),
            Expanded(child: _seatRow(6, 4)),
          ],
        ),
        const SizedBox(height: 10),
        _seatRow(10, 10),
      ],
    );
  }

  Widget _bigCoachBox() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
          color: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
      child: const Center(
          child: Text("Coach", style: TextStyle(fontWeight: FontWeight.bold))),
    );
  }

  Widget _seatRow(int start, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        int seat = start + i;
        return Obx(() {
          final isOccupied = con.occupiedEquipos.contains(seat);
          final isBlocked = con.blockedEquipos.contains(seat);
          final isSelected = con.selectedEquipos.contains(seat);

          Color color = Colors.grey[300]!;
          if (isOccupied)
            color = indigoAmina;
          else if (isBlocked) color = Colors.grey.shade600;
          if (isSelected) color = limeGreen;

          return GestureDetector(
            onTap: () => con.toggleSeat(seat),
            child: Container(
              margin: const EdgeInsets.all(4),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(4)),
              child: Center(child: Text("$seat")),
            ),
          );
        });
      }),
    );
  }

  Widget _buttons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: con.applyBlock,
            style: ElevatedButton.styleFrom(
                backgroundColor: almostBlack,
                minimumSize: const Size(double.infinity, 48)),
            child: const Text("Bloquear selección"),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: con.applyUnblock,
            style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48)),
            child: const Text("Desbloquear selección"),
          ),
        ],
      ),
    );
  }
}
