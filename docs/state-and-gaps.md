# 청약 코파일럿 프론트 — 현재 상태 + 갭 분석

> 작성일: 2026-04-26
> 브랜치: `docs/state-and-gaps`
> 분석 대상: `lib/` 25개 Dart 파일 + Stitch 디자인 15개 화면 + 백엔드 30+ Edge Functions

## 0. 한 줄 요약

**디자인 골격은 잘 만들어졌으나 데이터 흐름은 announcements만 연결됨.** 5개 페이지(home/analysis/preparation/notifications/score_tracker)는 모두 정적 mock UI. 백엔드 API 9종 + Stitch 화면 9종은 Flutter 페이지가 없거나 stub.

**즉시 우선순위**: 정적 페이지 5개를 백엔드 API에 연결 (Repository + Provider 추가). 그 다음 미구현 페이지 9개 신규.

---

## 1. 현재 구현 상태

### 1.1 페이지·라우팅

| 라우트 | 페이지 | 라인 | 데이터 흐름 |
|--------|-------|------|-----------|
| `/` → `/home` | `HomeDashboardPage` | 417 | ❌ 정적 mock UI |
| `/announcements` | `AnnouncementsPage` | — | ✅ Repository + Provider 연결 |
| `/announcements/:id` | `AnnouncementDetailPage` | — | ⚠️ 부분 (모델만, 진단 미통합) |
| `/analysis` | `AiReportPage` | 341 | ❌ 정적 mock UI |
| `/preparation` | `PreparationPage` | 365 | ❌ 정적 mock UI |
| `/my` | `ScoreTrackerPage` | 320 | ❌ 정적 mock UI |
| `/notifications` | `NotificationsPage` | 306 | ❌ 정적 mock UI |

### 1.2 features 모듈별 깊이

| Feature | files | 모델 | Repository | Provider | 상태 |
|---------|------|------|-----------|----------|------|
| `announcements` | 6 | ✅ Announcement, Category, Response | ✅ | ✅ | **완성형 reference** |
| `analysis` | 1 | ❌ | ❌ | ❌ | UI만 |
| `home` | 1 | ❌ | ❌ | ❌ | UI만 |
| `my_cheongyak` | 1 | ❌ | ❌ | ❌ | UI만 |
| `notifications` | 1 | ❌ | ❌ | ❌ | UI만 |
| `preparation` | 1 | ❌ | ❌ | ❌ | UI만 |

### 1.3 인프라

- ✅ `core/api/api_client.dart` — http 래퍼 (180s timeout)
- ✅ `core/api/api_exception.dart`
- ✅ `core/config/api_config.dart` — `--dart-define=API_BASE_URL` 처리
- ✅ `core/theme/app_theme.dart` — Stitch design system 적용
- ✅ `core/widgets/` — 공통 위젯 3개 (top_bar, page_container, section_card)
- ✅ `app/main_scaffold.dart` — 5개 탭 bottom nav
- ✅ `app/router.dart` — go_router 7개 라우트
- ✅ Vercel 배포 설정 (`vercel-build.sh`, `vercel.json`)

---

## 2. Stitch 디자인 ↔ 백엔드 ↔ Flutter 매핑

| Stitch screen | 백엔드 endpoint | Flutter 구현 | 갭 |
|--------------|---------------|------------|------|
| 홈 대시보드 (3d7454ec) | `/recommendations` + `/notifications?unread_only` | `HomeDashboardPage` (mock) | **API 연결** |
| 공고 목록 (8a9e26a9) | `/announcements` | `AnnouncementsPage` ✅ | (필터·정렬 검증) |
| 공고 상세 (9d762970) | `/announcement-detail?id=` | `AnnouncementDetailPage` | **진단 통합** |
| 공고 비교 (3f5030df) | `/compare?ids=` | ❌ 없음 | 신규 페이지 |
| 공고 변경 내역 (fe8d00f0) | `/announcement-changes?id=` | ❌ 없음 | 신규 페이지 |
| AI 분석 리포트 (3587a9f0) | `/notice/{id}/raw` + `/reports` | `AiReportPage` (mock) | **API 연결** + verdict/evidence 렌더 |
| 부적격 사전검증 (aad3ecef) | `/eligibility-precheck` | ❌ 없음 | 신규 페이지 |
| 가점 트래커 (f0a04020) | `/my-score` GET/POST | `ScoreTrackerPage` (mock) | **API 연결** |
| 준비 체크리스트 (fb84342a) | `/preparation` | `PreparationPage` (mock) | **API 연결** + documents 자동 연동 표시 |
| 임장 체크리스트 (4316f446) | `/visit-checklist?id=` | ❌ 없음 | 신규 페이지 |
| 내 서류함 (07aac125) | `/documents` | ❌ 없음 | 신규 페이지 + Storage upload |
| 알림 센터 (616a7880) | `/notifications` | `NotificationsPage` (mock) | **API 연결** + read 처리 |
| 마이페이지 (ecdbf516) | `/profile` GET/PATCH | ❌ 없음 (`/my`는 ScoreTracker) | 신규 페이지 |
| 온보딩 (550553a6) | `/profile` PATCH (step별) | ❌ 없음 | 신규 페이지 (5-step) |
| 근거 상세 패널 (2d69b5eb) | reports.evidence JSONB | ❌ 없음 | 모달 (BottomSheet) |

요약:
- **API 연결만 필요한 mock 페이지: 5개** (home, analysis, preparation, notifications, score_tracker)
- **신규 구현 필요 페이지: 9개** (공고 비교, 공고 변경 내역, 부적격 사전검증, 임장 체크리스트, 서류함, 마이페이지, 온보딩, 즐겨찾기, 근거 모달)
- **부분 구현 페이지: 1개** (announcement_detail — 진단 통합 누락)

---

## 3. 갭 카테고리별 상세

### 3.1 데이터 흐름 갭 (5개 페이지 mock → API)

| 페이지 | 추가할 모델 | 추가할 Repository | 추가할 Provider |
|--------|-----------|------------------|----------------|
| HomeDashboardPage | Recommendation, NotificationSummary | RecommendationsRepository, NotificationsRepository (read) | recommendationsProvider, unreadCountProvider |
| AiReportPage | Report, ReportCreateInput, NoticeRaw | ReportsRepository (CRUD), NoticeRawRepository (GET) | reportsProvider, currentReportProvider |
| PreparationPage | ChecklistItem, ChecklistSummary | PreparationRepository (init/list/toggle) | preparationProvider(announcementId) |
| NotificationsPage | Notification, NotificationsSummary | NotificationsRepository (list, markRead, refresh) | notificationsProvider |
| ScoreTrackerPage | UserProfile, ScoreBreakdown | MyScoreRepository (GET/POST) | myScoreProvider |

### 3.2 신규 페이지 (9개)

| 페이지 | Stitch | 우선순위 | 작업량 |
|-------|--------|--------|--------|
| `documents/presentation/documents_page.dart` | 07aac125 | ⭐⭐⭐ | 4~6h (Storage upload) |
| `mypage/presentation/mypage_page.dart` | ecdbf516 | ⭐⭐⭐ | 3~4h |
| `onboarding/presentation/onboarding_flow.dart` | 550553a6 | ⭐⭐⭐ | 4~5h (5-step) |
| `announcements/presentation/compare_page.dart` | 3f5030df | ⭐⭐ | 3~4h |
| `announcements/presentation/changes_page.dart` | fe8d00f0 | ⭐⭐ | 2~3h |
| `analysis/presentation/eligibility_precheck_page.dart` | aad3ecef | ⭐⭐ | 3~4h |
| `analysis/presentation/visit_checklist_page.dart` | 4316f446 | ⭐ | 2~3h |
| `favorites/presentation/favorites_page.dart` | (공고 상세 inline) | ⭐⭐ | 2~3h |
| `analysis/presentation/widgets/evidence_panel.dart` | 2d69b5eb | ⭐ | 2h (BottomSheet) |

### 3.3 라우팅·네비게이션 갭

- **5탭 bottom nav** 그대로 유지하되, 신규 페이지 라우팅 추가:
  - `/profile` → MypagePage (현재 `/my`는 ScoreTracker)
  - `/onboarding/:step` → OnboardingFlow
  - `/announcements/:id/compare?with=` → ComparePage
  - `/announcements/:id/changes` → ChangesPage
  - `/announcements/:id/eligibility` → EligibilityPrecheckPage
  - `/announcements/:id/visit-checklist` → VisitChecklistPage
  - `/documents` → DocumentsPage
  - `/favorites` → FavoritesPage
- **"내 청약" 탭 의미** — 현재 `/my` → ScoreTracker. 디자인엔 **마이페이지가 들어가야 함**. 가점은 별도 진입.

### 3.4 모델 매핑 갭

백엔드 응답에 맞춰 추가할 Dart 모델:

```dart
// features/recommendations/models/
class Recommendation {
  final Announcement announcement;
  final int matchScore;
  final List<String> matchReasons;
}

// features/notifications/models/
class Notification {
  final String id;
  final String type;             // 'dday_alert' | 'announcement_new' | 'change_alert' | 'user_memo' | ...
  final String title;
  final String body;
  final String? link;
  final String? relatedAnnouncementId;
  final DateTime? readAt;
  final DateTime createdAt;
}

class NotificationsSummary {
  final List<Notification> notifications;
  final int unreadCount;
}

// features/reports/models/
class Report {
  final String id;
  final String noticeId;
  final String? noticeUrl;
  final String? title;
  final String summaryMarkdown;
  final String? rawExcerpt;
  final Map<String, dynamic>? matchedProfileSnapshot;
  final int? matchScore;
  // PR #17 추가
  final String? verdict;          // 'strong_recommend' | 'conditional_recommend' | 'caution' | 'not_recommend'
  final int? confidenceScore;
  final List<KeyPoint>? keyPoints;
  final List<Evidence>? evidence;
  final Map<String, dynamic>? chartsData;
  final DateTime createdAt;
}

class KeyPoint {
  final String? icon;
  final String label;
  final String? value;
  final String? tone;             // 'positive' | 'neutral' | 'caution' | 'negative'
}

class Evidence {
  final String category;          // 'official_source' | 'official_db' | 'market_data' | 'ai_inference'
  final String? icon;
  final String title;
  final String? citation;
  final String? link;
}

// features/profile/models/
class UserProfile {
  // UserProfile (가점 계산용) 12개 필드
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
  // UI extras 6개
  final String? nickname;
  final List<String>? preferredRegions;
  final int? preferredSizeSqm;
  final String? incomeBracket;
  final String? householdType;
  final List<String>? specialSupplyInterests;
  // PR #18 추가
  final int? onboardingStep;
  final DateTime? onboardingCompletedAt;
  final int? subscriptionContributions;
}

class DerivedFields {
  final int? age;
  final int? homelessYears;
  final String? accountJoinDate;
  final int? accountBalanceWon;
  final int? marriageYears;
}

// features/documents/models/
class Document {
  final String id;
  final String docType;
  final String docTypeLabelKo;
  final String? description;
  final bool isRequired;
  final String status;            // 'missing' | 'ready' | 'expiring' | 'expired'
  final DateTime? issuedDate;
  final DateTime? expiresDate;
  final int? validityMonths;
  final String? fileUrl;
  // ...
}

// features/preparation/models/
class ChecklistItem {
  final String id;
  final String? relatedAnnouncementId;
  final String category;          // '기본준비' | '서류및결정' | '접수당일'
  final String type;              // '자금' | '자격' | '서류' | '결정' | '접수'
  final String title;
  final String? description;
  final int? dueOffsetDays;
  final bool isAutoCheckable;
  final String? linkedDocType;
  final bool isDone;
  final DateTime? doneAt;
  final int sortOrder;
  // GET 응답 시 documents 연동 결과
  final String? linkedDocumentStatus;
  final bool autoDoneByDoc;
  final bool effectiveIsDone;
}

class ChecklistSummary {
  final int total;
  final int done;
  final int autoDone;
  final int manualDone;
  final int pending;
  final int percent;
}

// features/favorites/models/
class Favorite {
  final String id;
  final String announcementId;
  final Announcement? announcement;  // JOIN
  final String? notes;
  final bool notifyOnChange;
  final DateTime createdAt;
}

// features/announcement_changes/models/
class AnnouncementChange {
  final String id;
  final String announcementId;
  final DateTime detectedAt;
  final String field;
  final String fieldLabelKo;
  final String changeType;        // 'updated' | 'added' | 'removed'
  final String? oldValue;
  final String? newValue;
}

// features/eligibility/models/
class EligibilityWarning {
  final String field;
  final String severity;          // 'critical' | 'warning' | 'info'
  final String message;
  final String detail;
}

class EligibilityResult {
  final ScoreBreakdown score;
  final List<EligibilityWarning> warnings;
  final Map<String, int> warningSummary;  // {critical, warning, info}
}
```

### 3.5 인증 인프라 갭

현재 `api_client`는 인증 토큰 처리 없음. 인증 필요한 API (profile, my-score, reports, documents, preparation, favorites, notifications) 호출 시:

- ⚠️ **AuthRepository / Provider 신규 필요** (Supabase Auth Flutter SDK)
- ⚠️ **ApiClient에 Authorization 헤더 자동 첨부** 메커니즘
- ⚠️ **로그인 페이지** (이메일 매직링크 / Google / Kakao OAuth)
- ⚠️ **session 영속** (SharedPreferences 또는 Supabase Auth state)

이건 **모든 인증 API 통합의 전제 조건**. 디자인 어딘가에 로그인 화면 있을 가능성 — 추가 분석 필요.

### 3.6 디자인 시스템 적용 정도

`core/theme/app_theme.dart` 존재. Stitch design system (Teal #008080, Ivory #f6faf9, Public Sans + Korean Pretendard, 16px rounded card, Score Gauges, Risk & D-Day Badges) 반영 여부는 코드 레벨 점검 필요. 별도 PR에서 검증.

---

## 4. 우선순위 로드맵 (단계별 PR 분할 권장)

| 단계 | 작업 | 작업량 | 의존 |
|------|------|--------|------|
| **1** | **AuthRepository + ApiClient 인증 헤더 + 로그인 페이지** | 4~6h | (디자인 추가 분석 필요) |
| **2** | mock 5개 페이지 → API 연결 (Repository + Provider 추가) | 5~7h | 1 (인증 필요 API) |
| **3** | 신규 documents 페이지 + Storage upload | 4~6h | 1 |
| **4** | 신규 mypage / onboarding 페이지 (마이페이지·5-step 온보딩) | 5~7h | 1 |
| **5** | 신규 favorites 페이지 + 공고 상세 통합 | 2~3h | 1 |
| **6** | 신규 compare / changes / eligibility / visit-checklist 페이지 | 8~10h | 일부만 1 |
| **7** | evidence_panel 모달 (AI 리포트 진입) | 2h | 2 |
| **8** | 디자인 시스템 정밀 적용 (게이지·뱃지·evidence labels) | 4~6h | 전체 |

**총 예상**: 34~47h

---

## 5. 다음 액션 결정 필요

### Q1. 어디서부터?
- A. 단계 1 (Auth) 먼저 — 이후 모든 작업 차단 해소
- B. 단계 2 (mock → API) 먼저 — 이미 만들어진 UI에 데이터 입히기
- C. 단계 3 (서류함) — 가장 사용자 체감 큰 신규 기능

### Q2. 디자인 추가 자료
- 로그인 화면 디자인 있나? Stitch 15개 외 추가 화면?
- "내 청약" 탭이 마이페이지인지 가점 트래커인지 디자인 의도?

### Q3. 인증 방식
- Supabase Auth Flutter SDK (`supabase_flutter` package)
- 매직링크 / Google OAuth / Kakao OAuth 중 우선 어떤 것?
- 디자인 토큰·CLI와 공유 vs 앱 전용?

### Q4. 작업 단위
- PR당 한 단계 (검토 부담 ↑) vs 한 PR에 1~3 단계 묶음

---

## 6. 본 분석 PR 범위

본 PR (`docs/state-and-gaps`)은 **plan doc 1개만 추가**. 코드 변경 0. 사용자 결정 (Q1~Q4) 후 단계별 PR로 진행.
