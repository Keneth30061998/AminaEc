class StudentInscription {
  final String classDate;
  final String classTime;
  final String studentId;
  final String studentName;
  final String email;
  //final String planName;
  final String? photo_url;
  final int bicycle;

  StudentInscription({
    required this.classDate,
    required this.classTime,
    required this.studentId,
    required this.studentName,
    required this.email,
    //required this.planName,
    required this.photo_url,
    required this.bicycle,
  });

  factory StudentInscription.fromJson(Map<String, dynamic> json) {
    return StudentInscription(
      classDate: json['class_date'],
      classTime: json['class_time'],
      studentId: json['student_id'].toString(),
      studentName: json['student_name'],
      email: json['email'],
      //planName: json['plan_name'],
      photo_url: json['photo_url'],
      bicycle: json['bicycle'] is int
          ? json['bicycle']
          : int.tryParse(json['bicycle'].toString()) ?? 0,
    );
  }
}
