import 'package:amina_ec/src/pages/Admin/Reports/Ratings/admin_reports_class_ratings_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AdminClassRatingsPage extends StatelessWidget {
  const AdminClassRatingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AdminClassRatingsReportController>()) {
      Get.put(AdminClassRatingsReportController());
    }

    final con = Get.find<AdminClassRatingsReportController>();

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 700;
          final tableHeight = isMobile ? 420.0 : 520.0;

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              _topBar(context, con),
              const SizedBox(height: 10),
              _filterSection(context, con, isMobile),
              const SizedBox(height: 10),
              _summarySection(con, isMobile),
              const SizedBox(height: 10),
              Obx(() {
                if (con.coachSummary.isEmpty) return const SizedBox.shrink();
                return Column(
                  children: [
                    _coachSummaryCard(con),
                    const SizedBox(height: 10),
                  ],
                );
              }),
              SizedBox(
                height: tableHeight,
                child: _resultsTableCard(con),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _topBar(BuildContext context, AdminClassRatingsReportController con) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Reporte de Calificaciones',
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: almostBlack,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: darkGrey),
            onPressed: () => con.exportPDF(context),
            tooltip: 'Exportar PDF',
          ),
          IconButton(
            icon: const Icon(Icons.grid_on, color: darkGrey),
            onPressed: () => con.exportExcel(context),
            tooltip: 'Exportar Excel',
          ),
        ],
      ),
    );
  }

  Widget _filterSection(
      BuildContext context,
      AdminClassRatingsReportController con,
      bool isMobile,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tune_rounded, color: almostBlack, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Filtros de búsqueda',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: almostBlack,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _boxField(
                  width: isMobile ? double.infinity : 250,
                  child: _textField(
                    controller: con.studentNameController,
                    label: 'Estudiante',
                    icon: Icons.person_outline,
                  ),
                ),
                _boxField(
                  width: isMobile ? double.infinity : 250,
                  child: _textField(
                    controller: con.coachNameController,
                    label: 'Coach',
                    icon: Icons.sports_gymnastics_outlined,
                  ),
                ),
                _boxField(
                  width: isMobile ? 150 : 150,
                  child: _selector(
                    context: context,
                    label: 'Año',
                    value: con.selectedYear,
                    items: con.years,
                    icon: Icons.calendar_today_outlined,
                  ),
                ),
                _boxField(
                  width: isMobile ? 170 : 180,
                  child: _selector(
                    context: context,
                    label: 'Mes',
                    value: con.selectedMonth,
                    items: con.months,
                    icon: Icons.date_range_outlined,
                  ),
                ),
                _boxField(
                  width: isMobile ? 120 : 120,
                  child: _selector(
                    context: context,
                    label: 'Día',
                    value: con.selectedDay,
                    items: con.days,
                    icon: Icons.today_outlined,
                  ),
                ),
                _boxField(
                  width: isMobile ? 145 : 145,
                  child: _selector(
                    context: context,
                    label: 'Desde',
                    value: con.startHour,
                    items: con.hours,
                    icon: Icons.schedule_outlined,
                  ),
                ),
                _boxField(
                  width: isMobile ? 145 : 145,
                  child: _selector(
                    context: context,
                    label: 'Hasta',
                    value: con.endHour,
                    items: con.hours,
                    icon: Icons.schedule_outlined,
                  ),
                ),
                _boxField(
                  width: isMobile ? 130 : 130,
                  child: _selector(
                    context: context,
                    label: 'Rating',
                    value: con.selectedRating,
                    items: con.ratingOptions,
                    icon: Icons.star_border_rounded,
                  ),
                ),
                _boxField(
                  width: isMobile ? double.infinity : 220,
                  child: _selector(
                    context: context,
                    label: 'Comentarios',
                    value: con.selectedCommentFilter,
                    items: con.commentOptions,
                    icon: Icons.mode_comment_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                SizedBox(
                  width: 210,
                  child: ElevatedButton.icon(
                    onPressed: con.buscar,
                    icon: const Icon(Icons.search, color: Colors.white),
                    label: Text(
                      'Buscar',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: almostBlack,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 170,
                  child: OutlinedButton.icon(
                    onPressed: con.limpiarFiltros,
                    icon: const Icon(Icons.cleaning_services_outlined),
                    label: Text(
                      'Limpiar',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: almostBlack,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summarySection(
      AdminClassRatingsReportController con,
      bool isMobile,
      ) {
    return Obx(() {
      final s = con.summary.value;

      final cards = [
        _metricCard('Total', '${s.totalRatings}', Icons.poll_outlined),
        _metricCard(
          'Promedio',
          s.averageRating.toStringAsFixed(2),
          Icons.star_rounded,
        ),
        _metricCard('Comentarios', '${s.commentedCount}', Icons.comment),
        _metricCard('5 estrellas', '${s.rating5Count}', Icons.workspace_premium),
      ];

      if (isMobile) {
        return Column(
          children: cards
              .map(
                (card) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: card,
            ),
          )
              .toList(),
        );
      }

      return Row(
        children: List.generate(cards.length, (index) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index == cards.length - 1 ? 0 : 10),
              child: cards[index],
            ),
          );
        }),
      );
    });
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
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
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

  Widget _metricCard(String title, String value, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.black12,
              child: Icon(icon, color: almostBlack),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: almostBlack,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _boxField({
    required double width,
    required Widget child,
  }) {
    if (width == double.infinity) return child;
    return SizedBox(width: width, child: child);
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        isDense: true,
      ),
    );
  }

  Widget _selector({
    required BuildContext context,
    required String label,
    required RxString value,
    required List<String> items,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () async {
        final selected = await showDialog<String>(
          context: context,
          builder: (_) => _simpleListDialog(
            title: 'Seleccionar $label',
            items: items,
            selected: value.value,
          ),
        );

        if (selected != null) {
          value.value = selected;
        }
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[700], size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Obx(
                    () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.montserrat(
                        color: Colors.grey[600],
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value.value.isEmpty ? 'Seleccionar' : value.value,
                      style: GoogleFonts.montserrat(
                        color: almostBlack,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _simpleListDialog({
    required String title,
    required List<String> items,
    required String selected,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: almostBlack,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final item = items[i];
                    final isSelected = item == selected;
                    return ListTile(
                      title: Text(
                        item,
                        style: GoogleFonts.montserrat(
                          fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: almostBlack)
                          : null,
                      onTap: () => Get.back(result: item),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}