import 'dart:convert';

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
  String? photo;
  String? session_token;

  User({
    this.id,
    this.email,
    this.name,
    this.lastname,
    this.ci,
    this.phone,
    this.password,
    this.photo,
    this.session_token,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        email: json["email"],
        name: json["name"],
        lastname: json["lastname"],
        ci: json["ci"],
        phone: json["phone"],
        password: json["password"],
        photo: json["photo"],
        session_token: json["session_token"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "email": email,
        "name": name,
        "lastname": lastname,
        "ci": ci,
        "phone": phone,
        "password": password,
        "photo": photo,
        "session_token": session_token,
      };
}
