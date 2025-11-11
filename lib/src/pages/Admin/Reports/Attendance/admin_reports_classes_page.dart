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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text('Asistencia', style: GoogleFonts.montserrat(color: almostBlack, fontSize: 18, fontWeight: FontWeight.w900,),textAlign: TextAlign.center,),
            _filterSection(context),
            const SizedBox(height: 8),
            Expanded(child: _attendanceTableCard()),

          ],
        ),
      ),
    );
  }

  /// 🔹 Sección de filtros (nombre, año, mes)
  Widget _filterSection(BuildContext context) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        child: Column(
          children: [
            // Nombre
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                onChanged: (value) => con.name.value = value,
                decoration: InputDecoration(
                  icon: const Icon(iconProfile, color: darkGrey),
                  border: InputBorder.none,
                  labelText: 'Nombre del Estudiante',
                  labelStyle: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                style: GoogleFonts.montserrat(
                  color: almostBlack,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Año y mes
            Row(
              children: [
                Expanded(
                  child: _modernSelector(
                    label: "Año",
                    value: con.selectedYear,
                    icon: Icons.calendar_today_outlined,
                    items: con.years,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _modernSelector(
                    label: "Mes",
                    value: con.selectedMonth,
                    icon: Icons.event_note_outlined,
                    items: con.months,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Botón buscar
            SizedBox(
              width: 300,
              child: ElevatedButton.icon(
                onPressed: con.buscar,
                icon: Icon(iconSearch, color: whiteLight),
                label: Text(
                  'Buscar',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: almostBlack,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔸 Selector visual moderno (reutilizado del estilo de transacciones)
  Widget _modernSelector({
    required String label,
    required RxString value,
    required IconData icon,
    required List<String> items,
  }) {
    return InkWell(
      onTap: () async {
        final selected = await showDialog<String>(
          context: Get.context!,
          builder: (_) => _simpleListDialog(
            title: "Seleccionar $label",
            items: items,
            selected: value.value,
          ),
        );
        if (selected != null) value.value = selected;
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[700], size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.montserrat(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      )),
                  Obx(() => Text(
                    value.value.isEmpty ? "Seleccionar" : value.value,
                    style: GoogleFonts.poppins(
                      color: almostBlack,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  )),
                ],
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  /// 🔸 Modal simple reutilizable
  Widget _simpleListDialog({
    required String title,
    required List<String> items,
    required String selected,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: almostBlack,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final item = items[i];
                  final isSelected = item == selected;
                  return ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    title: Text(
                      item,
                      style: GoogleFonts.montserrat(
                        fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? almostBlack : Colors.grey[800],
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: almostBlack)
                        : null,
                    onTap: () => Get.back(result: item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Tabla estilizada
  Widget _attendanceTableCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Obx(() {
          if (con.attendanceResults.isEmpty) {
            return Center(
              child: Text(
                'No hay resultados',
                style: GoogleFonts.montserrat(
                  color: Colors.grey[700],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(almostBlack),
                  headingTextStyle: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  dataTextStyle: GoogleFonts.montserrat(
                    color: Colors.black87,
                    fontSize: 12,
                  ),
                  columnSpacing: 14,
                  columns: const [
                    DataColumn(label: Text('Fecha')),
                    DataColumn(label: Text('Estudiante')),
                    DataColumn(label: Text('Coach')),
                    DataColumn(label: Text('Bicicleta')),
                    DataColumn(label: Text('Estado')),
                  ],
                  rows: con.attendanceResults.map((r) {
                    return DataRow(cells: [
                      DataCell(Text(DateFormat('dd/MM/yyyy')
                          .format(DateTime.parse(r.classDate)))),
                      DataCell(Text(r.userName)),
                      DataCell(Text(r.coachName)),
                      DataCell(Text(r.bicycle.toString())),
                      DataCell(Text(
                        r.status == 'present'
                            ? '✅ Presente'
                            : '❌ Ausente',
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// 🔹 Footer con gráfico circular resumido

  Widget _chartBox(String label, int count, Color color) => Column(
    children: [
      Text(
        label,
        style: GoogleFonts.montserrat(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
      const SizedBox(height: 6),
      Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Center(
          child: Text(
            '$count',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    ],
  );
}
