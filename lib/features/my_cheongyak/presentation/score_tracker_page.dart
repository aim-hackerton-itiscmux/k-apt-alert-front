import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/main_scaffold.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/page_container.dart';
import '../../../core/widgets/section_card.dart';
import '../models/score_result.dart';
import '../providers/score_providers.dart';

/// /my — 가점 트래커 (GET /my-score API 연동)
class ScoreTrackerPage extends ConsumerWidget {
  const ScoreTrackerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncScore = ref.watch(myScoreProvider);

    return MainScaffold(
      appBar: AppTopBar(
        onNotificationTap: () => context.push('/notifications'),
      ),
      body: SafeArea(
        child: PageContainer(
          child: asyncScore.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _buildError(context, ref, e),
            data: (result) => _buildBody(context, ref, result),
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, Object e) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text('가점을 불러올 수 없습니다.\n$e', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => ref.invalidate(myScoreProvider),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, ScoreResult result) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        _Header(updatedAt: result.updatedAt, recalculated: result.recalculated),
        const SizedBox(height: 16),
        if (result.upcomingAlert != null) ...[
          _NextUpgradeBanner(alert: result.upcomingAlert!),
          const SizedBox(height: 16),
        ],
        _ScoreDonutCard(score: result.score.total, total: ScoreBreakdown.maxTotal),
        const SizedBox(height: 16),
        _BreakdownCard(score: result.score),
        const SizedBox(height: 16),
        const _RecalcRow(),
        const SizedBox(height: 8),
        _SettingsRow(),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({this.updatedAt, this.recalculated});
  final String? updatedAt;
  final bool? recalculated;

  @override
  Widget build(BuildContext context) {
    String? dateStr;
    if (updatedAt != null) {
      try {
        final dt = DateTime.parse(updatedAt!).toLocal();
        dateStr = '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} 기준';
      } catch (_) {}
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '가점 트래커',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          dateStr ?? '현재 나의 청약 가점 현황을 분석합니다.',
          style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _NextUpgradeBanner extends StatelessWidget {
  const _NextUpgradeBanner({required this.alert});
  final UpcomingAlert alert;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondaryContainer),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active_outlined, color: AppColors.onSecondaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              alert.message,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreDonutCard extends StatelessWidget {
  const _ScoreDonutCard({required this.score, required this.total});
  final int score;
  final int total;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: SizedBox(
          width: 180,
          height: 180,
          child: CustomPaint(
            painter: _DonutPainter(progress: score / total),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$score점',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    '총 $total점 만점',
                    style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 8;
    final track = Paint()
      ..color = AppColors.surfaceContainerHigh
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final fill = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, track);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      progress * 2 * math.pi,
      false,
      fill,
    );
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.progress != progress;
}

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({required this.score});
  final ScoreBreakdown score;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('무주택기간', score.homelessScore, ScoreBreakdown.maxHomeless,
          score.homelessYears != null ? '${score.homelessYears!.toStringAsFixed(1)}년' : null),
      ('부양가족', score.dependentsScore, ScoreBreakdown.maxDependents, null),
      ('통장기간', score.savingsScore, ScoreBreakdown.maxSavings,
          score.savingsMonths != null ? '${score.savingsMonths}개월' : null),
    ];

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '항목별 상세 가점',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          for (final (label, value, max, sub) in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            if (sub != null)
                              Text(sub, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      Text.rich(
                        TextSpan(children: [
                          TextSpan(
                            text: '$value',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          TextSpan(
                            text: ' / $max',
                            style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                          ),
                        ]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: max > 0 ? value / max : 0,
                      minHeight: 6,
                      backgroundColor: AppColors.surfaceContainerHigh,
                      valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 4),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => context.push('/mypage'),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.tune, size: 16, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text(
                    '내 조건 수정하기',
                    style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                  Spacer(),
                  Icon(Icons.chevron_right, size: 18, color: AppColors.outline),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecalcRow extends ConsumerWidget {
  const _RecalcRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recalcState = ref.watch(scoreRecalcProvider);
    final isLoading = recalcState.isLoading;

    return OutlinedButton.icon(
      onPressed: isLoading
          ? null
          : () async {
              try {
                await ref.read(scoreRecalcProvider.notifier).recalculate({});
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('가점이 재계산되었습니다')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('재계산 실패: $e')),
                  );
                }
              }
            },
      icon: isLoading
          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.refresh),
      label: const Text('가점 재계산'),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('데이터 사용 안내', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
          Text('내 정보 삭제하기', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}
