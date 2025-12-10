// File: user_coach_schedule_page.dart

import 'package:amina_ec/src/pages/user/Coach/List/user_coach_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../../models/coach.dart';
import '../../../../models/schedule.dart';
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

                final List<_ClassCardEntry> entries = [];
                final seenScheduleIds = <String>{};

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
                    final scheduleId = (s.id ?? '').toString();
                    if (scheduleId.isNotEmpty && seenScheduleIds.contains(scheduleId)) continue;
                    seenScheduleIds.add(scheduleId);

                    final card = _coachClassCardWithMulti(coach, s, isTablet);
                    final time = DateTime.parse('${s.date} ${s.start_time}');
                    entries.add(_ClassCardEntry(time: time, card: card));
                  }
                }

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

  Widget _coachClassCardWithMulti(Coach coachPrincipal, Schedule schedule, bool isTablet) {
    List<Coach> relatedCoaches = [];

    try {
      if (schedule.coaches is List && (schedule.coaches as List).isNotEmpty) {
        final List<String> coachIds =
        (schedule.coaches as List).map((e) => e.toString()).toList();
        for (final cid in coachIds) {
          final c = con.allCoaches.firstWhereOrNull((x) => (x.id ?? '').toString() == cid);
          if (c != null) relatedCoaches.add(c);
        }
      }
    } catch (e) {
      print('⚠️ parsing coaches for schedule failed: $e');
    }

    if (relatedCoaches.isEmpty) relatedCoaches = [coachPrincipal];

    final theme = (schedule.class_theme?.isNotEmpty == true) ? schedule.class_theme! : 'Clase';
    final formattedTime = _formatTime(schedule.start_time);
    final key = '${relatedCoaches.first.id}-${schedule.date}-${schedule.start_time}';
    const total = 18;

    if (!con.occupiedBikeMap.containsKey(key)) {
      con.fetchOccupiedCount(
        coachId: relatedCoaches.first.id ?? '',
        date: schedule.date ?? '',
        time: schedule.start_time ?? '',
      );
    }

    final avatarWidget = PremiumAnimatedAvatar(
      coaches: relatedCoaches,
      isTablet: isTablet,
      size: isTablet ? 86 : 68,
    );

    return Obx(() {
      final occupied = con.occupiedBikeMap[key] ?? 0;

      final coachNames = relatedCoaches.take(2).map((c) => c.user?.name ?? '').where((n) => n.isNotEmpty).toList();
      final title = coachNames.isNotEmpty ? 'Rueda con ${coachNames.join(' & ')}' : 'Rueda';

      return _AnimatedClassCard(
        avatar: avatarWidget,
        coachName: title,
        coachImageUrl: relatedCoaches.first.user?.photo_url ?? '',
        classTheme: theme,
        duration: '$formattedTime — ${_formatTime(schedule.end_time)}',
        locationName: coachPrincipal.hobby?.isNotEmpty == true ? coachPrincipal.hobby! : 'Studio',
        occupiedCount: occupied,
        totalCount: total,
        isTablet: isTablet,
        onTap: () {
          con.goToUserCoachReservePage(
            coachId: relatedCoaches.first.id ?? '',
            classTime: schedule.start_time ?? '00:00:00',
            coachName: relatedCoaches.first.user?.name ?? '',
            classTheme: theme,
          );
        },
        heroTag: '${relatedCoaches.first.id}_${schedule.date}_${schedule.start_time}',
      );
    });
  }

  String _formatTime(String? time) {
    if (time == null) return '';
    final parts = time.split(':');
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }
}

// -----------------------------------------------------------------------------
// Animated avatar para 2 coaches (flip cada 3s)
// -----------------------------------------------------------------------------
class PremiumAnimatedAvatar extends StatefulWidget {
  final List<Coach> coaches;
  final bool isTablet;
  final double size;

  const PremiumAnimatedAvatar({
    super.key,
    required this.coaches,
    required this.isTablet,
    required this.size,
  });

  @override
  State<PremiumAnimatedAvatar> createState() => _PremiumAnimatedAvatarState();
}

class _PremiumAnimatedAvatarState extends State<PremiumAnimatedAvatar> {
  bool _flipped = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 3000), _swapAvatarsLoop);
  }

  void _swapAvatarsLoop() {
    if (!mounted) return;
    setState(() {
      _flipped = !_flipped;
    });
    Future.delayed(const Duration(milliseconds: 3000), _swapAvatarsLoop);
  }

  @override
  Widget build(BuildContext context) {
    final overlap = widget.size * 0.3;
    final coaches = widget.coaches.take(2).toList();

    if (coaches.length == 1) {
      final c = coaches.first;
      final url = c.user?.photo_url ?? '';
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: widget.size,
          height: widget.size,
          color: Colors.grey.shade100,
          child: url.isNotEmpty
              ? Image.network(url, fit: BoxFit.cover)
              : Icon(Icons.person, size: widget.size * 0.55, color: Colors.grey.shade500),
        ),
      );
    }

    final firstCoach = _flipped ? coaches[1] : coaches[0];
    final secondCoach = _flipped ? coaches[0] : coaches[1];

    return SizedBox(
      width: widget.size + overlap,
      height: widget.size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: overlap,
            top: 0,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
              child: Container(
                key: ValueKey(secondCoach.id),
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 3,
                      offset: Offset(0, 2),
                    ),
                  ],
                  color: Colors.grey.shade200,
                ),
                child: (secondCoach.user?.photo_url ?? '').isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(secondCoach.user!.photo_url!, fit: BoxFit.cover),
                )
                    : Icon(Icons.person, size: widget.size * 0.55, color: Colors.grey.shade500),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
              child: Container(
                key: ValueKey(firstCoach.id),
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                  color: Colors.grey.shade100,
                ),
                child: (firstCoach.user?.photo_url ?? '').isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(firstCoach.user!.photo_url!, fit: BoxFit.cover),
                )
                    : Icon(Icons.person, size: widget.size * 0.55, color: Colors.grey.shade500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Animated card (acepta avatar Widget para 1 o 2 fotos)
// -----------------------------------------------------------------------------
class _AnimatedClassCard extends StatefulWidget {
  final Widget avatar;
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
    required this.avatar,
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
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _prettyDateFromHeroTag(String heroTag) {
    final parts = heroTag.split('_');
    if (parts.length >= 3) {
      final dateIso = parts[1];
      try {
        final d = DateTime.parse(dateIso);
        return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
      } catch (_) {
        return dateIso;
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.isTablet ? 640.0 : double.infinity;

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
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
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
                  widget.avatar,
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _prettyDateFromHeroTag(widget.heroTag),
                          style: TextStyle(
                            fontSize: widget.isTablet ? 14 : 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Hero(
                                tag: widget.heroTag,
                                flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
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
                                  widget.coachName,
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
}
