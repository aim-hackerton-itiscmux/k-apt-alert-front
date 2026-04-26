import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../models/announcements_response.dart';
import '../models/category.dart';

class AnnouncementsRepository {
  AnnouncementsRepository(this._client);

  final ApiClient _client;

  Future<List<Category>> fetchCategories() async {
    final data = await _client.getJson('/categories');
    if (data is! Map || data['categories'] is! List) {
      throw ApiException('잘못된 카테고리 응답 형식입니다.');
    }
    final list = (data['categories'] as List)
        .whereType<Map>()
        .map((e) => Category.fromJson(e.cast<String, dynamic>()))
        .toList(growable: false);
    return list;
  }

  Future<AnnouncementsResponse> fetchAnnouncements({
    String category = 'all',
    bool activeOnly = true,
    int monthsBack = 2,
  }) async {
    final query = <String, String>{
      'category': category,
      'active_only': activeOnly.toString(),
      'months_back': monthsBack.toString(),
    };
    final data = await _client.getJson(
      '/announcements',
      queryParameters: query,
    );
    if (data is! Map) {
      throw ApiException('잘못된 청약 응답 형식입니다.');
    }
    return AnnouncementsResponse.fromJson(data.cast<String, dynamic>());
  }
}
