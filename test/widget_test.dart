import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:k_apt_alert_front/main.dart';

void main() {
  testWidgets('App boots', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: KAptAlertApp()));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(KAptAlertApp), findsOneWidget);
    expect(find.text('청약 코파일럿'), findsWidgets);
  });
}
