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
  final selectedDay = ''.obs; // ✅ Nuevo filtro: día del mes

  final List<String> years = List.generate(6, (i) => (2025 + i).toString());
  final List<String> months = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  final transactions = <TransactionReport>[].obs;
  final totalAmount = 0.0.obs;

  final TransactionProvider _provider = TransactionProvider();

  /// 🔍 Buscar transacciones
  void buscar() async {
    print('==============================');
    print('🚀 Iniciando búsqueda de transacciones...');

    String? monthParam;
    if (selectedMonth.value.isNotEmpty) {
      final idx = months.indexOf(selectedMonth.value);
      if (idx >= 0) monthParam = (idx + 1).toString();
    }

    String? yearParam = selectedYear.value.isNotEmpty ? selectedYear.value : null;
    String? dayParam = selectedDay.value.isNotEmpty ? selectedDay.value : null;

    print('📆 Filtros: Año=$yearParam | Mes=$monthParam | Día=$dayParam');

    final results = await _provider.getReport(month: monthParam, year: yearParam);

    print('📊 Transacciones obtenidas del servidor: ${results.length}');

    // 🔹 Filtro adicional por día (solo si se selecciona un día)
    List<TransactionReport> filtered = results;
    if (dayParam != null && dayParam.isNotEmpty) {
      try {
        final int dayInt = int.parse(dayParam);
        filtered = results.where((tx) => tx.fecha.day == dayInt).toList();
        print('📅 Filtradas por día $dayInt → ${filtered.length} resultados');
      } catch (e) {
        print('⚠️ Error al filtrar por día: $e');
      }
    }

    for (var i = 0; i < filtered.length; i++) {
      final tx = filtered[i];
      print(
          '🧾 [$i] ${tx.name} ${tx.lastname} | CI: ${tx.ci} | Fecha: ${tx.fecha} | Total: ${tx.total}');
    }

    transactions.assignAll(filtered);
    totalAmount.value = filtered.fold(0.0, (sum, item) => sum + item.total);

    print('💰 Total calculado: ${totalAmount.value}');
    print('==============================');
  }

  /// ✅ Generar PDF
  Future<File> generatePDF() async {
    print('📄 Generando PDF...');
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.TableHelper.fromTextArray(
            headers: [
              'Fecha', 'Estudiante', 'Cédula', 'Email', 'Subtotal', 'IVA', 'Total'
            ],
            data: transactions.map((tx) {
              return [
                DateFormat('dd/MM/yyyy').format(tx.fecha),
                '${tx.name} ${tx.lastname}',
                tx.ci,
                tx.email,
                tx.subtotal.toStringAsFixed(2),
                tx.iva.toStringAsFixed(2),
                tx.total.toStringAsFixed(2),
              ];
            }).toList(),
          );
        },
      ),
    );

    Directory dir;
    if (Platform.isAndroid) {
      final status = await Permission.manageExternalStorage.request();
      dir = status.isGranted
          ? Directory('/storage/emulated/0/Download')
          : await getApplicationDocumentsDirectory();
    } else {
      dir = await getApplicationDocumentsDirectory();
    }

    final file = File('${dir.path}/reporte_transacciones.pdf');
    await file.writeAsBytes(await pdf.save(), flush: true);
    print('✅ PDF generado en: ${file.path}');
    return file;
  }

  /// 📤 Exportar PDF
  Future<void> exportPDF(BuildContext context) async {
    print('📤 Exportando PDF...');
    final box = context.findRenderObject() as RenderBox?;
    final shareRect =
    box != null ? (box.localToGlobal(Offset.zero) & box.size) : null;
    final file = await generatePDF();

    final params = ShareParams(
      files: [XFile(file.path)],
      text: 'Reporte de Transacciones',
      sharePositionOrigin: shareRect,
    );

    try {
      await SharePlus.instance.share(params);
      print('📨 PDF compartido correctamente.');
    } catch (e) {
      print('⚠️ Error compartiendo PDF: $e');
      Get.snackbar('Exportación', 'Archivo guardado en: ${file.path}');
    }
  }

  /// ✅ Generar Excel
  Future<void> exportExcel(BuildContext context) async {
    print('📊 Generando Excel...');
    final excel = Excel.createExcel();
    final sheet = excel['Reporte'];

    sheet.appendRow([
      TextCellValue('Fecha'),
      TextCellValue('Estudiante'),
      TextCellValue('Cédula'),
      TextCellValue('Email'),
      TextCellValue('Subtotal'),
      TextCellValue('IVA'),
      TextCellValue('Total'),
    ]);

    for (var tx in transactions) {
      sheet.appendRow([
        TextCellValue(DateFormat('dd/MM/yyyy').format(tx.fecha)),
        TextCellValue('${tx.name} ${tx.lastname}'),
        TextCellValue(tx.ci),
        TextCellValue(tx.email),
        DoubleCellValue(tx.subtotal),
        DoubleCellValue(tx.iva),
        DoubleCellValue(tx.total),
      ]);
    }

    final bytes = excel.encode();
    if (bytes == null) {
      print('❌ Error: bytes nulos en exportación Excel.');
      return;
    }

    Directory dir;
    if (Platform.isAndroid) {
      final status = await Permission.manageExternalStorage.request();
      dir = status.isGranted
          ? Directory('/storage/emulated/0/Download')
          : await getApplicationDocumentsDirectory();
    } else {
      dir = await getApplicationDocumentsDirectory();
    }

    final file = File('${dir.path}/reporte_transacciones.xlsx');
    await file.writeAsBytes(bytes, flush: true);
    print('✅ Excel generado en: ${file.path}');

    if (Platform.isIOS) {
      final box = context.findRenderObject() as RenderBox?;
      final shareRect =
      box != null ? (box.localToGlobal(Offset.zero) & box.size) : null;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Reporte de Transacciones',
          sharePositionOrigin: shareRect,
        ),
      );
    } else {
      Get.snackbar('Excel generado', 'Archivo guardado en: ${file.path}');
    }
  }
}
