//Modelo para reservar un plan users - plans
import 'dart:convert';

UserPlan userPlanFromJson(String str) => UserPlan.fromJson(json.decode(str));

String userPlanToJson(UserPlan data) => json.encode(data.toJson());

class UserPlan {
  final String? userId;
  final String? planId;

  UserPlan({
    this.userId,
    this.planId,
  });

  factory UserPlan.fromJson(Map<String, dynamic> json) => UserPlan(
        userId: json["user_id"],
        planId: json["plan_id"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "plan_id": planId,
      };
}
