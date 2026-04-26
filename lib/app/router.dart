import 'package:go_router/go_router.dart';

import '../features/analysis/presentation/ai_report_page.dart';
import '../features/announcements/presentation/announcement_detail_page.dart';
import '../features/announcements/presentation/announcements_page.dart';
import '../features/home/presentation/home_dashboard_page.dart';
import '../features/my_cheongyak/presentation/score_tracker_page.dart';
import '../features/notifications/presentation/notifications_page.dart';
import '../features/preparation/presentation/preparation_page.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/home',
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
        path: '/announcements/:id',
        builder: (context, state) =>
            AnnouncementDetailPage(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
    ],
  );
}
