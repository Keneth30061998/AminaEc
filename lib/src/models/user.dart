import 'dart:convert';

import 'package:amina_ec/src/models/rol.dart';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

//funcion de converison de valores - string a int
int? _parseInt(dynamic value) {
  if (value == null) return null;

  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value.toString());
}

class User {
  String? id;
  String? email;
  String? name;
  String? lastname;
  String? ci;
  String? phone;
  String? password;
  String? photo_url;
  String? session_token;
  String? birthDate;
  List<Rol>? roles = [];
  int? totalRides;
  int? ridesCompleted;
  User({
    this.id,
    this.email,
    this.name,
    this.lastname,
    this.ci,
    this.phone,
    this.password,
    this.photo_url,
    this.session_token,
    this.birthDate,
    this.roles,
    this.totalRides,
    this.ridesCompleted,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        email: json["email"],
        name: json["name"],
        lastname: json["lastname"],
        ci: json["ci"],
        phone: json["phone"],
        password: json["password"],
        photo_url: json["photo_url"],
        session_token: json["session_token"],
        birthDate: json["birth_date"],
        roles: json["roles"] == null
            ? []
            : List<Rol>.from(json["roles"].map((model) => Rol.fromJson(model))),
        totalRides: json['total_rides'],
        //aplicamos el parseo
        ridesCompleted: _parseInt(
              json["completed_rides"] ??
                  json["rides_completed"] ??
                  json["completedRides"],
            ) ??
            0,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "email": email,
        "name": name,
        "lastname": lastname,
        "ci": ci,
        "phone": phone,
        "password": password,
        "photo_url": photo_url,
        "session_token": session_token,
        "birth_date": birthDate,
        "roles": roles,
        "total_rides": totalRides,
        // Nombre oficial utilizado por el backend.
        "completed_rides": ridesCompleted,

        // Compatibilidad con posibles datos guardados anteriormente.
        "rides_completed": ridesCompleted,
      };
}
