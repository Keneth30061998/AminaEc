class TransactionReport {
  final int id;
  final String name;
  final String lastname;
  final String email;
  final double subtotal;
  final double iva;
  final double total;
  final DateTime fecha;

  TransactionReport({
    required this.id,
    required this.name,
    required this.lastname,
    required this.email,
    required this.subtotal,
    required this.iva,
    required this.total,
    required this.fecha,
  });

  factory TransactionReport.fromJson(Map<String, dynamic> json) =>
      TransactionReport(
        id: json['id'],
        name: json['name'],
        lastname: json['lastname'],
        email: json['email'],
        subtotal: double.parse(json['subtotal'].toString()),
        iva: double.parse(json['iva'].toString()),
        total: double.parse(json['total'].toString()),
        fecha: DateTime.parse(json['fecha']),
      );
}
