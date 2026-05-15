import 'dart:io';

import 'package:amina_ec/src/models/attendance_result.dart';
import 'package:amina_ec/src/providers/attendance_provider.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';

class AdminReportsController extends GetxController {
  final name = ''.obs;
  final selectedYear = ''.obs;
  final selectedMonth = ''.obs;
  final selectedDay = ''.obs;
  final startHour = ''.obs;
  final endHour = ''.obs;

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
    'Diciembre'
  ];
  final List<String> days = List.generate(31, (i) => (i + 1).toString());
  final List<String> hours =
  List.generate(24, (i) => '${i.toString().padLeft(2, '0')}:00');

  final attendanceResults = <AttendanceResult>[].obs;
  final presentCount = 0.obs;
  final absentCount = 0.obs;

  final AttendanceProvider _provider = AttendanceProvider();

  void buscar() async {
    final results = await _provider.findByFilters(
      username: name.value.trim().isNotEmpty ? name.value.trim() : null,
      year: selectedYear.value.isNotEmpty ? selectedYear.value : null,
      month: selectedMonth.value.isNotEmpty
          ? (months.indexOf(selectedMonth.value) + 1).toString()
          : null,
      day: selectedDay.value.isNotEmpty ? selectedDay.value : null,
      startHour: startHour.value.isNotEmpty ? startHour.value : null,
      endHour: endHour.value.isNotEmpty ? endHour.value : null,
    );

    attendanceResults.value = results;
    presentCount.value = results.where((r) => r.status == 'present').length;
    absentCount.value = results.where((r) => r.status == 'absent').length;
  }

  Future<File> generatePDF() async {
    print('📄 Generando PDF de asistencias...');
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        maxPages: 1000,
        build: (context) => [
          pw.Text(
            'Reporte de Asistencias',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.TableHelper.fromTextArray(
            headers: [
              'Fecha',
              'Estudiante',
              'Coach',
              'Bicicleta',
              'Estado',
            ],
            data: attendanceResults.map((r) {
              return [
                DateFormat('dd/MM/yyyy').format(DateTime.parse(r.classDate)),
                r.userName,
                r.coachName,
                r.bicycle.toString(),
                r.status == 'present' ? 'Presente' : 'Ausente',
              ];
            }).toList(),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
              fontSize: 10,
            ),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColors.grey800,
            ),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellAlignment: pw.Alignment.centerLeft,
            headerHeight: 24,
            cellHeight: 22,
          ),
        ],
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

    final file = File('${dir.path}/reporte_asistencias.pdf');
    await file.writeAsBytes(await pdf.save(), flush: true);
    print('✅ PDF generado en: ${file.path}');
    return file;
  }

  Future<void> exportPDF(BuildContext context) async {
    print('📤 Exportando PDF de asistencias...');
    final box = context.findRenderObject() as RenderBox?;
    final shareRect =
    box != null ? (box.localToGlobal(Offset.zero) & box.size) : null;

    final file = await generatePDF();

    final params = ShareParams(
      files: [XFile(file.path)],
      text: 'Reporte de Asistencias',
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

  Future<void> exportExcel(BuildContext context) async {
    print('📊 Generando Excel de asistencias...');
    final excel = Excel.createExcel();
    final sheet = excel['Reporte'];

    sheet.appendRow([
      TextCellValue('Fecha'),
      TextCellValue('Estudiante'),
      TextCellValue('Coach'),
      TextCellValue('Bicicleta'),
      TextCellValue('Estado'),
    ]);

    for (var r in attendanceResults) {
      sheet.appendRow([
        TextCellValue(
          DateFormat('dd/MM/yyyy').format(DateTime.parse(r.classDate)),
        ),
        TextCellValue(r.userName),
        TextCellValue(r.coachName),
        TextCellValue(r.bicycle.toString()),
        TextCellValue(r.status == 'present' ? 'Presente' : 'Ausente'),
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

    final file = File('${dir.path}/reporte_asistencias.xlsx');
    await file.writeAsBytes(bytes, flush: true);
    print('✅ Excel generado en: ${file.path}');

    if (Platform.isIOS) {
      final box = context.findRenderObject() as RenderBox?;
      final shareRect =
      box != null ? (box.localToGlobal(Offset.zero) & box.size) : null;

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Reporte de Asistencias',
          sharePositionOrigin: shareRect,
        ),
      );
    } else {
      Get.snackbar('Excel generado', 'Archivo guardado en: ${file.path}');
    }
  }
}