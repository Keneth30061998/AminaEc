class StudentInscription {
  final String classDate;
  final String classTime;
  final String studentId;
  final String studentName;
  final String email;
  //final String planName;
  final String? photo_url;
  final int bicycle;
  int ridesCompleted;

  StudentInscription({
    required this.classDate,
    required this.classTime,
    required this.studentId,
    required this.studentName,
    required this.email,
    //required this.planName,
    required this.photo_url,
    required this.bicycle,
    this.ridesCompleted = 0
  });

  factory StudentInscription.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v, {int fallback = 0}) {
      if (v == null) return fallback;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? fallback;
    }

    return StudentInscription(
      classDate: (json['class_date'] ?? '').toString(),
      classTime: (json['class_time'] ?? '').toString().split(".").first,
      studentId: (json['student_id'] ?? '').toString(),
      studentName: (json['student_name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      photo_url: json['photo_url']?.toString(),
      bicycle: toInt(json['bicycle']),
      // ✅ API trae completed_rides
      ridesCompleted: toInt(json['completed_rides'] ?? json['rides_completed'] ?? 0),
    );
  }

}
