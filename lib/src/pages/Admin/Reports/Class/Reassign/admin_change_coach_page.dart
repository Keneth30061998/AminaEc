import 'package:amina_ec/src/models/coach.dart';
import 'package:amina_ec/src/pages/Admin/Reports/Class/Reassign/admin_change_coach_controller.dart';

import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminChangeCoachPage extends StatelessWidget {
  final con = Get.put(AdminChangeCoachController());

  AdminChangeCoachPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cambiar coach',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
        body: RefreshIndicator(
          color: indigoAmina,
          onRefresh: () async {
            await con.loadCoachesAndInferEndTime(); // recarga lista de coaches
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Obx(() {
              if (con.loadingCoaches.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _currentCoachCard(),
                  const SizedBox(height: 12),
                  Text('Seleccionar nuevo coach',
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w700, color: almostBlack)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: con.coaches.map((c) => _coachList(c)).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _reassignButton(context),
                ],
              );
            }),
          ),
        )

    );
  }

  Widget _currentCoachCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            const Icon(Icons.person_outline, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Coach actual',
                          style: GoogleFonts.montserrat(
                              fontSize: 12, color: Colors.grey[700])),
                      const SizedBox(height: 4),
                      Text(
                        con.oldCoachName.value.isNotEmpty
                            ? con.oldCoachName.value
                            : '—',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[850],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Fecha: ${con.classDate.value}  •  Hora: ${con.classTime.value.substring(0, 5)}',
                        style: GoogleFonts.montserrat(
                            fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _coachList(Coach c) {
    final bool isOld = c.id == con.oldCoachId.value;
    final bool isSelected = c.id == con.selectedCoachId.value;

    return InkWell(
      key: ValueKey(c.id),
      onTap: isOld ? null : () => con.selectCoach(c.id ?? ''),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[300] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOld
                ? Colors.grey.shade300
                : (isSelected ? Colors.grey.shade400 : Colors.grey.shade200),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: c.user?.photo_url != null
                  ? NetworkImage(c.user!.photo_url!)
                  : null,
              child: c.user?.photo_url == null
                  ? Text((c.user?.name ?? '?').substring(0, 1))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${c.user?.name ?? '—'} ${c.user?.lastname ?? ''}',
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600, color: almostBlack),
              ),
            ),
            if (isOld)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                    color: indigoAmina,
                    borderRadius: BorderRadius.circular(8)),
                child: Text('Actual',
                    style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white)),
              )
            else if (isSelected)
              const Icon(Icons.check_circle, color: Colors.green)
            else
              const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }



  Widget _reassignButton(BuildContext context) {
    return Obx(() => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                con.loading.value ? null : () => con.confirmAndSend(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: almostBlack,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: con.loading.value
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : Text('Reasignar coach',
                    style: GoogleFonts.montserrat(
                        color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ));
  }
}
