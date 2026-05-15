class TransactionReport {
  final int id;
  final String name;
  final String lastname;
  final String ci;
  final String email;
  final String planComprado;
  final double subtotal;
  final double iva;
  final double total;
  final DateTime fecha;
  final String estado;
  final String referenciaOrden;
  final String tipoPago;
  final String tipoPagoLabel;
  final int cuotasSolicitadas;
  final String banco;
  final String tipoTarjeta;
  final String marcaTarjeta;
  final String tarjetaLast4;

  TransactionReport({
    required this.id,
    required this.name,
    required this.lastname,
    required this.ci,
    required this.email,
    required this.planComprado,
    required this.subtotal,
    required this.iva,
    required this.total,
    required this.fecha,
    required this.estado,
    required this.referenciaOrden,
    required this.tipoPago,
    required this.tipoPagoLabel,
    required this.cuotasSolicitadas,
    required this.banco,
    required this.tipoTarjeta,
    required this.marcaTarjeta,
    required this.tarjetaLast4,
  });

  String get nombreCompleto => '$name $lastname'.trim();

  bool get isApproved => estado.toLowerCase() == 'approved';
  bool get isRejected => estado.toLowerCase() == 'rejected';

  String get estadoLabel {
    final value = estado.toLowerCase();

    if (value == 'approved') return 'Aprobado';
    if (value == 'rejected') return 'Rechazado';
    if (value == 'unknown') return 'Desconocido';

    return estado.isEmpty ? 'Sin estado' : estado;
  }

  String get tipoTarjetaLabel {
    final value = tipoTarjeta.toLowerCase().trim();

    if (value == 'credit') return 'Crédito';

    // Regla solicitada:
    // si viene null, vacío, "null" o cualquier valor no identificado,
    // se trata como débito.
    return 'Débito';
  }

  String get tarjetaResumen {
    final marca = marcaTarjeta.isEmpty ? 'Tarjeta' : marcaTarjeta.toUpperCase();
    final last4 = tarjetaLast4.isEmpty ? '----' : tarjetaLast4;

    return '$marca •••• $last4';
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    return double.tryParse(value.toString()) ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    return int.tryParse(value.toString()) ?? 0;
  }

  static String _toString(dynamic value) {
    if (value == null) return '';
    if (value.toString().toLowerCase() == 'null') return '';
    return value.toString();
  }

  static DateTime _toDate(dynamic value) {
    if (value == null) return DateTime.now();

    final raw = value.toString();

    try {
      return DateTime.parse(raw);
    } catch (_) {
      return DateTime.tryParse(raw.replaceAll(' ', 'T')) ?? DateTime.now();
    }
  }

  factory TransactionReport.fromJson(Map<String, dynamic> json) {
    return TransactionReport(
      id: _toInt(json['id']),
      name: _toString(json['name']),
      lastname: _toString(json['lastname']),
      ci: _toString(json['ci']),
      email: _toString(json['email']),
      planComprado: _toString(json['plan_comprado']),
      subtotal: _toDouble(json['subtotal']),
      iva: _toDouble(json['iva']),
      total: _toDouble(json['total']),
      fecha: _toDate(json['fecha']),
      estado: _toString(json['estado']),
      referenciaOrden: _toString(json['referencia_orden']),
      tipoPago: _toString(json['tipo_pago']),
      tipoPagoLabel: _toString(json['tipo_pago_label']),
      cuotasSolicitadas: _toInt(json['cuotas_solicitadas']),
      banco: _toString(json['banco']),
      tipoTarjeta: _toString(json['tipo_tarjeta']),
      marcaTarjeta: _toString(json['marca_tarjeta']),
      tarjetaLast4: _toString(json['tarjeta_last4']),
    );
  }
}