import 'package:amina_ec/src/pages/user/Coach/Reserve/user_coach_reserve_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Register/Terms_Conditions/terms_dialog.dart';

class UserCoachReservePage extends StatelessWidget {
  final UserCoachReserveController con = Get.put(UserCoachReserveController());

  UserCoachReservePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: whiteLight,
          foregroundColor: almostBlack,

          title: _textTitleAppBar(),
          actions: [
            IconButton.filled(
                style: IconButton.styleFrom(backgroundColor: whiteGrey),
                onPressed: () {
                  showTermsAndConditionsDialog(
                      context: context, onAccepted: () {});
                },
                icon: Icon(
                  Icons.contact_page_outlined,
                  color: whiteLight,
                ))
          ],
        ),
        body: Obx(() {
          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  SingleChildScrollView(child: _containerCount()),
                  const SizedBox(height: 30),
                  _simbolIndicator(),
                  const SizedBox(height: 30),
                  _buildBigSeat(),
                  const SizedBox(height: 20),

                  //PRIMERA FILA DIVIDIDA CON SEPARACIÓN ENTRE CASILLA 5 Y 6
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _buildSeatRow(context, 2, 4), // 2, 3, 4, 5
                      ),
                      const SizedBox(width: 24), // Espacio entre 5 y 6
                      Expanded(
                        child: _buildSeatRow(context, 6, 4), // 6, 7, 8, 9
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  _buildSeatRow(context, 10, 10), // Segunda fila: 10-19
                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        final con = Get.find<UserCoachReserveController>();
                        con.reserveClass();
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        backgroundColor: almostBlack,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        "Reservar",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }));
  }

  Widget _containerCount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _boxDate(),
        const SizedBox(width: 15),
        _boxCoach(),
        const SizedBox(width: 15),
        _boxRides(),
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

  Widget _boxRides() {
    return _boxTemplate(
      icon: Icons.directions_bike,
      title: 'Rides',
      subtitle: '${con.totalRides.value}',
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
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 3,
            offset: const Offset(3, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          Text(title,
              style: GoogleFonts.roboto(
                  color: almostBlack,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
          Text(subtitle,
              style: GoogleFonts.kodchasan(
                color: darkGrey,
                fontSize: 15,
              )),
        ],
      ),
    );
  }

  Widget _textTitleAppBar() {
    return Text(
      'Estudio',
      style: GoogleFonts.montserrat(
        fontSize: 22,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _simbolIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 15,
          height: 15,
          color: limeGreen,
        ),
        Text(
          ' Tu selección',
          style: GoogleFonts.robotoCondensed(color: almostBlack),
        ),
        SizedBox(
          width: 20,
        ),
        Container(
          width: 15,
          height: 15,
          color: Colors.black12,
        ),
        Text(' Disponible',
            style: GoogleFonts.robotoCondensed(color: almostBlack)),
        SizedBox(
          width: 20,
        ),
        Container(
          width: 15,
          height: 15,
          color: indigoAmina,
        ),
        Text(' Ocupada',
            style: GoogleFonts.robotoCondensed(color: almostBlack)),
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

  Widget _buildSeatRow(BuildContext context, int start, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double availableWidth = constraints.maxWidth;
          double seatWidth = (availableWidth - (count * 8)) / count;

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(count, (index) {
              int seatNumber = start + index;
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: Obx(() {
                  final con = Get.find<UserCoachReserveController>();
                  final bool isSelected =
                      con.selectedEquipos.contains(seatNumber);
                  final bool isOccupied =
                      con.occupiedEquipos.contains(seatNumber);

                  Color seatColor;
                  if (isSelected) {
                    seatColor = limeGreen;
                  } else if (isOccupied) {
                    seatColor = indigoAmina;
                  } else {
                    seatColor = Colors.grey[300]!;
                  }

                  return GestureDetector(
                    onTap: () {
                      if (isOccupied) {
                        Get.snackbar('Máquina ocupada',
                            'Esta bicicleta ya está reservada');
                        return;
                      }
                      con.toggleEquipo(seatNumber);
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

String formatHora(String rawTime) {
  final parts = rawTime.split(":");
  final hour = parts[0].padLeft(2, '0');
  final minute = parts[1].padLeft(2, '0');
  return "$hour:$minute";
}
