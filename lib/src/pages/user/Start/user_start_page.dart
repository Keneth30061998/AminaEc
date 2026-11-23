import 'package:amina_ec/src/services/waitlist_service.dart';
import 'package:amina_ec/src/pages/user/Start/user_start_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:amina_ec/src/utils/iconos.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../../models/coach.dart';
import '../../../models/scheduled_class.dart';
import '../../../widgets/app_banner_carousel.dart';

class UserStartPage extends StatelessWidget {
  final UserStartController con = Get.put(UserStartController());

  UserStartPage({super.key});

  static const Color _background = Color(0xFFF7F8FA);
  static const Color _border = Color(0xFFE9ECF2);
  static const Color _muted = Color(0xFF737B8C);
  static const Color _softIndigo = Color(0xFFF0F0FA);
  static const Color _green = Color(0xFF23846B);

  TextStyle _heading(double size) => GoogleFonts.montserrat(
    fontSize: size,
    fontWeight: FontWeight.w700,
    color: almostBlack,
    letterSpacing: -0.5,
    height: 1.25,
  );

  TextStyle _body({
    double size = 14,
    Color color = _muted,
    FontWeight weight = FontWeight.w400,
  }) =>
      GoogleFonts.roboto(
        fontSize: size,
        color: color,
        fontWeight: weight,
        height: 1.45,
      );

  RoundedRectangleBorder get _cardShape => RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(22),
    side: const BorderSide(color: _border),
  );

  Widget _surface({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(20),
    VoidCallback? onTap,
    Color color = Colors.white,
  }) {
    return Material(
      color: color,
      shape: _cardShape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 24,
        toolbarHeight: 72,
        title: Text(
          'Amina',
          style: _heading(27),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: _actionInfo(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: indigoAmina,
        backgroundColor: Colors.white,
        onRefresh: () async {
          con.getScheduledClasses();
          con.getAttendedClasses();
          con.getTotalRides();
          con.getAcquiredPlans();
          con.getCoaches();
          con.getCompletedRides();

          await con.getAppBanner();
          await WaitlistService.to.refresh(force: true);

          await Future.delayed(
            const Duration(milliseconds: 500),
          );
        },
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _heroHeader(),
                      const SizedBox(height: 24),
                      _ridesOverview(),
                      const SizedBox(height: 14),
                      Obx(() => _waitlistCard()),
                      Obx(() {
                        final banners = con.activeBanners.toList();

                        if (banners.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: AppBannerCarousel(
                              banners: banners,
                              onTap: (banner) =>
                                  con.openBannerLink(banner),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 30),
                      _sectionTitle(
                        title: 'Nuestros coaches',
                      ),
                      const SizedBox(height: 16),
                      _coachesList(context),
                      const SizedBox(height: 30),
                      _sectionTitle(
                        title: 'Tus clases agendadas',
                      ),
                      const SizedBox(height: 16),
                      Obx(() {
                        if (con.scheduledClasses.isEmpty) {
                          return _emptyScheduledState();
                        }

                        return ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: con.scheduledClasses.length,
                          shrinkWrap: true,
                          physics:
                          const NeverScrollableScrollPhysics(),
                          separatorBuilder: (_, __) =>
                          const SizedBox(height: 14),
                          itemBuilder: (context, index) =>
                              _scheduledClassCard(
                                con.scheduledClasses[index],
                                context,
                              ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _heroHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hola, ${con.user.name}',
          style: _heading(26),
        ),
      ],
    );
  }

  Widget _sectionTitle({
    required String title,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _heading(19)),
        const SizedBox(height: 5),
      ],
    );
  }

  Widget _ridesOverview() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          Obx(
                () => _statCard(
              count: '${con.completedRides.value}',
              label: 'Rides completados',
              icon: Icons.check_circle_outline_rounded,
              accent: _green,
            ),
          ),
          Obx(
                () => _statCard(
              count: '${con.totalRides.value}',
              label: 'Rides adquiridos',
              icon: Icons.pedal_bike_rounded,
              accent: indigoAmina,
              onTap: () => con.showUserPlansInfo(),
            ),
          ),
        ];

        if (constraints.maxWidth < 300) {
          return Column(
            children: [
              cards[0],
              const SizedBox(height: 12),
              cards[1],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 12),
            Expanded(child: cards[1]),
          ],
        );
      },
    );
  }

  Widget _statCard({
    required String count,
    required String label,
    required IconData icon,
    required Color accent,
    VoidCallback? onTap,
  }) {
    return _surface(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 21, color: accent),
              ),
              const Spacer(),
              if (onTap != null)
                const Icon(
                  Icons.arrow_outward_rounded,
                  size: 17,
                  color: _muted,
                ),
            ],
          ),
          const SizedBox(height: 17),
          Text(
            count,
            style: GoogleFonts.montserrat(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: almostBlack,
              letterSpacing: -1.2,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            style: _body(
              size: 13,
              weight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _waitlistCard() {
    final queue = WaitlistService.to;
    final hasError = queue.error.value != null;
    final isLoading = queue.loading.value;
    final hasOffers = queue.offerCount > 0;

    final subtitle = hasError
        ? 'No se pudo actualizar. Toca para reintentar.'
        : isLoading
        ? 'Consultando tus listas…'
        : '${queue.activeCount} activas · '
        '${queue.offerCount} ofertas disponibles';

    return _surface(
      onTap: () => queue.openList(),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _softIndigo,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.format_list_numbered_rounded,
              color: indigoAmina,
              size: 22,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mis listas de espera',
                  style: _body(
                    size: 14,
                    color: almostBlack,
                    weight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: _body(
                    size: 12,
                    color: hasError
                        ? const Color(0xFFAD5838)
                        : _muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (isLoading && !hasError)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: indigoAmina,
              ),
            )
          else
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasOffers && !hasError) ...[
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: _green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
                const Icon(
                  Icons.chevron_right_rounded,
                  color: _muted,
                  size: 22,
                ),
              ],
            ),
        ],
      ),
    );
  }



  Widget _avatar({
    required String? photoUrl,
    required double size,
  }) {
    final url = photoUrl?.trim() ?? '';

    Widget placeholder() => Container(
      color: _softIndigo,
      alignment: Alignment.center,
      child: Icon(
        Icons.person_outline_rounded,
        size: size * 0.44,
        color: indigoAmina,
      ),
    );

    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: url.isEmpty
            ? placeholder()
            : Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => placeholder(),
          loadingBuilder: (context, child, progress) {
            return progress == null
                ? child
                : placeholder();
          },
        ),
      ),
    );
  }

  void showCoachBottomSheet(
      BuildContext context,
      Coach coach,
      ) {
    showMaterialModalBottomSheet(
      context: context,
      expand: false,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCE0E8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    tooltip: 'Cerrar',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: _muted,
                    ),
                  ),
                ),
                _avatar(
                  photoUrl: coach.user?.photo_url,
                  size: 104,
                ),
                const SizedBox(height: 20),
                Text(
                  coach.user?.name ?? 'Nombre no disponible',
                  textAlign: TextAlign.center,
                  style: _heading(23),
                ),
                const SizedBox(height: 7),
                Text(
                  'Coach Amina',
                  style: _body(size: 14),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        size: 21,
                        color: indigoAmina,
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Correo electrónico',
                              style: _body(size: 12),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              coach.user?.email ??
                                  'Correo no disponible',
                              style: _body(
                                color: almostBlack,
                                weight: FontWeight.w500,
                              ),
                            ),
                          ],
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

  Widget _coachesList(BuildContext context) {
    return SizedBox(
      height: 168,
      child: Obx(() {
        if (con.coaches.isEmpty) {
          return _loadingCard();
        }

        return ListView.separated(
          padding: EdgeInsets.zero,
          scrollDirection: Axis.horizontal,
          itemCount: con.coaches.length,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (context, index) =>
              _cardCoach(con.coaches[index], context),
        );
      }),
    );
  }

  Widget _cardCoach(Coach coach, BuildContext context) {
    final hasPhoto = coach.user?.photo_url != null &&
        coach.user!.photo_url!.trim().isNotEmpty;

    return GestureDetector(
      onTap: () => showCoachBottomSheet(context, coach),
      child: Container(
        width: 124,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.black.withOpacity(0.04),
          ),
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
                    ? const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 34,
                )
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

  Widget _scheduledClassCard(
      ScheduledClass c,
      BuildContext context,
      ) {
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

    // Estilo original de las etiquetas, exclusivo de esta tarjeta.
    Widget classInfoChip({
      required IconData icon,
      required String text,
    }) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F6FA),
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.black.withOpacity(0.04),
        ),
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
                ? const Icon(
              Icons.person,
              color: Colors.white,
            )
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
                    classInfoChip(
                      icon: Icons.calendar_today_rounded,
                      text: formattedDate,
                    ),
                    classInfoChip(
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
                            : 'No se puede cancelar dentro de '
                            'las 12 horas previas',
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          color: canModify
                              ? const Color(0xFF1E9E67)
                              : Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: canModify
                          ? 'Cancelar clase'
                          : 'Cancelación no disponible',
                      child: Material(
                        color: canModify
                            ? Colors.red.withOpacity(0.10)
                            : Colors.grey.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(14),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: canModify
                              ? () => con.onPressCancel(c, context)
                              : null,
                          child: SizedBox(
                            width: 42,
                            height: 42,
                            child: Icon(
                              Icons.delete_outline_rounded,
                              color: canModify
                                  ? Colors.red
                                  : Colors.grey.shade400,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
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
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: _softIndigo,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: indigoAmina),
          const SizedBox(width: 7),
          Text(
            text,
            style: _body(
              size: 12,
              color: indigoAmina,
              weight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _deleteButton(
      bool enabled,
      VoidCallback onPressed,
      ) {
    return Tooltip(
      message: enabled
          ? 'Cancelar clase'
          : 'Cancelación no disponible',
      child: SizedBox(
        width: 48,
        height: 48,
        child: Material(
          color: enabled
              ? const Color(0xFFFFF1F0)
              : _background,
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAlias,
          child: IconButton(
            onPressed: enabled ? onPressed : null,
            icon: const Icon(Icons.delete_outline_rounded),
            iconSize: 22,
            color: const Color(0xFFCA5858),
            disabledColor: const Color(0xFFB5BBC7),
          ),
        ),
      ),
    );
  }

  Widget _emptyScheduledState() {
    return SizedBox(
      width: double.infinity,
      child: _surface(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 30,
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _softIndigo,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.event_available_outlined,
                color: indigoAmina,
                size: 28,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Tu próximo ride te espera',
              textAlign: TextAlign.center,
              style: _heading(17),
            ),
            const SizedBox(height: 9),
            Text(
              'Aún no tienes clases agendadas. '
                  'Cuando reserves una sesión, podrás '
                  'consultarla aquí.',
              textAlign: TextAlign.center,
              style: _body(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loadingCard() {
    return SizedBox(
      width: double.infinity,
      child: _surface(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: indigoAmina,
              ),
            ),
            const SizedBox(height: 13),
            Text(
              'Cargando coaches…',
              style: _body(size: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionInfo(BuildContext context) {
    return Center(
      child: Tooltip(
        message: 'Información sobre tus rides',
        child: SizedBox(
          width: 44,
          height: 44,
          child: Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: _border),
            ),
            clipBehavior: Clip.antiAlias,
            child: IconButton(
              onPressed: () => _showModalInfo(context),
              icon: Icon(
                iconInfo,
                color: almostBlack,
                size: 21,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showModalInfo(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        scrollable: true,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 24,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
        actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _softIndigo,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                color: indigoAmina,
                size: 22,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Información sobre tus rides',
              style: _heading(20),
            ),
          ],
        ),
        content: Text(
          _ridesTerms,
          style: _body(size: 14, color: const Color(0xFF596174)),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: indigoAmina,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: Text(
                'Entendido',
                style: _body(
                  color: Colors.white,
                  weight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const String _ridesTerms = '''
En AMINA, valoramos tu tiempo y compromiso con nuestras clases. Reconocemos que a veces surgen imprevistos que requieren cambios en los horarios de clases. Con el fin de brindar flexibilidad y mantener la eficiencia en nuestra programación, hemos establecido la siguiente política de cancelación.

Cancelación con 12 horas de ANTICIPACIÓN: tienen derecho a cancelar una clase sin penalización si lo hacen con al menos 12 horas de anticipación antes de la hora de inicio programada.

Proceso de Cancelación: En la pantalla de inicio se mostrarán las clases que el usuario agendó. En la sección derecha encontrará un botón que da paso al proceso de reagendamiento de clases.''';
}