// lib/src/models/sponsor.dart
import 'dart:convert';

Sponsor sponsorFromJson(String str) => Sponsor.fromJson(json.decode(str));
String sponsorToJson(Sponsor data) => json.encode(data.toJson());

class Sponsor {
  String? id;
  String? name;
  String? description;
  String? image;
  int? priority; // tamaño del card
  String? target; // 👈 NEW ('coach' | 'student' | 'both')

  Sponsor({
    this.id,
    this.name,
    this.description,
    this.image,
    this.priority,
    this.target,
  });

  factory Sponsor.fromJson(Map<String, dynamic> json) => Sponsor(
    id: json['id']?.toString(),
    name: json['name'],
    description: json['description'],
    image: json['image'],
    priority: json['priority'] is int
        ? json['priority']
        : int.tryParse(json['priority']?.toString() ?? '3') ?? 3,
    target: json['target'] ?? 'both',
  );

  static List<Sponsor> fromJsonList(List<dynamic> jsonList) {
    List<Sponsor> list = [];
    for (var item in jsonList) {
      list.add(Sponsor.fromJson(item));
    }
    return list;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "image": image,
    "priority": priority,
    "target": target ?? 'both',
  };
}
