/// GET/POST /my-score 응답 모델
class ScoreResult {
  const ScoreResult({
    required this.userId,
    required this.score,
    this.upcomingAlert,
    this.updatedAt,
    this.recalculated,
  });

  final String userId;
  final ScoreBreakdown score;
  final UpcomingAlert? upcomingAlert;
  final String? updatedAt;
  final bool? recalculated;

  factory ScoreResult.fromJson(Map<String, dynamic> json) {
    return ScoreResult(
      userId: (json['user_id'] as String?) ?? '',
      score: json['score'] is Map
          ? ScoreBreakdown.fromJson((json['score'] as Map).cast<String, dynamic>())
          : const ScoreBreakdown(),
      upcomingAlert: json['upcoming_alert'] is Map
          ? UpcomingAlert.fromJson((json['upcoming_alert'] as Map).cast<String, dynamic>())
          : null,
      updatedAt: json['updated_at'] as String?,
      recalculated: json['recalculated'] as bool?,
    );
  }
}

class ScoreBreakdown {
  const ScoreBreakdown({
    this.total = 0,
    this.homelessYears,
    this.homelessScore = 0,
    this.dependentsScore = 0,
    this.savingsMonths,
    this.savingsScore = 0,
    this.nextUpgrade,
  });

  final int total;
  final double? homelessYears;
  final int homelessScore;
  final int dependentsScore;
  final int? savingsMonths;
  final int savingsScore;
  final NextUpgrade? nextUpgrade;

  static const int maxHomeless = 32;
  static const int maxDependents = 35;
  static const int maxSavings = 17;
  static const int maxTotal = 84;

  factory ScoreBreakdown.fromJson(Map<String, dynamic> json) {
    return ScoreBreakdown(
      total: (json['total'] as num?)?.toInt() ?? 0,
      homelessYears: (json['homeless_years'] as num?)?.toDouble(),
      homelessScore: (json['homeless_score'] as num?)?.toInt() ?? 0,
      dependentsScore: (json['dependents_score'] as num?)?.toInt() ?? 0,
      savingsMonths: (json['savings_months'] as num?)?.toInt(),
      savingsScore: (json['savings_score'] as num?)?.toInt() ?? 0,
      nextUpgrade: json['next_upgrade'] is Map
          ? NextUpgrade.fromJson((json['next_upgrade'] as Map).cast<String, dynamic>())
          : null,
    );
  }
}

class NextUpgrade {
  const NextUpgrade({required this.field, required this.daysUntil, required this.scoreGain});
  final String field;
  final int daysUntil;
  final int scoreGain;

  factory NextUpgrade.fromJson(Map<String, dynamic> json) {
    return NextUpgrade(
      field: (json['field'] as String?) ?? '',
      daysUntil: (json['days_until'] as num?)?.toInt() ?? 0,
      scoreGain: (json['score_gain'] as num?)?.toInt() ?? 0,
    );
  }
}

class UpcomingAlert {
  const UpcomingAlert({
    required this.message,
    required this.daysUntil,
    required this.field,
    this.confirmRequired = false,
  });

  final String message;
  final int daysUntil;
  final String field;
  final bool confirmRequired;

  factory UpcomingAlert.fromJson(Map<String, dynamic> json) {
    return UpcomingAlert(
      message: (json['message'] as String?) ?? '',
      daysUntil: (json['days_until'] as num?)?.toInt() ?? 0,
      field: (json['field'] as String?) ?? '',
      confirmRequired: (json['confirm_required'] as bool?) ?? false,
    );
  }
}
