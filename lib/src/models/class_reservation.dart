import 'dart:convert';

ClassReservation classReservationFromJson(
  String source,
) {
  return ClassReservation.fromJson(
    json.decode(source),
  );
}

String classReservationToJson(
  ClassReservation reservation,
) {
  return json.encode(
    reservation.toJson(),
  );
}

class ClassReservation {
  /*
   * Datos principales de la reservación.
   */
  final String? id;
  final String? userId;
  final String? coachId;
  final String? planId;

  final int? bicycle;
  final String? classDate;
  final String? classTime;
  final String? status;

  /*
   * Datos del usuario asignado.
   *
   * El backend solo los devuelve completos
   * cuando la petición corresponde a un administrador.
   */
  final String? userName;
  final String? userEmail;
  final String? userPhotoUrl;

  /*
   * Información adicional del flujo.
   */
  final bool scheduledByAdmin;
  final bool removedByAdmin;
  final bool rideReturned;

  final String? source;

  /*
   * Resultado de sincronización con Google Calendar.
   */
  final Map<String, dynamic>? googleCalendar;

  const ClassReservation({
    this.id,
    this.userId,
    this.coachId,
    this.planId,
    this.bicycle,
    this.classDate,
    this.classTime,
    this.status,
    this.userName,
    this.userEmail,
    this.userPhotoUrl,
    this.scheduledByAdmin = false,
    this.removedByAdmin = false,
    this.rideReturned = false,
    this.source,
    this.googleCalendar,
  });

  factory ClassReservation.fromJson(
    Map<String, dynamic> json,
  ) {
    return ClassReservation(
      id: _stringValue(
        json['id'] ?? json['reservation_id'],
      ),
      userId: _stringValue(
        json['user_id'],
      ),
      coachId: _stringValue(
        json['coach_id'],
      ),
      planId: _stringValue(
        json['plan_id'],
      ),
      bicycle: _intValue(
        json['bicycle'],
      ),
      classDate: _normalizeDate(
        json['class_date'],
      ),
      classTime: _normalizeTime(
        json['class_time'],
      ),
      status: _stringValue(
        json['status'],
      ),
      userName: _stringValue(
        json['user_name'],
      ),
      userEmail: _stringValue(
        json['user_email'],
      ),
      userPhotoUrl: _stringValue(
        json['user_photo_url'],
      ),
      scheduledByAdmin: _boolValue(
        json['scheduled_by_admin'],
      ),
      removedByAdmin: _boolValue(
        json['removed_by_admin'],
      ),
      rideReturned: _boolValue(
        json['ride_returned'],
      ),
      source: _stringValue(
        json['source'],
      ),
      googleCalendar: json['google_calendar'] is Map
          ? Map<String, dynamic>.from(
              json['google_calendar'],
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reservation_id': id,
      'user_id': userId,
      'coach_id': coachId,
      'plan_id': planId,
      'bicycle': bicycle,
      'class_date': classDate,
      'class_time': classTime,
      'status': status,
      'user_name': userName,
      'user_email': userEmail,
      'user_photo_url': userPhotoUrl,
      'scheduled_by_admin': scheduledByAdmin,
      'removed_by_admin': removedByAdmin,
      'ride_returned': rideReturned,
      'source': source,
      'google_calendar': googleCalendar,
    };
  }

  /*
   * Convierte cualquier ID numérico o texto
   * en String sin generar errores de tipo.
   */
  static String? _stringValue(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    final result = value.toString().trim();

    return result.isEmpty ? null : result;
  }

  /*
   * MySQL puede devolver bicycle como int,
   * String o número decimal.
   */
  static int? _intValue(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value.toString(),
    );
  }

  static bool _boolValue(
    dynamic value,
  ) {
    if (value == true || value == 1 || value == '1') {
      return true;
    }

    if (value is String) {
      return value.toLowerCase() == 'true';
    }

    return false;
  }

  /*
   * Convierte:
   * 2026-08-05T00:00:00.000Z
   * en:
   * 2026-08-05
   */
  static String? _normalizeDate(
    dynamic value,
  ) {
    final raw = _stringValue(value);

    if (raw == null) {
      return null;
    }

    return raw.split('T').first.split(' ').first;
  }

  /*
   * Convierte:
   * 18:00:00.000000
   * en:
   * 18:00:00
   */
  static String? _normalizeTime(
    dynamic value,
  ) {
    final raw = _stringValue(value);

    if (raw == null) {
      return null;
    }

    return raw.split('.').first;
  }
}
