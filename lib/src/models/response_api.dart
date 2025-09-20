import 'dart:convert';

ResponseApi responseApiFromJson(String str) =>
    ResponseApi.fromJson(json.decode(str));

String responseApiToJson(ResponseApi data) => json.encode(data.toJson());

class ResponseApi {
  bool? success;
  String? message;
  dynamic data;

  // Campos nuevos para OTP
  bool? requiresConfirmation;
  String? transactionId;

  ResponseApi({
    this.success,
    this.message,
    this.data,
    this.requiresConfirmation,
    this.transactionId,
  });

  factory ResponseApi.fromJson(Map<String, dynamic> json) {
    return ResponseApi(
      success: json["success"] as bool?,
      message: json["message"] as String?,
      data: json["data"],
      requiresConfirmation: json["requiresConfirmation"] as bool? ??
          json["requires_confirmation"] as bool?,
      transactionId:
          json["transactionId"] as String? ?? json["transaction_id"] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      "success": success,
      "message": message,
      "data": data,
    };
    if (requiresConfirmation != null) {
      map["requiresConfirmation"] = requiresConfirmation;
    }
    if (transactionId != null) {
      map["transactionId"] = transactionId;
    }
    return map;
  }
}
