import 'dart:convert';

Plan planFromJson(String str) => Plan.fromJson(json.decode(str));

String planToJson(Plan data) => json.encode(data.toJson());

class Plan {
  String? id;
  String? name;
  String? description;
  String? image;
  int? rides;
  double? price;
  int? duration_days;
  int? is_new_user_only;

  Plan({
    this.id,
    this.name,
    this.description,
    this.image,
    this.rides,
    this.price,
    this.duration_days,
    this.is_new_user_only,
  });
  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        image: json['image'],
        rides: json['rides'],
        price: json['price'] is num
            ? json['price'].toDouble()
            : double.tryParse(json["price"]?.toString() ?? "0.0") ?? 0.0,
        duration_days: json['duration_days'],
        is_new_user_only: json['is_new_user_only'] ?? 0,
      );

  //Se requiere para listar el plan que llega como json
  static List<Plan> fromJsonList(List<dynamic> jsonList) {
    List<Plan> toList = [];
    for (var item in jsonList) {
      Plan plan = Plan.fromJson(item);
      toList.add(plan);
    }
    return toList;
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "image": image,
        "rides": rides,
        "price": price,
        "duration_days": duration_days,
        "is_new_user_only": is_new_user_only,
      };
}
