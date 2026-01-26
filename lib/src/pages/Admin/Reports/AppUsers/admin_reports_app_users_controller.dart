import 'dart:io';

import 'package:amina_ec/src/models/response_api.dart';
import 'package:amina_ec/src/models/user.dart';
import 'package:amina_ec/src/providers/admin_users_provider.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class AdminReportsAppUsersController extends GetxController {
  final AdminUsersProvider _provider = AdminUsersProvider();

  // State
  final users = <User>[].obs;
  final filteredUsers = <User>[].obs;
  final loading = false.obs;
  final error = RxnString();

  // Search
  final searchQuery = ''.obs;
  final searchController = TextEditingController();

  final User userSession = User.fromJson(GetStorage().read('user') ?? {});

  @override
  void onInit() {
    super.onInit();

    // Debounce para que no filtre en cada tecla (mejor performance)
    debounce<String>(
      searchQuery,
          (_) => _applyFilter(),
      time: const Duration(milliseconds: 250),
    );

    getUsers();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // ----------------------------
  // Data
  // ----------------------------
  Future<void> getUsers() async {
    try {
      error.value = null;
      loading.value = true;

      final token = userSession.session_token;
      if (token == null || token.isEmpty) {
        error.value = 'Sesión inválida. Inicia sesión nuevamente.';
        return;
      }

      final result = await _provider.getAllUsers(token);
      users.assignAll(result);
      _applyFilter();
    } catch (e) {
      error.value = 'Error cargando usuarios: $e';
    } finally {
      loading.value = false;
    }
  }

  // ----------------------------
  // Search
  // ----------------------------
  void onSearchChanged(String query) {
    searchQuery.value = query;
  }
  void filterUsers(String query) => onSearchChanged(query);

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  void _applyFilter() {
    final q = searchQuery.value.trim().toLowerCase();

    if (q.isEmpty) {
      filteredUsers.assignAll(users);
      return;
    }

    filteredUsers.assignAll(
      users.where((u) {
        final name = (u.name ?? '').toLowerCase();
        final lastname = (u.lastname ?? '').toLowerCase();
        final email = (u.email ?? '').toLowerCase();
        return name.contains(q) || lastname.contains(q) || email.contains(q);
      }),
    );
  }

  // ----------------------------
  // Navigation & Actions
  // ----------------------------
  void openUserPlans(User user) {
    Get.toNamed('/admin/users/plans', arguments: user);
  }

  void openUserHistory(User user) {
    Get.toNamed('/admin/users/history', arguments: user);
  }

  void openUserActionsSheet(User user) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text('Información de planes', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                onTap: () async {
                  Get.back();
                  showUserPlansInfo(user);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month_outlined),
                title: Text('Extender días', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                onTap: () {
                  Get.back();
                  showExtendDialog(user);
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: Text('Agregar rides', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                onTap: () {
                  Get.back();
                  showRidesDialog(user);
                },
              ),
              ListTile(
                leading: const Icon(Icons.timeline_outlined),
                title: Text('Histórico', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                onTap: () {
                  Get.back();
                  openUserHistory(user);
                },
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: Get.back,
                child: Text('Cerrar', style: GoogleFonts.poppins(color: indigoAmina, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ----------------------------
  // API Actions
  // ----------------------------
  Future<void> extendPlan(User user, int days) async {
    final res = await _provider.extendPlan(
      user.id!,
      days,
      userSession.session_token!,
    );
    Get.snackbar('Extender plan', res.message ?? 'Error');
    await getUsers();
  }

  Future<void> returnRides(User user, int rides) async {
    final res = await _provider.returnRides(
      user.id!,
      rides,
      userSession.session_token!,
    );
    Get.snackbar('Devolver rides', res.message ?? 'Error');
    await getUsers();
  }

  // ----------------------------
  // Dialogs (reutilizables)
  // ----------------------------
  void showExtendDialog(User user) {
    _showCounterDialog(
      title: 'Extender plan',
      subtitle: 'Selecciona los días a añadir:',
      unit: 'días',
      confirmText: 'Confirmar',
      onConfirm: (value) => extendPlan(user, value),
    );
  }

  void showRidesDialog(User user) {
    _showCounterDialog(
      title: 'Añadir Rides',
      subtitle: 'Selecciona la cantidad de rides a añadir:',
      unit: 'rides',
      confirmText: 'Confirmar',
      onConfirm: (value) => returnRides(user, value),
    );
  }

  void _showCounterDialog({
    required String title,
    required String subtitle,
    required String unit,
    required String confirmText,
    required Future<void> Function(int value) onConfirm,
  }) {
    int value = 1;

    Get.dialog(
      StatefulBuilder(
        builder: (_, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: Text(title, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(subtitle, textAlign: TextAlign.center, style: GoogleFonts.poppins(color: darkGrey)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: value > 1 ? () => setState(() => value--) : null,
                    ),
                    Text(
                      '$value $unit',
                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w800, color: almostBlack),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => setState(() => value++),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: Get.back,
                child: Text('Cancelar', style: GoogleFonts.poppins(color: indigoAmina, fontWeight: FontWeight.w700)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: almostBlack,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  Get.back();
                  await onConfirm(value);
                },
                child: Text(confirmText, style: GoogleFonts.poppins(color: whiteLight, fontWeight: FontWeight.w700)),
              ),
            ],
          );
        },
      ),
    );
  }

  // ----------------------------
  // Plans Info Dialog
  // ----------------------------
  void showUserPlansInfo(User user) async {
    final token = userSession.session_token!;
    final plans = await _provider.getUserPlansSummary(user.id!, token);

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          "Planes de ${user.name}",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w800, color: almostBlack),
        ),
        content: SizedBox(
          width: Get.width * 0.82,
          child: plans.isEmpty
              ? Center(
            child: Text(
              "Este usuario no tiene planes activos.",
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          )
              : SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: plans.map((plan) {
                final start = plan["start_date"]?.split('T').first.split('-').reversed.join('/') ?? 'No definida';
                final end = plan["end_date"]?.split('T').first.split('-').reversed.join('/') ?? 'No definida';
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xfff3f3f3),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan["plan_name"] ?? "Plan sin nombre",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: indigoAmina,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text("Rides restantes: ${plan["remaining_rides"]}",
                          style: GoogleFonts.poppins(fontSize: 12, color: almostBlack)),
                      Text("Inicio: $start", style: GoogleFonts.poppins(fontSize: 12, color: almostBlack)),
                      Text("Fin: $end", style: GoogleFonts.poppins(fontSize: 12, color: almostBlack)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text("Cerrar", style: GoogleFonts.poppins(color: indigoAmina, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  // ----------------------------
  // Export (PDF / Excel)
  // ----------------------------
  List<User> get _exportList => filteredUsers; // exporta lo que estás viendo

  Future<File> generatePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (_) {
          return [
            pw.Table.fromTextArray(
              headers: ['Nombre', 'Email', 'CI', 'Rides', 'Cumpleaños'],
              data: _exportList.map((u) {
                final birth = (u.birthDate != null && u.birthDate!.isNotEmpty)
                    ? DateFormat('dd/MM/yyyy').format(DateTime.parse(u.birthDate!))
                    : '';
                return [
                  '${u.name ?? ''} ${u.lastname ?? ''}'.trim(),
                  u.email ?? '',
                  u.ci ?? '',
                  (u.totalRides ?? 0).toString(),
                  birth,
                ];
              }).toList(),
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            ),
          ];
        },
      ),
    );

    final dir = await _resolveExportDir();
    final file = File('${dir.path}/reporte_usuarios.pdf');
    await file.writeAsBytes(await pdf.save(), flush: true);
    return file;
  }

  Future<void> exportPDF(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    final shareRect = box != null ? (box.localToGlobal(Offset.zero) & box.size) : null;

    final file = await generatePDF();

    final params = ShareParams(
      files: [XFile(file.path)],
      text: 'Reporte de Usuarios',
      sharePositionOrigin: shareRect,
    );

    try {
      await SharePlus.instance.share(params);
    } catch (_) {
      Get.snackbar('Exportación', 'Archivo guardado en: ${file.path}');
    }
  }

  Future<void> exportExcel(BuildContext context) async {
    final excel = Excel.createExcel();
    final sheet = excel['Usuarios'];
    excel.delete('Sheet1');

    sheet.appendRow([
      TextCellValue('Nombre'),
      TextCellValue('Email'),
      TextCellValue('CI'),
      TextCellValue('Rides'),
      TextCellValue('Cumpleaños'),
    ]);

    for (final u in _exportList) {
      final birth = (u.birthDate != null && u.birthDate!.isNotEmpty)
          ? DateFormat('dd/MM/yyyy').format(DateTime.parse(u.birthDate!))
          : '';
      sheet.appendRow([
        TextCellValue('${u.name ?? ''} ${u.lastname ?? ''}'.trim()),
        TextCellValue(u.email ?? ''),
        TextCellValue(u.ci ?? ''),
        DoubleCellValue((u.totalRides ?? 0).toDouble()),
        TextCellValue(birth),
      ]);
    }

    final bytes = excel.encode();
    if (bytes == null) return;

    final dir = await _resolveExportDir();
    final file = File('${dir.path}/reporte_usuarios.xlsx');
    await file.writeAsBytes(bytes, flush: true);

    if (Platform.isIOS) {
      final box = context.findRenderObject() as RenderBox?;
      final shareRect = box != null ? (box.localToGlobal(Offset.zero) & box.size) : null;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Reporte de Usuarios',
          sharePositionOrigin: shareRect,
        ),
      );
    } else {
      Get.snackbar('Excel generado', 'Archivo guardado en: ${file.path}');
    }
  }

  Future<Directory> _resolveExportDir() async {
    if (Platform.isAndroid) {
      final status = await Permission.manageExternalStorage.request();
      if (status.isGranted) {
        return Directory('/storage/emulated/0/Download');
      }
      return getApplicationDocumentsDirectory();
    }
    return getApplicationDocumentsDirectory();
  }


}
