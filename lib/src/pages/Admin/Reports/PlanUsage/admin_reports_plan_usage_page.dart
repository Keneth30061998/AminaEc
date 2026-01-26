import 'package:amina_ec/src/models/plan_usage_event.dart';
import 'package:amina_ec/src/pages/Admin/Reports/PlanUsage/admin_reports_plan_usage_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AdminUserHistoryPage extends StatelessWidget {
  final AdminUserHistoryController con = Get.put(AdminUserHistoryController());

  AdminUserHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = con.targetUser; // no es Rx, ok

    return Scaffold(
      backgroundColor: const Color(0xfff9f9f9),
      appBar: AppBar(
        title: const Text('Histórico del usuario'),
        centerTitle: true,
        backgroundColor: whiteLight,
        surfaceTintColor: whiteLight,
        forceMaterialTransparency: true,
      ),
      body: Column(
        children: [
          // --------------------------
          // Header: usuario
          // --------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundImage:
                    (user.photo_url != null && user.photo_url!.isNotEmpty)
                        ? NetworkImage(user.photo_url!)
                        : null,
                    backgroundColor: Colors.grey[200],
                    child: (user.photo_url == null || user.photo_url!.isEmpty)
                        ? const Icon(Icons.person, color: Colors.black54)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${user.name ?? ''} ${user.lastname ?? ''}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: almostBlack,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.email ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --------------------------
          // Filtros (Obx correcto)
          // --------------------------
          Obx(() {
            final f = con.filter.value; // ✅ Rx leído dentro del Obx
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip('ALL', 'Todos', f == 'ALL'),
                  _chip('PLAN', 'Planes', f == 'PLAN'),
                  _chip('CLASS', 'Clases', f == 'CLASS'),
                  _chip('ATTENDANCE', 'Asistencia', f == 'ATTENDANCE'),
                ],
              ),
            );
          }),

          const SizedBox(height: 8),

          // --------------------------
          // Lista (timeline agrupado por día)
          // --------------------------
          Expanded(
            child: Obx(() {
              if (con.loading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (con.error.value != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      con.error.value!,
                      style: GoogleFonts.poppins(color: Colors.redAccent),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final list = con.filteredEvents; // ✅ lee Rx internamente (events + filter)
              if (list.isEmpty) {
                return RefreshIndicator(
                  color: almostBlack,
                  onRefresh: con.fetchHistory,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 140),
                      Center(child: Text('No hay eventos para mostrar')),
                    ],
                  ),
                );
              }

              // Agrupar por día (según occurredAt local)
              final fmtDayKey = DateFormat('yyyy-MM-dd');
              final fmtDayLabel = DateFormat('dd/MM/yyyy');
              final Map<String, List<PlanUsageEvent>> grouped = {};

              for (final e in list) {
                final d = e.occurredAt.toLocal();
                final key = fmtDayKey.format(d);
                grouped.putIfAbsent(key, () => []);
                grouped[key]!.add(e);
              }

              final keys = grouped.keys.toList()
                ..sort((a, b) => b.compareTo(a)); // descendente (más reciente arriba)

              return RefreshIndicator(
                color: almostBlack,
                onRefresh: con.fetchHistory,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: keys.length,
                  itemBuilder: (_, idx) {
                    final key = keys[idx];
                    final events = grouped[key]!;
                    final day = DateTime.parse(key);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DayHeader(label: fmtDayLabel.format(day)),
                        const SizedBox(height: 10),
                        ...events.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _EventCard(e: e),
                        )),
                        const SizedBox(height: 6),
                      ],
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _chip(String value, String label, bool selected) {
    return ChoiceChip(
      selected: selected,
      label: Text(label),
      labelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: selected ? Colors.white : Colors.black87,
      ),
      selectedColor: almostBlack,
      backgroundColor: Colors.white,
      onSelected: (_) => con.setFilter(value),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}

class _DayHeader extends StatelessWidget {
  final String label;
  const _DayHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: almostBlack,
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final PlanUsageEvent e;
  const _EventCard({required this.e});

  @override
  Widget build(BuildContext context) {
    final fmtTime = DateFormat('HH:mm');
    final occurred = fmtTime.format(e.occurredAt.toLocal());

    // “Detalles” de clase si existen
    final fmtDay = DateFormat('dd/MM/yyyy');
    String? classInfo;
    if (e.classDate != null && e.classTime != null) {
      final cd = fmtDay.format(e.classDate!.toLocal());
      classInfo = '$cd • ${e.classTime}';
    }

    final coachInfo = (e.coachName != null) ? 'Coach: ${e.coachName}' : null;
    final bikeInfo = (e.bicycle != null) ? 'Bici: ${e.bicycle}' : null;

    final meta = _eventMeta(e.eventType);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: meta.bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(meta.icon, color: meta.fg, size: 20),
          ),
          const SizedBox(width: 10),

          // Contenido
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + hora
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        e.title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: almostBlack,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      occurred,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Tag (tipo)
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Text(
                    meta.label,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),

                // Plan info
                if (e.planName != null) ...[
                  const SizedBox(height: 8),
                  _kv('Plan', e.planName!),
                  if (e.remainingRides != null) _kv('Rides restantes', '${e.remainingRides}'),
                ],

                // Clase info
                if (classInfo != null || coachInfo != null || bikeInfo != null) ...[
                  const SizedBox(height: 8),
                  if (classInfo != null) _kv('Clase', classInfo),
                  if (coachInfo != null) _kvRaw(coachInfo),
                  if (bikeInfo != null) _kvRaw(bikeInfo),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        '$k: $v',
        style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
      ),
    );
  }

  Widget _kvRaw(String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        v,
        style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
      ),
    );
  }

  _EventMeta _eventMeta(String? type) {
    // Mantengo un mapeo “amigable” sin depender de colores raros.
    // Usa tus constantes: almostBlack, indigoAmina, pinkAmina, etc.
    final t = (type ?? '').toUpperCase();

    if (t.contains('PLAN')) {
      return _EventMeta(
        label: 'Plan',
        icon: Icons.workspace_premium_outlined,
        bg: Colors.grey[100]!,
        fg: almostBlack,
      );
    }
    if (t.contains('CANCEL')) {
      return _EventMeta(
        label: 'Clase cancelada',
        icon: Icons.event_busy_outlined,
        bg: Colors.grey[100]!,
        fg: almostBlack,
      );
    }
    if (t.contains('RESERV')) {
      return _EventMeta(
        label: 'Clase reservada',
        icon: Icons.event_available_outlined,
        bg: Colors.grey[100]!,
        fg: almostBlack,
      );
    }
    if (t.contains('ATTEND')) {
      return _EventMeta(
        label: 'Asistencia',
        icon: Icons.fact_check_outlined,
        bg: Colors.grey[100]!,
        fg: almostBlack,
      );
    }

    // default
    return _EventMeta(
      label: 'Evento',
      icon: Icons.bolt_outlined,
      bg: Colors.grey[100]!,
      fg: almostBlack,
    );
  }
}

class _EventMeta {
  final String label;
  final IconData icon;
  final Color bg;
  final Color fg;

  _EventMeta({
    required this.label,
    required this.icon,
    required this.bg,
    required this.fg,
  });
}
