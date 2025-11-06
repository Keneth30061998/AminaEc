// File: user_coach_schedule_page.dart

import 'package:amina_ec/src/pages/user/Coach/List/user_coach_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../../models/coach.dart';
import '../../../../utils/color.dart';
import '../../../../widgets/no_data_widget.dart';
class _ClassCardEntry {
  final DateTime time;
  final Widget card;
  _ClassCardEntry({required this.time, required this.card});
}

class UserCoachSchedulePage extends StatelessWidget {
  final con = Get.put(UserCoachScheduleController());

  UserCoachSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 650;

    return Scaffold(
      backgroundColor: whiteLight,
      appBar: AppBar(
        title: Text(
          'Agendar Ride',
          style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        backgroundColor: whiteLight,
        foregroundColor: almostBlack,
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: indigoAmina,
        onRefresh: () async {
          await con.loadCoaches();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Obx(() {
                final refreshKey = con.calendarRefreshTrigger.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SfCalendar(
                        key: ValueKey(refreshKey),
                        minDate: DateTime.now(),
                        view: CalendarView.month,
                        onTap: (details) {
                          if (details.date != null) con.selectDate(details.date!);
                        },
                        initialSelectedDate: con.selectedDate.value,
                        dataSource: con.calendarDataSource.value,
                        headerStyle: CalendarHeaderStyle(
                          textAlign: TextAlign.center,
                          backgroundColor: indigoAmina,
                          textStyle: const TextStyle(color: whiteLight),
                        ),
                        selectionDecoration: BoxDecoration(
                          color: darkGrey.withAlpha((0.2 * 255).toInt()),
                          border: Border.all(color: darkGrey, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        showNavigationArrow: true,
                        todayHighlightColor: indigoAmina,
                        monthViewSettings: const MonthViewSettings(
                          appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
                          showAgenda: false,
                        ),
                        appointmentBuilder: (context, details) {
                          final appointment = details.appointments.first as Appointment;
                          return Container(
                            width: details.bounds.width,
                            height: details.bounds.height,
                            decoration: BoxDecoration(
                              color: appointment.color,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Center(
                              child: Text(
                                appointment.subject,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              }),

              Obx(() {
                if (con.filteredCoaches.isEmpty) {
                  return const Center(
                    child: NoDataWidget(text: 'No hay entrenadores disponibles ese día'),
                  );
                }

                // Vamos a guardar una lista de objetos que contengan:
                // - el widget card
                // - la hora de inicio como DateTime
                final List<_ClassCardEntry> entries = [];

                for (final coach in con.filteredCoaches) {
                  final schedules = coach.schedules.where((s) {
                    final sDate = DateTime.tryParse(s.date ?? '');
                    final d = con.selectedDate.value;
                    return sDate != null && sDate.year == d.year && sDate.month == d.month && sDate.day == d.day;
                  }).toList()
                    ..sort((a, b) {
                      final t1 = DateTime.parse('${a.date} ${a.start_time}');
                      final t2 = DateTime.parse('${b.date} ${b.start_time}');
                      return t1.compareTo(t2);
                    });

                  for (final s in schedules) {
                    final card = _coachClassCard(coach, s, isTablet);
                    final time = DateTime.parse('${s.date} ${s.start_time}');
                    entries.add(_ClassCardEntry(time: time, card: card));
                  }
                }

                // ✅ Ordenamos por hora
                entries.sort((a, b) => a.time.compareTo(b.time));

                return ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  children: entries.map((e) => e.card).toList(),
                );
              }),


            ],
          ),
        ),
      ),
    );
  }

  // Si el coach tiene múltiples horarios en el día, se renderiza un card por horario.
  Widget _coachCardsForCoach(Coach coach, DateTime date, bool isTablet) {
    final schedules = coach.schedules.where((s) {
      final sDate = DateTime.tryParse(s.date ?? '');
      return sDate != null &&
          sDate.year == date.year &&
          sDate.month == date.month &&
          sDate.day == date.day;
    }).toList()
      ..sort((a, b) {
        final t1 = (a.start_time ?? '00:00').split(':');
        final t2 = (b.start_time ?? '00:00').split(':');
        final aMinutes = int.parse(t1[0]) * 60 + int.parse(t1[1]);
        final bMinutes = int.parse(t2[0]) * 60 + int.parse(t2[1]);
        return aMinutes.compareTo(bMinutes);
      });

    // Antes de construir las tarjetas, solicitamos los contadores que aún no estén en el mapa
    for (final s in schedules) {
      final key = '${coach.id}-${s.date}-${s.start_time}';
      // Solo solicitar si no existe la key para evitar múltiples requests por rebuilds
      if (!con.occupiedBikeMap.containsKey(key)) {
        // No await: disparamos la carga en background (se actualizará reactivamente)
        con.fetchOccupiedCount(
          coachId: coach.id ?? '',
          date: s.date ?? '',
          time: s.start_time ?? '',
        );
      }
    }

    return Column(
      children: schedules.map((s) {
        final theme = (s.class_theme?.isNotEmpty == true) ? s.class_theme! : 'Clase';
        final formattedTime = _formatTime(s.start_time);
        final key = '${coach.id}-${s.date}-${s.start_time}';
        const total = 18; // bicicletas totales

        // Usamos Obx para que el badge se actualice reactivamente cuando cambia el mapa
        return Obx(() {
          final occupied = con.occupiedBikeMap[key] ?? 0;

          return _AnimatedClassCard(
            coachName: coach.user?.name ?? '',
            coachImageUrl: coach.user?.photo_url ?? '',
            classTheme: theme,
            duration: '$formattedTime — ${_formatTime(s.end_time)}',
            locationName: coach.hobby?.isNotEmpty == true ? coach.hobby! : 'Studio',
            occupiedCount: occupied,
            totalCount: total,
            isTablet: isTablet,
            onTap: () {
              con.goToUserCoachReservePage(
                coachId: coach.id ?? '',
                classTime: s.start_time ?? '00:00:00',
                coachName: coach.user?.name ?? '',
                classTheme: theme,
              );
            },
            heroTag: '${coach.id}_${s.date}_${s.start_time}',
          );
        });
      }).toList(),
    );
  }
  Widget _coachClassCard(Coach coach, schedule, bool isTablet) {
    final theme = (schedule.class_theme?.isNotEmpty == true) ? schedule.class_theme! : 'Clase';
    final formattedTime = _formatTime(schedule.start_time);
    final key = '${coach.id}-${schedule.date}-${schedule.start_time}';
    const total = 18;

    // Dispara carga si falta
    if (!con.occupiedBikeMap.containsKey(key)) {
      con.fetchOccupiedCount(
        coachId: coach.id ?? '',
        date: schedule.date ?? '',
        time: schedule.start_time ?? '',
      );
    }

    return Obx(() {
      final occupied = con.occupiedBikeMap[key] ?? 0;

      return _AnimatedClassCard(
        coachName: coach.user?.name ?? '',
        coachImageUrl: coach.user?.photo_url ?? '',
        classTheme: theme,
        duration: '$formattedTime — ${_formatTime(schedule.end_time)}',
        locationName: coach.hobby?.isNotEmpty == true ? coach.hobby! : 'Studio',
        occupiedCount: occupied,
        totalCount: total,
        isTablet: isTablet,
        onTap: () {
          con.goToUserCoachReservePage(
            coachId: coach.id ?? '',
            classTime: schedule.start_time ?? '00:00:00',
            coachName: coach.user?.name ?? '',
            classTheme: theme,
          );
        },
        heroTag: '${coach.id}_${schedule.date}_${schedule.start_time}',
      );
    });
  }

  String _formatTime(String? time) {
    if (time == null) return '';
    final parts = time.split(':');
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }
}

class _AnimatedClassCard extends StatefulWidget {
  final String coachName;
  final String coachImageUrl;
  final String classTheme;
  final String duration;
  final String locationName;
  final VoidCallback onTap;
  final bool isTablet;
  final String heroTag;
  final int occupiedCount;
  final int totalCount;

  const _AnimatedClassCard({
    super.key,
    required this.coachName,
    required this.coachImageUrl,
    required this.classTheme,
    required this.duration,
    required this.locationName,
    required this.onTap,
    required this.isTablet,
    required this.heroTag,
    required this.occupiedCount,
    required this.totalCount,
  });

  @override
  State<_AnimatedClassCard> createState() => _AnimatedClassCardState();
}

class _AnimatedClassCardState extends State<_AnimatedClassCard> with SingleTickerProviderStateMixin {
  double scale = 1;
  late AnimationController _animController;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _slide = Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    // arrancar la animación de entrada
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.isTablet ? 640.0 : double.infinity;

    // blancos diferenciados: colorBackgroundBox para internal card, y fondo blanco para page.
    // Sombra menos difuminada (más definida) parecida al calendario
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 130),
          curve: Curves.easeOut,
          child: GestureDetector(
            onTapDown: (_) => setState(() => scale = .98),
            onTapUp: (_) => setState(() => scale = 1),
            onTapCancel: () => setState(() => scale = 1),
            onTap: widget.onTap,
            child: Container(
              width: width,
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white, // card blanco principal
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  // sombra más definida, menos difuminada, similar al calendario
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 3,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Imagen circular
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: widget.isTablet ? 86 : 68,
                      height: widget.isTablet ? 86 : 68,
                      color: Colors.grey.shade100, // ligero contraste con el blanco de la card
                      child: widget.coachImageUrl.isNotEmpty
                          ? Image.network(widget.coachImageUrl, fit: BoxFit.cover)
                          : Icon(Icons.person, size: widget.isTablet ? 40 : 36, color: Colors.grey.shade500),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Fecha (arriba)
                        Text(
                          // Parseamos fecha humana (ISO yyyy-mm-dd) a dd/mm/yyyy
                          _prettyDateFromHeroTag(widget.heroTag),
                          style: TextStyle(
                            fontSize: widget.isTablet ? 14 : 12,
                            color: Colors.grey.shade600,
                          ),
                        ),

                        const SizedBox(height: 6),
                        // Nombre del coach con Hero (opción 3)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Hero(
                                tag: widget.heroTag, // tag único por coach+date+time
                                flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
                                  // transición sutil para texto
                                  return DefaultTextStyle(
                                    style: TextStyle(
                                      fontSize: widget.isTablet ? 22 : 18,
                                      fontWeight: FontWeight.w800,
                                      color: almostBlack,
                                    ),
                                    child: fromHeroContext.widget,
                                  );
                                },
                                child: Text(
                                  'Rueda con ${widget.coachName}',
                                  style: TextStyle(
                                    fontSize: widget.isTablet ? 20 : 16,
                                    fontWeight: FontWeight.w800,
                                    color: almostBlack,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),
                        Text(
                          widget.classTheme,
                          style: TextStyle(
                            fontSize: widget.isTablet ? 15 : 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),

                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.duration,
                              style: TextStyle(
                                fontSize: widget.isTablet ? 15 : 13,
                                color: Colors.grey.shade700,
                              ),
                            ),

                            // 🔥 CONTADOR DE BICICLETAS (ocupadas/total)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.directions_bike_outlined, size: 15,),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${widget.occupiedCount}/${widget.totalCount}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: widget.isTablet ? 16 : 14,
                                      color: almostBlack,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),
                            Icon(Icons.chevron_right, color: Colors.grey.shade600),
                          ],
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Extrae fecha legible desde heroTag que armamos en la page: '${coach.id}_${s.date}_${s.start_time}'
  String _prettyDateFromHeroTag(String heroTag) {
    final parts = heroTag.split('_');
    if (parts.length >= 3) {
      final dateIso = parts[1]; // yyyy-mm-dd
      try {
        final d = DateTime.parse(dateIso);
        return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
      } catch (_) {
        return dateIso;
      }
    }
    return '';
  }
}
