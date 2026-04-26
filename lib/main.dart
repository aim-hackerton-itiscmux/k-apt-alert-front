import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app/router.dart';
import 'core/theme/app_theme.dart';

void main() {
  usePathUrlStrategy();
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
