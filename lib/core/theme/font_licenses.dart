import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'app_tokens.dart';

/// Registers the SIL OFL 1.1 license of each bundled font family, which must
/// accompany every distributed copy of the font. The texts are read lazily,
/// only when something (the licenses page) asks for them.
abstract final class FontLicenses {
  static const _families = [AppTypography.heading, AppTypography.body];

  static void register() {
    LicenseRegistry.addLicense(() async* {
      for (final family in _families) {
        yield LicenseEntryWithLineBreaks([
          family,
        ], await rootBundle.loadString('assets/fonts/$family-OFL.txt'));
      }
    });
  }
}
