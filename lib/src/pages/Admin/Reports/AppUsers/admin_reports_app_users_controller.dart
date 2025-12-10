import 'dart:io';
import 'package:amina_ec/src/models/response_api.dart';
import 'package:amina_ec/src/models/user.dart';
import 'package:amina_ec/src/providers/admin_users_provider.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart' hide Border;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class AdminReportsAppUsersController extends GetxController {
  final AdminUsersProvider _provider = AdminUsersProvider();

  var users = <User>[].obs; // Lista completa
  var filteredUsers = <User>[].obs; // Lista filtrada
  var loading = false.obs;

  var searchQuery = ''.obs; // Texto de búsqueda
  final searchController = TextEditingController();

  User userSession = User.fromJson(GetStorage().read('user') ?? {});

  @override
  void onInit() {
    super.onInit();
    getUsers();
  }

  /// Obtener todos los usuarios
  Future<void> getUsers() async {
    loading.value = true;
    final result = await _provider.getAllUsers(userSession.session_token!);
    users.value = result;
    filteredUsers.value = result;
    loading.value = false;
  }

  /// Filtrar usuarios por nombre
  void filterUsers(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredUsers.value = users;
    } else {
      filteredUsers.value = users
          .where(
              (u) => (u.name ?? '').toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  /// Extender plan
  Future<void> extendPlan(User user, int days) async {
    ResponseApi res = await _provider.extendPlan(
      user.id!,
      days,
      userSession.session_token!,
    );
    Get.snackbar('Extender plan', res.message ?? 'Error');
    await getUsers();
  }

  /// Devolver rides
  Future<void> returnRides(User user, int rides) async {
    ResponseApi res = await _provider.returnRides(
      user.id!,
      rides,
      userSession.session_token!,
    );
    Get.snackbar('Devolver rides', res.message ?? 'Error');
    await getUsers();
  }

  /// Diálogo para extender plan
  void showExtendDialog(User user) {
    int days = 1;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              'Extender plan',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Selecciona los días a añadir:',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: darkGrey),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: days > 1 ? () => setState(() => days--) : null,
                    ),
                    Text(
                      '$days días',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: almostBlack,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => setState(() => days++),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: Get.back,
                child: Text('Cancelar', style: TextStyle(color: indigoAmina)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  Get.back();
                  await extendPlan(user, days);
                },
                child: Text('Confirmar', style: TextStyle(color: whiteLight)),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Diálogo para agregar rides
  void showRidesDialog(User user) {
    int rides = 1;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.grey[100],
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              'Añadir Rides',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Selecciona la cantidad de rides a añadir:',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: darkGrey),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed:
                      rides > 1 ? () => setState(() => rides--) : null,
                    ),
                    Text(
                      '$rides rides',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: almostBlack,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => setState(() => rides++),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: Get.back,
                child: Text('Cancelar', style: TextStyle(color: indigoAmina)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  Get.back();
                  await returnRides(user, rides);
                },
                child: Text('Confirmar', style: TextStyle(color: whiteLight)),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Mostrar planes de usuario
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
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: almostBlack,
          ),
        ),
        content: SizedBox(
          width: Get.width * 0.8,
          child: plans.isEmpty
              ? Center(
            child: Text(
              "Este usuario no tiene planes activos.",
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          )
              : Column(
            mainAxisSize: MainAxisSize.min,
            children: plans.map((plan) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                width: Get.width * 0.8,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan["plan_name"] ?? "Plan sin nombre",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: indigoAmina,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Rides restantes: ${plan["remaining_rides"]}",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: almostBlack,
                      ),
                    ),
                    Text(
                      "Inicio: ${plan["start_date"]?.split('T').first.split('-').reversed.join('/') ?? 'No definida'} ",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: almostBlack,
                      ),
                    ),
                    Text(
                      "Fin: ${plan["end_date"]?.split('T').first.split('-').reversed.join('/') ?? 'No definida'} ",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: almostBlack,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text("Cerrar",
                style: TextStyle(
                  color: indigoAmina,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                )),
          ),
        ],
      ),
    );
  }

  /// Generar PDF de todos los usuarios (MultiPage)
  Future<File> generatePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return [
            pw.Table.fromTextArray(
              headers: ['Nombre', 'Email', 'CI', 'Rides', 'Cumpleaños'],
              data: users.map((u) => [
                u.name ?? '',
                u.email ?? '',
                u.ci ?? '',
                u.totalRides?.toString() ?? '0',
                u.birthDate != null
                    ? DateFormat('dd/MM/yyyy').format(DateTime.parse(u.birthDate!))
                    : '',
              ]).toList(),
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
              headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
            ),
          ];
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

    final file = File('${dir.path}/reporte_usuarios.pdf');
    await file.writeAsBytes(await pdf.save(), flush: true);
    return file;
  }

  /// Exportar PDF
  Future<void> exportPDF(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    final shareRect =
    box != null ? (box.localToGlobal(Offset.zero) & box.size) : null;
    final file = await generatePDF();

    final params = ShareParams(
      files: [XFile(file.path)],
      text: 'Reporte de Usuarios',
      sharePositionOrigin: shareRect,
    );

    try {
      await SharePlus.instance.share(params);
    } catch (e) {
      Get.snackbar('Exportación', 'Archivo guardado en: ${file.path}');
    }
  }

  /// Exportar Excel
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

    for (var u in users) {
      sheet.appendRow([
        TextCellValue(u.name ?? ''),
        TextCellValue(u.email ?? ''),
        TextCellValue(u.ci ?? ''),
        DoubleCellValue(u.totalRides?.toDouble() ?? 0),
        TextCellValue(u.birthDate != null
            ? DateFormat('dd/MM/yyyy').format(DateTime.parse(u.birthDate!))
            : ''),
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

    final file = File('${dir.path}/reporte_usuarios.xlsx');
    await file.writeAsBytes(bytes, flush: true);

    if (Platform.isIOS) {
      final box = context.findRenderObject() as RenderBox?;
      final shareRect =
      box != null ? (box.localToGlobal(Offset.zero) & box.size) : null;
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
}
