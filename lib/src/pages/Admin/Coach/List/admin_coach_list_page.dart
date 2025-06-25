import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../models/coach.dart';
import '../../../../widgets/no_data_widget.dart';
import 'admin_coach_list_controller.dart';

class AdminCoachListPage extends StatelessWidget {
  final AdminCoachListController con = Get.put(AdminCoachListController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteLight,
        foregroundColor: darkGrey,
        title: _textTitleAppbar(),
      ),
      floatingActionButton: _buttonAddCoach(context),
      body: Obx(() {
        if (con.coaches.isEmpty) {
          return Center(
              child: NoDataWidget(text: 'No hay coaches disponibles'));
        } else {
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: con.coaches.length,
            itemBuilder: (context, index) {
              final coach = con.coaches[index];
              return _cardCoach(context, coach);
            },
          );
        }
      }),
    );
  }

  Widget _textTitleAppbar() {
    return Text(
      'Coaches',
      style: GoogleFonts.montserrat(
        fontSize: 22,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _cardCoach(BuildContext context, Coach coach) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          color: color_background_box,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: coach.user?.photo_url != null
                  ? Image.network(
                      coach.user!.photo_url!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.person, size: 40),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${coach.user?.name ?? ''} ${coach.user?.lastname ?? ''}',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: almostBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    coach.description ?? 'Sin descripción',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    coach.hobby ?? 'Sin Hobby',
                    style: GoogleFonts.robotoCondensed(
                      fontSize: 14,
                      color: Colors.indigo,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'edit_data') {
                  con.goToUpdateCoachPage(coach);
                } else if (value == 'edit_schedule') {
                  con.goToUpdateCoachSchedulePage(coach);
                } else if (value == 'delete') {
                  con.deleteCoach(coach.id!);
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'edit_data',
                  child: Row(
                    children: [
                      Icon(Icons.person, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Editar datos'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit_schedule',
                  child: Row(
                    children: [
                      Icon(Icons.schedule, color: Colors.indigo),
                      SizedBox(width: 8),
                      Text('Editar horarios'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Eliminar'),
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
      backgroundColor: limeGreen,
      label: const Text('Añadir Coach'),
      icon: const Icon(Icons.add_outlined),
      onPressed: () => con.goToAdminCoachRegisterPage(),
    );
  }
}
