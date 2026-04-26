import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';

class MainScaffold extends StatelessWidget {
  const MainScaffold({
    super.key,
    this.appBar,
    required this.body,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;

  static const _tabs = <_NavTabSpec>[
    _NavTabSpec(
      route: '/home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: '홈',
    ),
    _NavTabSpec(
      route: '/announcements',
      icon: Icons.list_alt_outlined,
      activeIcon: Icons.list_alt,
      label: '공고',
    ),
    _NavTabSpec(
      route: '/analysis',
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics,
      label: '분석',
    ),
    _NavTabSpec(
      route: '/preparation',
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment,
      label: '준비',
    ),
    _NavTabSpec(
      route: '/mypage',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: '내 청약',
    ),
  ];

  int _activeIndex(BuildContext context) {
    final location =
        GoRouter.of(context).routeInformationProvider.value.uri.path;
    for (var i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].route)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final activeIndex = _activeIndex(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: appBar,
      body: body,
      bottomNavigationBar: _BottomNav(
        tabs: _tabs,
        activeIndex: activeIndex,
        onTap: (i) {
          if (i == activeIndex) return;
          context.go(_tabs[i].route);
        },
      ),
    );
  }
}

class _NavTabSpec {
  const _NavTabSpec({
    required this.route,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
  final String route;
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.tabs,
    required this.activeIndex,
    required this.onTap,
  });

  final List<_NavTabSpec> tabs;
  final int activeIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final pad = constraints.maxWidth > 480
                  ? (constraints.maxWidth - 480) / 2
                  : 16.0;
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: pad, vertical: 8),
                child: Row(
                  children: [
                    for (var i = 0; i < tabs.length; i++)
                      Expanded(
                        child: _NavItem(
                          spec: tabs[i],
                          selected: i == activeIndex,
                          onTap: () => onTap(i),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.spec,
    required this.selected,
    required this.onTap,
  });

  final _NavTabSpec spec;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : const Color(0xFF9CA3AF);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? spec.activeIcon : spec.icon,
              color: color,
              size: 22,
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                spec.label,
                maxLines: 1,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
