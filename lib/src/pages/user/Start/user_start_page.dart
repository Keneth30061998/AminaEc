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
      backgroundColor: const Color(0xffF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleSpacing: 24,
        title: Text(
          'Amina',
          style: GoogleFonts.montserrat(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: almostBlack,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: _actionInfo(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: indigoAmina,
        onRefresh: () async {
          con.getScheduledClasses();
          con.getAttendedClasses();
          con.getTotalRides();
          con.getAcquiredPlans();
          con.getCoaches();
          con.getCompletedRides();
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _heroHeader(),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(child: Obx(() => _boxBikesComplete())),
                    const SizedBox(width: 14),
                    Expanded(child: Obx(() => _boxBikesPending())),
                  ],
                ),
                const SizedBox(height: 20),
                _sectionTitle(
                  title: 'Nuestros Coaches',
                  subtitle: 'Conoce al equipo que te acompaña en cada ride',
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 168,
                  child: Obx(() {
                    if (con.coaches.isEmpty) {
                      return _loadingCard();
                    }
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: con.coaches.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (context, index) =>
                          _cardCoach(con.coaches[index], context),
                    );
                  }),
                ),
                const SizedBox(height: 30),
                _sectionTitle(
                  title: 'Tus clases agendadas',
                  subtitle: 'Administra tus próximas sesiones fácilmente',
                ),
                const SizedBox(height: 14),
                Obx(() {
                  if (con.scheduledClasses.isEmpty) {
                    return _emptyScheduledState();
                  }

                  return ListView.separated(
                    itemCount: con.scheduledClasses.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) =>
                        _scheduledClassCard(con.scheduledClasses[index], context),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _heroHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        'Hola, ${con.user.name}',
        style: GoogleFonts.montserrat(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: almostBlack,
          letterSpacing: -0.4,
        ),
      ),
    );
  }

  Widget _sectionTitle({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: almostBlack,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.roboto(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _boxBikesComplete() => _modernStatCard(
    title: 'Rides',
    count: '${con.completedRides.value}',
    subtitle: 'Completos',
    icon: Icons.check_circle_rounded,
    accent: const Color(0xff20C997),
  );

  Widget _boxBikesPending() => GestureDetector(
    onTap: () => con.showUserPlansInfo(),
    child: _modernStatCard(
      title: 'Rides',
      count: '${con.totalRides.value}',
      subtitle: 'Adquiridos',
      icon: Icons.local_fire_department_rounded,
      accent: const Color(0xff6C63FF),
    ),
  );

  Widget _modernStatCard({
    required String title,
    required String count,
    required String subtitle,
    required IconData icon,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accent, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  count,
                  style: GoogleFonts.montserrat(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: almostBlack,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.roboto(
                    fontSize: 13.5,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardCoach(Coach coach, BuildContext context) {
    final hasPhoto = coach.user?.photo_url != null &&
        coach.user!.photo_url!.trim().isNotEmpty;

    return GestureDetector(
      onTap: () => showCoachBottomSheet(context, coach),
      child: Container(
        width: 124,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.black.withOpacity(0.04)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.045),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: indigoAmina.withOpacity(0.14),
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 36,
                backgroundColor: Colors.grey.shade200,
                backgroundImage:
                hasPhoto ? NetworkImage(coach.user!.photo_url!) : null,
                child: !hasPhoto
                    ? const Icon(Icons.person, color: Colors.white, size: 34)
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              coach.user?.name ?? 'Nombre no disponible',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: almostBlack,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showCoachBottomSheet(BuildContext context, Coach coach) {
    final hasPhoto = coach.user?.photo_url != null &&
        coach.user!.photo_url!.trim().isNotEmpty;

    showMaterialModalBottomSheet(
      context: context,
      expand: false,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xff12141A),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 52,
                  backgroundColor: Colors.white.withOpacity(0.08),
                  backgroundImage:
                  hasPhoto ? NetworkImage(coach.user!.photo_url!) : null,
                  child: !hasPhoto
                      ? const Icon(Icons.person, size: 46, color: Colors.white70)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  coach.user?.name ?? 'Nombre no disponible',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.06),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.email_outlined,
                          size: 18, color: Colors.white.withOpacity(0.75)),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          coach.user?.email ?? 'Correo no disponible',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.84),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _scheduledClassCard(ScheduledClass c, BuildContext context) {
    final formattedDate =
    c.classDate.split('T').first.split('-').reversed.join('/');
    final formattedTime = c.classTime.substring(0, 5);

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
    final hasPhoto = c.photo_url.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: hasPhoto ? NetworkImage(c.photo_url) : null,
            child: !hasPhoto
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _infoChip(
                      icon: Icons.calendar_today_rounded,
                      text: formattedDate,
                    ),
                    _infoChip(
                      icon: Icons.access_time_rounded,
                      text: formattedTime,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  c.coachName,
                  style: GoogleFonts.montserrat(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: almostBlack,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Bicicleta: ${c.bicycle}',
                  style: GoogleFonts.roboto(
                    fontSize: 14.5,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        canModify
                            ? 'Disponible para cancelar'
                            : 'No se puede cancelar dentro de las 12 horas previas',
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          color: canModify
                              ? const Color(0xff1E9E67)
                              : Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _deleteButton(canModify, () => con.onPressCancel(c, context)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xffF4F6FA),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: indigoAmina),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.roboto(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: almostBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _deleteButton(bool enabled, VoidCallback onPressed) {
    return InkWell(
      onTap: enabled ? onPressed : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: enabled
              ? Colors.red.withOpacity(0.10)
              : Colors.grey.withOpacity(0.10),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          Icons.delete_outline_rounded,
          color: enabled ? Colors.red : Colors.grey.shade400,
          size: 22,
        ),
      ),
    );
  }

  Widget _emptyScheduledState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: darkGrey.withOpacity(0.08),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              Icons.event_busy_rounded,
              color: almostBlack,
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes clases agendadas',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: almostBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cuando agendes una clase, aparecerá aquí para que puedas verla o cancelarla con anticipación.',
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _actionInfo(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: () => _showModalInfo(context),
      icon: Icon(iconInfo, color: almostBlack, size: 18),
      label: Text(
        'Info',
        style: GoogleFonts.roboto(
          color: almostBlack,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: almostBlack,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.black.withOpacity(0.05),
          ),
        ),
      ),
    );
  }

  Future<void> _showModalInfo(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          title: Text(
            'Rides',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w800,
              fontSize: 22,
              color: almostBlack,
            ),
          ),
          content: Text(
            _ridesTerms,
            style: GoogleFonts.roboto(
              color: Colors.grey.shade700,
              height: 1.55,
              fontSize: 14.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: indigoAmina,
              ),
              child: Text(
                'Cerrar',
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w700,
                ),
              ),
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