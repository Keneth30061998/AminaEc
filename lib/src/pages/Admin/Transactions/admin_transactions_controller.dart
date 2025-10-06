import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../../models/transaction_report.dart';
import '../../../providers/transaction_provider.dart';

class AdminTransactionsController extends GetxController {
  final selectedYear = ''.obs;
  final selectedMonth = ''.obs;

  final List<String> years = List.generate(6, (i) => (2025 + i).toString());
  final List<String> months = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  final transactions = <TransactionReport>[].obs;
  final totalAmount = 0.0.obs;

  final TransactionProvider _provider = TransactionProvider();

  /// Buscar transacciones según mes/año seleccionados
  void buscar() async {
    String? monthParam;
    if (selectedMonth.value.isNotEmpty) {
      final idx = months.indexOf(selectedMonth.value);
      if (idx >= 0) monthParam = (idx + 1).toString();
    }

    String? yearParam = selectedYear.value.isNotEmpty ? selectedYear.value : null;

    final results = await _provider.getReport(
      month: monthParam,
      year: yearParam,
    );

    transactions.value = results;
    totalAmount.value = results.fold(0.0, (sum, item) => sum + item.total);
  }

  /// Genera PDF y devuelve el File
  Future<File> generatePDF() async {
    final pdf = pw.Document();


    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.TableHelper.fromTextArray(
            headers: ['Fecha', 'Estudiante', 'Email', 'Subtotal', 'IVA', 'Total'],
            data: transactions.map((tx) => [
              '${tx.fecha.day}/${tx.fecha.month}/${tx.fecha.year}',
              '${tx.name} ${tx.lastname}',
              tx.email,
              tx.subtotal.toStringAsFixed(2),
              tx.iva.toStringAsFixed(2),
              tx.total.toStringAsFixed(2),
            ]).toList(),
          );
        },
      ),
    );

    final dir = Platform.isAndroid
        ? (await getExternalStorageDirectory())!
        : await getApplicationDocumentsDirectory();

    final file = File('${dir.path}/reporte_transacciones.pdf');
    await file.writeAsBytes(await pdf.save(), flush: true);

    return file;
  }

  /// Exportar PDF y compartir (iOS)
  Future<void> exportPDF(BuildContext context) async {
    final file = await generatePDF();

    if (Platform.isIOS) {
      final box = context.findRenderObject() as RenderBox?;
      if (box != null) {
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Reporte de Transacciones',
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
        );
      } else {
        await Share.shareXFiles([XFile(file.path)], text: 'Reporte de Transacciones');
      }
    } else {
      Get.snackbar('PDF generado', 'Archivo guardado en: ${file.path}');
    }
  }

  /// Exportar Excel
  Future<void> exportExcel() async {
    final excel = Excel.createExcel();
    final sheet = excel['Reporte'];

    // Encabezados
    sheet.appendRow([
      TextCellValue('Fecha'),
      TextCellValue('Estudiante'),
      TextCellValue('Email'),
      TextCellValue('Subtotal'),
      TextCellValue('IVA'),
      TextCellValue('Total'),
    ]);

    // Filas de datos
    for (var tx in transactions) {
      sheet.appendRow([
        TextCellValue(DateFormat('dd/MM/yyyy').format(tx.fecha)),
        TextCellValue('${tx.name} ${tx.lastname}'),
        TextCellValue(tx.email),
        DoubleCellValue(tx.subtotal),
        DoubleCellValue(tx.iva),
        DoubleCellValue(tx.total),
      ]);
    }

    final bytes = excel.encode();
    if (bytes == null) return;

    // Directorio según plataforma
    Directory dir;
    if (Platform.isAndroid) {
      dir = (await getExternalStorageDirectory())!;
    } else {
      dir = await getApplicationDocumentsDirectory();
    }

    final file = File('${dir.path}/reporte_transacciones.xlsx');
    await file.writeAsBytes(bytes, flush: true);

    Get.snackbar('Excel generado', 'Archivo guardado en: ${file.path}');
  }
}
