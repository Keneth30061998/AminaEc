import 'dart:convert';

ClassReservation classReservationFromJson(String str) =>
    ClassReservation.fromJson(json.decode(str));

String classReservationToJson(ClassReservation data) =>
    json.encode(data.toJson());

class ClassReservation {
  String id;
  String userId;
  String coachId;
  int bicycle;
  String classDate;
  String classTime;
  String status;

  ClassReservation({
    required this.id,
    required this.userId,
    required this.coachId,
    required this.bicycle,
    required this.classDate,
    required this.classTime,
    required this.status,
  });

  factory ClassReservation.fromJson(Map<String, dynamic> json) =>
      ClassReservation(
        id: json['id'].toString(),
        userId: json['user_id'].toString(),
        coachId: json['coach_id'].toString(),
        bicycle: json['bicycle'] is int
            ? json['bicycle']
            : int.tryParse(json['bicycle'].toString()) ?? 0,
        classDate: json['class_date'],
        classTime: json['class_time'],
        status: json['status'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'coach_id': coachId,
        'bicycle': bicycle,
        'class_date': classDate,
        'class_time': classTime,
        'status': status,
      };
}
