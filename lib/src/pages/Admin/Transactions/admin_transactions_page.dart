
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../utils/color.dart';
import '../../../utils/iconos.dart';
import '../../../utils/textos.dart';
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
    txCon = Get.put(AdminTransactionsController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de Transacciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => txCon.exportPDF(context),
            tooltip: 'Exportar PDF',
          ),
          IconButton(
            icon: const Icon(Icons.grid_on),
            onPressed: () => txCon.exportExcel(context),
            tooltip: 'Exportar Excel',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _yearDropdown()),
                const SizedBox(width: 10),
                Expanded(child: _monthDropdown()),
              ],
            ),
            const SizedBox(height: 16),
            _searchButton(),
            const SizedBox(height: 16),
            Expanded(child: _tableTransactions()),
            Obx(() => Text(
              'Total: \$${txCon.totalAmount.value.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            )),
          ],
        ),
      ),
    );
  }

  Widget _yearDropdown() {
    return Obx(() => DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: txCon.selectedYear.value.isEmpty ? null : txCon.selectedYear.value,
      items: txCon.years.map((year) => DropdownMenuItem(
        value: year,
        child: Text(year),
      )).toList(),
      onChanged: (value) => txCon.selectedYear.value = value ?? '',
      decoration: const InputDecoration(
        labelText: 'Año',
        prefixIcon: Icon(iconSchedule),
        border: OutlineInputBorder(),
      ),
    ));
  }

  Widget _monthDropdown() {
    return Obx(() => DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: txCon.selectedMonth.value.isEmpty ? null : txCon.selectedMonth.value,
      items: txCon.months.map((month) => DropdownMenuItem(
        value: month,
        child: Text(month),
      )).toList(),
      onChanged: (value) => txCon.selectedMonth.value = value ?? '',
      decoration: const InputDecoration(
        labelText: 'Mes',
        prefixIcon: Icon(iconSchedule),
        border: OutlineInputBorder(),
      ),
    ));
  }

  Widget _searchButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: txCon.buscar,
        icon: const Icon(iconSearch),
        label: const Text(txtSearch),
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(almostBlack),
          foregroundColor: WidgetStatePropertyAll(whiteLight)
          
        ),
      ),
    );
  }

  Widget _tableTransactions() {
    return Obx(() {
      if (txCon.transactions.isEmpty) {
        return Center(
          child: Text(
            'No hay resultados',
            style: GoogleFonts.montserrat(color: almostBlack),
          ),
        );
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Fecha')),
            DataColumn(label: Text('Estudiante')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Subtotal')),
            DataColumn(label: Text('IVA')),
            DataColumn(label: Text('Total')),
          ],
          rows: txCon.transactions.map((tx) => DataRow(cells: [
            DataCell(Text(DateFormat('dd/MM/yyyy').format(tx.fecha),
                style: GoogleFonts.montserrat(color: almostBlack))),
            DataCell(Text('${tx.name} ${tx.lastname}',
                style: GoogleFonts.montserrat(color: almostBlack))),
            DataCell(Text(tx.email,
                style: GoogleFonts.montserrat(color: almostBlack))),
            DataCell(Text('\$${tx.subtotal.toStringAsFixed(2)}',
                style: GoogleFonts.montserrat(color: almostBlack))),
            DataCell(Text('\$${tx.iva.toStringAsFixed(2)}',
                style: GoogleFonts.montserrat(color: almostBlack))),
            DataCell(Text('\$${tx.total.toStringAsFixed(2)}',
                style: GoogleFonts.montserrat(color: almostBlack))),
          ])).toList(),
        ),
      );
    });
  }
}
