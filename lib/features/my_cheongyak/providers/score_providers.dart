import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../announcements/providers/announcements_providers.dart' show apiClientProvider;
import '../data/score_repository.dart';
import '../models/score_result.dart';

final scoreRepositoryProvider = Provider<ScoreRepository>((ref) {
  return ScoreRepository(ref.watch(apiClientProvider));
});

/// 내 가점 조회 (인증 필수)
final myScoreProvider = FutureProvider<ScoreResult>((ref) async {
  return ref.watch(scoreRepositoryProvider).fetchScore();
});

/// 재계산 notifier — POST /my-score 후 myScoreProvider invalidate
class ScoreRecalcNotifier extends AsyncNotifier<ScoreResult?> {
  @override
  Future<ScoreResult?> build() async => null;

  Future<void> recalculate(Map<String, dynamic> profile) async {
    state = const AsyncLoading();
    try {
      final result = await ref.read(scoreRepositoryProvider).recalculate(profile);
      ref.invalidate(myScoreProvider);
      state = AsyncData(result);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final scoreRecalcProvider =
    AsyncNotifierProvider<ScoreRecalcNotifier, ScoreResult?>(ScoreRecalcNotifier.new);
