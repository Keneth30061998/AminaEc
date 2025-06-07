import 'dart:convert';

import 'schedule.dart';
import 'user.dart';

Coach coachFromJson(String str) => Coach.fromJson(json.decode(str));
String coachToJson(Coach data) => json.encode(data.toJson());

class Coach {
  String? id;
  String? hobby;
  String? description;
  String? presentation;
  int? state;
  DateTime? createdAt;
  DateTime? updatedAt;
  User? user;
  List<Schedule> schedules = [];

  Coach({
    this.id,
    this.hobby,
    this.description,
    this.presentation,
    this.state = 1,
    this.user,
    this.schedules = const [],
  });

  factory Coach.fromJson(Map<String, dynamic> json) => Coach(
        id: json["id"]?.toString(),
        hobby: json["hobby"],
        description: json["description"],
        presentation: json["presentation"],
        state: json["state"],
        // Si la API no anida "user", se construye con los campos planos
        user: json["user"] is Map
            ? User.fromJson(json["user"])
            : User.fromJson({
                "id": json["id"],
                "name": json["name"],
                "lastname": json["lastname"],
                "email": json["email"],
                "ci": json["ci"],
                "phone": json["phone"],
                "photo_url": json["photo_url"],
              }),
        schedules: (json["schedules"] as List<dynamic>? ?? [])
            .map((x) => Schedule.fromJson(x))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "hobby": hobby,
        "description": description,
        "presentation": presentation,
        "state": state,
        "user": user?.toJson(),
        "schedules": List<dynamic>.from(schedules.map((x) => x.toJson())),
      };

  static List<Coach> fromJsonList(List<dynamic> jsonList) =>
      jsonList.map((e) => Coach.fromJson(e as Map<String, dynamic>)).toList();
}
