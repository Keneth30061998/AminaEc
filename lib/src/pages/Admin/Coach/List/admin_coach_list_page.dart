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
        backgroundColor: darkGrey,
        foregroundColor: limeGreen,
        title: _texttitleAppbar(),
      ),
      floatingActionButton: _buttonAddCoach(context),
      body: Obx(() {
        if (con.coaches.isEmpty) {
          return Center(
              child: NoDataWidget(text: 'No hay coaches disponibles'));
        } else {
          return ListView.builder(
            itemCount: con.coaches.length,
            itemBuilder: (context, index) {
              final coach = con.coaches[index];
              return _cardCoach(coach);
            },
          );
        }
      }),
    );
  }

  Widget _texttitleAppbar() {
    return Text(
      'Coachs',
      style: GoogleFonts.montserrat(
        fontSize: 22,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _cardCoach(Coach coach) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 5,
      child: ListTile(
        leading: coach.user?.photo_url != null
            ? Image.network(coach.user!.photo_url!,
                width: 60, height: 60, fit: BoxFit.cover)
            : const Icon(Icons.person),
        title: Text('${coach.user?.name ?? ''} ${coach.user?.lastname ?? ''}'),
        subtitle: Text(coach.hobby ?? 'Sin hobby'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              // Ir a la página de edición
              // Navigator.pushNamed(context, '/admin/plan/edit', arguments: plan);
              print('Editando plan');
            } else if (value == 'delete') {
              //con.deletePlan(plan.id!);
              print('Eliminando coach: ');
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Text('Editar'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Eliminar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buttonAddCoach(BuildContext context) {
    return FloatingActionButton.extended(
      backgroundColor: limeGreen,
      label: Text('Añadir Coach'),
      icon: Icon(Icons.add_outlined),
      onPressed: () => con.goToAdminCoachRegisterPage(),
    );
  }
}
