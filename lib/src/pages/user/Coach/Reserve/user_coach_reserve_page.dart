import 'package:amina_ec/src/pages/user/Coach/Reserve/user_coach_reserve_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class UserCoachReservePage extends StatelessWidget {
  final UserCoachReserveController con = Get.put(UserCoachReserveController());

  UserCoachReservePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteLight,
        foregroundColor: almostBlack,
        automaticallyImplyLeading: false,
        title: _textTitleAppBar(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildScreen(),
              const SizedBox(height: 20),
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
                    // Aquí podrías agregar la funcionalidad de guardar.
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
      ),
    );
  }

  Widget _containerCount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _boxDate(),
        const SizedBox(width: 14),
        _boxCoach(),
        const SizedBox(width: 14),
        _boxRides(),
      ],
    );
  }

  Widget _boxDate() {
    return _boxTemplate(
      icon: Icons.date_range,
      title: 'Hora',
      subtitle: '18:00 - 20:00',
      color: Colors.blueGrey.shade50,
    );
  }

  Widget _boxCoach() {
    return _boxTemplate(
      icon: Icons.person,
      title: 'Instructor',
      subtitle: 'Sebastian',
      color: Colors.blueGrey.shade50,
    );
  }

  Widget _boxRides() {
    return _boxTemplate(
      icon: Icons.directions_bike,
      title: 'Rides',
      subtitle: '1',
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
      width: 120,
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
              )),
          Text(subtitle,
              style: GoogleFonts.kodchasan(
                color: darkGrey,
                fontSize: 13,
              )),
        ],
      ),
    );
  }

  Widget _textTitleAppBar() {
    return Text(
      'Máquinas',
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

  Widget _buildScreen() {
    return ClipPath(
      clipper: ScreenClipper(),
      child: Container(
        color: indigoAmina,
        height: 70,
        alignment: Alignment.center,
        child: Text(
          "Sala de entrenamiento",
          style: GoogleFonts.roboto(
            color: whiteLight,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
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
                  bool isSelected = con.selectedEquipos.contains(seatNumber);
                  return GestureDetector(
                    onTap: () => con.toggleEquipo(seatNumber),
                    child: Container(
                      width: seatWidth,
                      height: seatWidth,
                      decoration: BoxDecoration(
                        color: isSelected ? limeGreen : Colors.grey[300],
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

class ScreenClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 20);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 20,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
