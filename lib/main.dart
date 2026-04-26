import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/router.dart';
import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  // Supabase 초기화 — anon key 설정된 경우만. 미설정 시 Auth 비활성.
  // 빌드 시 --dart-define=SUPABASE_ANON_KEY=... 로 주입.
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  runApp(const ProviderScope(child: KAptAlertApp()));
}

class KAptAlertApp extends StatefulWidget {
  const KAptAlertApp({super.key});

  @override
  State<KAptAlertApp> createState() => _KAptAlertAppState();
}

class _KAptAlertAppState extends State<KAptAlertApp> {
  late final _router = buildRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '청약 코파일럿',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko', 'KR'), Locale('en', 'US')],
      locale: const Locale('ko', 'KR'),
      routerConfig: _router,
    );
  }
}
