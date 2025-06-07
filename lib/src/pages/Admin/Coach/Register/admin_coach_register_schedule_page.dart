import 'package:amina_ec/src/pages/Admin/Coach/Register/admin_coach_register_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminCoachRegisterSchedulePage extends StatelessWidget {
  AdminCoachRegisterController con = Get.put(AdminCoachRegisterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Horario Semanal'),
        backgroundColor: darkGrey,
        foregroundColor: limeGreen,
      ),
      body: GetBuilder<AdminCoachRegisterController>(
        builder: (_) => SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Table(
                border: TableBorder.all(color: Colors.grey),
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(3),
                  2: FlexColumnWidth(3),
                  3: FlexColumnWidth(1.5),
                },
                children: [
                  // Cabecera
                  TableRow(
                    decoration: BoxDecoration(color: limeGreen),
                    children: [
                      _celdaTitulo('Día'),
                      _celdaTitulo('Hora Entrada'),
                      _celdaTitulo('Hora Salida'),
                      _celdaTitulo('Estado'),
                    ],
                  ),
                  // Filas para cada día
                  for (var dia in con.dias)
                    TableRow(
                      children: [
                        _celdaTexto(dia),
                        _celdaHora(dia, 'entrada', context),
                        _celdaHora(dia, 'salida', context),
                        _celdaCheckbox(dia),
                      ],
                    ),
                ],
              ),
              _buttonRegister(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _celdaTitulo(String text) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Text(text,
          style: TextStyle(color: almostBlack, fontWeight: FontWeight.bold)),
    );
  }

  Widget _celdaTexto(String text) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _celdaHora(String dia, String tipo, BuildContext context) {
    return GestureDetector(
      onTap: () => con.seleccionarHora(tipo, dia, context),
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(8),
        child: Text(
          tipo == 'entrada'
              ? con.formatHora(con.horaEntrada[dia])
              : con.formatHora(con.horaSalida[dia]),
          style: TextStyle(color: limeGreen, fontSize: 16),
        ),
      ),
    );
  }

  Widget _celdaCheckbox(String dia) {
    return Center(
      child: Checkbox(
        value: con.estadoDia[dia] ?? false,
        onChanged: (value) {
          con.estadoDia[dia] = value!;
          con.update();
        },
      ),
    );
  }

  Widget _buttonRegister(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      width: double.infinity,
      child: FloatingActionButton.extended(
        onPressed: () {
          con.registerCoach(context);
        },
        label: Text(
          'Registrar',
          style: TextStyle(fontSize: 16, color: almostBlack),
        ),
        icon: Icon(
          Icons.save,
          color: almostBlack,
        ),
        backgroundColor: limeGreen,
      ),
    );
  }
}
