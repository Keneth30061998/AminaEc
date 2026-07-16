class ClassRating {
  final String? userId;
  final String? attendanceId;
  final int? rating;
  final String? comment;

  ClassRating({
    this.userId,
    this.attendanceId,
    this.rating,
    this.comment,
  });

  factory ClassRating.fromJson(Map<String, dynamic> json) => ClassRating(
    userId: json["userId"]?.toString(),
    attendanceId: json["attendanceId"]?.toString(),
    rating: json["rating"] == null
        ? null
        : int.tryParse(json["rating"].toString()),
    comment: json["comment"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "attendanceId": attendanceId,
    "rating": rating,
    "comment": comment,
  };
}