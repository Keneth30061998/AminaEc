import 'dart:convert';

ScheduledClass scheduledClassFromJson(String str) =>
    ScheduledClass.fromJson(json.decode(str));

String scheduledClassToJson(ScheduledClass data) => json.encode(data.toJson());

class ScheduledClass {
  final String id;
  final String classDate;
  final String classTime;
  final int bicycle;
  final String coachName;
  final String photo_url;
  final String coachId;
  final DateTime createdAt;

  ScheduledClass({
    required this.id,
    required this.classDate,
    required this.classTime,
    required this.bicycle,
    required this.coachName,
    required this.photo_url,
    required this.coachId,
    required this.createdAt,
  });
  factory ScheduledClass.fromJson(Map<String, dynamic> json) {
    return ScheduledClass(
        id: json['id'].toString(),
        classDate: json['class_date'].toString(),
        classTime: json['class_time'].toString(),
        bicycle: json['bicycle'] is int
            ? json['bicycle']
            : int.tryParse(json['bicycle'].toString()) ?? 0,
        coachName: json['coach_name'] ?? 'No definido',
        photo_url: json['photo_url'] ?? '',
        coachId: json['coach_id'].toString(),
        createdAt: DateTime.parse(json['created_at']));
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'class_date': classDate,
        'class_time': classTime,
        'bicycle': bicycle,
        'coach_name': coachName,
        'photo_url': photo_url,
        'coach_id': coachId,
        'created_at': createdAt
      };
  static List<ScheduledClass> fromJsonList(List<dynamic> list) {
    return list.map((item) => ScheduledClass.fromJson(item)).toList();
  }
}
