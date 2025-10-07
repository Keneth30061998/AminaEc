import 'package:amina_ec/src/utils/color.dart';
import 'package:amina_ec/src/utils/iconos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../models/coach.dart';
import '../../../../widgets/no_data_widget.dart';
import 'admin_coach_list_controller.dart';

class AdminCoachListPage extends StatelessWidget {
  final AdminCoachListController con = Get.put(AdminCoachListController());

  AdminCoachListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteLight,
      appBar: AppBar(
        backgroundColor: whiteLight,
        foregroundColor: darkGrey,
        title:
            _appBarTitle().animate().fade(duration: 400.ms).slideY(begin: 0.3),
        elevation: 0,
      ),
      floatingActionButton: _buttonAddCoach(context),
      body: Obx(() {
        if (con.coaches.isEmpty) {
          return Center(
            child: NoDataWidget(text: 'No hay coaches disponibles')
                .animate()
                .fade(duration: 500.ms)
                .slideY(begin: 0.2),
          );
        } else {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            itemCount: con.coaches.length,
            itemBuilder: (context, index) {
              final coach = con.coaches[index];
              return _cardCoach(context, coach)
                  .animate(delay: Duration(milliseconds: 100))
                  .fade()
                  .slideY(begin: 0.2);
            },
          );
        }
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coach.user?.name ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: almostBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            const SizedBox(width: 8),
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
                  //con.deleteCoach(coach.id!);
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
                      Icon(coach.state == 1 ? Icons.block : Icons.check, color: coach.state == 1 ? Colors.red : Colors.green),
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

  Widget _buttonAddCoach(BuildContext context) {
    return FloatingActionButton.extended(
      backgroundColor: almostBlack,
      foregroundColor: whiteLight,
      label: Text(
        'Añadir Coach',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
        ),
      ),
      icon: const Icon(iconAdd),
      onPressed: () => con.goToAdminCoachRegisterPage(),
    );
  }
}
