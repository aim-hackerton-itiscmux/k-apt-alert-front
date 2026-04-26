# k-apt-alert-front

한국 청약 정보를 한눈에 보기 위한 Flutter 웹 앱. 백엔드는 같은 워크스페이스의
[`k-apt-alert`](../k-apt-alert) (Supabase Edge Functions) 를 그대로 사용한다.

## 기술 스택

- Flutter `3.41.7` (Dart `3.11.5`) / Web 타겟
- 상태관리: `flutter_riverpod` 3.x
- HTTP: `http` 패키지
- 로컬라이제이션: `flutter_localizations` (한국어 기본)

## 폴더 구조

```
lib/
  main.dart
  core/
    config/api_config.dart        # --dart-define=API_BASE_URL 처리
    api/
      api_client.dart             # http 래퍼 (180s 타임아웃, JSON 파싱)
      api_exception.dart
  features/
    announcements/
      models/                     # Announcement, Category, AnnouncementsResponse
      data/                       # AnnouncementsRepository
      providers/                  # Riverpod providers
      presentation/
        announcements_page.dart
        widgets/                  # CategoryFilter, AnnouncementCard
```

## 실행

```bash
# 의존성 설치
flutter pub get

# Chrome 으로 실행 (기본 Base URL = 라이브 Supabase)
flutter run -d chrome

# 로컬 백엔드 사용 시
flutter run -d chrome \
  --dart-define=API_BASE_URL=http://127.0.0.1:54321/functions/v1
```

기본 API Base URL은 `lib/core/config/api_config.dart` 에 하드코딩된 라이브 Supabase
주소를 사용한다. 빌드 시 `--dart-define=API_BASE_URL=...` 로 덮어쓸 수 있다.

## Auth (매직링크 로그인)

인증 API (profile / my-score / reports / documents / preparation / favorites / notifications)
사용 시 Supabase Auth 매직링크 로그인 필요. 미설정 시 무인증 API만 동작.

```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://xnyhzyvigazofjoozuub.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<your_anon_key> \
  --dart-define=AUTH_REDIRECT_URL=http://localhost:54080/auth/callback
```

| Env var | 설명 | 기본값 |
|---------|------|------|
| `SUPABASE_URL` | Supabase 프로젝트 URL | `https://xnyhzyvigazofjoozuub.supabase.co` |
| `SUPABASE_ANON_KEY` | Supabase anon (public) key | (비어있으면 Auth 비활성) |
| `AUTH_REDIRECT_URL` | 매직링크 콜백 URL | (Supabase Site URL 설정) |

→ `/login` 진입 시 매직링크 발송. 이메일 클릭 → 자동 로그인 → 원래 페이지로 redirect.

## 검증 명령

```bash
flutter analyze   # 정적 분석
flutter test      # 위젯 테스트
```

## 백엔드 API 요약

소비하는 엔드포인트 (인증 불필요, CORS 전체 허용):

| Method | Path | 용도 |
|--------|------|------|
| GET | `/categories` | 8개 카테고리 + 한글 이름/설명 |
| GET | `/announcements` | `category`, `active_only`, `months_back` 등으로 필터링된 청약 공고 목록 |

> 콜드 캐시 시 `/announcements` 응답이 60–120초 걸릴 수 있다. HTTP 타임아웃은
> 180초로 설정되어 있다.

## Vercel 배포

### 파일 구성
- `vercel.json` — 빌드 명령, 출력 경로(`build/web`), SPA rewrite, 정적 자산 캐시 헤더
- `vercel-build.sh` — Flutter SDK 다운로드 + `flutter build web --release` 실행

### 1회 셋업

1. GitHub에 이 저장소 push
2. [vercel.com/new](https://vercel.com/new) → 저장소 import
3. **Framework Preset**: `Other` (자동 감지된 값이 있으면 그대로 둬도 OK — `vercel.json`이 우선)
4. **Build Command / Output Directory**: 비워두기 (vercel.json이 정의)
5. **Environment Variables** (선택):
   - `API_BASE_URL` — 라이브 Supabase 외 다른 백엔드 사용 시. 미설정 시 기본값(`https://xnyhzyvigazofjoozuub.supabase.co/functions/v1`) 사용
   - `FLUTTER_VERSION` — 기본 `3.41.7`. SDK 버전 핀 변경 시
6. Deploy

### 배포 흐름
- 푸시 시 Vercel이 `bash vercel-build.sh` 실행 → Flutter 3.41.7 tarball 다운로드 → `flutter build web --release --dart-define=API_BASE_URL=$API_BASE_URL` → `build/web` 결과물 정적 호스팅
- 첫 빌드는 SDK 다운로드(약 1.4GB, 1–3분) 포함. Vercel은 SDK를 빌드 간 캐시하지 않으므로 매 배포마다 다시 받음
- SPA rewrite로 모든 경로가 `index.html` 로 서빙됨 → 향후 `go_router` 등 추가해도 새로고침 시 404 발생 X

### 로컬 검증
```bash
# 프로덕션 동일하게 빌드
flutter build web --release \
  --dart-define=API_BASE_URL="https://xnyhzyvigazofjoozuub.supabase.co/functions/v1"

# 정적 서버로 미리보기
cd build/web && python3 -m http.server 8000
```

## 다음 단계 (현재 범위 외)

- 지역/구 필터, 시공사 검색 등 부가 필터
- 청약 상세 페이지 + 공식 공고 URL 외부 링크 (`url_launcher`)
- D-day 자동 계산/색상 분기 강화
- 즐겨찾기 (로컬 저장)
- `/notify` 기반 알림 설정 화면
- 다크 모드 / 반응형 레이아웃
- `freezed` + `json_serializable` 도입 (모델 코드젠)
- `go_router` 도입
