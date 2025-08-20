import 'dart:convert';

Attendance attendanceFromJson(String str) =>
    Attendance.fromJson(json.decode(str));

String attendanceToJson(Attendance data) => json.encode(data.toJson());

class Attendance {
  final String? userId;
  final String? coachId;
  final DateTime? classDate;
  final String? classTime;
  final int? bicycle;
  final String? status;

  Attendance({
    this.userId,
    this.coachId,
    this.classDate,
    this.classTime,
    this.bicycle,
    this.status,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) => Attendance(
        userId: json["user_id"],
        coachId: json["coach_id"],
        classDate: json["class_date"] == null
            ? null
            : DateTime.parse(json["class_date"]),
        classTime: json["class_time"],
        bicycle: json["bicycle"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "coach_id": coachId,
        "class_date":
            "${classDate!.year.toString().padLeft(4, '0')}-${classDate!.month.toString().padLeft(2, '0')}-${classDate!.day.toString().padLeft(2, '0')}",
        "class_time": classTime,
        "bicycle": bicycle,
        "status": status,
      };
}
