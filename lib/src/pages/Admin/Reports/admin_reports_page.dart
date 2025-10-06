import 'package:amina_ec/src/pages/Admin/Reports/admin_reports_controller.dart';
import 'package:amina_ec/src/utils/iconos.dart';
import 'package:amina_ec/src/utils/textos.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

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
                  prefixIcon: Icon(iconProfile),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Filtros de año y mes (responsive)
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 400) {
                    // 📱 Pantallas pequeñas → Columna
                    return Column(
                      children: [
                        Obx(() => DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: con.selectedYear.value.isEmpty
                                  ? null
                                  : con.selectedYear.value,
                              items: con.years.map((year) {
                                return DropdownMenuItem(
                                  value: year,
                                  child: Text(
                                    year,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) =>
                                  con.selectedYear.value = value ?? '',
                              decoration: const InputDecoration(
                                labelText: 'Año',
                                prefixIcon: Icon(iconSchedule),
                                border: OutlineInputBorder(),
                              ),
                            )),
                        const SizedBox(height: 10),
                        Obx(() => DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: con.selectedMonth.value.isEmpty
                                  ? null
                                  : con.selectedMonth.value,
                              items: con.months.map((month) {
                                return DropdownMenuItem(
                                  value: month,
                                  child: Text(
                                    month,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) =>
                                  con.selectedMonth.value = value ?? '',
                              decoration: const InputDecoration(
                                labelText: 'Mes',
                                prefixIcon: Icon(iconSchedule),
                                border: OutlineInputBorder(),
                              ),
                            )),
                      ],
                    );
                  } else {
                    // 💻 Pantallas grandes → Fila
                    return Row(
                      children: [
                        Expanded(
                          child: Obx(() => DropdownButtonFormField<String>(
                                isExpanded: true,
                                initialValue: con.selectedYear.value.isEmpty
                                    ? null
                                    : con.selectedYear.value,
                                items: con.years.map((year) {
                                  return DropdownMenuItem(
                                    value: year,
                                    child: Text(
                                      year,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) =>
                                    con.selectedYear.value = value ?? '',
                                decoration: const InputDecoration(
                                  labelText: 'Año',
                                  prefixIcon: Icon(iconSchedule),
                                  border: OutlineInputBorder(),
                                ),
                              )),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Obx(() => DropdownButtonFormField<String>(
                                isExpanded: true,
                                initialValue: con.selectedMonth.value.isEmpty
                                    ? null
                                    : con.selectedMonth.value,
                                items: con.months.map((month) {
                                  return DropdownMenuItem(
                                    value: month,
                                    child: Text(
                                      month,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) =>
                                    con.selectedMonth.value = value ?? '',
                                decoration: const InputDecoration(
                                  labelText: 'Mes',
                                  prefixIcon: Icon(iconSchedule),
                                  border: OutlineInputBorder(),
                                ),
                              )),
                        ),
                      ],
                    );
                  }
                },
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
          iconSearch,
          color: whiteLight,
        ),
        label: const Text(
          txtSearch,
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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
          headingTextStyle: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: almostBlack,
          ),
          dataTextStyle: GoogleFonts.montserrat(
            fontSize: 14,
            color: almostBlack,
          ),
          columnSpacing: 20,
          horizontalMargin: 12,
          dividerThickness: 0.7,
          columns: const [
            DataColumn(label: Text('Fecha')),
            DataColumn(label: Text('Estudiante')),
            DataColumn(label: Text('Coach')),
            DataColumn(label: Text('Bicicleta')),
            DataColumn(label: Text('Estado')),
          ],
          rows: con.attendanceResults.map((r) {
            return DataRow(
              color: WidgetStateProperty.resolveWith<Color?>(
                (states) {
                  int index = con.attendanceResults.indexOf(r);
                  return index.isEven ? Colors.white : Colors.grey.shade50;
                },
              ),
              cells: [
                DataCell(Text(
                  DateFormat('dd/MM/yyyy', 'es_ES')
                      .format(DateTime.parse(r.classDate)),
                )),
                DataCell(Text(r.userName)),
                DataCell(Text(r.coachName)),
                DataCell(Text(r.bicycle.toString())),
                DataCell(
                  Text(
                    r.status == 'present' ? '✅ Presente' : '❌ Ausente',
                    style: TextStyle(
                      color: r.status == 'present' ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
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
