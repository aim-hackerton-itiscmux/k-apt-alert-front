import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/page_container.dart';
import '../../../core/widgets/section_card.dart';

class AnnouncementDetailPage extends StatelessWidget {
  const AnnouncementDetailPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(showBack: true, title: '뒤로'),
      body: SafeArea(
        child: PageContainer(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  children: const [
                    _Header(),
                    SizedBox(height: 12),
                    _ChangeBanner(),
                    SizedBox(height: 16),
                    _ScheduleCard(),
                    SizedBox(height: 16),
                    _ScoreEstimateCard(),
                    SizedBox(height: 16),
                    _AnalysisGrid(),
                  ],
                ),
              ),
              const _BottomActions(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '투기과열지구',
                style: TextStyle(
                  color: AppColors.onErrorContainer,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          '서초 리버포레',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '서울 서초구 반포동 123-45',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ChangeBanner extends StatelessWidget {
  const _ChangeBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.errorContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.errorContainer),
      ),
      child: Row(
        children: const [
          Icon(Icons.info_outline,
              size: 18, color: AppColors.onErrorContainer),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '최근 정정공고가 있습니다.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.onErrorContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '변경 내역 보기',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.onErrorContainer,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard();

  static const _items = [
    ('2023.10.25', '특별공급'),
    ('서울 서초구 반포동 123-45', '특별공급'),
    ('2023.11.06', '1순위'),
    ('2023.11.07', '2순위'),
    ('2023.11.15', '당첨자 발표'),
  ];

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.event, size: 18, color: AppColors.primary),
              SizedBox(width: 6),
              Text(
                '주요 일정',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final (date, label) in _items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 96,
                    child: Text(
                      date,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
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

class _ScoreEstimateCard extends StatelessWidget {
  const _ScoreEstimateCard();

  static const _items = [
    ('부양수 (3)', 12, 32),
    ('통장기간', 15, 35),
    ('청약가입기간 (8년)', 5, 17),
  ];

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.calculate_outlined,
                  size: 18, color: AppColors.primary),
              SizedBox(width: 6),
              Text(
                '확정 계산 결과',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              Spacer(),
              Text(
                '가점제 적용',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Text(
                '내 추정 가점',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Spacer(),
              Text(
                '32',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              Text(
                ' / 84점',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: const LinearProgressIndicator(
              value: 32 / 84,
              minHeight: 6,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: 12),
          for (final (label, value, max) in _items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    '$value점',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    ' / $max점',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.outline,
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

class _AnalysisGrid extends StatelessWidget {
  const _AnalysisGrid();

  static const _items = [
    (Icons.attach_money, '분양가 적정성', '+6.3%'),
    (Icons.location_on_outlined, '입지 점수', '도보 8분'),
    (Icons.school_outlined, '학군', '강남 학군'),
    (Icons.directions_subway, '교통 분석', '2호선'),
  ];

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.bar_chart_rounded,
                  size: 18, color: AppColors.primary),
              SizedBox(width: 6),
              Text(
                '단지 분석 요약',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.75,
            children: [
              for (final (icon, label, sub) in _items)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: AppColors.primary, size: 20),
                      const SizedBox(height: 6),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sub,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.bookmark_border, size: 18),
              label: const Text('관심 저장'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                side: const BorderSide(color: AppColors.outlineVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('AI 리포트 보기'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
