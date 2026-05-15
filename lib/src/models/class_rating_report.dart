class ClassRatingReportSummary {
  final int totalRatings;
  final double averageRating;
  final int commentedCount;
  final int rating1Count;
  final int rating2Count;
  final int rating3Count;
  final int rating4Count;
  final int rating5Count;

  ClassRatingReportSummary({
    required this.totalRatings,
    required this.averageRating,
    required this.commentedCount,
    required this.rating1Count,
    required this.rating2Count,
    required this.rating3Count,
    required this.rating4Count,
    required this.rating5Count,
  });

  factory ClassRatingReportSummary.empty() => ClassRatingReportSummary(
    totalRatings: 0,
    averageRating: 0,
    commentedCount: 0,
    rating1Count: 0,
    rating2Count: 0,
    rating3Count: 0,
    rating4Count: 0,
    rating5Count: 0,
  );

  factory ClassRatingReportSummary.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) => int.tryParse('${v ?? 0}') ?? 0;
    double toDouble(dynamic v) => double.tryParse('${v ?? 0}') ?? 0;

    return ClassRatingReportSummary(
      totalRatings: toInt(json['totalRatings']),
      averageRating: toDouble(json['averageRating']),
      commentedCount: toInt(json['commentedCount']),
      rating1Count: toInt(json['rating1Count']),
      rating2Count: toInt(json['rating2Count']),
      rating3Count: toInt(json['rating3Count']),
      rating4Count: toInt(json['rating4Count']),
      rating5Count: toInt(json['rating5Count']),
    );
  }

  double get commentRate =>
      totalRatings == 0 ? 0 : (commentedCount / totalRatings) * 100;
}

class CoachRatingSummary {
  final String coachId;
  final String coachName;
  final int totalRatings;
  final double averageRating;
  final int fiveStarCount;
  final int commentedCount;

  CoachRatingSummary({
    required this.coachId,
    required this.coachName,
    required this.totalRatings,
    required this.averageRating,
    required this.fiveStarCount,
    required this.commentedCount,
  });

  factory CoachRatingSummary.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) => int.tryParse('${v ?? 0}') ?? 0;
    double toDouble(dynamic v) => double.tryParse('${v ?? 0}') ?? 0;

    return CoachRatingSummary(
      coachId: '${json['coach_id'] ?? ''}',
      coachName: '${json['coach_name'] ?? ''}',
      totalRatings: toInt(json['total_ratings']),
      averageRating: toDouble(json['average_rating']),
      fiveStarCount: toInt(json['five_star_count']),
      commentedCount: toInt(json['commented_count']),
    );
  }
}

class ClassRatingReportResult {
  final String ratingId;
  final String userId;
  final String classReservationId;
  final String? attendanceId;
  final String userName;
  final String coachName;
  final String classDate;
  final String classTime;
  final int bicycle;
  final int rating;
  final String? comment;
  final String ratedAt;
  final String reservationStatus;
  final String? attendanceStatus;
  final String? classTheme;
  final String? typeClass;

  ClassRatingReportResult({
    required this.ratingId,
    required this.userId,
    required this.classReservationId,
    required this.attendanceId,
    required this.userName,
    required this.coachName,
    required this.classDate,
    required this.classTime,
    required this.bicycle,
    required this.rating,
    required this.comment,
    required this.ratedAt,
    required this.reservationStatus,
    required this.attendanceStatus,
    required this.classTheme,
    required this.typeClass,
  });

  factory ClassRatingReportResult.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) => int.tryParse('${v ?? 0}') ?? 0;

    return ClassRatingReportResult(
      ratingId: '${json['rating_id'] ?? ''}',
      userId: '${json['user_id'] ?? ''}',
      classReservationId: '${json['class_reservation_id'] ?? ''}',
      attendanceId: json['attendance_id']?.toString(),
      userName: '${json['user_name'] ?? ''}',
      coachName: '${json['coach_name'] ?? ''}',
      classDate: '${json['class_date'] ?? ''}',
      classTime: '${json['class_time'] ?? ''}',
      bicycle: toInt(json['bicycle']),
      rating: toInt(json['rating']),
      comment: json['comment']?.toString(),
      ratedAt: '${json['rated_at'] ?? ''}',
      reservationStatus: '${json['reservation_status'] ?? ''}',
      attendanceStatus: json['attendance_status']?.toString(),
      classTheme: json['class_theme']?.toString(),
      typeClass: json['type_class']?.toString(),
    );
  }
}