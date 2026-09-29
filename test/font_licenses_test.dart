import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uni_cronos/app/app_bootstrap.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(LicenseRegistry.reset);

  test(
    'CA-01: app startup registers the OFL license of Montserrat and Inter',
    () async {
      await AppBootstrap.initialize();

      final licenses = await LicenseRegistry.licenses.toList();
      for (final family in ['Montserrat', 'Inter']) {
        final entry = licenses.where((l) => l.packages.contains(family));
        expect(entry, hasLength(1), reason: '$family license entry');
        final text = entry.single.paragraphs.map((p) => p.text).join('\n');
        expect(text, contains('SIL Open Font License'), reason: family);
      }
    },
  );
}
