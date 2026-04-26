import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/main_scaffold.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/page_container.dart';
import '../../../core/widgets/section_card.dart';

class HomeDashboardPage extends StatelessWidget {
  const HomeDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      appBar: AppTopBar(
        notificationBadge: 2,
        onNotificationTap: () => context.push('/notifications'),
      ),
      body: SafeArea(
        child: PageContainer(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              const _Greeting(name: '성호'),
              const SizedBox(height: 20),
              const _ProfileProgressCard(),
              const SizedBox(height: 16),
              _UrgentAnnouncementCard(
                onTap: () => context.push('/analysis'),
              ),
              const SizedBox(height: 16),
              const _ChecklistCard(),
              const SizedBox(height: 16),
              _RecommendationsCard(
                onItemTap: (id) => context.push('/announcements/$id'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '안녕하세요, $name님',
          style: const TextStyle(
            fontSize: 26,
            height: 34 / 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '오늘 확인할 청약 준비가 3개 있어요.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ProfileProgressCard extends StatelessWidget {
  const _ProfileProgressCard();

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '나의 청약 프로필',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '업데이트 추천',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.outline),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              _ProfileMetric(label: '청약 여부', value: '예'),
              SizedBox(width: 12),
              _ProfileMetric(label: '가입 기간', value: '36개월'),
              SizedBox(width: 12),
              _ProfileMetric(label: '관심 지역', value: '서울/경기'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileMetric extends StatelessWidget {
  const _ProfileMetric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UrgentAnnouncementCard extends StatelessWidget {
  const _UrgentAnnouncementCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFBA1A1A),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'D-7',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '1순위',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '서초 리버포레',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            '모집공고 확인이 필요합니다.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: const LinearProgressIndicator(
              value: 0.4,
              minHeight: 6,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: FilledButton.icon(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text(
                'AI로 공고 분석하기',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistCard extends StatelessWidget {
  const _ChecklistCard();

  static const _items = [
    (true, '청약통장 예치금 확인'),
    (false, '공동인증서 갱신 확인'),
    (false, '최근 납입회차 점검'),
  ];

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_box_outlined,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              const Text(
                '필수 준비 체크리스트',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                '전체보기',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final (done, label) in _items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    done
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: done ? AppColors.primary : AppColors.outline,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: done
                          ? AppColors.onSurfaceVariant
                          : AppColors.onSurface,
                      decoration:
                          done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RecommendationsCard extends StatelessWidget {
  const _RecommendationsCard({required this.onItemTap});
  final ValueChanged<String> onItemTap;

  static const _items = [
    ('demo-seocho', '서초 리버포레', '강남권'),
    ('demo-pangyo', '판교 센트럴파크', '입지+분양가 우수'),
  ];

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.auto_awesome, size: 20, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'AI 추천 공고',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final (id, name, badge) in _items)
            InkWell(
              onTap: () => onItemTap(id),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          color: AppColors.onSecondaryContainer,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.outline,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
