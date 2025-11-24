import 'package:amina_ec/src/pages/Admin/Services/Sponsor/List/admin_sponsor_list_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../models/sponsor.dart';
import '../../../../../utils/iconos.dart';
import '../../../../../widgets/no_data_widget.dart';

class AdminSponsorListPage extends StatelessWidget {
  final AdminSponsorListController con = Get.put(AdminSponsorListController());

  AdminSponsorListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: indigoAmina,
        onPressed: () => Get.toNamed('/admin/sponsors/create'),
        child: const Icon(iconAdd, color: Colors.white),
      ),
      body: Obx(() {
        if (con.sponsors.isEmpty) {
          return Center(child: NoDataWidget(text: 'No hay beneficios disponibles'));
        } else {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            itemCount: con.sponsors.length,
            itemBuilder: (context, index) {
              final sponsor = con.sponsors[index];
              return _cardSponsor(context, sponsor);
            },
          );
        }
      }),
    );
  }

  Widget _cardSponsor(BuildContext context, Sponsor sponsor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Dismissible(
          key: Key(sponsor.id.toString()),
          background: _slideActionLeft(),
          secondaryBackground: _slideActionRight(),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              // EDITAR
              Get.toNamed('/admin/sponsors/update', arguments: {'sponsor': sponsor});
              return false; // No cerrar el dismiss
            } else if (direction == DismissDirection.endToStart) {
              // ELIMINAR
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Confirmar eliminación'),
                  content: const Text(
                    '¿Deseas eliminar este beneficio?',
                    style: TextStyle(color: almostBlack),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar')),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Eliminar')),
                  ],
                ),
              );

              if (confirm == true) {
                con.deleteSponsor(sponsor.id!);
                return true;
              }
              return false;
            }
            return false;
          },
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            shadowColor: const Color.fromARGB(50, 128, 128, 128),
            child: Container(
              decoration: BoxDecoration(
                color: colorBackgroundBox,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: sponsor.image != null
                        ? Image.network(
                      sponsor.image!,
                      width: 75,
                      height: 75,
                      fit: BoxFit.cover,
                    )
                        : Container(
                      width: 75,
                      height: 75,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 40),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sponsor.name ?? 'Sin nombre',
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: almostBlack,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          sponsor.description ?? 'Sin descripción',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Prioridad: ${sponsor.priority ?? 3}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
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

  Widget _slideActionLeft() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: indigoAmina,
      child: const Row(
        children: [
          Icon(iconEdit, color: Colors.white),
          SizedBox(width: 8),
          Text('Editar',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _slideActionRight() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: darkGrey,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(iconEraser, color: Colors.white),
          SizedBox(width: 8),
          Text('Eliminar',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
