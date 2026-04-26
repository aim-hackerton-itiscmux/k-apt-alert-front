import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/page_container.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String _selected = '전체';
  static const _filters = ['전체', '일정', '변경사항', '접수', '서류'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        showBack: true,
        trailing: IconButton(
          icon: const Icon(Icons.settings_outlined),
          tooltip: '설정',
          onPressed: () {},
        ),
      ),
      body: SafeArea(
        child: PageContainer(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            children: [
              Row(
                children: [
                  const Text(
                    '알림',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      '모두 읽음',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final f = _filters[i];
                    final selected = f == _selected;
                    return _FilterChip(
                      label: f,
                      selected: selected,
                      onTap: () => setState(() => _selected = f),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ..._notificationItems(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _notificationItems() {
    final items = <_NotifItemSpec>[
      const _NotifItemSpec(
        kind: _NotifKind.urgent,
        ddayLabel: 'D-7',
        category: '접수',
        title: '래미안 원베일리 특별공급 접수',
        body:
            '관심 단지로 등록하신 레미안 원베일리의 특별공급 청약 접수가 7일 후 마감됩니다. 서…',
        time: '방금 전',
      ),
      const _NotifItemSpec(
        kind: _NotifKind.tip,
        category: '가점 업데이트',
        title: '다음 달 청약 가점 2점 상승 예상',
        body:
            '무주택 기간이 1년 증가하면서 다음 달 청약 가점이 총 54점으로 상승할 예정입니다.',
        time: '2시간 전',
      ),
      const _NotifItemSpec(
        kind: _NotifKind.notice,
        category: '공지사항',
        title: '2024년 하반기 청약 제도 개편 안내',
        body: '신생아 특공 신설 및 다자녀 기준 완화 등 주요 변경 사항을 확인하세요.',
        time: '어제',
      ),
    ];
    return items
        .map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _NotificationCard(spec: s),
            ))
        .toList();
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? AppColors.primaryContainer
        : AppColors.surfaceContainerLowest;
    final fg = selected
        ? AppColors.onPrimaryFixedVariant
        : AppColors.onSurfaceVariant;
    final border =
        selected ? AppColors.primaryContainer : AppColors.outlineVariant;
    return Material(
      color: bg,
      shape: StadiumBorder(side: BorderSide(color: border)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

enum _NotifKind { urgent, tip, notice }

class _NotifItemSpec {
  const _NotifItemSpec({
    required this.kind,
    required this.category,
    required this.title,
    required this.body,
    required this.time,
    this.ddayLabel,
  });

  final _NotifKind kind;
  final String category;
  final String title;
  final String body;
  final String time;
  final String? ddayLabel;
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.spec});
  final _NotifItemSpec spec;

  @override
  Widget build(BuildContext context) {
    final (Color leadingColor, IconData leadingIcon) = switch (spec.kind) {
      _NotifKind.urgent => (const Color(0xFFBA1A1A), Icons.priority_high),
      _NotifKind.tip => (AppColors.tertiaryContainer, Icons.trending_up),
      _NotifKind.notice => (AppColors.outline, Icons.campaign_outlined),
    };

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: leadingColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (spec.ddayLabel != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: leadingColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              spec.ddayLabel!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        if (spec.ddayLabel != null) const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(leadingIcon, size: 12, color: leadingColor),
                              const SizedBox(width: 4),
                              Text(
                                spec.category,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          spec.time,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      spec.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      spec.body,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 18 / 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
