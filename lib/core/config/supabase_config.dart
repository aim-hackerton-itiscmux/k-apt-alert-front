/// Supabase 프로젝트 설정.
///
/// 빌드 시 `--dart-define=SUPABASE_ANON_KEY=...` 로 덮어쓸 수 있다.
/// (anon key는 클라이언트 노출이 의도된 키이므로 코드 포함 가능. 다만
/// 환경별 분리를 위해 dart-define 권장.)
class SupabaseConfig {
  const SupabaseConfig._();

  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://xnyhzyvigazofjoozuub.supabase.co',
  );

  /// anon (public) key — 빌드 시 dart-define으로 주입.
  /// 비어있으면 Auth 기능 비활성 (로그인 페이지에서 안내).
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// 매직링크 콜백 URL.
  /// Web: `${origin}/auth/callback` (router에서 처리)
  /// 운영 도메인: Vercel URL.
  /// dart-define 으로 명시 가능 (Vercel 환경별 다름).
  static const String authRedirectUrl = String.fromEnvironment(
    'AUTH_REDIRECT_URL',
    defaultValue: '',
  );

  static bool get isConfigured => anonKey.isNotEmpty;
}
