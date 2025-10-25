import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../models/transaction_report.dart';
import '../../../../providers/transaction_provider.dart';



class AdminTransactionsController extends GetxController {
  final selectedYear = ''.obs;
  final selectedMonth = ''.obs;

  final List<String> years = List.generate(6, (i) => (2025 + i).toString());
  final List<String> months = [
    'Enero','Febrero','Marzo','Abril','Mayo','Junio',
    'Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'
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

    Directory dir;
    if (Platform.isAndroid) {
      final status = await Permission.manageExternalStorage.request();
      if (status.isGranted) {
        dir = Directory('/storage/emulated/0/Download');
      } else {
        dir = await getApplicationDocumentsDirectory();
      }
    } else {
      dir = await getApplicationDocumentsDirectory();
    }

    final file = File('${dir.path}/reporte_transacciones.pdf');
    await file.writeAsBytes(await pdf.save(), flush: true);
    return file;
  }

  /// Exportar PDF
  Future<void> exportPDF(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    final shareRect = box != null ? (box.localToGlobal(Offset.zero) & box.size) : null;

    final file = await generatePDF();

    final params = ShareParams(
      files: [XFile(file.path)],
      text: 'Reporte de Transacciones',
      sharePositionOrigin: shareRect,
    );

    try {
      await SharePlus.instance.share(params);
    } catch (e) {
      Get.snackbar(
        'Exportación',
        'Archivo guardado en: ${file.path}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Exportar Excel (funciona en Android y iOS)
  Future<void> exportExcel(BuildContext context) async {
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

    // Filas
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

    Directory dir;
    if (Platform.isAndroid) {
      final status = await Permission.manageExternalStorage.request();
      if (status.isGranted) {
        dir = Directory('/storage/emulated/0/Download');
      } else {
        dir = await getApplicationDocumentsDirectory();
      }
    } else {
      dir = await getApplicationDocumentsDirectory();
    }

    final file = File('${dir.path}/reporte_transacciones.xlsx');
    await file.writeAsBytes(bytes, flush: true);

    if (Platform.isIOS) {
      // En iOS compartimos el archivo para que el usuario pueda guardarlo
      final box = context.findRenderObject() as RenderBox?;
      final shareRect = box != null ? (box.localToGlobal(Offset.zero) & box.size) : null;

      final params = ShareParams(
        files: [XFile(file.path)],
        text: 'Reporte de Transacciones',
        sharePositionOrigin: shareRect,
      );

      try {
        await SharePlus.instance.share(params);
      } catch (_) {
        Get.snackbar(
          'Exportación',
          'Archivo guardado en: ${file.path}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } else {
      Get.snackbar(
        'Excel generado',
        'Archivo guardado en: ${file.path}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
