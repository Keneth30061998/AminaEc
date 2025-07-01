import 'dart:convert';

Schedule scheduleFromJson(String str) => Schedule.fromJson(json.decode(str));
String scheduleToJson(Schedule data) => json.encode(data.toJson());

class Schedule {
  String? date;
  String? start_time;
  String? end_time;

  Schedule({
    this.date,
    this.start_time,
    this.end_time,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
        date: json["date"],
        start_time: json["start_time"],
        end_time: json["end_time"],
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "start_time": start_time,
        "end_time": end_time,
      };

  static List<Schedule> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((item) => Schedule.fromJson(item)).toList();
  }
}
