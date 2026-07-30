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
                padding: const EdgeInsets.only(right: 6),
                child: IconButton.filledTonal(
                  tooltip: 'Banner del inicio',
                  onPressed: () =>
                      _openBannerManager(context),
                  icon: const Icon(
                    Icons.campaign_outlined,
                    size: 21,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: colorBackgroundBox,
                    foregroundColor: almostBlack,
                  ),
                ),
              ),
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

  Future<void> _openBannerManager(
      BuildContext context,
      ) async {
    await con.loadAppBanner(showError: true);

    if (!context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (
              modalContext,
              setModalState,
              ) {
            void refreshPreview() {
              setModalState(() {});
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalContext)
                    .viewInsets
                    .bottom,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight:
                  MediaQuery.of(modalContext)
                      .size
                      .height *
                      0.92,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    14,
                    20,
                    28,
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 48,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius:
                            BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        'Banner del inicio',
                        style: GoogleFonts.montserrat(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: almostBlack,
                        ),
                      ),
                      const SizedBox(height: 5),

                      Text(
                        'Configura el aviso fijo que aparecerá en el Home de los usuarios.',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          height: 1.4,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Obx(
                            () => Container(
                          decoration: BoxDecoration(
                            color: colorBackgroundBox,
                            borderRadius:
                            BorderRadius.circular(16),
                          ),
                          child: SwitchListTile.adaptive(
                            value:
                            con.bannerActive.value,
                            activeColor: almostBlack,
                            title: Text(
                              con.bannerActive.value
                                  ? 'Banner activo'
                                  : 'Banner desactivado',
                              style:
                              GoogleFonts.poppins(
                                fontWeight:
                                FontWeight.w700,
                                color: almostBlack,
                              ),
                            ),
                            subtitle: Text(
                              con.bannerActive.value
                                  ? 'Los usuarios pueden verlo en su pantalla de inicio.'
                                  : 'El contenido queda guardado, pero no se muestra.',
                              style:
                              GoogleFonts.roboto(
                                fontSize: 12.5,
                                color: Colors.black54,
                              ),
                            ),
                            onChanged: (value) {
                              con.bannerActive.value =
                                  value;

                              refreshPreview();
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller:
                        con.bannerTitleController,
                        maxLength: 120,
                        onChanged: (_) =>
                            refreshPreview(),
                        style: GoogleFonts.poppins(),
                        decoration:
                        _bannerInputDecoration(
                          label: 'Título',
                          hint:
                          'Ej. Información importante',
                          icon:
                          Icons.title_rounded,
                        ),
                      ),
                      const SizedBox(height: 8),

                      TextField(
                        controller:
                        con.bannerMessageController,
                        maxLength: 500,
                        minLines: 3,
                        maxLines: 5,
                        onChanged: (_) =>
                            refreshPreview(),
                        style: GoogleFonts.poppins(),
                        decoration:
                        _bannerInputDecoration(
                          label: 'Mensaje',
                          hint:
                          'Escribe el contenido que verá el usuario.',
                          icon: Icons
                              .subject_rounded,
                        ),
                      ),
                      const SizedBox(height: 8),

                      TextField(
                        controller:
                        con.bannerLinkTextController,
                        maxLength: 60,
                        onChanged: (_) =>
                            refreshPreview(),
                        style: GoogleFonts.poppins(),
                        decoration:
                        _bannerInputDecoration(
                          label:
                          'Texto del enlace (opcional)',
                          hint:
                          'Ej. Conoce más',
                          icon: Icons
                              .short_text_rounded,
                        ),
                      ),
                      const SizedBox(height: 8),

                      TextField(
                        controller:
                        con.bannerLinkUrlController,
                        keyboardType:
                        TextInputType.url,
                        autocorrect: false,
                        onChanged: (_) =>
                            refreshPreview(),
                        style: GoogleFonts.poppins(),
                        decoration:
                        _bannerInputDecoration(
                          label:
                          'Enlace web (opcional)',
                          hint:
                          'https://ejemplo.com',
                          icon:
                          Icons.link_rounded,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        'Vista previa',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight:
                          FontWeight.w700,
                          color: almostBlack,
                        ),
                      ),
                      const SizedBox(height: 10),

                      _adminBannerPreview(),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.of(
                                  sheetContext,
                                ).pop();
                              },
                              style:
                              OutlinedButton.styleFrom(
                                foregroundColor:
                                almostBlack,
                                side: const BorderSide(
                                  color:
                                  Colors.black12,
                                ),
                                padding:
                                const EdgeInsets
                                    .symmetric(
                                  vertical: 15,
                                ),
                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius
                                      .circular(15),
                                ),
                              ),
                              child: Text(
                                'Cancelar',
                                style:
                                GoogleFonts.poppins(
                                  fontWeight:
                                  FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Obx(
                                  () => FilledButton(
                                onPressed: con
                                    .isBannerSaving
                                    .value
                                    ? null
                                    : () async {
                                  final saved =
                                  await con
                                      .saveAppBanner();

                                  if (saved &&
                                      sheetContext
                                          .mounted) {
                                    Navigator.of(
                                      sheetContext,
                                    ).pop();
                                  }
                                },
                                style:
                                FilledButton.styleFrom(
                                  backgroundColor:
                                  almostBlack,
                                  foregroundColor:
                                  Colors.white,
                                  disabledBackgroundColor:
                                  Colors.black26,
                                  padding:
                                  const EdgeInsets
                                      .symmetric(
                                    vertical: 15,
                                  ),
                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius
                                        .circular(15),
                                  ),
                                ),
                                child: con
                                    .isBannerSaving
                                    .value
                                    ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                  CircularProgressIndicator(
                                    strokeWidth:
                                    2.5,
                                    color:
                                    Colors.white,
                                  ),
                                )
                                    : Text(
                                  'Guardar',
                                  style:
                                  GoogleFonts
                                      .poppins(
                                    fontWeight:
                                    FontWeight
                                        .w700,
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
              ),
            );
          },
        );
      },
    );
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

  InputDecoration _bannerInputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: almostBlack,
      ),
      filled: true,
      fillColor: colorBackgroundBox,
      counterStyle: GoogleFonts.roboto(
        fontSize: 11,
        color: Colors.black45,
      ),
      labelStyle: GoogleFonts.poppins(
        color: Colors.black54,
      ),
      hintStyle: GoogleFonts.roboto(
        color: Colors.black38,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: almostBlack,
          width: 1.2,
        ),
      ),
    );
  }

  Widget _adminBannerPreview() {
    final title =
    con.bannerTitleController.text.trim();

    final message =
    con.bannerMessageController.text.trim();

    final linkText =
    con.bannerLinkTextController.text.trim();

    final linkUrl =
    con.bannerLinkUrlController.text.trim();

    final hasLink = linkUrl.isNotEmpty;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity:
      con.bannerActive.value ? 1 : 0.55,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.black.withOpacity(0.06),
          ),
          boxShadow: [
            BoxShadow(
              color:
              Colors.black.withOpacity(0.035),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color:
                indigoAmina.withOpacity(0.09),
                borderRadius:
                BorderRadius.circular(13),
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                color: indigoAmina,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title.isEmpty
                        ? 'Título del banner'
                        : title,
                    style: GoogleFonts.montserrat(
                      fontSize: 14.5,
                      fontWeight:
                      FontWeight.w700,
                      color: almostBlack,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    message.isEmpty
                        ? 'Aquí se mostrará el mensaje para los usuarios.'
                        : message,
                    maxLines: 4,
                    overflow:
                    TextOverflow.ellipsis,
                    style: GoogleFonts.roboto(
                      fontSize: 13.5,
                      height: 1.42,
                      color:
                      Colors.grey.shade700,
                    ),
                  ),
                  if (hasLink) ...[
                    const SizedBox(height: 7),
                    Row(
                      mainAxisSize:
                      MainAxisSize.min,
                      children: [
                        Text(
                          linkText.isEmpty
                              ? 'Ver más'
                              : linkText,
                          style: GoogleFonts.roboto(
                            fontSize: 13,
                            fontWeight:
                            FontWeight.w700,
                            color: indigoAmina,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.open_in_new_rounded,
                          size: 15,
                          color: indigoAmina,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
