import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigKeys {
  RemoteConfigKeys._();

  static const androidShareUrl = 'android_share_url';
  static const iosShareUrl = 'ios_share_url';
  static const webShareUrl = 'web_share_url';
  static const contactUrl = 'contact_url';
  static const privacyPolicyUrl = 'privacy_policy_url';
  static const termsUrl = 'terms_url';
}

class RemoteConfigService {
  RemoteConfigService._();

  static FirebaseRemoteConfig get _rc => FirebaseRemoteConfig.instance;

  static const Map<String, dynamic> defaults = {
    RemoteConfigKeys.androidShareUrl: '',
    RemoteConfigKeys.iosShareUrl: '',
    RemoteConfigKeys.webShareUrl: '',
    RemoteConfigKeys.contactUrl: '',
    RemoteConfigKeys.privacyPolicyUrl: '',
    RemoteConfigKeys.termsUrl: '',
  };

  static Future<void> configureAndFetch() async {
    await _rc.setDefaults(defaults);
    await _rc.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: kReleaseMode
            ? const Duration(hours: 1)
            : const Duration(milliseconds: 10),
      ),
    );
    await _rc.fetchAndActivate();
  }

  /// Without a Firebase app (init failed, or tests) there is no remote value:
  /// fall back to the defaults instead of throwing inside the UI.
  static String get(String key) {
    try {
      return _rc.getString(key).trim();
    } catch (_) {
      return (defaults[key] as String?) ?? '';
    }
  }

  static bool getBool(String key) => _rc.getBool(key);
  static int getInt(String key) => _rc.getInt(key);
  static double getDouble(String key) => _rc.getDouble(key);
}
