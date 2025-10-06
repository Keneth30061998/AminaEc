import 'package:amina_ec/src/pages/user/Start/user_start_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
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
        actions: [
          _actionInfo(context),
        ],
      ),
      body: Obx(() {
        return RefreshIndicator(
          color: indigoAmina,
          onRefresh: () async {
            //print('🔄 Pull-to-refresh activado -> recargando datos...');
            // Todas estas funciones no devuelven Future<void>, así que se llaman directo
            con.getScheduledClasses();
            con.getAttendedClasses();
            con.getTotalRides();
            con.getAcquiredPlans();
            con.getCoaches();

            // Este pequeño delay permite que el indicador se muestre correctamente
            await Future.delayed(const Duration(seconds: 1));
          },
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _textGreeting(),
                  const SizedBox(height: 15),
                  _containerCount(),
                  const SizedBox(height: 15),
                  _reelCoach(context),
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
                  Flexible(
                    child: _scheduledClassesScrollableSection(),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _appBarTitle() {
    return Text(
      'Amina',
      style: GoogleFonts.montserrat(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: almostBlack,
      ),
    );
  }

  Widget _textGreeting() {
    return Text(
      'Hola, ${con.user.name}',
      style: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: darkGrey,
      ),
    );
  }

  Widget _containerCount() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _boxBikesComplete(),
          _boxBikesPending(),
        ],
      ),
    );
  }

  Widget _boxBikesComplete() {
    return Obx(() => _boxTemplate(
      title: 'Rides',
      count: '${con.attendedClasses.value}',
      subtitle: 'Completados',
      color: Colors.blueGrey.shade50,
    ));
  }

  Widget _boxBikesPending() {
    return Obx(() => _boxTemplate(
      title: 'Rides',
      count: '${con.totalRides.value}',
      subtitle: 'Adquiridos',
      color: Colors.blueGrey.shade50,
    ));
  }

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
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(2, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: GoogleFonts.roboto(
                color: almostBlack,
                fontSize: 16,
              )),
          Text(count,
              style: GoogleFonts.montserrat(
                color: darkGrey,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              )),
          Text(subtitle,
              style: GoogleFonts.kodchasan(
                color: almostBlack,
                fontSize: 15,
              )),
        ],
      ),
    );
  }

  Widget _reelCoach(BuildContext context) {
    return Column(
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
        Container(
          color: whiteLight,
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: con.coaches.length,
            itemBuilder: (context, index) {
              final coach = con.coaches[index];
              return _cardCoach(coach, context);
            },
          ),
        ),
      ],
    );
  }

  Widget _cardCoach(Coach coach, BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        showCoachBottomSheet(context, coach);
      },
      child: Container(
        width: 95,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: whiteLight,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(1, 2),
            ),
          ],
          border: BoxBorder.all(
            color: colorBackgroundBox,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: coach.user?.photo_url != null
                  ? Image.network(
                coach.user!.photo_url!,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image,
                    size: 30,
                    color: Colors.grey),
              )
                  : Container(
                width: 70,
                height: 70,
                color: Colors.grey[300],
                child: const Icon(Icons.person,
                    size: 30, color: Colors.white),
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
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: darkGrey,
                ),
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
                child: const Icon(Icons.person,
                    size: 60, color: Colors.white),
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
                  style: GoogleFonts.roboto(
                    fontSize: 15,
                    color: Colors.grey[700],
                  ),
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

    final createdLocal = c.createdAt.toLocal();
    final windowEndLocal = createdLocal.add(const Duration(hours: 24));
    final nowLocal = DateTime.now();

    final canReschedule = nowLocal.isBefore(windowEndLocal);

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
                  errorBuilder: (_, __, ___) =>
                  const Icon(Icons.broken_image, size: 30),
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
                    Text(
                      '$formattedDate · $formattedTime',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: almostBlack,
                      ),
                    ),
                    Text(
                      'Coach: ${c.coachName}',
                      style: GoogleFonts.roboto(fontSize: 15, color: darkGrey),
                    ),
                    Text(
                      'Bicicleta: ${c.bicycle}',
                      style: GoogleFonts.roboto(fontSize: 15, color: darkGrey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: Icon(
              Icons.schedule,
              color: canReschedule ? darkGrey : Colors.grey.shade400,
            ),
            onPressed:
            canReschedule ? () => con.onPressReschedule(c, context) : null,
          ),
        ),
      ],
    );
  }

  Widget _scheduledClassesScrollableSection() {
    return Obx(() {
      if (con.scheduledClasses.isEmpty) {
        return Center(
          child: Text(
            'No tienes clases agendadas.',
            style: GoogleFonts.roboto(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: con.scheduledClasses.length,
        itemBuilder: (context, index) {
          return _scheduledClassCard(con.scheduledClasses[index], context);
        },
      );
    });
  }

  Widget _actionInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: FilledButton.tonalIcon(
        onPressed: () => _showModalInfo(context),
        icon: Icon(Icons.info_outline, color: almostBlack),
        label: Text(
          'Rides',
          style: TextStyle(color: darkGrey),
        ),
        style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(colorBackgroundBox)),
      ),
    );
  }

  Future<void> _showModalInfo(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Rides',
              style:
              GoogleFonts.poppins(fontWeight: FontWeight.w800)),
          content: Text(_ridesTerms,
              style: GoogleFonts.montserrat(color: darkGrey)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(indigoAmina),
              ),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  static const String _ridesTerms = '''
En AMINA, valoramos tu tiempo y compromiso con nuestras clases. Reconocemos que a veces surgen imprevistos que requieren cambios en los horarios de clases. Con el fin de brindar flexibilidad y mantener la eficiencia en nuestra programación hemos establecido la siguiente política de cancelación.

Cancelacion con 12 horas de anticipación: tienen derecho a cancelar una clase sin penalización si lo hacen con almenos 12 horas de anticipación antes de la hora de inicio programada.

Proceso de Cancelacion: En la pantalla de inicio se mostrarán las clases que el usuario agendo, en la sección derecha encontrará un botón que da paso al proceso de reagendamiento de clases''';
}
