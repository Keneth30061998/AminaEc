import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../models/transaction_report.dart';
import '../../../../utils/color.dart';
import '../../../../utils/iconos.dart';
import 'admin_transactions_controller.dart';

class AdminTransactionsPage extends StatefulWidget {
  const AdminTransactionsPage({super.key});

  @override
  State<AdminTransactionsPage> createState() => _AdminTransactionsPageState();
}

class _AdminTransactionsPageState extends State<AdminTransactionsPage> {
  late AdminTransactionsController txCon;

  @override
  void initState() {
    super.initState();

    if (!Get.isRegistered<AdminTransactionsController>()) {
      txCon = Get.put(AdminTransactionsController(), permanent: true);
    } else {
      txCon = Get.find<AdminTransactionsController>();
    }
  }

  @override
  void dispose() {
    if (Get.isRegistered<AdminTransactionsController>()) {
      Get.delete<AdminTransactionsController>(force: true);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Reporte de Transacciones',
          style: GoogleFonts.montserrat(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: almostBlack,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: darkGrey, size: 21),
            onPressed: () => txCon.exportPDF(context),
            tooltip: 'Exportar PDF',
          ),
          IconButton(
            icon: const Icon(Icons.grid_on, color: darkGrey, size: 21),
            onPressed: () => txCon.exportExcel(context),
            tooltip: 'Exportar Excel',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            _filterSection(context),
            const SizedBox(height: 6),
            _summarySection(),
            const SizedBox(height: 6),
            Expanded(child: _transactionsList()),
            _totalFooter(),
          ],
        ),
      ),
    );
  }

  Widget _filterSection(BuildContext context) {
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.only(top: 6),
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _modernSelector(
                    label: 'Año',
                    value: txCon.selectedYear,
                    icon: Icons.calendar_today_outlined,
                    items: txCon.years,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _modernSelector(
                    label: 'Mes',
                    value: txCon.selectedMonth,
                    icon: Icons.event_note_outlined,
                    items: txCon.months,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _modernSelector(
                    label: 'Día',
                    value: txCon.selectedDay,
                    icon: Icons.today_outlined,
                    items: txCon.days,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _modernSelector(
                    label: 'Estado',
                    value: txCon.selectedStatus,
                    icon: Icons.verified_outlined,
                    items: txCon.statuses,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 36,
              child: ElevatedButton.icon(
                onPressed: txCon.buscar,
                icon: Icon(
                  iconSearch,
                  color: whiteLight,
                  size: 16,
                ),
                label: Text(
                  'Buscar',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: almostBlack,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modernSelector({
    required String label,
    required RxString value,
    required IconData icon,
    required List<String> items,
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

        if (selected != null) value.value = selected;
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.grey[700],
              size: 15,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.montserrat(
                      color: Colors.grey[600],
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Obx(
                        () => Text(
                      value.value.isEmpty ? 'Todos' : value.value,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: almostBlack,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_drop_down,
              color: Colors.grey,
              size: 18,
            ),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: almostBlack,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 280,
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final item = items[i];
                  final isSelected = item == selected;

                  return ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    title: Text(
                      item,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? almostBlack : Colors.grey[800],
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                      Icons.check_circle,
                      color: almostBlack,
                      size: 19,
                    )
                        : null,
                    onTap: () => Get.back(result: item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summarySection() {
    return Obx(
          () => Row(
        children: [
          Expanded(
            child: _summaryCard(
              title: 'Aprobado',
              value: '\$${txCon.totalApprovedAmount.value.toStringAsFixed(2)}',
              icon: Icons.attach_money,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _summaryCard(
              title: 'Trans.',
              value: txCon.totalTransactions.value.toString(),
              icon: Icons.receipt_long,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _summaryCard(
              title: 'Diferidos',
              value: txCon.deferredCount.value.toString(),
              icon: Icons.calendar_month,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 14,
              color: almostBlack,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: almostBlack,
                  ),
                ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                    fontSize: 8.5,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionsList() {
    return Obx(() {
      if (txCon.transactions.isEmpty) {
        return Center(
          child: Text(
            'No hay resultados',
            style: GoogleFonts.montserrat(
              color: Colors.grey[700],
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }

      return ListView.builder(
        itemCount: txCon.transactions.length,
        itemBuilder: (_, index) {
          final tx = txCon.transactions[index];
          return _transactionCard(tx);
        },
      );
    });
  }

  Widget _transactionCard(TransactionReport tx) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: almostBlack,
                child: Text(
                  tx.name.isNotEmpty ? tx.name[0].toUpperCase() : '?',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.nombreCompleto,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: almostBlack,
                      ),
                    ),
                    Text(
                      '${tx.ci} • ${tx.email}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(
                        fontSize: 10.5,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              _statusChip(tx.estadoLabel, tx.estado),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            tx.planComprado,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.montserrat(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: almostBlack,
            ),
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              _infoChip(Icons.event, dateFormat.format(tx.fecha)),
              const SizedBox(width: 6),
              _infoChip(Icons.payment, tx.tipoPagoLabel),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Expanded(
                child: _detailItem(
                  label: 'Subtotal',
                  value: '\$${tx.subtotal.toStringAsFixed(2)}',
                ),
              ),
              Expanded(
                child: _detailItem(
                  label: 'IVA',
                  value: '\$${tx.iva.toStringAsFixed(2)}',
                ),
              ),
              Expanded(
                child: _detailItem(
                  label: 'Total',
                  value: '\$${tx.total.toStringAsFixed(2)}',
                  isStrong: true,
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          Row(
            children: [
              Expanded(
                child: _miniText(
                  'Cuotas',
                  tx.cuotasSolicitadas > 1
                      ? '${tx.cuotasSolicitadas} meses'
                      : 'Pago directo',
                ),
              ),
              Expanded(
                child: _miniText(
                  'Tarjeta',
                  tx.tipoTarjetaLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: _miniText(
                  'Banco',
                  tx.banco.isEmpty ? 'No identificado' : tx.banco,
                ),
              ),
              Expanded(
                child: _miniText(
                  'Referencia',
                  tx.referenciaOrden.isEmpty
                      ? 'Sin referencia'
                      : tx.referenciaOrden,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String label, String status) {
    Color background;
    Color foreground;

    final value = status.toLowerCase();

    if (value == 'approved') {
      background = Colors.green.shade50;
      foreground = Colors.green.shade700;
    } else if (value == 'rejected') {
      background = Colors.red.shade50;
      foreground = Colors.red.shade700;
    } else {
      background = Colors.orange.shade50;
      foreground = Colors.orange.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          color: foreground,
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 13,
              color: Colors.grey[700],
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  fontSize: 9.8,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailItem({
    required String label,
    required String value,
    bool isStrong = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 9.5,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: isStrong ? 13.5 : 11.5,
            fontWeight: isStrong ? FontWeight.w900 : FontWeight.w700,
            color: almostBlack,
          ),
        ),
      ],
    );
  }

  Widget _miniText(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 9.5,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.montserrat(
            fontSize: 10.5,
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _totalFooter() {
    return Obx(
          () => Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 6),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: almostBlack,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            'Total aprobado: \$${txCon.totalApprovedAmount.value.toStringAsFixed(2)}',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}