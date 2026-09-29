import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'admin_edit_class_controller.dart';
import 'admin_class_attendance_page.dart';
import '../Reassign/admin_change_coach_page.dart';
import '../../../Shared/admin_ui.dart';

enum _BikeMode { reservations, block, unblock }

class AdminCoachBlockPage extends StatefulWidget {
  const AdminCoachBlockPage({super.key});
  @override
  State<AdminCoachBlockPage> createState() => _AdminCoachBlockPageState();
}

class _AdminCoachBlockPageState extends State<AdminCoachBlockPage> {
  late final AdminCoachBlockController con;
  _BikeMode mode = _BikeMode.reservations;
  bool navigating = false;

  @override
  void initState() {
    super.initState();
    con = Get.put(AdminCoachBlockController());
  }

  bool get busy => con.isProcessing.value || con.isLoading.value || navigating;

  String get instruction {
    switch (mode) {
      case _BikeMode.reservations:
        return 'Toca una bicicleta disponible para asignar un alumno, o una ocupada para consultar su reserva.';
      case _BikeMode.block:
        return 'Selecciona bicicletas disponibles y pulsa Bloquear. Tocar el mapa todavía no guarda cambios.';
      case _BikeMode.unblock:
        return 'Selecciona bicicletas bloqueadas y pulsa Desbloquear. Tocar el mapa todavía no guarda cambios.';
    }
  }

  String get dateLabel {
    final date = DateTime.tryParse(con.classDate);
    return date == null
        ? con.classDate
        : DateFormat('EEEE d MMMM yyyy', 'es_ES').format(date);
  }

  void _setMode(_BikeMode next) {
    if (busy || next == mode) return;
    // Only draft selection is cleared. No request is sent when changing modes.
    con.selectedEquipos.clear();
    setState(() => mode = next);
  }

  void _tapBike(int bicycle) {
    if (busy) return;
    final occupied = con.occupiedEquipos.contains(bicycle);
    final blocked = con.blockedEquipos.contains(bicycle);
    if (mode == _BikeMode.reservations) {
      if (occupied) {
        con.onBikePressed(bicycle); // Original remove/return-ride flow.
      } else if (blocked) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Esta bicicleta está bloqueada. Usa Desbloquear para habilitarla.')));
      } else {
        con.showUserPicker(
            bicycle); // Original search, assignment and confirmation.
      }
      return;
    }
    final eligible =
        !occupied && (mode == _BikeMode.block ? !blocked : blocked);
    if (eligible) con.toggleSeat(bicycle);
  }

  Future<void> _runClassAction(bool attendance) async {
    if (busy) return;
    setState(() => navigating = true);
    try {
      if (attendance) {
        final date = DateTime.tryParse(con.classDate);
        if (date == null) return;
        await Get.to(
            () => AdminStyled(
                child: AdminClassAttendancePage(
                    coachId: con.coachId,
                    coachName: con.coachName,
                    date: date,
                    classTime: con.classTime)),
            routeName: '/admin/classes/attendance');
        if (mounted) await con.refreshBikeStatus();
      } else {
        final changed = await Get.to<bool>(
            () => AdminStyled(child: AdminChangeCoachPage()),
            routeName: '/admin/classes/change-coach',
            arguments: {
              'coach_id': con.coachId,
              'coach_name': con.coachName,
              'class_date': con.classDate,
              'class_time': con.classTime
            });
        // Return to refreshed calendar after reassignment: old context is stale.
        if (changed == true && mounted) Get.back(result: true);
      }
    } finally {
      if (mounted) setState(() => navigating = false);
    }
  }

  Future<void> _applySelection() async {
    if (busy || con.selectedEquipos.isEmpty) return;
    try {
      if (mode == _BikeMode.block) {
        await con.applyBlock();
      } else if (mode == _BikeMode.unblock) {
        await con.applyUnblock();
      }
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'No se completó la operación. Actualiza el mapa antes de reintentar.'),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Detalle de clase'), actions: [
          Obx(() => IconButton(
              tooltip: 'Actualizar bicicletas',
              onPressed: busy ? null : con.refreshBikeStatus,
              icon: const Icon(Icons.refresh))),
        ]),
        body: SafeArea(
          child: ListView(
            key: PageStorageKey(
                'class-${con.coachId}-${con.classDate}-${con.classTime}'),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Text('${con.coachName} · ${formatHora(con.classTime)}',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(dateLabel, style: const TextStyle(color: AdminUi.muted)),
              const SizedBox(height: 12),
              Obx(
                () => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: busy ? null : () => _runClassAction(true),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Asistencia'),
                    ),
                    TextButton.icon(
                      onPressed: busy ? null : () => _runClassAction(false),
                      icon: const Icon(Icons.swap_horiz),
                      label: const Text('Cambiar coach'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Bicicletas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Obx(
                () => Wrap(
                  spacing: 8,
                  children: [
                    for (final item in _BikeMode.values)
                      ChoiceChip(
                          label: Text(const [
                            'Reservas',
                            'Bloquear',
                            'Desbloquear'
                          ][item.index]),
                          selected: mode == item,
                          showCheckmark: false,
                          onSelected: busy ? null : (_) => _setMode(item)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(instruction,
                  style: const TextStyle(fontSize: 13, color: AdminUi.muted)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 14,
                runSpacing: 8,
                children: [
                  _legend(Colors.grey.shade300, 'Disponible'),
                  _legend(indigoAmina, 'Ocupada'),
                  _legend(Colors.grey.shade600, 'Bloqueada'),
                  if (mode != _BikeMode.reservations)
                    _legend(limeGreen, 'Seleccionada'),
                ],
              ),
              const SizedBox(height: 20),
              Obx(() => con.isLoading.value
                  ? const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()))
                  : _map()),
              Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                      onPressed: _expandMap,
                      icon: const Icon(Icons.zoom_in),
                      label: const Text('Ampliar mapa'))),
              const SizedBox(height: 12),
              if (mode == _BikeMode.reservations)
                Obx(
                  () {
                    final entries = con.reservationByBike.entries.toList()
                      ..sort((a, b) => a.key.compareTo(b.key));
                    return ExpansionTile(
                      key: PageStorageKey<String>(
                        'reserved-students-${con.coachId}-${con.classDate}-${con.classTime}',
                      ),
                      title: Text('Alumnos reservados (${entries.length})'),
                      children: [
                        if (entries.isEmpty)
                          const ListTile(
                              title: Text('No hay reservas activas.')),
                        for (final entry in entries)
                          ListTile(
                            leading: CircleAvatar(child: Text('${entry.key}')),
                            title: Text(entry.value.userName ?? 'Alumno'),
                            subtitle: Text('Bicicleta ${entry.key}'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: busy ? null : () => _tapBike(entry.key),
                          ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
        bottomNavigationBar:
            mode == _BikeMode.reservations ? null : _selectionBar(),
      );

  Widget _selectionBar() => Obx(
        () {
          final count = con.selectedEquipos.length;
          final verb = mode == _BikeMode.block ? 'Bloquear' : 'Desbloquear';
          return Material(
            color: Colors.white,
            elevation: 6,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$count seleccionada(s)',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        TextButton(
                          onPressed: busy || count == 0
                              ? null
                              : () => con.selectedEquipos.clear(),
                          child: const Text('Limpiar'),
                        )
                      ],
                    ),
                    SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                            onPressed:
                                busy || count == 0 ? null : _applySelection,
                            child: Text(con.isProcessing.value
                                ? 'Guardando…'
                                : '$verb $count bicicleta(s)'))),
                  ],
                ),
              ),
            ),
          );
        },
      );

  // Physical arrangement from the original page. Rows never wrap or reflow.
  Widget _map() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
              child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      border: Border.all(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Center(
                      child: Text('Coach',
                          style: TextStyle(fontWeight: FontWeight.bold))))),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _seatRow(2, 4)),
              const SizedBox(width: 24),
              Expanded(child: _seatRow(6, 4)),
            ],
          ),
          const SizedBox(height: 10),
          _seatRow(10, 10),
        ],
      );

  Widget _seatRow(int start, int count) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final seatWidth = (constraints.maxWidth - count * 8) / count;
            return Row(
              children: List.generate(
                count,
                (index) {
                  final bicycle = start + index;
                  return Padding(
                    padding: const EdgeInsets.all(4),
                    child: Obx(
                      () {
                        final selected = con.selectedEquipos.contains(bicycle);
                        final occupied = con.occupiedEquipos.contains(bicycle);
                        final blocked = con.blockedEquipos.contains(bicycle);
                        final eligible = mode == _BikeMode.reservations ||
                            (!occupied &&
                                (mode == _BikeMode.block ? !blocked : blocked));
                        final color = selected
                            ? limeGreen
                            : occupied
                                ? indigoAmina
                                : blocked
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade300;
                        final state = occupied
                            ? 'ocupada'
                            : blocked
                                ? 'bloqueada'
                                : 'disponible';
                        return Semantics(
                          button: true,
                          selected: selected,
                          enabled: eligible && !busy,
                          label: 'Bicicleta $bicycle, $state',
                          child: Tooltip(
                            message: 'Bicicleta $bicycle · $state',
                            child: Opacity(
                              opacity: eligible ? 1 : .35,
                              child: Material(
                                color: color,
                                borderRadius: BorderRadius.circular(4),
                                child: InkWell(
                                  onTap: busy || !eligible
                                      ? null
                                      : () => _tapBike(bicycle),
                                  child: Container(
                                    width: seatWidth,
                                    height: seatWidth,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: selected
                                                ? almostBlack
                                                : Colors.black26,
                                            width: 2),
                                        borderRadius: BorderRadius.circular(4)),
                                    child: Center(
                                      child: Text(
                                        '$bicycle',
                                        style: TextStyle(
                                            fontSize: seatWidth * .3,
                                            fontWeight: FontWeight.bold,
                                            color: selected ||
                                                    (!occupied && !blocked)
                                                ? almostBlack
                                                : Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),
      );

  Widget _legend(Color color, String label) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 12)),
      ]);

  Future<void> _expandMap() async {
    await showDialog<void>(
      context: context,
      useSafeArea: true,
      builder: (dialog) => Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text('Mapa de bicicletas'),
              leading: IconButton(
                  tooltip: 'Cerrar mapa',
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(dialog))),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(instruction),
              ),
              const Text(
                  'Pellizca para ampliar y arrastra para recorrer el mapa.'),
              Expanded(
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Center(
                    child: _map(),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar:
              mode == _BikeMode.reservations ? null : _selectionBar(),
        ),
      ),
    );
  }
}

String formatHora(String rawTime) {
  final parts = rawTime.split(':');
  if (parts.length < 2) return rawTime;
  return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
}
