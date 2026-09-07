import 'package:amina_ec/src/models/class_rating_report.dart';
import 'package:amina_ec/src/pages/Admin/Reports/Ratings/admin_reports_class_ratings_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';


class AdminClassRatingsPage extends StatefulWidget {
  final VoidCallback? onBack;
  const AdminClassRatingsPage({super.key, this.onBack});

  @override
  State<AdminClassRatingsPage> createState() => _AdminClassRatingsPageState();
}

class _AdminClassRatingsPageState extends State<AdminClassRatingsPage> {
  late final AdminClassRatingsReportController con;

  @override
  void initState() {
    super.initState();
    con = Get.isRegistered<AdminClassRatingsReportController>()
        ? Get.find<AdminClassRatingsReportController>()
        : Get.put(AdminClassRatingsReportController());
  }

  List<String> get _activeFilters => [
    if (con.studentNameController.text.trim().isNotEmpty)
      'Estudiante: ${con.studentNameController.text.trim()}',
    if (con.coachNameController.text.trim().isNotEmpty)
      'Coach: ${con.coachNameController.text.trim()}',
    if (con.selectedYear.value.isNotEmpty) 'Año: ${con.selectedYear.value}',
    if (con.selectedMonth.value.isNotEmpty) con.selectedMonth.value,
    if (con.selectedDay.value.isNotEmpty) 'Día: ${con.selectedDay.value}',
    if (con.startHour.value.isNotEmpty) 'Desde: ${con.startHour.value}',
    if (con.endHour.value.isNotEmpty) 'Hasta: ${con.endHour.value}',
    if (con.selectedRating.value.isNotEmpty) '${con.selectedRating.value} estrellas',
    if (con.selectedCommentFilter.value != 'Todos') con.selectedCommentFilter.value,
  ];

  Future<void> _search() async {
    if (con.isLoading.value) return;
    // Evita conservar un reporte anterior bajo los nuevos filtros si falla la red.
    con.results.clear();
    con.coachSummary.clear();
    con.summary.value = ClassRatingReportSummary.empty();
    try {
      await con.buscar();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(content: Text('No se pudo consultar. Intenta nuevamente.')),
        );
      }
    } finally {
      con.isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        key: const PageStorageKey('admin-class-ratings-scroll'),
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            if (widget.onBack != null)
              IconButton(onPressed: widget.onBack, icon: const Icon(Icons.arrow_back)),
            Expanded(child: Text('Valoraciones', style: GoogleFonts.montserrat(
                fontSize: 22, fontWeight: FontWeight.w800, color: almostBlack))),
            Obx(() => PopupMenuButton<String>(
              tooltip: 'Exportar reporte',
              enabled: !con.isLoading.value,
              icon: const Icon(Icons.file_download_outlined),
              onSelected: (value) async {
                try {
                  if (value == 'pdf') {
                    await con.exportPDF(context);
                  } else {
                    await con.exportExcel(context);
                  }
                } catch (_) {
                  if (mounted) {
                    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                        const SnackBar(content: Text('No se pudo exportar el reporte.')));
                  }
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'pdf', child: Text('Exportar PDF')),
                PopupMenuItem(value: 'excel', child: Text('Exportar Excel')),
              ],
            )),
          ]),
          const SizedBox(height: 4),
          const Text('Consulta las opiniones y calificaciones de las clases.',
              style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 20),
          Obx(() {
            final busy = con.isLoading.value;
            final filters = _activeFilters;
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(spacing: 8, runSpacing: 8, children: [
                OutlinedButton.icon(
                  onPressed: busy ? null : _openFilters,
                  icon: const Icon(Icons.tune),
                  label: Text(filters.isEmpty ? 'Filtros' : 'Filtros (${filters.length})'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: almostBlack,
                      foregroundColor: Colors.white, minimumSize: const Size(0, 48)),
                  onPressed: busy ? null : _search,
                  icon: const Icon(Icons.search), label: const Text('Buscar'),
                ),
                if (filters.isNotEmpty)
                  TextButton(onPressed: busy ? null : () {
                    con.limpiarFiltros();
                    setState(() {});
                  }, child: const Text('Limpiar')),
              ]),
              const SizedBox(height: 8),
              if (filters.isEmpty)
                const Text('Sin filtros · La búsqueda incluye todas las valoraciones.',
                    style: TextStyle(fontSize: 12, color: Colors.black54))
              else
                SizedBox(height: 40, child: ListView.separated(
                  key: const PageStorageKey<String>('ratings-active-filters-scroll'),
                  primary: false,
                  scrollDirection: Axis.horizontal,
                  itemCount: filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (_, i) => Chip(label: Text(filters[i]),
                      backgroundColor: const Color(0xFFF1F2F5),
                      side: BorderSide.none),
                )),
            ]);
          }),
          const SizedBox(height: 20),
          _summary(),
          const SizedBox(height: 12),
          Obx(() => con.coachSummary.isEmpty ? const SizedBox.shrink() :
          ExpansionTile(
            key: const PageStorageKey('ratings-coach-summary'),
            tilePadding: EdgeInsets.zero,
            title: const Text('Resumen por coach', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('${con.coachSummary.length} coaches · Ver comparación'),
            children: [_coachSummaryCard(con)],
          )),
          const SizedBox(height: 16),
          Obx(() => Text('Resultados (${con.results.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
          const SizedBox(height: 4),
          const Text('Desliza la tabla hacia los lados para ver todas las columnas.',
              style: TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 8),
          SizedBox(height: 480, child: _resultsTableCard(con)),
        ],
      ),
    );
  }

  Widget _summary() => Obx(() {
    final s = con.summary.value;
    final values = ['${s.totalRatings}', s.averageRating.toStringAsFixed(2),
      '${s.commentedCount}', '${s.rating5Count}'];
    const labels = ['Valoraciones', 'Promedio / 5', 'Con comentario', '5 estrellas'];
    return LayoutBuilder(builder: (_, constraints) {
      final columns = constraints.maxWidth >= 700 ? 4 : 2;
      final width = (constraints.maxWidth - (columns - 1) * 10) / columns;
      return Wrap(spacing: 10, runSpacing: 10, children: List.generate(4, (i) =>
          Container(width: width, padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(values[i], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(labels[i], style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ]),
          )));
    });
  });

  Future<void> _openFilters() async {
    var student = con.studentNameController.text;
    var coach = con.coachNameController.text;
    var resetVersion = 0;
    var year = con.selectedYear.value;
    var month = con.selectedMonth.value;
    var day = con.selectedDay.value;
    var start = con.startHour.value;
    var end = con.endHour.value;
    var rating = con.selectedRating.value;
    var comments = con.selectedCommentFilter.value;
    final applied = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => StatefulBuilder(builder: (context, update) {
        Widget select(String label, String value, List<String> options,
            ValueChanged<String> change, {String empty = 'Todos'}) {
          return DropdownButtonFormField<String>(
            key: ValueKey('$label:$value'),
            value: value,
            isExpanded: true,
            decoration: InputDecoration(labelText: label, filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none)),
            items: [
              if (!options.contains('')) DropdownMenuItem(value: '', child: Text(empty)),
              ...options.map((item) => DropdownMenuItem(value: item, child: Text(item))),
            ],
            onChanged: (next) => update(() => change(next ?? '')),
          );
        }
        Widget group(String title, List<Widget> children) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 12),
              ...children.expand((child) => [child, const SizedBox(height: 12)]),
            ]));
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SafeArea(top: false, child: SizedBox(
            height: MediaQuery.of(context).size.height * .85,
            child: Column(children: [
              Padding(padding: const EdgeInsets.fromLTRB(20, 12, 8, 4),
                  child: Row(children: [
                    const Expanded(child: Text('Filtros', style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800))),
                    IconButton(tooltip: 'Cerrar sin aplicar', icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(sheetContext).pop(false)),
                  ])),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Align(alignment: Alignment.centerLeft,
                      child: Text('Selecciona solo lo que necesitas. Todo es opcional.',
                          style: TextStyle(color: Colors.black54)))),
              Expanded(child: ListView(
                  key: const PageStorageKey<String>('ratings-filter-panel-scroll'),
                  primary: false,
                  padding: const EdgeInsets.all(20), children: [
                group('Personas', [
                  TextFormField(key: ValueKey('student:$resetVersion'), initialValue: student,
                      onChanged: (v) => student = v, decoration: const InputDecoration(
                          labelText: 'Estudiante', prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder())),
                  TextFormField(key: ValueKey('coach:$resetVersion'), initialValue: coach,
                      onChanged: (v) => coach = v, decoration: const InputDecoration(
                          labelText: 'Coach', prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder())),
                ]),
                group('Fecha de la clase', [
                  select('Año', year, con.years, (v) => year = v),
                  select('Mes', month, con.months, (v) => month = v),
                  select('Día', day, con.days, (v) => day = v),
                ]),
                ExpansionTile(
                  initiallyExpanded: start.isNotEmpty || end.isNotEmpty,
                  tilePadding: EdgeInsets.zero,
                  title: const Text('Horario'),
                  subtitle: const Text('Hora inicial y final'),
                  children: [
                    select('Desde', start, con.hours, (v) => start = v),
                    const SizedBox(height: 12),
                    select('Hasta', end, con.hours, (v) => end = v),
                    const SizedBox(height: 16),
                  ],
                ),
                const SizedBox(height: 16),
                group('Valoración', [
                  select('Estrellas', rating, con.ratingOptions, (v) => rating = v),
                  select('Comentarios', comments == 'Todos' ? '' : comments,
                      con.commentOptions.where((v) => v != 'Todos').toList(),
                          (v) => comments = v.isEmpty ? 'Todos' : v),
                ]),
              ])),
              const Divider(height: 1),
              Padding(padding: const EdgeInsets.all(16), child: Row(children: [
                TextButton(onPressed: () => update(() {
                  student = coach = ''; resetVersion++;
                  year = month = day = start = end = rating = '';
                  comments = 'Todos';
                }), child: const Text('Restablecer')),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: almostBlack,
                        foregroundColor: Colors.white, minimumSize: const Size(0, 48)),
                    onPressed: () {
                      con.studentNameController.text = student.trim();
                      con.coachNameController.text = coach.trim();
                      con.selectedYear.value = year;
                      con.selectedMonth.value = month;
                      con.selectedDay.value = day;
                      con.startHour.value = start;
                      con.endHour.value = end;
                      con.selectedRating.value = rating;
                      con.selectedCommentFilter.value = comments;
                      Navigator.of(sheetContext).pop(true);
                    }, child: const Text('Aplicar y buscar'))),
              ])),
            ]),
          )),
        );
      }),
    );
    if (!mounted || applied != true) return;
    setState(() {});
    await _search();
  }
  Widget _coachSummaryCard(AdminClassRatingsReportController con) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resumen por coach',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: almostBlack,
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                key: const PageStorageKey<String>('ratings-coach-table-horizontal'),
                primary: false,
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
                  headingTextStyle: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    color: almostBlack,
                    fontSize: 12,
                  ),
                  dataTextStyle: GoogleFonts.montserrat(
                    color: Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  columns: const [
                    DataColumn(label: Text('Coach')),
                    DataColumn(label: Text('Total')),
                    DataColumn(label: Text('Promedio')),
                    DataColumn(label: Text('5★')),
                    DataColumn(label: Text('Comentarios')),
                  ],
                  rows: con.coachSummary.map((item) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            item.coachName,
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                        DataCell(
                          Text(
                            '${item.totalRatings}',
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                        DataCell(
                          Text(
                            item.averageRating.toStringAsFixed(2),
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                        DataCell(
                          Text(
                            '${item.fiveStarCount}',
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                        DataCell(
                          Text(
                            '${item.commentedCount}',
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _resultsTableCard(AdminClassRatingsReportController con) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Obx(() {
          if (con.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (con.results.isEmpty) {
            return Center(
              child: Text(
                'No hay resultados',
                style: GoogleFonts.montserrat(
                  color: Colors.grey[700],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SingleChildScrollView(
              key: const PageStorageKey<String>('ratings-results-vertical'),
              primary: false,
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                key: const PageStorageKey<String>('ratings-results-horizontal'),
                primary: false,
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(almostBlack),
                  headingTextStyle: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  dataTextStyle: GoogleFonts.montserrat(
                    color: Colors.black87,
                    fontSize: 12,
                  ),
                  columnSpacing: 16,
                  columns: const [
                    DataColumn(label: Text('Fecha')),
                    DataColumn(label: Text('Hora')),
                    DataColumn(label: Text('Estudiante')),
                    DataColumn(label: Text('Coach')),
                    DataColumn(label: Text('Rating')),
                    DataColumn(label: Text('Comentario')),
                    DataColumn(label: Text('Tema')),
                    DataColumn(label: Text('Tipo')),
                    DataColumn(label: Text('Asistencia')),
                  ],
                  rows: con.results.map((r) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            DateFormat('dd/MM/yyyy')
                                .format(DateTime.parse(r.classDate)),
                          ),
                        ),
                        DataCell(Text(r.classTime)),
                        DataCell(
                          SizedBox(
                            width: 150,
                            child: Text(r.userName),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 150,
                            child: Text(r.coachName),
                          ),
                        ),
                        DataCell(Text('⭐ ${r.rating}/5')),
                        DataCell(
                          SizedBox(
                            width: 220,
                            child: Text(
                              (r.comment ?? '').trim().isEmpty
                                  ? '-'
                                  : r.comment!,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 180,
                            child: Text(
                              (r.classTheme ?? '').trim().isEmpty
                                  ? '-'
                                  : r.classTheme!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            (r.typeClass ?? '').trim().isEmpty
                                ? '-'
                                : r.typeClass!,
                          ),
                        ),
                        DataCell(
                          Text(
                            (r.attendanceStatus ?? '').trim().isEmpty
                                ? '-'
                                : r.attendanceStatus!,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

}
