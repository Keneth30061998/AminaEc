import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../utils/color.dart';
import 'admin_coach_update_schedule_controller.dart';

class AdminCoachUpdateSchedulePage extends StatelessWidget {
  final AdminCoachUpdateScheduleController con =
      Get.put(AdminCoachUpdateScheduleController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Horario',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w800)),
        backgroundColor: whiteLight,
        foregroundColor: darkGrey,
      ),
      backgroundColor: Colors.white,
      body: GetBuilder<AdminCoachUpdateScheduleController>(
        builder: (_) => con.horariosPorDia.isEmpty
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    for (var dia in con.dias) _seccionDia(context, dia),
                    _buttonUpdate(context),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _seccionDia(BuildContext context, String dia) {
    return Card(
      color: color_background_box,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      elevation: 8,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dia,
                style: TextStyle(
                    color: darkGrey,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            ...List.generate(con.horariosPorDia[dia]!.length, (index) {
              final rango = con.horariosPorDia[dia]![index];
              return Row(
                children: [
                  _botonHora(context, dia, index, 'entrada', rango['entrada']),
                  SizedBox(width: 10),
                  _botonHora(context, dia, index, 'salida', rango['salida']),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => con.eliminarRango(dia, index),
                  ),
                ],
              );
            }),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => con.agregarRango(dia),
                icon: Icon(Icons.add, color: almostBlack),
                label:
                    Text('Añadir horario', style: TextStyle(color: darkGrey)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _botonHora(BuildContext context, String dia, int index, String tipo,
      TimeOfDay? hora) {
    return Expanded(
      child: GestureDetector(
        onTap: () => con.seleccionarHora(dia, index, tipo, context),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade500),
            borderRadius: BorderRadius.circular(5),
          ),
          alignment: Alignment.center,
          child: Text(
            con.formatHora(hora),
            style: TextStyle(fontSize: 16, color: darkGrey),
          ),
        ),
      ),
    );
  }

  Widget _buttonUpdate(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      width: double.infinity,
      child: FloatingActionButton.extended(
        onPressed: () => con.updateSchedule(context),
        label:
            Text('Guardar', style: TextStyle(fontSize: 16, color: almostBlack)),
        icon: Icon(Icons.save, color: almostBlack),
        backgroundColor: limeGreen,
      ),
    );
  }
}
