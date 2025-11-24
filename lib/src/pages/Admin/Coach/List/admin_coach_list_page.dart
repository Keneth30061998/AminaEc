import 'package:amina_ec/src/utils/color.dart';
import 'package:amina_ec/src/utils/iconos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../models/coach.dart';
import '../../../../providers/notifications_provider.dart';
import '../../../../widgets/no_data_widget.dart';
import 'admin_coach_list_controller.dart';

class AdminCoachListPage extends StatelessWidget {
  final AdminCoachListController con = Get.put(AdminCoachListController());
  final NotificationsProvider _notificationsProvider = NotificationsProvider();

  AdminCoachListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteLight,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: whiteLight,
        foregroundColor: darkGrey,
        title: _appBarTitle()
            .animate()
            .fade(duration: 400.ms)
            .slideY(begin: 0.3),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilledButton.tonalIcon(
              onPressed: () => _openGlobalNotificationDialog(context),
              icon: Icon(iconInfo, color: whiteLight),
              label: Text('Notificación', style: TextStyle(color: whiteLight)),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(indigoAmina),
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: _bottomAddCoachBar(),

      body: Obx(() {
        return RefreshIndicator(
          onRefresh: () async => await con.refreshCoaches(),
          child: con.coaches.isEmpty
              ? Center(
            child: NoDataWidget(text: 'No hay coaches disponibles')
                .animate()
                .fade(duration: 500.ms)
                .slideY(begin: 0.2),
          )
              : ListView.builder(
            padding:
            const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            itemCount: con.coaches.length,
            itemBuilder: (context, index) {
              final coach = con.coaches[index];
              return _cardCoach(context, coach)
                  .animate(delay: const Duration(milliseconds: 100))
                  .fade()
                  .slideY(begin: 0.2);
            },
          ),
        );
      }),
    );
  }

  Widget _appBarTitle() {
    return Text(
      'Coaches',
      style: GoogleFonts.montserrat(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        color: almostBlack,
      ),
    );
  }

  Widget _cardCoach(BuildContext context, Coach coach) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        decoration: BoxDecoration(
          color: colorBackgroundBox,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: coach.user?.photo_url != null
                  ? Image.network(
                coach.user!.photo_url!,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              )
                  : Container(
                width: 70,
                height: 70,
                color: Colors.grey[300],
                child: Icon(iconProfile, size: 36),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                coach.user?.name ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: almostBlack,
                ),
              ),
            ),
            PopupMenuButton<String>(
              color: whiteLight,
              icon: const Icon(iconMore, color: darkGrey),
              onSelected: (value) {
                if (value == 'edit_data') {
                  con.goToUpdateCoachPage(coach);
                } else if (value == 'edit_schedule') {
                  con.goToUpdateCoachSchedulePage(coach);
                } else if (value == 'toggle_state') {
                  final newState = coach.state == 1 ? 0 : 1;
                  con.toggleCoachState(coach.id!, newState);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit_data',
                  child: Row(
                    children: [
                      Icon(iconProfile, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Editar datos'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit_schedule',
                  child: Row(
                    children: [
                      Icon(iconSchedule, color: indigoAmina),
                      SizedBox(width: 8),
                      Text('Editar horarios'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'toggle_state',
                  child: Row(
                    children: [
                      Icon(Icons.power_settings_new,
                          color: coach.state == 1 ? Colors.red : Colors.green),
                      SizedBox(width: 8),
                      Text(coach.state == 1 ? 'Desactivar' : 'Reactivar'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomAddCoachBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: whiteLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 0),
          )
        ],
      ),
      child: SafeArea(
        child: ElevatedButton.icon(
          onPressed: () => con.goToAdminCoachRegisterPage(),
          icon: const Icon(iconAdd),
          label: Text(
            'Añadir Coach',
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
