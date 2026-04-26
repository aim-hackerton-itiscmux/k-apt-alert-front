import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/main_scaffold.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/page_container.dart';
import '../../../core/widgets/section_card.dart';

class PreparationPage extends StatelessWidget {
  const PreparationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      appBar: AppTopBar(
        title: '준비 / 내 서류함',
        notificationBadge: 2,
        onNotificationTap: () => context.push('/notifications'),
      ),
      body: SafeArea(
        child: PageContainer(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  children: const [
                    _ProgressCard(),
                    SizedBox(height: 16),
                    _DocumentsCard(),
                    SizedBox(height: 16),
                    _DDayChecklistCard(),
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

class _ProgressCard extends StatelessWidget {
  const _ProgressCard();

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text(
                '서류 준비율',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              Spacer(),
              Text(
                '45%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: const LinearProgressIndicator(
              value: 0.45,
              minHeight: 8,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '총 10개 중 4개 완료',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentsCard extends StatelessWidget {
  const _DocumentsCard();

  static const _docs = [
    (
      Icons.fact_check_outlined,
      '주민등록등본',
      '최근 3개월 이내 발급',
      '확인',
      _Status.warning
    ),
    (
      Icons.family_restroom_outlined,
      '가족관계증명서',
      '주민번호 미공개 본 발급 필요',
      '준비 완료',
      _Status.ready
    ),
    (
      Icons.verified_user_outlined,
      '공동인증서',
      'BJ인증 예정 (공동 인감)',
      '만료 임박',
      _Status.danger
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '내 서류함',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          for (var i = 0; i < _docs.length; i++) ...[
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.outlineVariant,
            ),
            _DocumentRow(
              icon: _docs[i].$1,
              title: _docs[i].$2,
              subtitle: _docs[i].$3,
              statusLabel: _docs[i].$4,
              status: _docs[i].$5,
            ),
          ],
        ],
      ),
    );
  }
}

enum _Status { warning, ready, danger }

class _DocumentRow extends StatelessWidget {
  const _DocumentRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    required this.status,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String statusLabel;
  final _Status status;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (status) {
      _Status.warning => (
          AppColors.tertiaryContainer.withValues(alpha: 0.45),
          AppColors.onTertiaryContainer
        ),
      _Status.ready => (
          AppColors.secondaryContainer,
          AppColors.onSecondaryContainer
        ),
      _Status.danger => (AppColors.errorContainer, AppColors.onErrorContainer),
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                color: fg,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DDayChecklistCard extends StatelessWidget {
  const _DDayChecklistCard();

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Icon(Icons.event_outlined,
                  size: 18, color: AppColors.primary),
              SizedBox(width: 6),
              Text(
                'D-day 체크리스트',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 12),
          _DDayBlock(
            label: 'D-14 ~ D-7',
            items: ['청약통장 부적격 확인 및 충전', '세대분 부적격 자가 재발급'],
          ),
          SizedBox(height: 8),
          _DDayBlock(
            label: 'D-3 ~ D-1',
            items: ['공동인증서/사용인감/유사 거주 적합 점검', '가점 항목별 증빙 서류 자료 출력'],
          ),
          SizedBox(height: 8),
          _DDayBlock(
            label: '접수 당일',
            items: ['청약신청 사이트 / 앱 접수 후료'],
          ),
        ],
      ),
    );
  }
}

class _DDayBlock extends StatelessWidget {
  const _DDayBlock({required this.label, required this.items});
  final String label;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
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
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '• $item',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.onSurface,
                ),
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
              child: const Text('알림 설정'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '준비 완료로 표시',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
