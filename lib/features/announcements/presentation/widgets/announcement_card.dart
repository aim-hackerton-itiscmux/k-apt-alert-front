import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../models/announcement.dart';

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({
    super.key,
    required this.announcement,
    this.onTap,
    this.onBookmarkTap,
    this.bookmarked = false,
  });

  final Announcement announcement;
  final VoidCallback? onTap;
  final VoidCallback? onBookmarkTap;
  final bool bookmarked;

  @override
  Widget build(BuildContext context) {
    final a = announcement;
    final regionLabel = [a.region, a.district]
        .where((s) => s.isNotEmpty)
        .join(' ');
    final tags = _tagsFor(a);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if ((a.dDayLabel ?? '').isNotEmpty)
                    _DDayBadge(label: a.dDayLabel!, dDay: a.dDay),
                  if ((a.dDayLabel ?? '').isNotEmpty && regionLabel.isNotEmpty)
                    const SizedBox(width: 8),
                  if (regionLabel.isNotEmpty)
                    Expanded(
                      child: Text(
                        regionLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.outline,
                        ),
                      ),
                    )
                  else
                    const Spacer(),
                  IconButton(
                    iconSize: 22,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: onBookmarkTap,
                    color: AppColors.outline,
                    icon: Icon(
                      bookmarked ? Icons.bookmark : Icons.bookmark_border,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                a.name.isEmpty ? '(이름 없음)' : a.name,
                style: const TextStyle(
                  fontSize: 18,
                  height: 26 / 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              if (a.totalUnits.isNotEmpty || a.size.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  _unitsLine(a),
                  style: const TextStyle(
                    fontSize: 14,
                    height: 20 / 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
              if (tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags.map((t) => _Tag(tag: t)).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _unitsLine(Announcement a) {
    final parts = <String>[];
    if (a.totalUnits.isNotEmpty) parts.add('${a.totalUnits}세대');
    if (a.size.isNotEmpty) parts.add(a.size);
    return parts.join(' · ');
  }

  List<_TagSpec> _tagsFor(Announcement a) {
    final list = <_TagSpec>[];
    if (a.priceControlled.toUpperCase() == 'Y' ||
        a.priceControlled.contains('Y')) {
      list.add(const _TagSpec('분양가상한제', _TagStyle.recommended));
    }
    if (a.speculativeZone.toUpperCase() == 'Y' ||
        a.speculativeZone.contains('Y')) {
      list.add(const _TagSpec('투기과열지구', _TagStyle.warning));
    }
    if (a.houseCategory.isNotEmpty) {
      list.add(_TagSpec(a.houseCategory, _TagStyle.neutral));
    }
    return list;
  }
}

enum _TagStyle { warning, caution, recommended, neutral }

class _TagSpec {
  const _TagSpec(this.label, this.style);
  final String label;
  final _TagStyle style;
}

class _Tag extends StatelessWidget {
  const _Tag({required this.tag});

  final _TagSpec tag;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (tag.style) {
      _TagStyle.warning => (AppColors.errorContainer, AppColors.onErrorContainer),
      _TagStyle.caution => (
          AppColors.tertiaryContainer,
          AppColors.onTertiaryContainer
        ),
      _TagStyle.recommended => (
          AppColors.secondaryContainer,
          AppColors.onSecondaryContainer
        ),
      _TagStyle.neutral => (
          AppColors.surfaceContainerHigh,
          AppColors.onSurfaceVariant
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: bg),
      ),
      child: Text(
        tag.label,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _DDayBadge extends StatelessWidget {
  const _DDayBadge({required this.label, this.dDay});

  final String label;
  final int? dDay;

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.primary;
    if (dDay != null) {
      if (dDay! <= 3) {
        bg = const Color(0xFFBA1A1A);
      } else if (dDay! <= 7) {
        bg = const Color(0xFFCCA830);
      }
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.onPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
