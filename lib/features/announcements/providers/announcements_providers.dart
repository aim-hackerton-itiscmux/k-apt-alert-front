import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../data/announcements_repository.dart';
import '../models/announcements_response.dart';
import '../models/category.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient();
  ref.onDispose(client.close);
  return client;
});

final announcementsRepositoryProvider =
    Provider<AnnouncementsRepository>((ref) {
  return AnnouncementsRepository(ref.watch(apiClientProvider));
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repo = ref.watch(announcementsRepositoryProvider);
  return repo.fetchCategories();
});

class SelectedCategoryNotifier extends Notifier<String> {
  @override
  String build() => 'all';

  void select(String id) => state = id;
}

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, String>(
  SelectedCategoryNotifier.new,
);

final announcementsProvider =
    FutureProvider.autoDispose<AnnouncementsResponse>((ref) async {
  final category = ref.watch(selectedCategoryProvider);
  final repo = ref.watch(announcementsRepositoryProvider);
  return repo.fetchAnnouncements(category: category);
});
