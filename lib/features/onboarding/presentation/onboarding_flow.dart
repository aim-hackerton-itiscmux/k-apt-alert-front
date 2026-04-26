import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../profile/models/user_profile.dart';
import '../../profile/providers/profile_providers.dart';

/// /onboarding/:step — 5-step 프로필 입력 (Stitch screen 550553a6 참고)
///
/// Step 분할 (백엔드 onboarding_step 1..5 매핑):
///   1: 환영 + 닉네임
///   2: 생년월일 + 결혼 여부
///   3: 무주택 + 거주지
///   4: 청약통장 + 부양가족 (Stitch에서 가장 명확하게 분석된 step)
///   5: 선호 (특공 관심 / 선호지역 / 평형 / 가구유형 / 소득)
///
/// 각 step 완료 시 PATCH /profile (해당 필드 + onboarding_step 갱신).
/// Step 5 완료 시 onboarding_completed_at = NOW → /home redirect.
class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key, required this.step});
  final int step;

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  static const int totalSteps = 5;

  @override
  Widget build(BuildContext context) {
    final step = widget.step.clamp(1, totalSteps);
    final asyncProfile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Step $step / $totalSteps'),
        centerTitle: true,
        leading: step > 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/onboarding/${step - 1}'),
              )
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.go('/home'),
              ),
        actions: [
          TextButton(
            onPressed: () => context.go('/home'),
            child: const Text('나중에'),
          ),
        ],
      ),
      body: asyncProfile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('프로필 로드 실패: $e')),
        data: (resp) => SafeArea(
          child: Column(
            children: [
              _StepIndicator(current: step, total: totalSteps),
              Expanded(
                child: _StepBody(step: step, current: resp.profile),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: LinearProgressIndicator(
        value: current / total,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      ),
    );
  }
}

class _StepBody extends StatelessWidget {
  const _StepBody({required this.step, required this.current});
  final int step;
  final UserProfile current;

  @override
  Widget build(BuildContext context) {
    switch (step) {
      case 1:
        return _Step1Welcome(current: current);
      case 2:
        return _Step2Birth(current: current);
      case 3:
        return _Step3Housing(current: current);
      case 4:
        return _Step4Account(current: current);
      case 5:
        return _Step5Preferences(current: current);
      default:
        return const Center(child: Text('알 수 없는 step'));
    }
  }
}

// ─── 공통 헬퍼 ──────────────────────────────────────────────────────

Future<void> _saveAndAdvance({
  required BuildContext context,
  required WidgetRef ref,
  required UserProfile updates,
  required int currentStep,
  required int totalSteps,
}) async {
  final isFinal = currentStep >= totalSteps;
  final patched = UserProfile(
    nickname: updates.nickname,
    birthDate: updates.birthDate,
    isMarried: updates.isMarried,
    marriageDate: updates.marriageDate,
    dependentsCount: updates.dependentsCount,
    isHomeless: updates.isHomeless,
    homelessSince: updates.homelessSince,
    savingsStart: updates.savingsStart,
    savingsBalanceWan: updates.savingsBalanceWan,
    subscriptionContributions: updates.subscriptionContributions,
    residentRegion: updates.residentRegion,
    hasHouse: updates.hasHouse,
    parentsRegistered: updates.parentsRegistered,
    parentsRegisteredSince: updates.parentsRegisteredSince,
    preferredRegions: updates.preferredRegions,
    preferredSizeSqm: updates.preferredSizeSqm,
    incomeBracket: updates.incomeBracket,
    householdType: updates.householdType,
    specialSupplyInterests: updates.specialSupplyInterests,
    onboardingStep: isFinal ? totalSteps : currentStep + 1,
    onboardingCompletedAt: isFinal ? DateTime.now().toUtc().toIso8601String() : null,
  );

  try {
    await ref.read(profileMutationProvider.notifier).patch(patched);
    if (!context.mounted) return;
    if (isFinal) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로필 설정 완료! 🎉')),
      );
      context.go('/home');
    } else {
      context.go('/onboarding/${currentStep + 1}');
    }
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('저장 실패: $e')),
    );
  }
}

Widget _stepActionRow({
  required BuildContext context,
  required VoidCallback onNext,
  required int currentStep,
  required int totalSteps,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    child: Row(
      children: [
        if (currentStep > 1)
          Expanded(
            child: OutlinedButton(
              onPressed: () => context.go('/onboarding/${currentStep - 1}'),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Text('이전'),
            ),
          ),
        if (currentStep > 1) const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: onNext,
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            child: Text(currentStep >= totalSteps ? '완료' : '다음'),
          ),
        ),
      ],
    ),
  );
}

// ─── Step 1: 환영 + 닉네임 ─────────────────────────────────────────────

class _Step1Welcome extends ConsumerStatefulWidget {
  const _Step1Welcome({required this.current});
  final UserProfile current;
  @override
  ConsumerState<_Step1Welcome> createState() => _Step1WelcomeState();
}

class _Step1WelcomeState extends ConsumerState<_Step1Welcome> {
  late final TextEditingController _nicknameController =
      TextEditingController(text: widget.current.nickname ?? '');

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 16),
              Text('환영합니다!', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                '시작 전에 닉네임을 알려주세요.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: '닉네임',
                  hintText: '예: 김청약',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        _stepActionRow(
          context: context,
          currentStep: 1,
          totalSteps: 5,
          onNext: () {
            if (_nicknameController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('닉네임을 입력해주세요')),
              );
              return;
            }
            _saveAndAdvance(
              context: context,
              ref: ref,
              updates: UserProfile(nickname: _nicknameController.text.trim()),
              currentStep: 1,
              totalSteps: 5,
            );
          },
        ),
      ],
    );
  }
}

// ─── Step 2: 생년월일 + 결혼 ────────────────────────────────────────────

class _Step2Birth extends ConsumerStatefulWidget {
  const _Step2Birth({required this.current});
  final UserProfile current;
  @override
  ConsumerState<_Step2Birth> createState() => _Step2BirthState();
}

class _Step2BirthState extends ConsumerState<_Step2Birth> {
  String? _birthDate;
  bool? _isMarried;
  String? _marriageDate;

  @override
  void initState() {
    super.initState();
    _birthDate = widget.current.birthDate;
    _isMarried = widget.current.isMarried;
    _marriageDate = widget.current.marriageDate;
  }

  Future<void> _pickDate(String which) async {
    final init = (which == 'birth' ? _birthDate : _marriageDate);
    final picked = await showDatePicker(
      context: context,
      initialDate: init != null ? DateTime.tryParse(init) ?? DateTime(1990) : DateTime(1990),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() {
      final iso = picked.toIso8601String().substring(0, 10);
      if (which == 'birth') _birthDate = iso;
      else _marriageDate = iso;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 8),
              Text('출생·결혼 정보', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                '가점 계산에 필요합니다.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              _DateField(
                label: '생년월일',
                value: _birthDate,
                onTap: () => _pickDate('birth'),
              ),
              const SizedBox(height: 24),
              const Text('결혼 여부 *', style: TextStyle(fontWeight: FontWeight.w600)),
              RadioListTile<bool>(
                title: const Text('미혼'),
                value: false,
                groupValue: _isMarried,
                onChanged: (v) => setState(() => _isMarried = v),
              ),
              RadioListTile<bool>(
                title: const Text('기혼'),
                value: true,
                groupValue: _isMarried,
                onChanged: (v) => setState(() => _isMarried = v),
              ),
              if (_isMarried == true) ...[
                const SizedBox(height: 16),
                _DateField(
                  label: '혼인신고일',
                  value: _marriageDate,
                  onTap: () => _pickDate('marriage'),
                ),
              ],
            ],
          ),
        ),
        _stepActionRow(
          context: context,
          currentStep: 2,
          totalSteps: 5,
          onNext: () {
            if (_birthDate == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('생년월일을 입력해주세요')),
              );
              return;
            }
            _saveAndAdvance(
              context: context,
              ref: ref,
              updates: UserProfile(
                birthDate: _birthDate,
                isMarried: _isMarried,
                marriageDate: _isMarried == true ? _marriageDate : null,
              ),
              currentStep: 2,
              totalSteps: 5,
            );
          },
        ),
      ],
    );
  }
}

// ─── Step 3: 무주택 + 거주지 ─────────────────────────────────────────

class _Step3Housing extends ConsumerStatefulWidget {
  const _Step3Housing({required this.current});
  final UserProfile current;
  @override
  ConsumerState<_Step3Housing> createState() => _Step3HousingState();
}

class _Step3HousingState extends ConsumerState<_Step3Housing> {
  bool? _isHomeless;
  String? _homelessSince;
  String? _residentRegion;

  static const _regions = [
    '서울', '경기', '인천', '부산', '대구', '광주', '대전', '울산', '세종',
    '강원', '충북', '충남', '전북', '전남', '경북', '경남', '제주',
  ];

  @override
  void initState() {
    super.initState();
    _isHomeless = widget.current.isHomeless;
    _homelessSince = widget.current.homelessSince;
    _residentRegion = widget.current.residentRegion;
  }

  Future<void> _pickHomelessSince() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _homelessSince != null
          ? DateTime.tryParse(_homelessSince!) ?? DateTime(2015)
          : DateTime(2015),
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() => _homelessSince = picked.toIso8601String().substring(0, 10));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('주거 현황', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              const Text('무주택 여부 *', style: TextStyle(fontWeight: FontWeight.w600)),
              RadioListTile<bool>(
                title: const Text('무주택'),
                value: true,
                groupValue: _isHomeless,
                onChanged: (v) => setState(() => _isHomeless = v),
              ),
              RadioListTile<bool>(
                title: const Text('유주택'),
                value: false,
                groupValue: _isHomeless,
                onChanged: (v) => setState(() => _isHomeless = v),
              ),
              if (_isHomeless == true) ...[
                const SizedBox(height: 16),
                _DateField(
                  label: '무주택 시작일',
                  value: _homelessSince,
                  onTap: _pickHomelessSince,
                ),
              ],
              const SizedBox(height: 24),
              const Text('거주 광역시·도 *', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _regions
                    .map((r) => ChoiceChip(
                          label: Text(r),
                          selected: _residentRegion == r,
                          onSelected: (_) => setState(() => _residentRegion = r),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
        _stepActionRow(
          context: context,
          currentStep: 3,
          totalSteps: 5,
          onNext: () {
            if (_isHomeless == null || _residentRegion == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('필수 항목을 모두 입력해주세요')),
              );
              return;
            }
            _saveAndAdvance(
              context: context,
              ref: ref,
              updates: UserProfile(
                isHomeless: _isHomeless,
                hasHouse: !(_isHomeless ?? true),
                homelessSince: _isHomeless == true ? _homelessSince : null,
                residentRegion: _residentRegion,
              ),
              currentStep: 3,
              totalSteps: 5,
            );
          },
        ),
      ],
    );
  }
}

// ─── Step 4: 청약통장 + 부양가족 (Stitch 디자인 매핑) ───────────────────

class _Step4Account extends ConsumerStatefulWidget {
  const _Step4Account({required this.current});
  final UserProfile current;
  @override
  ConsumerState<_Step4Account> createState() => _Step4AccountState();
}

class _Step4AccountState extends ConsumerState<_Step4Account> {
  String? _savingsStart;
  late final TextEditingController _balanceWanController;
  late final TextEditingController _contributionsController;
  int _dependentsCount = 0;

  @override
  void initState() {
    super.initState();
    _savingsStart = widget.current.savingsStart;
    _balanceWanController = TextEditingController(
      text: widget.current.savingsBalanceWan?.toString() ?? '',
    );
    _contributionsController = TextEditingController(
      text: widget.current.subscriptionContributions?.toString() ?? '',
    );
    _dependentsCount = widget.current.dependentsCount ?? 0;
  }

  @override
  void dispose() {
    _balanceWanController.dispose();
    _contributionsController.dispose();
    super.dispose();
  }

  Future<void> _pickStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _savingsStart != null
          ? DateTime.tryParse(_savingsStart!) ?? DateTime(2020)
          : DateTime(2020),
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() => _savingsStart = picked.toIso8601String().substring(0, 10));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                '청약 기본 조건을 알려주세요',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text('정확한 분석을 위해 현재 상태를 입력해주세요.'),
              const SizedBox(height: 24),

              // 청약통장 가입일
              const Row(children: [
                Icon(Icons.account_balance_wallet, size: 18),
                SizedBox(width: 8),
                Text('청약통장 가입일 *', style: TextStyle(fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 8),
              _DateField(label: '가입일', value: _savingsStart, onTap: _pickStart),

              const SizedBox(height: 16),
              TextField(
                controller: _contributionsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '납입 회차 (회)',
                  hintText: '예: 24',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _balanceWanController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '예치금 (만원)',
                  hintText: '예: 300',
                  border: OutlineInputBorder(),
                  suffixText: '만원',
                ),
              ),
              const SizedBox(height: 24),

              // 부양가족
              const Row(children: [
                Icon(Icons.group, size: 18),
                SizedBox(width: 8),
                Text('부양가족 수 *', style: TextStyle(fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 4),
              const Text(
                '본인을 제외한 부양가족 수를 입력해주세요.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton.outlined(
                    icon: const Icon(Icons.remove),
                    onPressed: _dependentsCount > 0
                        ? () => setState(() => _dependentsCount--)
                        : null,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '$_dependentsCount명',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  ),
                  IconButton.outlined(
                    icon: const Icon(Icons.add),
                    onPressed: _dependentsCount < 20
                        ? () => setState(() => _dependentsCount++)
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
        _stepActionRow(
          context: context,
          currentStep: 4,
          totalSteps: 5,
          onNext: () {
            if (_savingsStart == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('청약통장 가입일을 입력해주세요')),
              );
              return;
            }
            _saveAndAdvance(
              context: context,
              ref: ref,
              updates: UserProfile(
                savingsStart: _savingsStart,
                savingsBalanceWan: int.tryParse(_balanceWanController.text.trim()),
                subscriptionContributions: int.tryParse(_contributionsController.text.trim()),
                dependentsCount: _dependentsCount,
              ),
              currentStep: 4,
              totalSteps: 5,
            );
          },
        ),
      ],
    );
  }
}

// ─── Step 5: 선호 (특공·지역·평형·소득) ─────────────────────────────────

class _Step5Preferences extends ConsumerStatefulWidget {
  const _Step5Preferences({required this.current});
  final UserProfile current;
  @override
  ConsumerState<_Step5Preferences> createState() => _Step5PreferencesState();
}

class _Step5PreferencesState extends ConsumerState<_Step5Preferences> {
  static const _allInterests = ['신혼부부', '생애최초', '다자녀', '노부모부양'];
  static const _regions = [
    '서울', '경기', '인천', '부산', '대구', '광주', '대전', '울산', '세종',
    '강원', '충북', '충남', '전북', '전남', '경북', '경남', '제주',
  ];
  static const _householdTypes = ['미혼(1인)', '신혼부부', '다자녀', '노부모부양'];
  static const _incomeBrackets = [
    '도시근로자 100% 이하',
    '도시근로자 120% 이하',
    '도시근로자 140% 이하',
    '도시근로자 160% 이하',
  ];

  late Set<String> _interests;
  late Set<String> _preferredRegions;
  late int _preferredSizeSqm;
  String? _householdType;
  String? _incomeBracket;

  @override
  void initState() {
    super.initState();
    _interests = {...?widget.current.specialSupplyInterests};
    _preferredRegions = {...?widget.current.preferredRegions};
    _preferredSizeSqm = widget.current.preferredSizeSqm ?? 84;
    _householdType = widget.current.householdType;
    _incomeBracket = widget.current.incomeBracket;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('선호 조건', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 24),

              const Text('가구 유형', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _householdTypes.map((t) => ChoiceChip(
                  label: Text(t),
                  selected: _householdType == t,
                  onSelected: (_) => setState(() => _householdType = t),
                )).toList(),
              ),

              const SizedBox(height: 24),
              const Text('소득 구간', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ..._incomeBrackets.map((b) => RadioListTile<String>(
                title: Text(b),
                value: b,
                groupValue: _incomeBracket,
                onChanged: (v) => setState(() => _incomeBracket = v),
                dense: true,
              )),

              const SizedBox(height: 16),
              const Text('관심 특별공급 (복수)', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allInterests.map((i) => FilterChip(
                  label: Text(i),
                  selected: _interests.contains(i),
                  onSelected: (sel) => setState(() {
                    sel ? _interests.add(i) : _interests.remove(i);
                  }),
                )).toList(),
              ),

              const SizedBox(height: 24),
              const Text('선호 지역 (복수)', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _regions.map((r) => FilterChip(
                  label: Text(r),
                  selected: _preferredRegions.contains(r),
                  onSelected: (sel) => setState(() {
                    sel ? _preferredRegions.add(r) : _preferredRegions.remove(r);
                  }),
                )).toList(),
              ),

              const SizedBox(height: 24),
              Text('선호 평형: ${_preferredSizeSqm}㎡', style: const TextStyle(fontWeight: FontWeight.w600)),
              Slider(
                value: _preferredSizeSqm.toDouble(),
                min: 30,
                max: 200,
                divisions: 17,
                label: '${_preferredSizeSqm}㎡',
                onChanged: (v) => setState(() => _preferredSizeSqm = v.round()),
              ),
            ],
          ),
        ),
        _stepActionRow(
          context: context,
          currentStep: 5,
          totalSteps: 5,
          onNext: () {
            _saveAndAdvance(
              context: context,
              ref: ref,
              updates: UserProfile(
                householdType: _householdType,
                incomeBracket: _incomeBracket,
                specialSupplyInterests: _interests.toList(),
                preferredRegions: _preferredRegions.toList(),
                preferredSizeSqm: _preferredSizeSqm,
              ),
              currentStep: 5,
              totalSteps: 5,
            );
          },
        ),
      ],
    );
  }
}

// ─── 공통 위젯 ──────────────────────────────────────────────────────

class _DateField extends StatelessWidget {
  const _DateField({required this.label, required this.value, required this.onTap});
  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(value ?? '날짜 선택'),
      ),
    );
  }
}
