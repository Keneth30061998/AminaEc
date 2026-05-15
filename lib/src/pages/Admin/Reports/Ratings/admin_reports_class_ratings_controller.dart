import 'dart:io';

import 'package:amina_ec/src/models/class_rating_report.dart';
import 'package:amina_ec/src/models/response_api.dart';
import 'package:amina_ec/src/providers/class_rating_provider.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class AdminClassRatingsReportController extends GetxController {
  final studentNameController = TextEditingController();
  final coachNameController = TextEditingController();

  final selectedYear = ''.obs;
  final selectedMonth = ''.obs;
  final selectedDay = ''.obs;
  final startHour = ''.obs;
  final endHour = ''.obs;
  final selectedRating = ''.obs;
  final selectedCommentFilter = 'Todos'.obs;

  final isLoading = false.obs;

  final results = <ClassRatingReportResult>[].obs;
  final coachSummary = <CoachRatingSummary>[].obs;
  final summary = ClassRatingReportSummary.empty().obs;

  final ClassRatingProvider _provider = ClassRatingProvider();

  final List<String> years = List.generate(6, (i) => (2025 + i).toString());

  final List<String> months = const [
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

  final List<String> ratingOptions = const ['1', '2', '3', '4', '5'];
  final List<String> commentOptions = const [
    'Todos',
    'Solo con comentario',
    'Solo sin comentario',
  ];

  String? get _hasCommentParam {
    switch (selectedCommentFilter.value) {
      case 'Solo con comentario':
        return 'true';
      case 'Solo sin comentario':
        return 'false';
      default:
        return null;
    }
  }

  void limpiarFiltros() {
    studentNameController.clear();
    coachNameController.clear();
    selectedYear.value = '';
    selectedMonth.value = '';
    selectedDay.value = '';
    startHour.value = '';
    endHour.value = '';
    selectedRating.value = '';
    selectedCommentFilter.value = 'Todos';

    results.clear();
    coachSummary.clear();
    summary.value = ClassRatingReportSummary.empty();
  }

  Future<void> buscar() async {
    isLoading.value = true;

    final ResponseApi response = await _provider.findRatingsReport(
      studentName: studentNameController.text.trim().isEmpty
          ? null
          : studentNameController.text.trim(),
      coachName: coachNameController.text.trim().isEmpty
          ? null
          : coachNameController.text.trim(),
      year: selectedYear.value.isEmpty ? null : selectedYear.value,
      month: selectedMonth.value.isEmpty
          ? null
          : (months.indexOf(selectedMonth.value) + 1).toString(),
      day: selectedDay.value.isEmpty ? null : selectedDay.value,
      startHour: startHour.value.isEmpty ? null : startHour.value,
      endHour: endHour.value.isEmpty ? null : endHour.value,
      rating: selectedRating.value.isEmpty ? null : selectedRating.value,
      hasComment: _hasCommentParam,
    );

    isLoading.value = false;

    if (response.success == true && response.data != null) {
      final data = Map<String, dynamic>.from(response.data);

      final summaryJson =
      Map<String, dynamic>.from(data['summary'] ?? <String, dynamic>{});
      final resultList =
      List<Map<String, dynamic>>.from(data['results'] ?? const []);
      final coachList =
      List<Map<String, dynamic>>.from(data['coachSummary'] ?? const []);

      summary.value = ClassRatingReportSummary.fromJson(summaryJson);
      results.assignAll(
        resultList.map((e) => ClassRatingReportResult.fromJson(e)).toList(),
      );
      coachSummary.assignAll(
        coachList.map((e) => CoachRatingSummary.fromJson(e)).toList(),
      );
    } else {
      summary.value = ClassRatingReportSummary.empty();
      results.clear();
      coachSummary.clear();
      Get.snackbar(
        'Reporte',
        response.message ?? 'No fue posible obtener el reporte',
      );
    }
  }

  Future<File> generatePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => [
          pw.Text(
            'Reporte de Calificaciones de Clases',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text('Total de calificaciones: ${summary.value.totalRatings}'),
          pw.Text('Promedio general: ${summary.value.averageRating.toStringAsFixed(2)}'),
          pw.Text('Con comentario: ${summary.value.commentedCount} (${summary.value.commentRate.toStringAsFixed(1)}%)'),
          pw.Text('5 estrellas: ${summary.value.rating5Count}'),
          pw.SizedBox(height: 14),

          if (coachSummary.isNotEmpty) ...[
            pw.Text(
              'Resumen por coach',
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headers: const ['Coach', 'Total', 'Promedio', '5★', 'Comentarios'],
              data: coachSummary.map((c) {
                return [
                  c.coachName,
                  c.totalRatings.toString(),
                  c.averageRating.toStringAsFixed(2),
                  c.fiveStarCount.toString(),
                  c.commentedCount.toString(),
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 14),
          ],

          pw.Text(
            'Detalle',
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: const [
              'Fecha',
              'Hora',
              'Estudiante',
              'Coach',
              'Rating',
              'Comentario',
              'Tema',
              'Tipo',
              'Asistencia',
            ],
            data: results.map((r) {
              return [
                DateFormat('dd/MM/yyyy').format(DateTime.parse(r.classDate)),
                r.classTime,
                r.userName,
                r.coachName,
                '${r.rating}/5',
                (r.comment ?? '').trim().isEmpty ? '-' : r.comment!,
                (r.classTheme ?? '').trim().isEmpty ? '-' : r.classTheme!,
                (r.typeClass ?? '').trim().isEmpty ? '-' : r.typeClass!,
                (r.attendanceStatus ?? '').trim().isEmpty
                    ? '-'
                    : r.attendanceStatus!,
              ];
            }).toList(),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
              fontSize: 9,
            ),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey800),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellAlignment: pw.Alignment.centerLeft,
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

    final file = File('${dir.path}/reporte_calificaciones_clases.pdf');
    await file.writeAsBytes(await pdf.save(), flush: true);
    return file;
  }

  Future<void> exportPDF(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    final shareRect =
    box != null ? (box.localToGlobal(Offset.zero) & box.size) : null;

    final file = await generatePDF();

    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Reporte de Calificaciones de Clases',
          sharePositionOrigin: shareRect,
        ),
      );
    } catch (_) {
      Get.snackbar('Exportación', 'Archivo guardado en: ${file.path}');
    }
  }

  Future<void> exportExcel(BuildContext context) async {
    final excel = Excel.createExcel();
    final summarySheet = excel['Resumen'];
    final detailSheet = excel['Detalle'];
    final coachSheet = excel['Coach'];

    summarySheet.appendRow([
      TextCellValue('Métrica'),
      TextCellValue('Valor'),
    ]);
    summarySheet.appendRow([
      TextCellValue('Total calificaciones'),
      IntCellValue(summary.value.totalRatings),
    ]);
    summarySheet.appendRow([
      TextCellValue('Promedio general'),
      DoubleCellValue(summary.value.averageRating),
    ]);
    summarySheet.appendRow([
      TextCellValue('Con comentario'),
      IntCellValue(summary.value.commentedCount),
    ]);
    summarySheet.appendRow([
      TextCellValue('5 estrellas'),
      IntCellValue(summary.value.rating5Count),
    ]);

    coachSheet.appendRow([
      TextCellValue('Coach'),
      TextCellValue('Total'),
      TextCellValue('Promedio'),
      TextCellValue('5 estrellas'),
      TextCellValue('Comentarios'),
    ]);

    for (final c in coachSummary) {
      coachSheet.appendRow([
        TextCellValue(c.coachName),
        IntCellValue(c.totalRatings),
        DoubleCellValue(c.averageRating),
        IntCellValue(c.fiveStarCount),
        IntCellValue(c.commentedCount),
      ]);
    }

    detailSheet.appendRow([
      TextCellValue('Fecha'),
      TextCellValue('Hora'),
      TextCellValue('Estudiante'),
      TextCellValue('Coach'),
      TextCellValue('Rating'),
      TextCellValue('Comentario'),
      TextCellValue('Tema'),
      TextCellValue('Tipo'),
      TextCellValue('Asistencia'),
    ]);

    for (final r in results) {
      detailSheet.appendRow([
        TextCellValue(
          DateFormat('dd/MM/yyyy').format(DateTime.parse(r.classDate)),
        ),
        TextCellValue(r.classTime),
        TextCellValue(r.userName),
        TextCellValue(r.coachName),
        IntCellValue(r.rating),
        TextCellValue((r.comment ?? '').trim().isEmpty ? '-' : r.comment!),
        TextCellValue((r.classTheme ?? '').trim().isEmpty ? '-' : r.classTheme!),
        TextCellValue((r.typeClass ?? '').trim().isEmpty ? '-' : r.typeClass!),
        TextCellValue((r.attendanceStatus ?? '').trim().isEmpty ? '-' : r.attendanceStatus!),
      ]);
    }

    final bytes = excel.encode();
    if (bytes == null) return;

    Directory dir;
    if (Platform.isAndroid) {
      final status = await Permission.manageExternalStorage.request();
      dir = status.isGranted
          ? Directory('/storage/emulated/0/Download')
          : await getApplicationDocumentsDirectory();
    } else {
      dir = await getApplicationDocumentsDirectory();
    }

    final file = File('${dir.path}/reporte_calificaciones_clases.xlsx');
    await file.writeAsBytes(bytes, flush: true);

    if (Platform.isIOS) {
      final box = context.findRenderObject() as RenderBox?;
      final shareRect =
      box != null ? (box.localToGlobal(Offset.zero) & box.size) : null;

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Reporte de Calificaciones de Clases',
          sharePositionOrigin: shareRect,
        ),
      );
    } else {
      Get.snackbar('Excel generado', 'Archivo guardado en: ${file.path}');
    }
  }

  @override
  void onClose() {
    studentNameController.dispose();
    coachNameController.dispose();
    super.onClose();
  }
}