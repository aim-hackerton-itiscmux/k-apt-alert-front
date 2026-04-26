import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';

/// Supabase Auth 래퍼 — 매직링크 로그인 + 세션 관리.
///
/// SupabaseConfig.isConfigured == false면 호출 시 StateError throw.
/// (Supabase가 초기화되지 않은 상태에서 호출 방지)
class AuthRepository {
  AuthRepository();

  GoTrueClient get _auth {
    if (!SupabaseConfig.isConfigured) {
      throw StateError(
        'Supabase가 설정되지 않음. --dart-define=SUPABASE_ANON_KEY=... 로 빌드하세요.',
      );
    }
    return Supabase.instance.client.auth;
  }

  /// 매직링크 발송. 사용자가 이메일 링크 클릭 → 세션 자동 생성.
  ///
  /// emailRedirectTo: 이메일 링크 클릭 시 돌아갈 URL.
  /// 미설정 시 Supabase 프로젝트의 기본 Site URL 사용.
  Future<void> sendMagicLink({required String email}) async {
    final redirectTo = SupabaseConfig.authRedirectUrl.isEmpty
        ? null
        : SupabaseConfig.authRedirectUrl;
    await _auth.signInWithOtp(
      email: email,
      emailRedirectTo: redirectTo,
    );
  }

  /// 현재 세션 조회.
  Session? currentSession() {
    if (!SupabaseConfig.isConfigured) return null;
    return Supabase.instance.client.auth.currentSession;
  }

  /// 현재 user 조회.
  User? currentUser() {
    if (!SupabaseConfig.isConfigured) return null;
    return Supabase.instance.client.auth.currentUser;
  }

  /// 인증 상태 변화 stream — Riverpod에서 watch.
  Stream<AuthState> authStateChanges() {
    if (!SupabaseConfig.isConfigured) {
      return const Stream.empty();
    }
    return Supabase.instance.client.auth.onAuthStateChange;
  }

  /// 로그아웃 (로컬 + 서버 세션 모두 무효화).
  Future<void> signOut() async {
    if (!SupabaseConfig.isConfigured) return;
    await Supabase.instance.client.auth.signOut();
  }

  /// 현재 access token (ApiClient에 첨부할 Bearer JWT).
  String? currentAccessToken() {
    return currentSession()?.accessToken;
  }
}
