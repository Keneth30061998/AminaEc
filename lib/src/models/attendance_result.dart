class AttendanceResult {
  final String userName;
  final String coachName;
  final String classDate;
  final int bicycle;
  final String status;

  AttendanceResult({
    required this.userName,
    required this.coachName,
    required this.classDate,
    required this.bicycle,
    required this.status,
  });

  factory AttendanceResult.fromJson(Map<String, dynamic> json) =>
      AttendanceResult(
        userName: json['user_name'],
        coachName: json['coach_name'],
        classDate: json['class_date'],
        bicycle: json['bicycle'],
        status: json['status'],
      );
}