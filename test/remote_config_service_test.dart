import 'package:flutter_test/flutter_test.dart';

import 'package:uni_cronos/core/config/remote_config_service.dart';

void main() {
  test('defines remote config defaults for app links and legal pages', () {
    expect(
      RemoteConfigService.defaults[RemoteConfigKeys.androidShareUrl],
      isEmpty,
    );
    expect(RemoteConfigService.defaults[RemoteConfigKeys.iosShareUrl], isEmpty);
    expect(
      RemoteConfigService.defaults[RemoteConfigKeys.privacyPolicyUrl],
      isEmpty,
    );
    expect(RemoteConfigService.defaults[RemoteConfigKeys.termsUrl], isEmpty);
  });

  test('CA-04: without Firebase, get falls back to the defaults', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    expect(RemoteConfigService.get(RemoteConfigKeys.termsUrl), isEmpty);
    expect(RemoteConfigService.get(RemoteConfigKeys.privacyPolicyUrl), isEmpty);
  });
}
