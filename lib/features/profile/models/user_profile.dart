/// user_profiles.profile JSONB 통합 타입
/// - UserProfile (가점 계산용, eligibility.ts) 12개
/// - UI extras 6개
/// - 020 추가 3개 (onboarding_step, completed_at, subscription_contributions)
class UserProfile {
  const UserProfile({
    // UserProfile
    this.birthDate,
    this.isMarried,
    this.marriageDate,
    this.dependentsCount,
    this.isHomeless,
    this.homelessSince,
    this.savingsStart,
    this.savingsBalanceWan,
    this.residentRegion,
    this.hasHouse,
    this.parentsRegistered,
    this.parentsRegisteredSince,
    // UI extras
    this.nickname,
    this.preferredRegions,
    this.preferredSizeSqm,
    this.incomeBracket,
    this.householdType,
    this.specialSupplyInterests,
    // Onboarding (020)
    this.onboardingStep,
    this.onboardingCompletedAt,
    this.subscriptionContributions,
  });

  final String? birthDate;
  final bool? isMarried;
  final String? marriageDate;
  final int? dependentsCount;
  final bool? isHomeless;
  final String? homelessSince;
  final String? savingsStart;
  final int? savingsBalanceWan;
  final String? residentRegion;
  final bool? hasHouse;
  final bool? parentsRegistered;
  final String? parentsRegisteredSince;

  final String? nickname;
  final List<String>? preferredRegions;
  final int? preferredSizeSqm;
  final String? incomeBracket;
  final String? householdType;
  final List<String>? specialSupplyInterests;

  final int? onboardingStep;
  final String? onboardingCompletedAt;
  final int? subscriptionContributions;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      birthDate: json['birth_date'] as String?,
      isMarried: json['is_married'] as bool?,
      marriageDate: json['marriage_date'] as String?,
      dependentsCount: (json['dependents_count'] as num?)?.toInt(),
      isHomeless: json['is_homeless'] as bool?,
      homelessSince: json['homeless_since'] as String?,
      savingsStart: json['savings_start'] as String?,
      savingsBalanceWan: (json['savings_balance_wan'] as num?)?.toInt(),
      residentRegion: json['resident_region'] as String?,
      hasHouse: json['has_house'] as bool?,
      parentsRegistered: json['parents_registered'] as bool?,
      parentsRegisteredSince: json['parents_registered_since'] as String?,
      nickname: json['nickname'] as String?,
      preferredRegions: (json['preferred_regions'] as List?)?.cast<String>(),
      preferredSizeSqm: (json['preferred_size_sqm'] as num?)?.toInt(),
      incomeBracket: json['income_bracket'] as String?,
      householdType: json['household_type'] as String?,
      specialSupplyInterests:
          (json['special_supply_interests'] as List?)?.cast<String>(),
      onboardingStep: (json['onboarding_step'] as num?)?.toInt(),
      onboardingCompletedAt: json['onboarding_completed_at'] as String?,
      subscriptionContributions:
          (json['subscription_contributions'] as num?)?.toInt(),
    );
  }

  /// PATCH body 생성 — null이 아닌 필드만 포함 (부분 업데이트).
  Map<String, dynamic> toPatchBody() {
    final body = <String, dynamic>{};
    void put(String key, dynamic value) {
      if (value != null) body[key] = value;
    }

    put('birth_date', birthDate);
    put('is_married', isMarried);
    put('marriage_date', marriageDate);
    put('dependents_count', dependentsCount);
    put('is_homeless', isHomeless);
    put('homeless_since', homelessSince);
    put('savings_start', savingsStart);
    put('savings_balance_wan', savingsBalanceWan);
    put('resident_region', residentRegion);
    put('has_house', hasHouse);
    put('parents_registered', parentsRegistered);
    put('parents_registered_since', parentsRegisteredSince);
    put('nickname', nickname);
    put('preferred_regions', preferredRegions);
    put('preferred_size_sqm', preferredSizeSqm);
    put('income_bracket', incomeBracket);
    put('household_type', householdType);
    put('special_supply_interests', specialSupplyInterests);
    put('onboarding_step', onboardingStep);
    put('onboarding_completed_at', onboardingCompletedAt);
    put('subscription_contributions', subscriptionContributions);
    return body;
  }

  bool get isOnboardingComplete =>
      onboardingCompletedAt != null && onboardingCompletedAt!.isNotEmpty;
}

/// 서버 응답의 derived fields (저장 X, 매번 계산).
class DerivedFields {
  const DerivedFields({
    this.age,
    this.homelessYears,
    this.accountJoinDate,
    this.accountBalanceWon,
    this.marriageYears,
  });

  final int? age;
  final int? homelessYears;
  final String? accountJoinDate;
  final int? accountBalanceWon;
  final int? marriageYears;

  factory DerivedFields.fromJson(Map<String, dynamic> json) {
    return DerivedFields(
      age: (json['age'] as num?)?.toInt(),
      homelessYears: (json['homeless_years'] as num?)?.toInt(),
      accountJoinDate: json['account_join_date'] as String?,
      accountBalanceWon: (json['account_balance_won'] as num?)?.toInt(),
      marriageYears: (json['marriage_years'] as num?)?.toInt(),
    );
  }
}

/// GET /profile 전체 응답.
class ProfileResponse {
  const ProfileResponse({
    required this.userId,
    required this.profile,
    required this.derived,
    this.score,
    this.updatedAt,
  });

  final String userId;
  final UserProfile profile;
  final DerivedFields derived;
  final Map<String, dynamic>? score;
  final String? updatedAt;

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      userId: (json['user_id'] as String?) ?? '',
      profile: json['profile'] is Map
          ? UserProfile.fromJson((json['profile'] as Map).cast<String, dynamic>())
          : const UserProfile(),
      derived: json['derived'] is Map
          ? DerivedFields.fromJson((json['derived'] as Map).cast<String, dynamic>())
          : const DerivedFields(),
      score: json['score'] is Map
          ? (json['score'] as Map).cast<String, dynamic>()
          : null,
      updatedAt: json['updated_at'] as String?,
    );
  }
}
