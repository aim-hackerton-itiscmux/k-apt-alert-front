import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/main_scaffold.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/page_container.dart';
import '../models/announcements_response.dart';
import '../providers/announcements_providers.dart';
import 'widgets/announcement_card.dart';
import 'widgets/category_filter.dart';

class AnnouncementsPage extends ConsumerWidget {
  const AnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncAnnouncements = ref.watch(announcementsProvider);

    return MainScaffold(
      appBar: AppTopBar(
        notificationBadge: 2,
        onNotificationTap: () => context.push('/notifications'),
      ),
      body: SafeArea(
        child: PageContainer(
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '지역 또는 공고명을 입력하세요',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const CategoryFilter(),
              const SizedBox(height: 16),
              Expanded(
                child: asyncAnnouncements.when(
                  loading: () => const _LoadingView(),
                  error: (error, stack) => _ErrorView(
                    message: error.toString(),
                    onRetry: () => ref.invalidate(announcementsProvider),
                  ),
                  data: (response) => _AnnouncementsList(
                    response: response,
                    onRefresh: () async =>
                        ref.invalidate(announcementsProvider),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            '데이터 로딩 중... (콜드 캐시 시 최대 2분)',
            style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.outline),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementsList extends StatelessWidget {
  const _AnnouncementsList({
    required this.response,
    required this.onRefresh,
  });

  final AnnouncementsResponse response;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (response.announcements.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          children: [
            const SizedBox(height: 80),
            const Icon(
              Icons.inbox_outlined,
              size: 56,
              color: AppColors.outline,
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                '표시할 청약 공고가 없습니다.',
                style: TextStyle(color: AppColors.onSurfaceVariant),
              ),
            ),
            if (response.errors != null && response.errors!.isNotEmpty) ...[
              const SizedBox(height: 16),
              for (final e in response.errors!)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    '⚠ $e',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        itemCount: response.announcements.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) return _SectionHeader(count: response.count);
          final a = response.announcements[index - 1];
          return AnnouncementCard(
            announcement: a,
            onTap: () => context.push('/announcements/${Uri.encodeComponent(a.id)}'),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Row(
        children: [
          const Text(
            '진행중인 청약',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
