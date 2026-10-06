/// Settings passed at build time with
/// `--dart-define-from-file=config/app.json`. Only public values belong here:
/// the publishable key is meant to ship inside the app.
abstract final class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );
  static const certificateReaderUrl = String.fromEnvironment(
    'CERTIFICATE_READER_URL',
  );

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;
}
