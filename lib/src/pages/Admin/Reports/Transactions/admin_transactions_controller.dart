import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
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
  final selectedDay = ''.obs;
  final selectedStatus = 'Todos'.obs;

  final List<String> years = List.generate(6, (i) => (2025 + i).toString());

  final List<String> months = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  final List<String> days = List.generate(31, (i) => (i + 1).toString());

  final List<String> statuses = [
    'Todos',
    'Aprobado',
    'Rechazado',
  ];

  final transactions = <TransactionReport>[].obs;

  final totalApprovedAmount = 0.0.obs;
  final totalTransactions = 0.obs;
  final approvedCount = 0.obs;
  final rejectedCount = 0.obs;
  final directCount = 0.obs;
  final deferredCount = 0.obs;

  final TransactionProvider _provider = TransactionProvider();

  String? _monthParam() {
    if (selectedMonth.value.isEmpty) return null;

    final idx = months.indexOf(selectedMonth.value);

    if (idx < 0) return null;

    return (idx + 1).toString();
  }

  String? _statusParam() {
    switch (selectedStatus.value) {
      case 'Aprobado':
        return 'approved';
      case 'Rechazado':
        return 'rejected';
      default:
        return null;
    }
  }

  void buscar() async {
    final results = await _provider.getReport(
      month: _monthParam(),
      year: selectedYear.value.isNotEmpty ? selectedYear.value : null,
      day: selectedDay.value.isNotEmpty ? selectedDay.value : null,
      status: _statusParam(),
    );

    transactions.assignAll(results);
    _calculateSummary();
  }

  void _calculateSummary() {
    totalTransactions.value = transactions.length;

    approvedCount.value = transactions.where((tx) => tx.isApproved).length;
    rejectedCount.value = transactions.where((tx) => tx.isRejected).length;

    directCount.value =
        transactions.where((tx) => tx.tipoPago == 'directo').length;

    deferredCount.value =
        transactions.where((tx) => tx.tipoPago == 'diferido').length;

    totalApprovedAmount.value = transactions
        .where((tx) => tx.isApproved)
        .fold(0.0, (sum, item) => sum + item.total);
  }

  String get filterResume {
    final parts = <String>[];

    if (selectedYear.value.isNotEmpty) {
      parts.add('Año: ${selectedYear.value}');
    }

    if (selectedMonth.value.isNotEmpty) {
      parts.add('Mes: ${selectedMonth.value}');
    }

    if (selectedDay.value.isNotEmpty) {
      parts.add('Día: ${selectedDay.value}');
    }

    if (selectedStatus.value != 'Todos') {
      parts.add('Estado: ${selectedStatus.value}');
    }

    return parts.isEmpty ? 'Sin filtros aplicados' : parts.join(' | ');
  }

  Future<Directory> _getExportDirectory() async {
    if (Platform.isAndroid) {
      final status = await Permission.manageExternalStorage.request();

      return status.isGranted
          ? Directory('/storage/emulated/0/Download')
          : await getApplicationDocumentsDirectory();
    }

    return await getApplicationDocumentsDirectory();
  }

  Future<File> generatePDF() async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(18),
        header: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Reporte de Transacciones',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                filterResume,
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.SizedBox(height: 8),
            ],
          );
        },
        footer: (context) {
          return pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Página ${context.pageNumber} de ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 8),
            ),
          );
        },
        build: (context) {
          return [
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _pdfSummaryItem(
                    'Total aprobado',
                    '\$${totalApprovedAmount.value.toStringAsFixed(2)}',
                  ),
                  _pdfSummaryItem(
                    'Transacciones',
                    totalTransactions.value.toString(),
                  ),
                  _pdfSummaryItem(
                    'Aprobadas',
                    approvedCount.value.toString(),
                  ),
                  _pdfSummaryItem(
                    'Rechazadas',
                    rejectedCount.value.toString(),
                  ),
                  _pdfSummaryItem(
                    'Directos',
                    directCount.value.toString(),
                  ),
                  _pdfSummaryItem(
                    'Diferidos',
                    deferredCount.value.toString(),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              headers: [
                'Fecha',
                'Usuario',
                'Cédula',
                'Email',
                'Plan',
                'Pago',
                'Cuotas',
                'Estado',
                'Referencia',
                'Banco',
                'Tarjeta',
                'Subtotal',
                'IVA',
                'Total',
              ],
              data: transactions.map((tx) {
                return [
                  dateFormat.format(tx.fecha),
                  tx.nombreCompleto,
                  tx.ci,
                  tx.email,
                  tx.planComprado,
                  tx.tipoPagoLabel,
                  tx.cuotasSolicitadas > 1
                      ? '${tx.cuotasSolicitadas} meses'
                      : 'Directo',
                  tx.estadoLabel,
                  tx.referenciaOrden,
                  tx.banco.isEmpty ? 'No identificado' : tx.banco,
                  tx.tipoTarjetaLabel,
                  tx.subtotal.toStringAsFixed(2),
                  tx.iva.toStringAsFixed(2),
                  tx.total.toStringAsFixed(2),
                ];
              }).toList(),
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 7,
                fontWeight: pw.FontWeight.bold,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey800,
              ),
              cellStyle: const pw.TextStyle(fontSize: 6),
              cellPadding: const pw.EdgeInsets.all(3),
              border: pw.TableBorder.all(
                color: PdfColors.grey300,
                width: 0.3,
              ),
            ),
          ];
        },
      ),
    );

    final dir = await _getExportDirectory();
    final file = File('${dir.path}/reporte_transacciones.pdf');

    await file.writeAsBytes(await pdf.save(), flush: true);

    return file;
  }

  pw.Widget _pdfSummaryItem(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(
            fontSize: 7,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Future<void> exportPDF(BuildContext context) async {
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
    } catch (e) {
      Get.snackbar(
        'PDF generado',
        'Archivo guardado en: ${file.path}',
      );
    }
  }

  Future<void> exportExcel(BuildContext context) async {
    final excel = Excel.createExcel();
    final sheet = excel['Reporte'];
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    sheet.appendRow([
      TextCellValue('Fecha y hora'),
      TextCellValue('Usuario'),
      TextCellValue('Cédula'),
      TextCellValue('Email'),
      TextCellValue('Plan comprado'),
      TextCellValue('Subtotal'),
      TextCellValue('IVA'),
      TextCellValue('Total'),
      TextCellValue('Tipo de pago'),
      TextCellValue('Cuotas solicitadas'),
      TextCellValue('Estado'),
      TextCellValue('Referencia orden'),
      TextCellValue('Banco'),
      TextCellValue('Tipo tarjeta'),
      TextCellValue('Marca tarjeta'),
      TextCellValue('Últimos 4 dígitos'),
    ]);

    for (var tx in transactions) {
      sheet.appendRow([
        TextCellValue(dateFormat.format(tx.fecha)),
        TextCellValue(tx.nombreCompleto),
        TextCellValue(tx.ci),
        TextCellValue(tx.email),
        TextCellValue(tx.planComprado),
        DoubleCellValue(tx.subtotal),
        DoubleCellValue(tx.iva),
        DoubleCellValue(tx.total),
        TextCellValue(tx.tipoPagoLabel),
        IntCellValue(tx.cuotasSolicitadas),
        TextCellValue(tx.estadoLabel),
        TextCellValue(tx.referenciaOrden),
        TextCellValue(tx.banco.isEmpty ? 'No identificado' : tx.banco),
        TextCellValue(tx.tipoTarjetaLabel),
        TextCellValue(tx.marcaTarjeta),
        TextCellValue(tx.tarjetaLast4),
      ]);
    }

    final bytes = excel.encode();

    if (bytes == null) {
      Get.snackbar(
        'Error',
        'No se pudo generar el archivo Excel',
      );
      return;
    }

    final dir = await _getExportDirectory();
    final file = File('${dir.path}/reporte_transacciones.xlsx');

    await file.writeAsBytes(bytes, flush: true);

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
      Get.snackbar(
        'Excel generado',
        'Archivo guardado en: ${file.path}',
      );
    }
  }
}