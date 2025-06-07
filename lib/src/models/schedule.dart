import 'dart:convert';

Schedule scheduleFromJson(String str) => Schedule.fromJson(json.decode(str));
String scheduleToJson(Schedule data) => json.encode(data.toJson());

class Schedule {
  String? day;
  String? start_time;
  String? end_time;

  Schedule({
    this.day,
    this.start_time,
    this.end_time,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
        day: json["day"],
        start_time: json["start_time"],
        end_time: json["end_time"],
      );

  Map<String, dynamic> toJson() => {
        "day": day,
        "start_time": start_time,
        "end_time": end_time,
      };

  static List<Schedule> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((item) => Schedule.fromJson(item)).toList();
  }
}
