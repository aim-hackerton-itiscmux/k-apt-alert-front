import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/main_scaffold.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/page_container.dart';
import '../../../core/widgets/section_card.dart';

class AiReportPage extends StatelessWidget {
  const AiReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      appBar: AppTopBar(
        title: '서초 리버포레 청약 분석 보고서',
        onNotificationTap: () => context.push('/notifications'),
        notificationBadge: 2,
      ),
      body: SafeArea(
        child: PageContainer(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  children: const [
                    _ScoreBadge(),
                    SizedBox(height: 16),
                    _KeyInsightsCard(),
                    SizedBox(height: 16),
                    _MetricsGrid(),
                    SizedBox(height: 16),
                    _ReferencesCard(),
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

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6D6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.tertiaryContainer),
      ),
      child: Row(
        children: const [
          Icon(Icons.workspace_premium,
              color: AppColors.onTertiaryContainer, size: 20),
          SizedBox(width: 8),
          Text(
            'AI 종합 평가',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onTertiaryContainer,
            ),
          ),
          Spacer(),
          Text(
            '오긴이 73점',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.onTertiaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyInsightsCard extends StatelessWidget {
  const _KeyInsightsCard();

  static const _insights = [
    '핵심 강점 평준비계수: 비교 가중치 88',
    '분양가능공략에 따라 비교 1순위 클래스 추천 등급',
    '지원할 가치 있음: 1건수 점수가 높음',
    '대비 평균 청약 점수가 100% 이상 채울 수 있음',
    '시기 정의에 따라 60% 이상 응당함',
    '중간 영역가 적정도 동일이 가장 잘 맞음',
    '현재 평균 가격대비 약 8% 저평가 진입 가능',
  ];

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.tips_and_updates_outlined,
                  size: 20, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                '핵심 요약 인사이트',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final line in _insights)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6, right: 8),
                    child: Icon(Icons.circle,
                        size: 6, color: AppColors.primary),
                  ),
                  Expanded(
                    child: Text(
                      line,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 20 / 13,
                        color: AppColors.onSurface,
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

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _MetricBox(
            icon: Icons.attach_money,
            label: '가격 경쟁력',
            value: '+6.3%',
            color: AppColors.onSecondaryContainer,
            bgColor: AppColors.secondaryContainer,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _MetricBox(
            icon: Icons.location_on_outlined,
            label: '입지 점수',
            value: '도보 8분\n2호선 강남역 인접',
            color: AppColors.onSurface,
            bgColor: AppColors.surfaceContainerLow,
          ),
        ),
      ],
    );
  }
}

class _MetricBox extends StatelessWidget {
  const _MetricBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
              height: 22 / 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferencesCard extends StatelessWidget {
  const _ReferencesCard();

  static const _refs = [
    ('AI 분석 근거 문서', '결과 보고서'),
    ('입주자모집공고 12조 - 분양가 산정', '분양가 산정 기준'),
    ('입주자 모집공고 18조 - 청약 신청 자격', '청약 자격 기준'),
  ];

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (title, sub) in _refs)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.description_outlined,
                        size: 16, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          sub,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
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

class _BottomActions extends StatelessWidget {
  const _BottomActions();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                side: const BorderSide(color: AppColors.outlineVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('근거 보기'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.checklist_rounded, size: 18),
              label: const Text('체크리스트 만들기'),
            ),
          ),
        ],
      ),
    );
  }
}
