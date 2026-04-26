import 'package:go_router/go_router.dart';

import '../core/auth/auth_repository.dart';
import '../core/config/supabase_config.dart';
import '../features/analysis/presentation/ai_report_page.dart';
import '../features/announcements/presentation/announcement_detail_page.dart';
import '../features/announcements/presentation/announcements_page.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/home/presentation/home_dashboard_page.dart';
import '../features/my_cheongyak/presentation/score_tracker_page.dart';
import '../features/notifications/presentation/notifications_page.dart';
import '../features/preparation/presentation/preparation_page.dart';

/// 인증 필요한 라우트 (Supabase 미설정 또는 미로그인 시 /login 으로 redirect).
/// 무인증 라우트는 그대로 통과 (announcements, /home, /login, /auth/callback 등).
const _authRequiredRoutes = <String>{
  '/preparation',
  '/notifications',
  // 신규 인증 화면 (mypage, documents, favorites, onboarding 등) 추가 시 등록
};

GoRouter buildRouter() {
  final authRepo = AuthRepository();

  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      // Supabase 미설정 시 redirect 비활성 (개발/무인증 모드)
      if (!SupabaseConfig.isConfigured) return null;

      final loggedIn = authRepo.currentUser() != null;
      final goingTo = state.matchedLocation;
      final goingToLogin = goingTo == '/login';
      final goingToCallback = goingTo.startsWith('/auth/callback');
      final needsAuth = _authRequiredRoutes.contains(goingTo);

      // 미로그인 + 인증 필요 → /login (next로 원래 경로 보존)
      if (!loggedIn && needsAuth && !goingToLogin && !goingToCallback) {
        return '/login?next=$goingTo';
      }

      // 이미 로그인 + /login 진입 → next 또는 /home
      if (loggedIn && goingToLogin) {
        final next = state.uri.queryParameters['next'];
        return next != null && next.isNotEmpty ? next : '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (_, _) => '/home',
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeDashboardPage(),
      ),
      GoRoute(
        path: '/announcements',
        builder: (context, state) => const AnnouncementsPage(),
      ),
      GoRoute(
        path: '/announcements/:id',
        builder: (context, state) =>
            AnnouncementDetailPage(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/analysis',
        builder: (context, state) => const AiReportPage(),
      ),
      GoRoute(
        path: '/preparation',
        builder: (context, state) => const PreparationPage(),
      ),
      GoRoute(
        path: '/my',
        builder: (context, state) => const ScoreTrackerPage(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      // 매직링크 콜백 — supabase_flutter SDK가 PKCE로 자동 처리.
      // 별도 안내 페이지 불필요 시 /home redirect.
      GoRoute(
        path: '/auth/callback',
        redirect: (_, _) => '/home',
      ),
    ],
  );
}
