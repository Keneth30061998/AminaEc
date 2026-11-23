class WaitlistEntry {
  final String id,
      scheduleId,
      userId,
      coachId,
      coachName,
      classDate,
      classTime,
      status;
  final String? userName, userEmail, closeReason, reservationId, theme;
  final int? bicycle, position;
  final DateTime? createdAt, expiresAt;
  const WaitlistEntry(
      {required this.id,
      required this.scheduleId,
      required this.userId,
      required this.coachId,
      required this.coachName,
      required this.classDate,
      required this.classTime,
      required this.status,
      this.userName,
      this.userEmail,
      this.closeReason,
      this.reservationId,
      this.theme,
      this.bicycle,
      this.position,
      this.createdAt,
      this.expiresAt});
  factory WaitlistEntry.fromJson(Map<String, dynamic> j) => WaitlistEntry(
      id: '${j['id'] ?? j['queue_id'] ?? ''}',
      scheduleId: '${j['schedule_id'] ?? ''}',
      userId: '${j['user_id'] ?? ''}',
      coachId: '${j['coach_id'] ?? ''}',
      coachName: '${j['coach_name'] ?? 'Coach'}',
      classDate: '${j['class_date'] ?? ''}'.split('T').first,
      classTime: normalizeTime('${j['class_time'] ?? ''}'),
      status: '${j['status'] ?? ''}',
      userName: j['user_name']?.toString(),
      userEmail: j['user_email']?.toString(),
      closeReason: j['close_reason']?.toString(),
      reservationId: j['reservation_id']?.toString(),
      theme: j['class_theme']?.toString(),
      bicycle: int.tryParse('${j['bicycle']}'),
      position: int.tryParse('${j['position']}'),
      createdAt: DateTime.tryParse('${j['created_at']}')?.toUtc(),
      expiresAt: DateTime.tryParse('${j['offer_expires_at']}')?.toUtc());
  WaitlistEntry withStatus(String next, {String? reservationId}) =>
      WaitlistEntry(
          id: id,
          scheduleId: scheduleId,
          userId: userId,
          coachId: coachId,
          coachName: coachName,
          classDate: classDate,
          classTime: classTime,
          status: next,
          userName: userName,
          userEmail: userEmail,
          closeReason: closeReason,
          reservationId: reservationId ?? this.reservationId,
          theme: theme,
          bicycle: bicycle,
          position: next == 'waiting' ? position : null,
          createdAt: createdAt,
          expiresAt: expiresAt);
  bool get active => status == 'waiting' || status == 'offered';
  Duration remaining(DateTime now) {
    final delta = expiresAt?.difference(now.toUtc()) ?? Duration.zero;
    return delta.isNegative ? Duration.zero : delta;
  }

  bool canAccept(DateTime now) =>
      status == 'offered' && remaining(now) > Duration.zero;
  String remainingLabel(DateTime now) {
    final seconds = remaining(now).inSeconds;
    return '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  String get statusLabel =>
      const {
        'waiting': 'En espera',
        'offered': 'Oferta activa',
        'accepted': 'Aceptada',
        'expired': 'Vencida',
        'rejected': 'Rechazada',
        'cancelled': 'Retirada',
        'ineligible': 'Sin acceso vigente',
        'class_closed': 'Clase cerrada'
      }[status] ??
      status;
  static String normalizeTime(String value) {
    final raw = value.split('.').first;
    return raw.length == 5 ? '$raw:00' : raw;
  }
}
