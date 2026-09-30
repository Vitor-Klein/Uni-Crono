import 'package:flutter_test/flutter_test.dart';

import 'package:uni_cronos/core/navigation/app_routes.dart';

import 'app_harness.dart';

void main() {
  testWidgets('CA-01: after the splash the app opens on the dashboard tab, '
      'with the four destinations in pt', (tester) async {
    await pumpRoutedApp(tester);

    expect(currentPath(), AppRoutes.dashboard);
    for (final label in ['Dashboard', 'Enviar', 'Atividades', 'Perfil']) {
      expect(navLabel(label), findsOneWidget, reason: label);
    }
  });
}
