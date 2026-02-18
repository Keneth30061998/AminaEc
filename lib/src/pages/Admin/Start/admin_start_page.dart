import 'package:amina_ec/src/utils/color.dart';
import 'package:amina_ec/src/utils/iconos.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../providers/notifications_provider.dart';
import '../../../widgets/no_data_widget.dart';
import 'admin_start_controller.dart';
import '../../../widgets/student_attendance_card.dart';

class AdminStartPage extends StatelessWidget {
  final AdminStartController con = Get.put(AdminStartController());
  final NotificationsProvider _notificationsProvider = NotificationsProvider();

  AdminStartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (con.coaches.isEmpty) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const NoDataWidget(text: 'No hay Horarios disponibles'),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 110),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      color: almostBlack,
                      backgroundColor: colorBackgroundBox,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return DefaultTabController(
        length: con.coaches.length,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            titleSpacing: 16,
            title: _appBarTitle(),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: FilledButton.tonalIcon(
                  onPressed: () => _openGlobalNotificationDialog(context),
                  icon: Icon(iconNotification, color: almostBlack, size: 18),
                  label: Text(
                    'Notify',
                    style: GoogleFonts.poppins(
                      color: almostBlack,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor:
                    MaterialStateProperty.all(colorBackgroundBox),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(52),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TabBar(
                  isScrollable: true,
                  dividerColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  indicator: BoxDecoration(
                    color: colorBackgroundBox,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  indicatorPadding: const EdgeInsets.symmetric(vertical: 8),
                  labelColor: almostBlack,
                  unselectedLabelColor: Colors.black54,
                  labelStyle:
                  GoogleFonts.poppins(fontWeight: FontWeight.w700),
                  unselectedLabelStyle:
                  GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  onTap: (index) {
                    final id = con.coaches[index].id;
                    if (id != null) con.selectCoach(id);
                  },
                  tabs: List.generate(
                    con.coaches.length,
                        (index) => Tab(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(con.coaches[index].user?.name ?? ''),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ✅ FIX: RefreshIndicator siempre funciona incluso si NO hay inscritos
          // porque el child ahora es un scrollable (CustomScrollView) con
          // AlwaysScrollableScrollPhysics.
          body: TabBarView(
            children: con.coaches.map((coach) {
              final coachId = coach.id!;
              return RefreshIndicator(
                color: almostBlack,
                onRefresh: () => con.refreshAll(),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    const SliverToBoxAdapter(child: SizedBox(height: 10)),
                    SliverToBoxAdapter(child: _dateSelector(con, coachId)),
                    const SliverToBoxAdapter(child: SizedBox(height: 8)),
                    SliverFillRemaining(
                      hasScrollBody: true,
                      child: Obx(() {
                        final selectedDate =
                            con.selectedDatePerCoach[coachId]?.value ??
                                con.today;

                        return StudentAttendanceCard(
                          coachId: coachId,
                          date: selectedDate,
                        );
                      }),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      );
    });
  }

  Widget _appBarTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Administrador',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: almostBlack,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Control de asistencia',
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            fontWeight: FontWeight.w400,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _dateSelector(AdminStartController con, String coachId) {
    final dates = con.generateDateRange();

    return Obx(() {
      final selectedDate = con.selectedDatePerCoach[coachId]?.value ?? con.today;

      bool sameDay(DateTime a, DateTime b) =>
          DateFormat('yyyy-MM-dd').format(a) ==
              DateFormat('yyyy-MM-dd').format(b);

      return SizedBox(
        height: 78,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          scrollDirection: Axis.horizontal,
          itemCount: dates.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, index) {
            final date = dates[index];
            final isSelected = sameDay(date, selectedDate);
            final isToday = sameDay(date, con.today);

            final dayName =
            DateFormat.E('es_ES').format(date).toUpperCase(); // LUN
            final dayNum = date.day.toString();

            return InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => con.selectDateForCoach(coachId, date),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                width: 62,
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? almostBlack : colorBackgroundBox,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : Colors.black.withOpacity(isToday ? .18 : .08),
                    width: isToday ? 1.2 : 1,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: Colors.black.withOpacity(.12),
                        blurRadius: 16,
                        offset: const Offset(0, 10),
                      ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dayName,
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        letterSpacing: .6,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    Text(
                      dayNum,
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: isSelected ? Colors.white : almostBlack,
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 6,
                      width: 6,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white
                            : (isToday ? almostBlack : Colors.black26),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  void _openGlobalNotificationDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController messageController = TextEditingController();
    String selectedEmoji = "";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enviar Notificación',
                      style: GoogleFonts.poppins(
                        color: almostBlack,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Título + emoji y el mensaje.',
                      style: GoogleFonts.poppins(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: titleController,
                            style: GoogleFonts.poppins(),
                            decoration: InputDecoration(
                              labelText: "Título",
                              labelStyle:
                              GoogleFonts.poppins(color: Colors.black54),
                              prefixIcon:
                              const Icon(Icons.title, color: almostBlack),
                              filled: true,
                              fillColor: colorBackgroundBox,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        DropdownButton<String>(
                          value: selectedEmoji.isNotEmpty ? selectedEmoji : null,
                          hint: const Text("Emoji"),
                          underline: const SizedBox.shrink(),
                          items: [
                            "🔴",
                            "🟠",
                            "🟡",
                            "🟢",
                            "⏱️",
                            "🚴‍♂️",
                            "🚨",
                            "⏳",
                            "🎵"
                          ].map((e) {
                            return DropdownMenuItem(
                              value: e,
                              child: Text(e,
                                  style:
                                  GoogleFonts.poppins(fontSize: 24)),
                            );
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => selectedEmoji = value ?? ""),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: messageController,
                      maxLines: 3,
                      style: GoogleFonts.poppins(),
                      decoration: InputDecoration(
                        labelText: "Mensaje",
                        labelStyle: GoogleFonts.poppins(color: Colors.black54),
                        prefixIcon: const Icon(Icons.message_rounded,
                            color: almostBlack),
                        filled: true,
                        fillColor: colorBackgroundBox,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "Cancelar",
                            style: GoogleFonts.poppins(
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () async {
                            String title = titleController.text.trim();
                            String message = messageController.text.trim();

                            if (title.isEmpty || selectedEmoji.isEmpty) {
                              Get.snackbar(
                                'Error',
                                'Debe ingresar un título y elegir un emoji',
                                backgroundColor: Colors.white,
                                colorText: Colors.redAccent,
                              );
                              return;
                            }

                            final finalTitle = "$title $selectedEmoji";
                            final res = await _notificationsProvider
                                .sendGlobalNotification(finalTitle, message);

                            if (res["success"] == true) {
                              Get.snackbar(
                                'Éxito 🎉',
                                'Notificación enviada correctamente',
                                backgroundColor: Colors.white,
                                colorText: Colors.green,
                              );
                              Navigator.pop(context);
                            } else {
                              Get.snackbar(
                                'Error',
                                res["message"] ??
                                    "No se pudo enviar la notificación",
                                backgroundColor: Colors.white,
                                colorText: Colors.redAccent,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: almostBlack,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            "Enviar",
                            style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
