import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/waitlist_entry.dart';
import '../../../services/waitlist_service.dart';
import '../../../utils/color.dart';

class UserWaitlistPage extends StatefulWidget {
  const UserWaitlistPage({super.key});

  @override
  State<UserWaitlistPage> createState() => _UserWaitlistPageState();
}

class _UserWaitlistPageState extends State<UserWaitlistPage> {
  final service = WaitlistService.to;

  String? focusId;
  WaitlistEntry? focused;
  String? focusError;

  static const Color _background = Color(0xFFF7F8FA);
  static const Color _border = Color(0xFFE9ECF2);
  static const Color _muted = Color(0xFF737B8C);
  static const Color _softIndigo = Color(0xFFF0F0FA);
  static const Color _green = Color(0xFF23846B);
  static const Color _orange = Color(0xFFAD6830);
  static const Color _red = Color(0xFFCA5858);

  TextStyle _heading(double size) => GoogleFonts.montserrat(
    fontSize: size,
    fontWeight: FontWeight.w700,
    color: almostBlack,
    letterSpacing: -0.4,
    height: 1.3,
  );

  TextStyle _body({
    double size = 14,
    Color color = _muted,
    FontWeight weight = FontWeight.w400,
  }) =>
      GoogleFonts.roboto(
        fontSize: size,
        color: color,
        fontWeight: weight,
        height: 1.45,
      );

  @override
  void initState() {
    super.initState();

    final args = Get.arguments;

    if (args is Map) {
      focusId = args['queue_id']?.toString();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _refresh();
      }
    });
  }

  Future<void> _refresh() async {
    await service.refresh();

    if (focusId != null) {
      final response = await service.provider.getEntry(focusId!);

      if (!mounted) return;

      service.syncClock(response);

      setState(() {
        focused = response.success == true && response.data is Map
            ? WaitlistEntry.fromJson(
          Map<String, dynamic>.from(response.data),
        )
            : null;

        focusError =
        response.success == true ? null : response.message;
      });
    }
  }

  Future<void> _act(WaitlistEntry entry, String action) async {
    if (action != 'accept') {
      final ok = await _confirmAction(action);

      if (ok != true) return;
    }

    final response = await service.act(entry, action);

    if (!mounted) return;

    Get.snackbar(
      response.success == true
          ? 'Lista de espera'
          : 'No se completó la operación',
      response.message ?? '',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 16,
      backgroundColor: almostBlack,
      colorText: Colors.white,
      icon: Icon(
        response.success == true
            ? Icons.check_circle_outline_rounded
            : Icons.info_outline_rounded,
        color: Colors.white,
      ),
    );

    await _refresh();
  }

  Future<bool?> _confirmAction(String action) {
    final isReject = action == 'reject';

    return Get.dialog<bool>(
      AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        scrollable: true,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 24,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
        actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F0),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isReject
                    ? Icons.close_rounded
                    : Icons.logout_rounded,
                color: _red,
                size: 22,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isReject ? 'Rechazar oferta' : 'Salir de la lista',
              style: _heading(20),
            ),
          ],
        ),
        content: Text(
          isReject
              ? 'El cupo pasará a la siguiente persona en espera.'
              : 'Perderás tu lugar en esta cola.',
          style: _body(color: const Color(0xFF596174)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            style: TextButton.styleFrom(
              foregroundColor: _muted,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            child: Text(
              'Volver',
              style: _body(
                weight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            style: FilledButton.styleFrom(
              backgroundColor: _red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Confirmar',
              style: _body(
                color: Colors.white,
                weight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 72,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          tooltip: 'Volver',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: almostBlack,
            size: 22,
          ),
        ),
        title: Text(
          'Mis listas de espera',
          maxLines: 2,
          style: _heading(19),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20, left: 8),
            child: Center(
              child: SizedBox(
                width: 44,
                height: 44,
                child: Material(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: _border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: IconButton(
                    onPressed: _refresh,
                    tooltip: 'Actualizar',
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: indigoAmina,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: indigoAmina,
          backgroundColor: Colors.white,
          onRefresh: _refresh,
          child: Obx(() {
            final rows = service.entries.toList();

            if (focused != null &&
                !rows.any((e) => e.id == focused!.id)) {
              rows.add(focused!);
            }

            rows.sort((a, b) {
              if (a.id == b.id) return 0;
              if (a.id == focusId) return -1;
              if (b.id == focusId) return 1;

              return (a.active ? 0 : 1).compareTo(
                b.active ? 0 : 1,
              );
            });

            final loading = service.loading.value;
            final error = service.error.value;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _introCard(),
                        if (loading) ...[
                          const SizedBox(height: 18),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: const LinearProgressIndicator(
                              minHeight: 3,
                              color: indigoAmina,
                              backgroundColor: _softIndigo,
                            ),
                          ),
                        ],
                        if (error != null) ...[
                          const SizedBox(height: 16),
                          _errorCard(error),
                        ],
                        if (focusError != null) ...[
                          const SizedBox(height: 16),
                          _errorCard(focusError!),
                        ],
                        const SizedBox(height: 26),
                        Text(
                          'Tus solicitudes',
                          style: _heading(19),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Consulta tu lugar y las ofertas de cupo.',
                          style: _body(),
                        ),
                        const SizedBox(height: 16),
                        if (rows.isEmpty &&
                            !loading &&
                            error == null &&
                            focusError == null)
                          _emptyState(),
                        for (final entry in rows)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _card(entry),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _introCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _softIndigo,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: indigoAmina.withOpacity(0.08),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.format_list_numbered_rounded,
              color: indigoAmina,
              size: 21,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Espera tu próximo ride',
                  style: _body(
                    color: almostBlack,
                    weight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Entrar a la cola no consume un ride. '
                      'Al aceptar se confirma la reserva y se '
                      'descuenta un ride de un plan compatible.',
                  style: _body(
                    size: 13,
                    color: const Color(0xFF626780),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _red.withOpacity(0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: _red,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: _body(size: 13, color: _red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 34,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _softIndigo,
              borderRadius: BorderRadius.circular(21),
            ),
            child: const Icon(
              Icons.format_list_numbered_rounded,
              color: indigoAmina,
              size: 28,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Tu lista está vacía',
            textAlign: TextAlign.center,
            style: _heading(18),
          ),
          const SizedBox(height: 9),
          Text(
            'No tienes listas de espera activas '
                'ni movimientos recientes.',
            textAlign: TextAlign.center,
            style: _body(),
          ),
        ],
      ),
    );
  }

  String _formattedDate(String value) {
    final date = value.split('T').first;
    final parts = date.split('-');

    if (parts.length == 3 && parts.first.length == 4) {
      return parts.reversed.join('/');
    }

    return date;
  }

  Color _statusColor(WaitlistEntry entry, bool valid) {
    if (entry.status == 'accepted') return _green;
    if (entry.status == 'offered' && valid) return _orange;
    if (entry.status == 'waiting') return indigoAmina;

    return _muted;
  }

  IconData _statusIcon(WaitlistEntry entry, bool valid) {
    if (entry.status == 'accepted') {
      return Icons.check_circle_outline_rounded;
    }

    if (entry.status == 'offered') {
      return valid
          ? Icons.pedal_bike_rounded
          : Icons.timer_off_outlined;
    }

    if (entry.status == 'waiting') {
      return Icons.hourglass_empty_rounded;
    }

    return Icons.info_outline_rounded;
  }

  Widget _card(WaitlistEntry e) {
    final busy = service.busyIds.contains(e.id);
    final valid = e.canAccept(service.now.value);
    final isFocused = e.id == focusId;
    final statusColor = _statusColor(e, valid);

    final formattedTime = e.classTime.length >= 5
        ? e.classTime.substring(0, 5)
        : e.classTime;

    final statusText = e.status == 'waiting'
        ? 'En espera${e.position == null ? '' : ' · Lugar ${e.position}'}'
        : e.statusLabel;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isFocused ? indigoAmina : _border,
          width: isFocused ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _infoChip(
                icon: Icons.calendar_today_outlined,
                text: _formattedDate(e.classDate),
              ),
              _infoChip(
                icon: Icons.schedule_rounded,
                text: formattedTime,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            e.coachName,
            style: _heading(17),
          ),
          const SizedBox(height: 5),
          Text(
            e.theme ?? 'Clase',
            style: _body(size: 13),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _statusIcon(e, valid),
                  color: statusColor,
                  size: 16,
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    statusText,
                    style: _body(
                      size: 12,
                      color: statusColor,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (e.status == 'offered') ...[
            const SizedBox(height: 14),
            _offerDetails(e, valid),
          ],
          if (e.closeReason?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Text(
              e.closeReason!,
              style: _body(size: 13),
            ),
          ],
          if (e.status == 'accepted') ...[
            const SizedBox(height: 12),
            Text(
              'Reserva #${e.reservationId ?? ''}',
              style: _body(
                size: 13,
                weight: FontWeight.w500,
              ),
            ),
          ],
          if (e.active || e.status == 'accepted') ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(
                height: 1,
                thickness: 1,
                color: _border,
              ),
            ),
            if (e.active) _entryActions(e, busy, valid),
            if (e.status == 'accepted')
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Get.offAllNamed('/user/home'),
                  icon: const Icon(
                    Icons.event_available_outlined,
                    size: 19,
                  ),
                  label: const Text('Ver mis reservas'),
                  style: _outlineButtonStyle(),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: indigoAmina),
          const SizedBox(width: 7),
          Text(
            text,
            style: _body(
              size: 12,
              color: almostBlack,
              weight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _offerDetails(WaitlistEntry e, bool valid) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: valid
            ? const Color(0xFFFFF8EF)
            : _background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            valid
                ? Icons.pedal_bike_rounded
                : Icons.timer_off_outlined,
            color: valid ? _orange : _muted,
            size: 22,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  valid
                      ? 'Bicicleta #${e.bicycle}'
                      : 'La oferta venció',
                  style: _body(
                    size: 14,
                    color: almostBlack,
                    weight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  valid
                      ? 'Confirma en ${e.remainingLabel(service.now.value)}'
                      : 'Actualiza para consultar el siguiente estado.',
                  style: _body(
                    size: 13,
                    color: valid ? _orange : _muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _entryActions(
      WaitlistEntry e,
      bool busy,
      bool valid,
      ) {
    final isOffered = e.status == 'offered';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isOffered) ...[
          FilledButton(
            onPressed:
            busy || !valid ? null : () => _act(e, 'accept'),
            style: FilledButton.styleFrom(
              backgroundColor: indigoAmina,
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFECEEF3),
              disabledForegroundColor: _muted,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
              textStyle: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Text(
              busy ? 'Confirmando…' : 'Aceptar bicicleta',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
        ],
        OutlinedButton(
          onPressed: busy
              ? null
              : () => _act(
            e,
            isOffered ? 'reject' : 'cancel',
          ),
          style: _outlineButtonStyle(
            color: isOffered ? _red : _muted,
          ),
          child: Text(
            isOffered ? 'Rechazar oferta' : 'Salir de la lista',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  ButtonStyle _outlineButtonStyle({
    Color color = indigoAmina,
  }) {
    return OutlinedButton.styleFrom(
      foregroundColor: color,
      disabledForegroundColor: const Color(0xFFB5BBC7),
      side: const BorderSide(color: _border),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(13),
      ),
      textStyle: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}