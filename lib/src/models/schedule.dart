import 'dart:convert';

Schedule scheduleFromJson(String str) => Schedule.fromJson(json.decode(str));
String scheduleToJson(Schedule data) => json.encode(data.toJson());

class Schedule {
  String? id;                 // <-- nuevo
  String? date;
  String? start_time;
  String? end_time;
  String? class_theme;
  List<int>? coaches;         // <-- soporta 1 o 2 coaches

  Schedule({
    this.id,
    this.date,
    this.start_time,
    this.end_time,
    String? class_theme,
    this.coaches,
  }) : class_theme =
  class_theme?.trim().isNotEmpty == true ? class_theme! : 'Clase';

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
    id: json["id"]?.toString(), // <-- importante
    date: json["date"],
    start_time: json["start_time"],
    end_time: json["end_time"],
    class_theme: json["class_theme"],
    coaches: json['coaches'] != null
        ? List<int>.from(
      (json['coaches'] as List).map((e) => int.tryParse(e.toString()) ?? e),
    )
        : null,
  );

  Map<String, dynamic> toJson() => {
    if (id != null) "id": id, // <-- se envía SOLO si existe
    "date": date,
    "start_time": start_time,
    "end_time": end_time,
    "class_theme": class_theme,
    if (coaches != null) "coaches": coaches,
  };

  static List<Schedule> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((item) => Schedule.fromJson(item)).toList();
  }
}
