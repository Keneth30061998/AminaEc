import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../utils/color.dart';
import '../../../../utils/iconos.dart';
import '../../../../utils/textos.dart';
import 'admin_transactions_controller.dart';

class AdminTransactionsPage extends StatefulWidget {
  const AdminTransactionsPage({super.key});

  @override
  State<AdminTransactionsPage> createState() => _AdminTransactionsPageState();
}

class _AdminTransactionsPageState extends State<AdminTransactionsPage> {
  late AdminTransactionsController txCon;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<AdminTransactionsController>()) {
      txCon = Get.put(AdminTransactionsController(), permanent: true);
    } else {
      txCon = Get.find<AdminTransactionsController>();
    }
  }

  @override
  void dispose() {
    if (Get.isRegistered<AdminTransactionsController>()) {
      Get.delete<AdminTransactionsController>(force: true);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Reporte de Transacciones',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: almostBlack,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: darkGrey),
            onPressed: () => txCon.exportPDF(context),
            tooltip: 'Exportar PDF',
          ),
          IconButton(
            icon: const Icon(Icons.grid_on, color: darkGrey),
            onPressed: () => txCon.exportExcel(context),
            tooltip: 'Exportar Excel',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16,),
        child: Column(
          children: [
            _filterSection(context),
            const SizedBox(height: 5),
            Expanded(child: _transactionsTableCard()),
            _totalFooter(),
          ],
        ),
      ),
    );
  }

  /// 🔹 Filtros: Año y Mes
  Widget _filterSection(BuildContext context) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _modernSelector(
                    label: "Año",
                    value: txCon.selectedYear,
                    icon: Icons.calendar_today_outlined,
                    items: txCon.years,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _modernSelector(
                    label: "Mes",
                    value: txCon.selectedMonth,
                    icon: Icons.event_note_outlined,
                    items: txCon.months,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: 300,
              child: ElevatedButton.icon(
                onPressed: txCon.buscar,
                icon: Icon(iconSearch, color: whiteLight,),
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

  /// 🔸 Selector visual moderno (solo texto reactivo)
  Widget _modernSelector({
    required String label,
    required RxString value,
    required IconData icon,
    required List<String> items,
  }) {
    return InkWell(
      onTap: () async {
        final selected = await showDialog<String>(
          context: context,
          builder: (_) => _simpleListDialog(
            title: "Seleccionar $label" ,
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
                          color: value.value.isEmpty
                              ? almostBlack
                              : almostBlack,
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
  Widget _transactionsTableCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Obx(() {
          if (txCon.transactions.isEmpty) {
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
                    DataColumn(label: Text('Cédula')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Subtotal')),
                    DataColumn(label: Text('IVA')),
                    DataColumn(label: Text('Total')),
                  ],
                  rows: txCon.transactions.map((tx) {
                    return DataRow(
                      cells: [
                        DataCell(
                            Text(DateFormat('dd/MM/yyyy').format(tx.fecha))),
                        DataCell(Text('${tx.name} ${tx.lastname}')),
                        DataCell(Text(tx.ci)),
                        DataCell(Text(tx.email)),
                        DataCell(Text('\$${tx.subtotal.toStringAsFixed(2)}')),
                        DataCell(Text('\$${tx.iva.toStringAsFixed(2)}')),
                        DataCell(Text('\$${tx.total.toStringAsFixed(2)}')),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// 🔹 Footer
  Widget _totalFooter() {
    return Obx(() => Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: almostBlack,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Total general: \$${txCon.totalAmount.value.toStringAsFixed(2)}',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ));
  }
}
