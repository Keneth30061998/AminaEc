import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../utils/color.dart';
import '../../../../utils/iconos.dart';
import '../../../../utils/textos.dart';
import 'admin_reports_controller.dart';

final con = Get.put(AdminReportsController());

class AdminClassesTab extends StatelessWidget {
  const AdminClassesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            onChanged: (value) => con.name.value = value,
            decoration: const InputDecoration(
              labelText: 'Nombre',
              prefixIcon: Icon(iconProfile),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Obx(() => DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: con.selectedYear.value.isEmpty ? null : con.selectedYear.value,
                  items: con.years.map((year) => DropdownMenuItem(
                    value: year,
                    child: Text(year),
                  )).toList(),
                  onChanged: (value) => con.selectedYear.value = value ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Año',
                    prefixIcon: Icon(iconSchedule),
                    border: OutlineInputBorder(),
                  ),
                )),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Obx(() => DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: con.selectedMonth.value.isEmpty ? null : con.selectedMonth.value,
                  items: con.months.map((month) => DropdownMenuItem(
                    value: month,
                    child: Text(month),
                  )).toList(),
                  onChanged: (value) => con.selectedMonth.value = value ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Mes',
                    prefixIcon: Icon(iconSchedule),
                    border: OutlineInputBorder(),
                  ),
                )),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buttonSearch(),
          const SizedBox(height: 24),
          Obx(() {
            if (con.attendanceResults.isEmpty) return const Text('No hay resultados');

            return Column(
              children: [
                _buildTable(),
                const SizedBox(height: 20),
                _buildChart(),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buttonSearch() => SizedBox(
    width: 200,
    height: 50,
    child: ElevatedButton.icon(
      onPressed: con.buscar,
      icon: const Icon(iconSearch),
      label: const Text(txtSearch),
      style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(almostBlack),
          foregroundColor: WidgetStatePropertyAll(whiteLight)

      ),
    ),
  );

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
            DataCell(Text(DateFormat('dd/MM/yyyy').format(DateTime.parse(r.classDate)),style: GoogleFonts.montserrat(color: almostBlack))),
            DataCell(Text(r.userName,style: GoogleFonts.montserrat(color: almostBlack))),
            DataCell(Text(r.coachName,style: GoogleFonts.montserrat(color: almostBlack))),
            DataCell(Text(r.bicycle.toString(),style: GoogleFonts.montserrat(color: almostBlack))),
            DataCell(Text(r.status == 'present' ? '✅ Presente' : '❌ Ausente',style: GoogleFonts.montserrat(color: almostBlack))),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildChart() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _chartBox('Presentes', con.presentCount.value, Colors.green),
      const SizedBox(width: 20),
      _chartBox('Ausentes', con.absentCount.value, Colors.red),
    ],
  );

  Widget _chartBox(String label, int count, Color color) => Column(
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Center(
          child: Text('$count', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    ],
  );
}
