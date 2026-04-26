import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../models/score_result.dart';

class ScoreRepository {
  ScoreRepository(this._client);
  final ApiClient _client;

  /// GET /v1/my-score — DB 저장 가점 반환 (30일 초과 시 서버 자동 재계산)
  Future<ScoreResult> fetchScore() async {
    final data = await _client.getJson('/my-score');
    if (data is! Map) throw ApiException('가점 응답 형식 오류');
    return ScoreResult.fromJson(data.cast<String, dynamic>());
  }

  /// POST /v1/my-score — 프로필 전달 → 즉시 재계산 + 저장
  Future<ScoreResult> recalculate(Map<String, dynamic> profile) async {
    final data = await _client.postJson('/my-score', body: profile);
    if (data is! Map) throw ApiException('가점 재계산 응답 형식 오류');
    return ScoreResult.fromJson(data.cast<String, dynamic>());
  }
}
