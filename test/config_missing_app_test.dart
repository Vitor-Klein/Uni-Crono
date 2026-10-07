import 'package:flutter_test/flutter_test.dart';

import 'package:uni_cronos/app/config_missing_app.dart';

void main() {
  testWidgets('without the server settings the app says how to run it, '
      'instead of a black screen', (tester) async {
    await tester.pumpWidget(const ConfigMissingApp());
    await tester.pumpAndSettle();

    expect(
      find.textContaining('--dart-define-from-file=config/app.json'),
      findsOneWidget,
    );
  });
}
