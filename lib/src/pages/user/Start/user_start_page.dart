import 'package:amina_ec/src/pages/user/Start/user_start_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:amina_ec/src/utils/iconos.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../../models/coach.dart';
import '../../../models/scheduled_class.dart';

class UserStartPage extends StatelessWidget {
  final UserStartController con =
  Get.put(UserStartController(), permanent: true);

  UserStartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteLight,
      appBar: AppBar(
        title: _appBarTitle(),
        actions: [_actionInfo(context)],
      ),
      body: RefreshIndicator(
        color: indigoAmina,
        onRefresh: () async {
          con.getScheduledClasses();
          con.getAttendedClasses();
          con.getTotalRides();
          con.getAcquiredPlans();
          con.getCoaches();
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _textGreeting(),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() => _boxBikesComplete()),
                      Obx(() => _boxBikesPending()),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nuestros Coaches',
                        style: GoogleFonts.roboto(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: darkGrey,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 130,
                        child: Obx(() {
                          if (con.coaches.isEmpty) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: con.coaches.length,
                            itemBuilder: (context, index) =>
                                _cardCoach(con.coaches[index], context),
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Tus clases agendadas',
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: darkGrey,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Obx(() {
                    if (con.scheduledClasses.isEmpty) {
                      return Container(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.15),
                        child: Center(
                          child: Text(
                            'No tienes clases agendadas.',
                            style: GoogleFonts.roboto(
                                fontSize: 16, color: Colors.grey[700]),
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: con.scheduledClasses.length,
                      itemBuilder: (context, index) =>
                          _scheduledClassCard(con.scheduledClasses[index], context),
                    );
                  }),
                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBarTitle() => Text(
    'Amina',
    style: GoogleFonts.montserrat(
      fontSize: 26,
      fontWeight: FontWeight.w800,
      color: almostBlack,
    ),
  );

  Widget _textGreeting() => Text(
    'Hola, ${con.user.name}',
    style: GoogleFonts.roboto(
      fontSize: 20,
      fontWeight: FontWeight.w900,
      color: darkGrey,
    ),
  );

  Widget _boxBikesComplete() => _boxTemplate(
    title: 'Rides',
    count: '${con.attendedClasses.value}',
    subtitle: 'Completados',
    color: Colors.blueGrey.shade50,
  );

  Widget _boxBikesPending() => GestureDetector(
    onTap: () => con.showUserPlansInfo(),
    child: _boxTemplate(
      title: 'Rides',
      count: '${con.totalRides.value}',
      subtitle: 'Adquiridos',
      color: Colors.blueGrey.shade50,
    ),
  );


  Widget _boxTemplate({
    required String title,
    required String count,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      height: 90,
      width: 145,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(2, 3))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: GoogleFonts.roboto(color: almostBlack, fontSize: 16)),
          Text(count,
              style: GoogleFonts.montserrat(
                  color: darkGrey, fontSize: 26, fontWeight: FontWeight.w700)),
          Text(subtitle,
              style: GoogleFonts.kodchasan(color: almostBlack, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _cardCoach(Coach coach, BuildContext context) {
    return GestureDetector(
      onDoubleTap: () => showCoachBottomSheet(context, coach),
      child: Container(
        width: 95,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: whiteLight,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(1, 2))
          ],
          border: Border.all(color: colorBackgroundBox, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: coach.user?.photo_url != null
                  ? Image.network(coach.user!.photo_url!,
                  width: 70, height: 70, fit: BoxFit.cover)
                  : Container(
                width: 70,
                height: 70,
                color: Colors.grey[300],
                child: const Icon(Icons.person, size: 30, color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Text(
                coach.user?.name ?? 'Nombre no disponible',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.roboto(
                    fontSize: 16, fontWeight: FontWeight.w900, color: darkGrey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showCoachBottomSheet(BuildContext context, Coach coach) {
    showMaterialModalBottomSheet(
      context: context,
      expand: false,
      backgroundColor: darkGrey,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) => SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 5,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.only(bottom: 20),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: coach.user?.photo_url != null
                  ? Image.network(
                coach.user!.photo_url!,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 50),
              )
                  : Container(
                width: 120,
                height: 120,
                color: Colors.grey[300],
                child: const Icon(Icons.person, size: 60, color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              coach.user?.name ?? 'Nombre no disponible',
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: limeGreen,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.email, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  coach.user?.email ?? 'Correo no disponible',
                  style: GoogleFonts.roboto(fontSize: 15, color: Colors.grey[700]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _scheduledClassCard(ScheduledClass c, BuildContext context) {
    final formattedDate =
    c.classDate.split('T').first.split('-').reversed.join('/');
    final formattedTime = c.classTime.substring(0, 5);

    // Calcular diferencia en horas (mismo criterio para reagendar y cancelar)
    final dateString = c.classDate.split('T').first;
    final timeString = c.classTime.substring(0, 5);
    final partsDate = dateString.split('-').map(int.parse).toList();
    final partsTime = timeString.split(':').map(int.parse).toList();
    final classDateTime = DateTime(
      partsDate[0],
      partsDate[1],
      partsDate[2],
      partsTime[0],
      partsTime[1],
    ).toLocal();

    final now = DateTime.now();
    final canModify = classDateTime.difference(now).inHours >= 12;

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: c.photo_url.isNotEmpty
                    ? Image.network(
                  c.photo_url,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                )
                    : Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[300],
                  child: const Icon(Icons.person, color: Colors.white),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$formattedDate · $formattedTime',
                        style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: almostBlack)),
                    Text('Coach: ${c.coachName}',
                        style:
                        GoogleFonts.roboto(fontSize: 15, color: darkGrey)),
                    Text('Bicicleta: ${c.bicycle}',
                        style:
                        GoogleFonts.roboto(fontSize: 15, color: darkGrey)),
                  ],
                ),
              ),
            ],
          ),
        ),

        // BOTÓN CANCELAR
        Positioned(
          top: 20,
          right: 20,
          child: IconButton(
            icon: Icon(Icons.delete,
                color: canModify ? Colors.red : Colors.grey.shade400),
            onPressed: canModify ? () => con.onPressCancel(c, context) : null,
          ),
        ),
      ],
    );
  }


  Widget _scheduledClassesScrollableSection(BuildContext context) {
    if (con.scheduledClasses.isEmpty) {
      return Container(
        padding:
        EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.15),
        child: Center(
          child: Text('No tienes clases agendadas.',
              style: GoogleFonts.roboto(fontSize: 16, color: Colors.grey[700])),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: con.scheduledClasses.length,
      itemBuilder: (context, index) =>
          _scheduledClassCard(con.scheduledClasses[index], context),
    );
  }

  Widget _actionInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: FilledButton.tonalIcon(
        onPressed: () => _showModalInfo(context),
        icon: Icon(iconInfo, color: almostBlack),
        label: Text('Info', style: TextStyle(color: darkGrey)),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(colorBackgroundBox),
        ),
      ),
    );
  }

  Future<void> _showModalInfo(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Rides',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w800)),
          content:
          Text(_ridesTerms, style: GoogleFonts.montserrat(color: darkGrey)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all(indigoAmina)),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  static const String _ridesTerms = '''
En AMINA, valoramos tu tiempo y compromiso con nuestras clases. Reconocemos que a veces surgen imprevistos que requieren cambios en los horarios de clases. Con el fin de brindar flexibilidad y mantener la eficiencia en nuestra programación, hemos establecido la siguiente política de cancelación.

Cancelación con 12 horas de ANTICIPACIÓN: tienen derecho a cancelar una clase sin penalización si lo hacen con al menos 12 horas de anticipación antes de la hora de inicio programada.

Proceso de Cancelación: En la pantalla de inicio se mostrarán las clases que el usuario agendó. En la sección derecha encontrará un botón que da paso al proceso de reagendamiento de clases.''';
}
