import 'dart:convert';

List<CardModel> cardModelFromJson(String str) =>
    List<CardModel>.from(json.decode(str).map((x) => CardModel.fromJson(x)));

String cardModelToJson(List<CardModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CardModel {
  String? token;
  String? type;
  String? last4;
  String? bin;
  String? expiryMonth;
  String? expiryYear;
  String? bank;

  CardModel({
    this.token,
    this.type,
    this.last4,
    this.bin,
    this.expiryMonth,
    this.expiryYear,
    this.bank,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) => CardModel(
    token: json["token"]?.toString(),
    type: json["type"]?.toString(),
    last4: json["last4"]?.toString(),
    bin: json["bin"]?.toString(),
    expiryMonth: json["expiry_month"] != null ? json["expiry_month"].toString() : null,
    expiryYear: json["expiry_year"] != null ? json["expiry_year"].toString() : null,
    bank: json["bank"]?.toString(),
  );


  Map<String, dynamic> toJson() => {
        "token": token,
        "type": type,
        "last4": last4,
        "bin": bin,
        "expiry_month": expiryMonth,
        "expiry_year": expiryYear,
        "bank": bank,
      };

  String get displayName => "$type •••• $last4";
}
