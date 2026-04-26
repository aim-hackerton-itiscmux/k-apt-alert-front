import 'package:flutter/material.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    this.title = '청약 코파일럿',
    this.showBack = false,
    this.onBack,
    this.notificationBadge,
    this.onNotificationTap,
    this.trailing,
  });

  final String title;
  final bool showBack;
  final VoidCallback? onBack;
  final int? notificationBadge;
  final VoidCallback? onNotificationTap;
  final Widget? trailing;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              tooltip: '뒤로',
            )
          : null,
      title: Text(title),
      actions: [
        ?trailing,
        if (onNotificationTap != null)
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                tooltip: '알림',
                onPressed: onNotificationTap,
              ),
              if (notificationBadge != null && notificationBadge! > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 16,
                    height: 16,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFFBA1A1A),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      notificationBadge! > 9 ? '9+' : '$notificationBadge',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        const SizedBox(width: 4),
      ],
    );
  }
}
