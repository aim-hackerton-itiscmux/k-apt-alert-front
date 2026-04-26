import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import 'auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// 현재 인증 상태 — onAuthStateChange stream 구독.
/// 미설정 시 항상 unauthenticated state 반환.
final authStateProvider = StreamProvider<AuthState?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges();
});

/// 현재 사용자 (편의용 — null이면 비로그인).
final currentUserProvider = Provider<User?>((ref) {
  final asyncState = ref.watch(authStateProvider);
  return asyncState.maybeWhen(
    data: (state) => state?.session?.user ?? AuthRepository().currentUser(),
    orElse: () => AuthRepository().currentUser(),
  );
});

/// 로그인 여부 — router redirect, UI 분기 등에서 사용.
final isAuthenticatedProvider = Provider<bool>((ref) {
  if (!SupabaseConfig.isConfigured) return false;
  return ref.watch(currentUserProvider) != null;
});
