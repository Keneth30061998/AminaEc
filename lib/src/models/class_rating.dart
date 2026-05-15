class ClassRating {
  final String? userId;
  final String? attendanceId;
  final int? rating;
  final String? comment;  // Campo para comentario opcional

  // Constructor
  ClassRating({
    this.userId,
    this.attendanceId,
    this.rating,
    this.comment, // Se incluye el campo comentario
  });

  // Método para convertir de JSON a objeto
  factory ClassRating.fromJson(Map<String, dynamic> json) => ClassRating(
    userId: json["userId"]?.toString(),
    attendanceId: json["attendanceId"]?.toString(),
    rating: json["rating"],
    comment: json["comment"],  // Comentario opcional
  );

  // Método para convertir de objeto a JSON
  Map<String, dynamic> toJson() => {
    "userId": userId,
    "attendanceId": attendanceId,
    "rating": rating,
    "comment": comment,  // Comentario opcional
  };
}