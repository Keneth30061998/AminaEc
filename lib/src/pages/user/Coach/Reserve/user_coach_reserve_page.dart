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
        return Stack(
          children: [
            SafeArea(
              child: AbsorbPointer(
                absorbing: con.isBusy,
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

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: _buildSeatRow(context, 2, 4),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _buildSeatRow(context, 6, 4),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      _buildSeatRow(context, 10, 10),
                      const SizedBox(height: 16),

                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Obx(() {
                          final bool busy = con.isBusy;
                          final bool reserving = con.isSubmittingReservation.value;

                          String text = "Reservar";
                          if (reserving) text = "Reservando...";

                          return ElevatedButton(
                            onPressed: busy ? null : () => con.reserveClass(),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 52),
                              backgroundColor: almostBlack,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: almostBlack.withOpacity(0.7),
                              disabledForegroundColor: Colors.white,
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: busy
                                  ? Row(
                                key: ValueKey(text),
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    text,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                                  : const Text(
                                "Reservar",
                                key: ValueKey("Reservar"),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Obx(() {
              if (!con.isBusy) return const SizedBox.shrink();

              return Container(
                color: Colors.black.withOpacity(0.12),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: almostBlack,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          con.loadingMessage.value.isEmpty
                              ? 'Procesando...'
                              : con.loadingMessage.value,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: almostBlack,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Espera un momento',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: darkGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      }),
    );
  }

  Widget _containerCount() {
    return Column(children: [
      Wrap(alignment: WrapAlignment.center, spacing: 10, runSpacing: 10,
          children: [_boxDate(), _boxCoach(), _boxRides()]),
      const SizedBox(height: 8),
      Obx(() => Text(con.accessMessage.value, textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: Colors.black54))),
    ]);
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
      title: con.courseClass.value ? 'Rides curso' : 'Rides regular',
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
          style: GoogleFonts.roboto(color: almostBlack),
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
            style: GoogleFonts.roboto(color: almostBlack)),
        SizedBox(
          width: 20,
        ),
        Container(
          width: 15,
          height: 15,
          color: indigoAmina,
        ),
        Text(' Ocupada',
            style: GoogleFonts.roboto(color: almostBlack)),
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
                      if (con.isBusy) return;

                      if (isOccupied) {
                        Get.snackbar(
                          'Máquina ocupada',
                          'Esta bicicleta ya está reservada',
                        );
                        return;
                      }

                      if (con.blockedEquipos.contains(seatNumber)) {
                        Get.snackbar(
                          'Máquina bloqueada',
                          'Esta bicicleta no está disponible para esta clase',
                        );
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

