import 'dart:convert';

import 'package:amina_ec/src/models/rol.dart';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

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
  List<Rol>? roles = [];

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
    this.roles,
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
        roles: json["roles"] == null
            ? []
            : List<Rol>.from(json["roles"].map((model) => Rol.fromJson(model))),
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
        "roles": roles,
      };
}
