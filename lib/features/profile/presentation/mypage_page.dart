import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/main_scaffold.dart';
import '../../../core/auth/auth_repository.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/page_container.dart';
import '../../../core/widgets/section_card.dart';
import '../models/user_profile.dart';
import '../providers/profile_providers.dart';

/// /mypage — Stitch screen ecdbf516 매핑
/// 헤더(닉네임 + 가점) + 기본 정보 / 청약통장 / 특공 자격 카드.
/// 가점은 단계 2 (my-score)에서 추가 (현재는 score JSONB에 있으면 표시).
class MypagePage extends ConsumerWidget {
  const MypagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProfile = ref.watch(profileProvider);

    return MainScaffold(
      appBar: AppTopBar(
        title: '내 청약',
        onNotificationTap: () => context.push('/notifications'),
      ),
      body: asyncProfile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _buildError(context, ref, e),
        data: (resp) => _buildBody(context, ref, resp),
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, Object e) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text('프로필을 불러올 수 없습니다.\n$e', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => ref.invalidate(profileProvider),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, ProfileResponse resp) {
    final profile = resp.profile;
    final derived = resp.derived;
    final scoreTotal = (resp.score?['total'] as num?)?.toInt();
    final isOnboardingComplete = profile.isOnboardingComplete;

    return PageContainer(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // 헤더
          _ProfileHeader(
            nickname: profile.nickname ?? '회원',
            scoreTotal: scoreTotal,
          ),
          const SizedBox(height: 16),

          // 온보딩 미완 시 배너
          if (!isOnboardingComplete) ...[
            _OnboardingBanner(
              currentStep: profile.onboardingStep ?? 1,
              onTap: () => context.push('/onboarding/${profile.onboardingStep ?? 1}'),
            ),
            const SizedBox(height: 16),
          ],

          // 기본 정보 카드
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader(
                  title: '기본 정보',
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => context.push('/onboarding/2'),
                  ),
                ),
                const SizedBox(height: 8),
                _InfoRow(label: '연령/세대', value: _ageHouseholdLine(derived, profile)),
                _InfoRow(label: '주택 소유', value: _ownershipLine(profile, derived)),
                _InfoRow(label: '소득 구간', value: profile.incomeBracket ?? '미입력'),
                _InfoRow(label: '선호 지역', value: _regionsLine(profile)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 청약 통장
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader(
                  title: '청약 통장',
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => context.push('/onboarding/4'),
                  ),
                ),
                const SizedBox(height: 8),
                _InfoRow(label: '가입일', value: derived.accountJoinDate ?? '미입력'),
                _InfoRow(
                  label: '납입 회차',
                  value: profile.subscriptionContributions != null
                      ? '${profile.subscriptionContributions}회'
                      : '미입력',
                ),
                _InfoRow(
                  label: '예치금',
                  value: derived.accountBalanceWon != null
                      ? '${_formatWon(derived.accountBalanceWon!)}원'
                      : '미입력',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 특별공급 자격 (관심)
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader(
                  title: '특별공급 자격 (관심)',
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => context.push('/onboarding/5'),
                  ),
                ),
                const SizedBox(height: 8),
                _SpecialSupplyChips(
                  interests: profile.specialSupplyInterests ?? const [],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 로그아웃
          OutlinedButton.icon(
            onPressed: () => _confirmSignOut(context, ref),
            icon: const Icon(Icons.logout),
            label: const Text('로그아웃'),
          ),
          const SizedBox(height: 8),
          if (resp.userId.isNotEmpty)
            Text(
              'user_id: ${resp.userId.substring(0, 8)}...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃하시겠어요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('로그아웃')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await AuthRepository().signOut();
    ref.invalidate(profileProvider);
    if (context.mounted) {
      context.go('/login');
    }
  }

  String _ageHouseholdLine(DerivedFields derived, UserProfile profile) {
    final ageStr = derived.age != null ? '${derived.age}세' : '?';
    final house = profile.householdType ?? '미입력';
    return '$ageStr / $house';
  }

  String _ownershipLine(UserProfile profile, DerivedFields derived) {
    if (profile.isHomeless == true) {
      final years = derived.homelessYears;
      return years != null ? '무주택 (${years}년)' : '무주택';
    }
    if (profile.hasHouse == true) return '유주택';
    return '미입력';
  }

  String _regionsLine(UserProfile profile) {
    final regions = profile.preferredRegions;
    if (regions == null || regions.isEmpty) return '미입력';
    final size = profile.preferredSizeSqm;
    final sizePart = size != null ? ' / ${size}㎡' : '';
    return '${regions.join(', ')}$sizePart';
  }

  String _formatWon(int won) {
    final s = won.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.nickname, this.scoreTotal});
  final String nickname;
  final int? scoreTotal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
            child: const Icon(Icons.person, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$nickname 님',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (scoreTotal != null)
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        const TextSpan(text: '청약가점: '),
                        TextSpan(
                          text: '${scoreTotal}점',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(text: ' (예상)'),
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

class _OnboardingBanner extends StatelessWidget {
  const _OnboardingBanner({required this.currentStep, required this.onTap});
  final int currentStep;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.primaryContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: colors.onPrimaryContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '프로필 설정을 완료해주세요 (Step $currentStep / 5)',
                      style: TextStyle(
                        color: colors.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '맞춤 추천 + 가점 계산을 위해 필요합니다',
                      style: TextStyle(color: colors.onPrimaryContainer),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward, color: colors.onPrimaryContainer),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecialSupplyChips extends StatelessWidget {
  const _SpecialSupplyChips({required this.interests});
  final List<String> interests;

  static const _all = ['신혼부부', '생애최초', '다자녀', '노부모부양'];

  @override
  Widget build(BuildContext context) {
    if (interests.isEmpty) {
      return const Text('미선택', style: TextStyle(color: Colors.grey));
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _all
          .map((s) => _Chip(label: s, selected: interests.contains(s)))
          .toList(),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected});
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? colors.primaryContainer : Colors.transparent,
        border: Border.all(color: selected ? colors.primary : colors.outline),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? colors.onPrimaryContainer : colors.onSurface,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
