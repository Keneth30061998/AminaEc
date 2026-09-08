import 'dart:io';

import 'package:amina_ec/src/models/response_api.dart';
import 'package:amina_ec/src/models/user.dart';
import 'package:amina_ec/src/providers/admin_users_provider.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // ----------------------------
  // State
  // ----------------------------
  final users = <User>[].obs;
  final filteredUsers = <User>[].obs;
  final loading = false.obs;
  final error = RxnString();

  // ----------------------------
  // Search
  // ----------------------------
  late final Worker _searchWorker;
  final searchQuery = ''.obs;
  final searchController = TextEditingController();

  final User userSession = User.fromJson(
    GetStorage().read('user') ?? {},
  );

  @override
  void onInit() {
    super.onInit();

    _searchWorker = debounce<String>(
      searchQuery,
          (_) => _applyFilter(),
      time: const Duration(milliseconds: 250),
    );

    getUsers();
  }

  @override
  void onClose() {
    _searchWorker.dispose();
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

      if (token == null || token.trim().isEmpty) {
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

  void filterUsers(String query) {
    onSearchChanged(query);
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  void _applyFilter() {
    final query = searchQuery.value.trim().toLowerCase();

    if (query.isEmpty) {
      filteredUsers.assignAll(users);
      return;
    }

    filteredUsers.assignAll(
      users.where((user) {
        final name = (user.name ?? '').toLowerCase();
        final lastname = (user.lastname ?? '').toLowerCase();
        final email = (user.email ?? '').toLowerCase();

        return name.contains(query) ||
            lastname.contains(query) ||
            email.contains(query);
      }),
    );
  }

  // ----------------------------
  // Navigation
  // ----------------------------
  Future<void> openUserPlans(User user) async {
    await Get.toNamed(
      '/admin/users/plans',
      arguments: user,
    );
    await getUsers();
  }

  void openUserHistory(User user) {
    Get.toNamed(
      '/admin/users/history',
      arguments: user,
    );
  }

  // ----------------------------
  // Actions sheet alternativo
  // ----------------------------
  Future<void> _closeActionsSheetThen(
      Future<void> Function() action,
      ) async {
    if (Get.isBottomSheetOpen == true) {
      Get.back();
    }

    await Future<void>.delayed(
      const Duration(milliseconds: 220),
    );

    await action();
  }

  void openUserActionsSheet(User user) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(22),
          ),
        ),
        child: SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: Get.height * 0.76,
            ),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(
                16,
                12,
                16,
                16,
              ),
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    margin: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.info_outline,
                  ),
                  title: Text(
                    'Información de planes',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () async {
                    await _closeActionsSheetThen(
                          () => showUserPlansInfo(user),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.calendar_month_outlined,
                  ),
                  title: Text(
                    'Extender días',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () async {
                    await _closeActionsSheetThen(
                          () async {
                        showExtendDialog(user);
                      },
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.add_circle_outline,
                  ),
                  title: Text(
                    'Agregar rides',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () async {
                    await _closeActionsSheetThen(
                          () async {
                        showRidesDialog(user);
                      },
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.edit_outlined,
                  ),
                  title: Text(
                    'Editar rides completos',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Actual: ${user.ridesCompleted ?? 0}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey[700],
                    ),
                  ),
                  onTap: () async {
                    await _closeActionsSheetThen(
                          () => showEditCompletedRidesDialog(user),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.timeline_outlined,
                  ),
                  title: Text(
                    'Histórico',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () async {
                    await _closeActionsSheetThen(
                          () async {
                        openUserHistory(user);
                      },
                    );
                  },
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    'Cerrar',
                    style: GoogleFonts.poppins(
                      color: indigoAmina,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // ----------------------------
  // API Actions
  // ----------------------------
  Future<void> extendPlan(
      User user,
      int days, {String? userPlanId}) async {
    final userId = user.id;
    final token = userSession.session_token;

    if (userId == null ||
        userId.trim().isEmpty ||
        token == null ||
        token.trim().isEmpty) {
      Get.snackbar(
        'Extender plan',
        'La sesión o el usuario no son válidos.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final response = await _provider.extendPlan(
        userId,
        days,
        token,
        userPlanId: userPlanId,
      );

      Get.snackbar(
        'Extender plan',
        response.message ?? 'No se pudo extender el plan.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(14),
        borderRadius: 14,
      );

      await getUsers();
    } catch (_) {
      Get.snackbar(
        'Extender plan',
        'No se pudo extender el plan.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(14),
        borderRadius: 14,
      );
    }
  }

  Future<void> returnRides(
      User user,
      int rides, {String? userPlanId}) async {
    final userId = user.id;
    final token = userSession.session_token;

    if (userId == null ||
        userId.trim().isEmpty ||
        token == null ||
        token.trim().isEmpty) {
      Get.snackbar(
        'Devolver rides',
        'La sesión o el usuario no son válidos.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final response = await _provider.returnRides(
        userId,
        rides,
        token,
        userPlanId: userPlanId,
      );

      Get.snackbar(
        'Devolver rides',
        response.message ?? 'No se pudieron devolver los rides.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(14),
        borderRadius: 14,
      );

      await getUsers();
    } catch (_) {
      Get.snackbar(
        'Devolver rides',
        'No se pudieron devolver los rides.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(14),
        borderRadius: 14,
      );
    }
  }

  Future<ResponseApi> editCompletedRides(
      User user,
      int completedRides,
      ) async {
    try {
      final userId = user.id;
      final token = userSession.session_token;

      if (userId == null || userId.trim().isEmpty) {
        return ResponseApi(
          success: false,
          message: 'El usuario seleccionado no es válido.',
        );
      }

      if (token == null || token.trim().isEmpty) {
        return ResponseApi(
          success: false,
          message: 'La sesión no es válida.',
        );
      }

      final response = await _provider.editCompletedRides(
        userId: userId,
        completedRides: completedRides,
        token: token,
      );

      if (response.success != true) {
        return response;
      }

      int updatedValue = completedRides;

      if (response.data is Map) {
        final map = Map<String, dynamic>.from(
          response.data as Map,
        );

        updatedValue = int.tryParse(
          map['completed_rides']?.toString() ?? '',
        ) ??
            completedRides;
      }

      for (final item in users) {
        if (item.id == userId) {
          item.ridesCompleted = updatedValue;
        }
      }

      for (final item in filteredUsers) {
        if (item.id == userId) {
          item.ridesCompleted = updatedValue;
        }
      }

      user.ridesCompleted = updatedValue;

      users.refresh();
      filteredUsers.refresh();

      return response;
    } catch (_) {
      return ResponseApi(
        success: false,
        message: 'No se pudieron guardar los cambios.',
      );
    }
  }

  // ----------------------------
  // Dialogs
  // ----------------------------
  Future<String?> _chooseUserPlan(User user) async {
    try {
      final plans = await _provider.getUserPlansSummary(user.id!, userSession.session_token!);
      final active = plans.where((p) => p['status'] == 'active').toList();
      if (active.isEmpty) { Get.snackbar('Planes', 'El cliente no tiene planes activos.'); return null; }
      if (active.length == 1) return '${active.first['id']}';
      return await Get.dialog<String>(AlertDialog(
        title: const Text('Selecciona el plan'),
        content: SizedBox(width: 360, height: 320, child: ListView(
          children: active.map((p) => ListTile(
            title: Text('${p['plan_name'] ?? 'Plan'} · #${p['id']}'),
            subtitle: Text('${p['is_course'].toString() == '1' ? 'Curso' : 'Regular'} · ${p['remaining_rides']} rides · Hasta ${p['end_date'] ?? 'activar'}'),
            onTap: () => Get.back(result: '${p['id']}'),
          )).toList(),
        )),
        actions: [TextButton(onPressed: () => Get.back(), child: const Text('Cancelar'))],
      ));
    } catch (_) { Get.snackbar('Planes', 'No se pudieron consultar los planes.'); return null; }
  }

  Future<void> showExtendDialog(User user) async {
    final planId = await _chooseUserPlan(user);
    if (planId == null) return;
    await _showCounterDialog(
      title: 'Extender plan',
      subtitle: 'Selecciona los días a añadir:',
      unit: 'días',
      confirmText: 'Confirmar',
      onConfirm: (value) => extendPlan(user, value, userPlanId: planId),
    );
  }

  Future<void> showRidesDialog(User user) async {
    final planId = await _chooseUserPlan(user);
    if (planId == null) return;
    await _showCounterDialog(
      title: 'Añadir rides',
      subtitle: 'Selecciona la cantidad de rides a añadir:',
      unit: 'rides',
      confirmText: 'Confirmar',
      onConfirm: (value) => returnRides(user, value, userPlanId: planId),
    );
  }

  Future<void> showEditCompletedRidesDialog(
      User user,
      ) async {
    final savedValue = await Get.dialog<int>(
      _EditCompletedRidesDialog(
        currentValue: user.ridesCompleted ?? 0,
        onSave: (newValue) {
          return editCompletedRides(
            user,
            newValue,
          );
        },
      ),
      barrierDismissible: false,
    );

    if (savedValue == null) {
      return;
    }

    Get.snackbar(
      'Rides actualizados',
      'El nuevo total es $savedValue.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(14),
      borderRadius: 14,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.white,
      colorText: almostBlack,
    );
  }

  Future<void> _showCounterDialog({
    required String title,
    required String subtitle,
    required String unit,
    required String confirmText,
    required Future<void> Function(int value) onConfirm,
  }) async {
    int value = 1;
    bool processing = false;

    await Get.dialog<void>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: darkGrey,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                      ),
                      onPressed: !processing && value > 1
                          ? () {
                        setState(() {
                          value--;
                        });
                      }
                          : null,
                    ),
                    Text(
                      '$value $unit',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: almostBlack,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle_outline,
                      ),
                      onPressed: processing
                          ? null
                          : () {
                        setState(() {
                          value++;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: processing
                    ? null
                    : () {
                  Get.back();
                },
                child: Text(
                  'Cancelar',
                  style: GoogleFonts.poppins(
                    color: indigoAmina,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: almostBlack,
                  disabledBackgroundColor: Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: processing
                    ? null
                    : () async {
                  setState(() {
                    processing = true;
                  });

                  Get.back();

                  await Future<void>.delayed(
                    const Duration(milliseconds: 180),
                  );

                  await onConfirm(value);
                },
                child: processing
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : Text(
                  confirmText,
                  style: GoogleFonts.poppins(
                    color: whiteLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      barrierDismissible: !processing,
    );
  }

  // ----------------------------
  // Plans Info Dialog
  // ----------------------------
  Future<void> showUserPlansInfo(User user) async {
    final userId = user.id;
    final token = userSession.session_token;

    if (userId == null ||
        userId.trim().isEmpty ||
        token == null ||
        token.trim().isEmpty) {
      Get.snackbar(
        'Planes del usuario',
        'La sesión o el usuario no son válidos.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final plans = await _provider.getUserPlansSummary(
      userId,
      token,
    );

    await Get.dialog<void>(
      AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: Text(
          'Planes de ${user.name ?? ''}',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w800,
            color: almostBlack,
          ),
        ),
        content: SizedBox(
          width: Get.width * 0.82,
          child: plans.isEmpty
              ? Text(
            'Este usuario no tiene planes activos.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.grey,
            ),
          )
              : SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: plans.map((plan) {
                final rawStart =
                plan['start_date']?.toString();
                final rawEnd =
                plan['end_date']?.toString();

                final start = rawStart != null
                    ? rawStart
                    .split('T')
                    .first
                    .split('-')
                    .reversed
                    .join('/')
                    : 'No definida';

                final end = rawEnd != null
                    ? rawEnd
                    .split('T')
                    .first
                    .split('-')
                    .reversed
                    .join('/')
                    : 'No definida';

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(
                    bottom: 10,
                  ),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xfff3f3f3),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.black12,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan['plan_name']?.toString() ??
                            'Plan sin nombre',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: indigoAmina,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rides restantes: '
                            '${plan['remaining_rides'] ?? 0}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: almostBlack,
                        ),
                      ),
                      Text(
                        'Inicio: $start',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: almostBlack,
                        ),
                      ),
                      Text(
                        'Fin: $end',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: almostBlack,
                        ),
                      ),
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
            onPressed: () => Get.back(),
            child: Text(
              'Cerrar',
              style: GoogleFonts.poppins(
                color: indigoAmina,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------
  // Export PDF / Excel
  // ----------------------------
  List<User> get _exportList => filteredUsers;

  String _formatBirthDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '';
    }

    try {
      return DateFormat('dd/MM/yyyy').format(
        DateTime.parse(value),
      );
    } catch (_) {
      return value;
    }
  }

  Future<File> generatePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (_) {
          return [
            pw.TableHelper.fromTextArray(
              headers: [
                'Nombre',
                'Email',
                'CI',
                'Rides',
                'Completos',
                'Cumpleaños',
              ],
              data: _exportList.map((user) {
                return [
                  '${user.name ?? ''} ${user.lastname ?? ''}'
                      .trim(),
                  user.email ?? '',
                  user.ci ?? '',
                  (user.totalRides ?? 0).toString(),
                  (user.ridesCompleted ?? 0).toString(),
                  _formatBirthDate(user.birthDate),
                ];
              }).toList(),
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
              ),
              cellAlignment: pw.Alignment.centerLeft,
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
            ),
          ];
        },
      ),
    );

    final directory = await _resolveExportDir();

    final file = File(
      '${directory.path}/reporte_usuarios.pdf',
    );

    await file.writeAsBytes(
      await pdf.save(),
      flush: true,
    );

    return file;
  }

  Future<void> exportPDF(
      BuildContext context,
      ) async {
    final box = context.findRenderObject() as RenderBox?;

    final shareRect = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : null;

    final file = await generatePDF();

    final params = ShareParams(
      files: [
        XFile(file.path),
      ],
      text: 'Reporte de Usuarios',
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
  }

  Future<void> exportExcel(
      BuildContext context,
      ) async {
    final excel = Excel.createExcel();
    final sheet = excel['Usuarios'];

    excel.delete('Sheet1');

    sheet.appendRow([
      TextCellValue('Nombre'),
      TextCellValue('Email'),
      TextCellValue('CI'),
      TextCellValue('Rides'),
      TextCellValue('Completos'),
      TextCellValue('Cumpleaños'),
    ]);

    for (final user in _exportList) {
      sheet.appendRow([
        TextCellValue(
          '${user.name ?? ''} ${user.lastname ?? ''}'.trim(),
        ),
        TextCellValue(user.email ?? ''),
        TextCellValue(user.ci ?? ''),
        DoubleCellValue(
          (user.totalRides ?? 0).toDouble(),
        ),
        DoubleCellValue(
          (user.ridesCompleted ?? 0).toDouble(),
        ),
        TextCellValue(
          _formatBirthDate(user.birthDate),
        ),
      ]);
    }

    final bytes = excel.encode();

    if (bytes == null) {
      return;
    }

    final directory = await _resolveExportDir();

    final file = File(
      '${directory.path}/reporte_usuarios.xlsx',
    );

    await file.writeAsBytes(
      bytes,
      flush: true,
    );

    if (Platform.isIOS) {
      final box = context.findRenderObject() as RenderBox?;

      final shareRect = box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : null;

      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile(file.path),
          ],
          text: 'Reporte de Usuarios',
          sharePositionOrigin: shareRect,
        ),
      );
    } else {
      Get.snackbar(
        'Excel generado',
        'Archivo guardado en: ${file.path}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<Directory> _resolveExportDir() async {
    if (Platform.isAndroid) {
      final status =
      await Permission.manageExternalStorage.request();

      if (status.isGranted) {
        return Directory(
          '/storage/emulated/0/Download',
        );
      }

      return getApplicationDocumentsDirectory();
    }

    return getApplicationDocumentsDirectory();
  }
}

// ======================================================
// Diálogo para editar rides completos
// ======================================================

class _EditCompletedRidesDialog extends StatefulWidget {
  final int currentValue;
  final Future<ResponseApi> Function(int value) onSave;

  const _EditCompletedRidesDialog({
    required this.currentValue,
    required this.onSave,
  });

  @override
  State<_EditCompletedRidesDialog> createState() {
    return _EditCompletedRidesDialogState();
  }
}

class _EditCompletedRidesDialogState
    extends State<_EditCompletedRidesDialog> {
  late final TextEditingController _valueController;

  String? _fieldError;
  String? _requestError;

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _valueController = TextEditingController(
      text: widget.currentValue.toString(),
    );

    _valueController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _valueController.text.length,
    );
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) {
      return;
    }

    FocusScope.of(context).unfocus();

    final rawValue = _valueController.text.trim();
    final newValue = int.tryParse(rawValue);

    if (newValue == null || newValue < 0) {
      setState(() {
        _fieldError = 'Ingresa un número entero válido';
        _requestError = null;
      });
      return;
    }

    if (newValue == widget.currentValue) {
      setState(() {
        _fieldError =
        'El valor ingresado es igual al actual';
        _requestError = null;
      });
      return;
    }

    setState(() {
      _fieldError = null;
      _requestError = null;
      _saving = true;
    });

    final response = await widget.onSave(newValue);

    if (!mounted) {
      return;
    }

    if (response.success == true) {
      Navigator.of(context).pop(newValue);
      return;
    }

    setState(() {
      _saving = false;
      _requestError = response.message ??
          'No se pudieron guardar los cambios.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 24,
      ),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 360,
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior:
          ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Editar rides completos',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: almostBlack,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xfff5f5f5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 20,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Valor actual',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      widget.currentValue.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: almostBlack,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _valueController,
                autofocus: true,
                enabled: !_saving,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onSubmitted: (_) {
                  _save();
                },
                onChanged: (_) {
                  if (_fieldError != null ||
                      _requestError != null) {
                    setState(() {
                      _fieldError = null;
                      _requestError = null;
                    });
                  }
                },
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: almostBlack,
                ),
                decoration: InputDecoration(
                  labelText: 'Nuevo valor',
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                  errorText: _fieldError,
                  errorMaxLines: 2,
                  filled: true,
                  fillColor: const Color(0xfffafafa),
                  contentPadding:
                  const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 16,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Colors.black12,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Colors.black12,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: almostBlack,
                      width: 1.3,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Colors.redAccent,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ),
              if (_requestError != null) ...[
                const SizedBox(height: 10),
                Text(
                  _requestError!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _saving
                        ? null
                        : () {
                      FocusScope.of(context).unfocus();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: almostBlack,
                      disabledBackgroundColor:
                      Colors.black26,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      'Guardar',
                      style: GoogleFonts.poppins(
                        color: whiteLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

