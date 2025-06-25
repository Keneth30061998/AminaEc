import 'package:amina_ec/src/pages/user/Coach/Reserve/user_coach_reserve_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class UserCoachReservePage extends StatelessWidget {
  // Instanciamos el controlador con GetX.
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
              // Asiento grande (Equipo 1) – no se puede seleccionar.
              _buildBigSeat(),
              const SizedBox(height: 20),
              // Primera fila: equipos 2 a 9 (8 asientos).
              _buildSeatRow(context, 2, 8),
              const SizedBox(height: 10),
              // Segunda fila: equipos 10 a 19 (10 asientos).
              _buildSeatRow(context, 10, 10),
              const SizedBox(height: 16),
              // Botón de guardar.
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
        SizedBox(width: 40),
        _boxCoach(),
      ],
    );
  }

  Widget _boxDate() {
    return _boxTemplate(
      icon: Icons.date_range,
      title: 'Dia y hora',
      subtitle: 'Lunes 8:00 - 10:00',
      color: Colors.blueGrey.shade50,
    );
  }

  Widget _boxCoach() {
    return _boxTemplate(
      icon: Icons.person,
      title: 'Instructor',
      subtitle: 'Nombre Apellido',
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
      height: 100,
      width: 165,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(4, 3),
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
                fontSize: 16,
              )),
          Text(subtitle,
              style: GoogleFonts.kodchasan(
                color: almostBlack,
                fontSize: 12,
              )),
        ],
      ),
    );
  }

  //Widget titulo del appbar
  Widget _textTitleAppBar() {
    return Text(
      'Máquinas',
      style: GoogleFonts.montserrat(
        fontSize: 22,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  // Widget para simular la "pantalla" (screen) con borde curvado.
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

  // Widget para el asiento grande (Equipo 1) – no es seleccionable.
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

  // Widget para construir una fila de asientos con ancho dinámico, usando LayoutBuilder.
  Widget _buildSeatRow(BuildContext context, int start, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double availableWidth = constraints.maxWidth;
          // Cada asiento tendrá un padding total (8 px) por asiento.
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
                      height: seatWidth, // Mantiene el cuadrado.
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
                            // Ajusta el tamaño del texto en función del ancho.
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

// CustomClipper para recortar la parte inferior de la "pantalla" y crear un borde curvo.
class ScreenClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    // Se inicia en la esquina superior izquierda.
    path.lineTo(0, size.height - 20);
    // Se crea una curva desde el borde inferior izquierdo hacia el derecho.
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
