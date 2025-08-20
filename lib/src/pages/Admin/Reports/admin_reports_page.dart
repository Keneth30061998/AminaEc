import 'package:amina_ec/src/pages/Admin/Reports/admin_reports_controller.dart';
import 'package:amina_ec/src/utils/iconos.dart';
import 'package:amina_ec/src/utils/textos.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/color.dart';

final con = Get.put(AdminReportsController());

class AdminReportsPage extends StatelessWidget {
  const AdminReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _appBarTitle(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Campo de nombre
              TextField(
                onChanged: (value) => con.name.value = value,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(icon_profile),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Filtros de año y mes
              Row(
                children: [
                  Expanded(
                    child: Obx(() => DropdownButtonFormField<String>(
                          value: con.selectedYear.value.isEmpty
                              ? null
                              : con.selectedYear.value,
                          items: con.years.map((year) {
                            return DropdownMenuItem(
                              value: year,
                              child: Text(year),
                            );
                          }).toList(),
                          onChanged: (value) =>
                              con.selectedYear.value = value ?? '',
                          decoration: const InputDecoration(
                            labelText: 'Año',
                            prefixIcon: Icon(icon_schedule),
                            border: OutlineInputBorder(),
                          ),
                        )),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Obx(() => DropdownButtonFormField<String>(
                          value: con.selectedMonth.value.isEmpty
                              ? null
                              : con.selectedMonth.value,
                          items: con.months.map((month) {
                            return DropdownMenuItem(
                              value: month,
                              child: Text(month),
                            );
                          }).toList(),
                          onChanged: (value) =>
                              con.selectedMonth.value = value ?? '',
                          decoration: const InputDecoration(
                            labelText: 'Mes',
                            prefixIcon: Icon(icon_schedule),
                            border: OutlineInputBorder(),
                          ),
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Botón de búsqueda
              _buttonSearch(),

              const SizedBox(height: 24),

              // Resultados
              Obx(() {
                if (con.attendanceResults.isEmpty) {
                  return const Text('No hay resultados');
                }

                return Column(
                  children: [
                    Text(
                      'Resultados',
                      style: GoogleFonts.montserrat(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    _buildTable(),
                    const SizedBox(height: 20),
                    _buildChart(),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appBarTitle() {
    return Text(
      'Reporte de clases',
      style: GoogleFonts.montserrat(
        fontSize: 22,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buttonSearch() {
    return SizedBox(
      width: 200,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () => con.buscar(),
        style: ElevatedButton.styleFrom(
          backgroundColor: almostBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 4,
        ),
        icon: Icon(
          icon_search,
          color: whiteLight,
        ),
        label: const Text(
          txt_search,
          style: TextStyle(
            color: whiteLight,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Fecha')),
          DataColumn(label: Text('Estudiante')),
          DataColumn(label: Text('Coach')),
          DataColumn(label: Text('Bicicleta')),
          DataColumn(label: Text('Estado')),
        ],
        rows: con.attendanceResults.map((r) {
          return DataRow(cells: [
            DataCell(Text(
              r.classDate,
              style: TextStyle(color: almostBlack),
            )),
            DataCell(Text(r.userName, style: TextStyle(color: almostBlack))),
            DataCell(Text(r.coachName, style: TextStyle(color: almostBlack))),
            DataCell(Text(r.bicycle.toString(),
                style: TextStyle(color: almostBlack))),
            DataCell(Text(
              r.status == 'present' ? '✅ Presente' : '❌ Ausente',
              style: TextStyle(
                color: r.status == 'present' ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            )),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildChart() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _chartBox('Presentes', con.presentCount.value, Colors.green),
        const SizedBox(width: 20),
        _chartBox('Ausentes', con.absentCount.value, Colors.red),
      ],
    );
  }

  Widget _chartBox(String label, int count, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$count',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
