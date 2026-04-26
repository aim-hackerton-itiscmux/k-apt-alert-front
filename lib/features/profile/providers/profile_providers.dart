import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../announcements/providers/announcements_providers.dart' show apiClientProvider;
import '../data/profile_repository.dart';
import '../models/user_profile.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(apiClientProvider));
});

/// 본인 프로필 — 인증된 상태에서만 의미 있음.
/// authStateProvider가 변할 때 자동 invalidate 되도록 watch.
final profileProvider = FutureProvider<ProfileResponse>((ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.fetchProfile();
});

/// PATCH 후 invalidate 트리거용 — 화면에서 ref.invalidate(profileProvider) 호출.
class ProfileMutationNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<ProfileResponse> patch(UserProfile updates) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(profileRepositoryProvider);
      final result = await repo.patchProfile(updates);
      // 갱신 후 profileProvider invalidate → 다른 화면 자동 refresh
      ref.invalidate(profileProvider);
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final profileMutationProvider =
    AsyncNotifierProvider<ProfileMutationNotifier, void>(
  ProfileMutationNotifier.new,
);
