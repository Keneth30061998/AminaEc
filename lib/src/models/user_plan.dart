//Modelo para reservar un plan users - plans
import 'dart:convert';

UserPlan userPlanFromJson(String str) => UserPlan.fromJson(json.decode(str));

String userPlanToJson(UserPlan data) => json.encode(data.toJson());

class UserPlan {
  final String? userId;
  final String? planId;
  final String? transactionId; // ✅ nuevo campo

  UserPlan({
    this.userId,
    this.planId,
    this.transactionId,
  });

  factory UserPlan.fromJson(Map<String, dynamic> json) => UserPlan(
        userId: json["user_id"],
        planId: json["plan_id"],
        transactionId: json["transaction_id"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "plan_id": planId,
        if (transactionId != null) "transaction_id": transactionId,
      };
  static List<UserPlan> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => UserPlan.fromJson(json)).toList();
  }
}
