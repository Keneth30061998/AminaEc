class PlanUsageEvent {
  final String eventType;
  final DateTime occurredAt;
  final int userId;

  final int? userPlanId;
  final int? planDefId;
  final String? planName;
  final int? remainingRides;
  final DateTime? startDate;
  final DateTime? endDate;

  final int? classReservationId;
  final int? attendanceId;

  final int? coachId;
  final String? coachName;

  final int? bicycle;
  final DateTime? classDate;
  final String? classTime;

  final String? reservationStatus;
  final String? attendanceStatus;

  PlanUsageEvent({
    required this.eventType,
    required this.occurredAt,
    required this.userId,
    this.userPlanId,
    this.planDefId,
    this.planName,
    this.remainingRides,
    this.startDate,
    this.endDate,
    this.classReservationId,
    this.attendanceId,
    this.coachId,
    this.coachName,
    this.bicycle,
    this.classDate,
    this.classTime,
    this.reservationStatus,
    this.attendanceStatus,
  });

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    try {
      return DateTime.parse(v.toString());
    } catch (_) {
      return null;
    }
  }

  factory PlanUsageEvent.fromJson(Map<String, dynamic> json) {
    return PlanUsageEvent(
      eventType: (json["event_type"] ?? "").toString(),
      occurredAt: DateTime.parse(json["occurred_at"].toString()),
      userId: (json["user_id"] is int)
          ? json["user_id"]
          : int.tryParse(json["user_id"].toString()) ?? 0,

      userPlanId: json["user_plan_id"] == null
          ? null
          : int.tryParse(json["user_plan_id"].toString()),
      planDefId: json["plan_def_id"] == null
          ? null
          : int.tryParse(json["plan_def_id"].toString()),
      planName: json["plan_name"]?.toString(),
      remainingRides: json["remaining_rides"] == null
          ? null
          : int.tryParse(json["remaining_rides"].toString()),
      startDate: _parseDate(json["start_date"]),
      endDate: _parseDate(json["end_date"]),

      classReservationId: json["class_reservation_id"] == null
          ? null
          : int.tryParse(json["class_reservation_id"].toString()),
      attendanceId: json["attendance_id"] == null
          ? null
          : int.tryParse(json["attendance_id"].toString()),

      coachId: json["coach_id"] == null
          ? null
          : int.tryParse(json["coach_id"].toString()),
      coachName: json["coach_name"]?.toString(),

      bicycle: json["bicycle"] == null
          ? null
          : int.tryParse(json["bicycle"].toString()),
      classDate: _parseDate(json["class_date"]),
      classTime: json["class_time"]?.toString(),

      reservationStatus: json["reservation_status"]?.toString(),
      attendanceStatus: json["attendance_status"]?.toString(),
    );
  }

  bool get isClassEvent =>
      eventType == "CLASS_RESERVED" || eventType == "CLASS_CANCELLED" || eventType == "CLASS_ATTENDED";

  bool get isAttendanceEvent => eventType == "ATTENDANCE_MARKED";

  bool get isPlanEvent => eventType == "PLAN_PURCHASED" || eventType == "PLAN_ACTIVATED";

  String get title {
    switch (eventType) {
      case "PLAN_PURCHASED":
        return "Plan comprado";
      case "PLAN_ACTIVATED":
        return "Plan activado";
      case "CLASS_RESERVED":
        return "Clase reservada";
      case "CLASS_CANCELLED":
        return "Clase cancelada";
      case "CLASS_ATTENDED":
        return "Clase asistida";
      case "ATTENDANCE_MARKED":
        return attendanceStatus == "present" ? "Asistencia marcada: presente" : "Asistencia marcada: ausente";
      default:
        return eventType;
    }
  }
}
