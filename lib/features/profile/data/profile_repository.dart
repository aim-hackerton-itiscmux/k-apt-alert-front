import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../models/user_profile.dart';

class ProfileRepository {
  ProfileRepository(this._client);

  final ApiClient _client;

  /// GET /v1/profile (인증 필수)
  Future<ProfileResponse> fetchProfile() async {
    final data = await _client.getJson('/profile');
    if (data is! Map) {
      throw ApiException('잘못된 프로필 응답 형식입니다.');
    }
    return ProfileResponse.fromJson(data.cast<String, dynamic>());
  }

  /// PATCH /v1/profile body는 toPatchBody() 결과 (null 제외 부분 머지)
  Future<ProfileResponse> patchProfile(UserProfile updates) async {
    final body = updates.toPatchBody();
    if (body.isEmpty) {
      throw ApiException('업데이트할 필드가 없습니다.');
    }
    final data = await _client.patchJson('/profile', body: body);
    if (data is! Map) {
      throw ApiException('잘못된 프로필 응답 형식입니다.');
    }
    return ProfileResponse.fromJson(data.cast<String, dynamic>());
  }
}
