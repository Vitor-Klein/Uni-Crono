import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uni_cronos/app/app.dart';
import 'package:uni_cronos/app/app_providers.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('renders the app shell', (WidgetTester tester) async {
    await tester.pumpWidget(
      const AppProviders(
        child: MyApp(
          enforceUpgradeGate: false,
          debugHome: Scaffold(body: Center(child: Text('Template smoke test'))),
        ),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Template smoke test'), findsOneWidget);
    expect(find.text('0'), findsNothing);
  });
}
