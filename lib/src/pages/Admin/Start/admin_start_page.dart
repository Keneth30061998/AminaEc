import 'package:amina_ec/src/utils/color.dart';
import 'package:amina_ec/src/utils/iconos.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../providers/notifications_provider.dart';
import '../../../widgets/no_data_widget.dart';
import 'admin_start_controller.dart';

class AdminStartPage extends StatelessWidget {
  final AdminStartController con = Get.put(AdminStartController());
  final NotificationsProvider _notificationsProvider = NotificationsProvider();
  AdminStartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (con.coaches.isEmpty) {
        return Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const NoDataWidget(text: 'No hay Horarios disponibles'),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 125),
                child: LinearProgressIndicator(
                  color: almostBlack,
                  backgroundColor: colorBackgroundBox,
                ),
              ),
            ],
          ),
        );
      }

      return DefaultTabController(
        length: con.coaches.length,
        child: Scaffold(
          appBar: AppBar(
            title: _appBarTitle(),
            centerTitle: false,
            actions: [
              Padding(
                padding:  EdgeInsets.symmetric(horizontal: 5),
                child: FilledButton.tonalIcon(
                  onPressed: () => _openGlobalNotificationDialog(context),
                  icon: Icon(iconNotification, color: whiteLight),
                  label: Text('Notify', style: TextStyle(color: whiteLight)),
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(indigoAmina),
                  ),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: TabBar(
                isScrollable: true,
                indicatorColor: almostBlack,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.black54,
                // ✅ Actualiza el coach activo al cambiar de pestaña
                onTap: (index) {
                  final id = con.coaches[index].id;
                  if (id != null) con.selectCoach(id);
                },
                tabs: List.generate(
                  con.coaches.length,
                      (index) => Tab(
                    child: Text(con.coaches[index].user?.name ?? ''),
                  ),
                ),
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: TabBarView(
              children: con.coaches.map((coach) {
                final coachId = coach.id!;
                final selectedDate =
                    con.selectedDatePerCoach[coachId]?.value ?? con.today;
                final students =
                con.getStudentsByCoachAndDate(coachId, selectedDate);

                return RefreshIndicator(
                  onRefresh: () => con.refreshAll(),
                  child: ListView(
                    padding: const EdgeInsets.only(top: 10),
                    children: [
                      _dateSelector(con, coachId),
                      const SizedBox(height: 30),
                      if (students.isEmpty)
                        const NoDataWidget(text: 'No hay estudiantes inscritos')
                      else
                        ...students.map((s) {
                          final timeFormatted = s.classTime.substring(0, 5);
                          final key = con.getStudentKey(s);
                          return Obx(() {
                            final isPresent =
                                con.attendanceMap[key]?.value ?? false;
                            return Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                leading: CircleAvatar(
                                  radius: 24,
                                  backgroundImage:
                                  NetworkImage(s.photo_url ?? ''),
                                ),
                                title: Text(
                                  s.studentName,
                                  style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  'Hora: $timeFormatted  |  Máquina: ${s.bicycle}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                                trailing: Checkbox(
                                  value: isPresent,
                                  onChanged: (value) {
                                    con.attendanceMap[key]?.value = value!;
                                  },
                                ),
                              ),
                            );
                          });
                        }).toList()
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          bottomNavigationBar: _bottomRegisterBar(),
        ),
      );
    });
  }

  Widget _appBarTitle() {
    return Text(
      'Administrador',
      style: GoogleFonts.montserrat(
        fontSize: 22,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _dateSelector(AdminStartController con, String coachId) {
    final dates = con.generateDateRange();

    return Obx(() {
      final selectedDate =
          (con.selectedDatePerCoach[coachId])?.value ?? con.today;

      return SizedBox(
        height: 72,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: dates.length,
          itemBuilder: (_, index) {
            final date = dates[index];
            final isSelected = DateFormat('yyyy-MM-dd').format(date) ==
                DateFormat('yyyy-MM-dd').format(selectedDate);

            return GestureDetector(
              onTap: () => con.selectDateForCoach(coachId, date),
              child: Container(
                width: 80,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected ? almostBlack : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat.E('es_ES').format(date),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      date.day.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black87,
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

  Widget _bottomRegisterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: SafeArea(
        child: ElevatedButton.icon(
          onPressed: () => con.confirmAttendanceRegister(),
          icon: Icon(iconCheck),
          label: Text(
            'Registrar Asistencia',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: almostBlack,
            foregroundColor: whiteLight,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  // ======== NUEVO SELECTOR DE EMOJI ========
  Widget _EmojiSelector({
    required String selectedEmoji,
    required Function(String) onSelect,
  }) {
    final emojis = ["🔴","🟠","🟡","🟢","⏱️","🚴‍♂️","🚨","⏳", "🎵"];

    return DropdownButton<String>(
      value: selectedEmoji.isNotEmpty ? selectedEmoji : null,
      hint: const Text("Emoji"),
      items: emojis.map((e) {
        return DropdownMenuItem(
          value: e,
          child: Text(e, style: GoogleFonts.poppins(fontSize: 26)),
        );
      }).toList(),
      onChanged: (value) => onSelect(value!),
    );
  }
  // ==========================================

  void _openGlobalNotificationDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController messageController = TextEditingController();

    String selectedEmoji = ""; // 👈 nuevo estado local sólo del diálogo

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: whiteLight,
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enviar Notificación',
                      style: GoogleFonts.poppins(
                        color: almostBlack,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      'Redacta el título, selecciona un emoji y escribe el mensaje.',
                      style: GoogleFonts.poppins(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ====== CAMPO TÍTULO + EMOJI ======
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
                              const Icon(Icons.title, color: Colors.black),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                const BorderSide(color: Colors.black),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _EmojiSelector(
                          selectedEmoji: selectedEmoji,
                          onSelect: (e) {
                            setState(() => selectedEmoji = e);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: messageController,
                      maxLines: 3,
                      style: GoogleFonts.poppins(),
                      decoration: InputDecoration(
                        labelText: "Mensaje",
                        labelStyle: GoogleFonts.poppins(color: Colors.black54),
                        prefixIcon: const Icon(Icons.message_rounded,
                            color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 18, horizontal: 16),
                      ),
                    ),

                    const SizedBox(height: 25),

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
                            foregroundColor: whiteLight,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 26, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Enviar",
                            style: GoogleFonts.poppins(fontSize: 16),
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
