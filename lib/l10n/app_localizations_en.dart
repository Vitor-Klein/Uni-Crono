// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get webViewDeviceDisclaimer =>
      'The display may vary depending on your device.';

  @override
  String get webViewDismiss => 'Dismiss';

  @override
  String get webViewErrorTitle => 'Could not load page';

  @override
  String get webViewErrorMessage => 'Check your connection and try again.';

  @override
  String get webViewRetry => 'Retry';

  @override
  String get notificationsEnabledMessage => 'Notifications enabled.';

  @override
  String get notificationsDisabledMessage => 'Notifications disabled.';

  @override
  String get notificationsUpdateError =>
      'Could not update notification settings.';

  @override
  String get homeMoreButton => 'MORE';

  @override
  String get notificationsSheetTitle => 'NOTIFICATIONS';

  @override
  String get pushNotificationsLabel => 'PUSH NOTIFICATIONS';

  @override
  String get enabledLabel => 'Enabled';

  @override
  String get disabledLabel => 'Disabled';

  @override
  String get notificationChannelName => 'General';

  @override
  String get notificationChannelDescription => 'General notifications';

  @override
  String get notificationOpenLinkAction => 'Open link';

  @override
  String get notificationFallbackTitle => 'Notification';

  @override
  String get messagesTitle => 'Messages';

  @override
  String get messagesClearAllTooltip => 'Clear all';

  @override
  String get messagesCloseTooltip => 'Close';

  @override
  String get messageNoTitle => '(No title)';

  @override
  String get messagesDeleteTooltip => 'Delete';

  @override
  String get messagesEmptyTitle => 'No messages yet';

  @override
  String get messagesEmptyMessage => 'Push notifications will appear here.';

  @override
  String get messagesFilterAll => 'All';

  @override
  String get messagesFilterUnread => 'Unread';

  @override
  String get messagesMarkAllReadTooltip => 'Mark all as read';

  @override
  String get messagesGroupToday => 'Today';

  @override
  String get messagesGroupYesterday => 'Yesterday';

  @override
  String get messagesEmptyUnreadTitle => 'No unread messages';

  @override
  String get messagesEmptyUnreadMessage => 'You\'re all caught up.';

  @override
  String get upgradeRequiredTitle => 'Update Required';

  @override
  String get upgradeRequiredBody =>
      'A new version is required to keep using the app.';

  @override
  String get upgradeNowButton => 'Update Now';

  @override
  String get moreMessagesTitle => 'MESSAGES';

  @override
  String get moreMessagesSubtitle => 'Latest updates and news';

  @override
  String get moreSettingsTitle => 'SETTINGS';

  @override
  String get moreSettingsSubtitle => 'App settings and preferences';

  @override
  String get moreShareTitle => 'SHARE APP';

  @override
  String get moreShareSubtitle => 'Invite friends to the app';

  @override
  String get morePrivacyTitle => 'PRIVACY POLICY';

  @override
  String get morePrivacySubtitle => 'Read our privacy policy';

  @override
  String get moreTermsTitle => 'TERMS OF USE';

  @override
  String get moreTermsSubtitle => 'Read our terms of use';

  @override
  String get legalPrivacyPageTitle => 'Privacy Policy';

  @override
  String get legalTermsPageTitle => 'Terms of Use';

  @override
  String get settingsTitle => 'SETTINGS';

  @override
  String get settingsAccessibilityTitle => 'ACCESSIBILITY';

  @override
  String get settingsAccessibilitySubtitle => 'Appearance and display settings';

  @override
  String get settingsLanguageTitle => 'LANGUAGE';

  @override
  String get settingsLanguageSemantics => 'Select the app language';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navUpload => 'Upload';

  @override
  String get navActivities => 'Activities';

  @override
  String get navProfile => 'Profile';

  @override
  String get shellMenuSemantics => 'Open menu';

  @override
  String get loginSubtitle => 'Access your academic resources.';

  @override
  String get loginInstitutionLabel => 'Institution';

  @override
  String get loginInstitutionHint => 'Select your university…';

  @override
  String get loginEmailLabel => 'Academic e-mail';

  @override
  String get loginEmailHint => 'student@university.edu';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginForgotPassword => 'Forgot?';

  @override
  String get loginShowPassword => 'Show password';

  @override
  String get loginHidePassword => 'Hide password';

  @override
  String get loginSubmit => 'Sign in';

  @override
  String get loginNewHere => 'New here?';

  @override
  String get loginInstitutionRequired => 'Choose your institution';

  @override
  String get loginEmailRequired => 'Enter your academic e-mail';

  @override
  String get loginEmailInvalid => 'Invalid e-mail';

  @override
  String get loginPasswordRequired => 'Enter your password';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get dashboardTitle => 'Academic progress';

  @override
  String get hoursComplementaryTitle => 'Complementary Hours';

  @override
  String get hoursComplementarySubtitle => 'Extracurricular activities';

  @override
  String get hoursExtensionTitle => 'Extension Hours';

  @override
  String get hoursExtensionSubtitle => 'Community engagement';

  @override
  String hoursAccumulated(int hours) {
    return '$hours hours';
  }

  @override
  String hoursGoalTotal(int goal) {
    return '$goal total';
  }

  @override
  String get dashboardRecentTitle => 'Recently approved';

  @override
  String get dashboardSeeAll => 'See all';

  @override
  String certificateHours(int hours) {
    return '+$hours h';
  }

  @override
  String get certificateApproved => 'Approved';

  @override
  String get settingsThemeLabel => 'Theme';

  @override
  String hoursProgressSemantics(int hours, int goal) {
    return '$hours of $goal hours';
  }

  @override
  String get settingsThemeSemantics => 'Select theme mode';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get settingsTextSizeLabel => 'Text size';

  @override
  String get settingsTextSizeSemantics => 'Select text size';

  @override
  String get textScaleDevice => 'Device setting';

  @override
  String get textScaleSmall => 'Small';

  @override
  String get textScaleMedium => 'Medium';

  @override
  String get textScaleLarge => 'Large';

  @override
  String get settingsEffectsLabel => 'Effects';

  @override
  String get settingsEffectsSemantics => 'Select animation preference';

  @override
  String get animationPreferenceSystem => 'System';

  @override
  String get animationPreferenceNormal => 'Normal';

  @override
  String get animationPreferenceReduced => 'Reduced';

  @override
  String get authInvalidCredentials => 'Wrong e-mail or password';

  @override
  String get authNetworkFailure => 'No connection. Try again.';

  @override
  String get authWrongInstitution =>
      'This account belongs to another institution';

  @override
  String get authEmailAlreadyRegistered => 'This e-mail already has an account';

  @override
  String get authConfirmationRequired =>
      'Account created. Confirm your e-mail to sign in.';

  @override
  String get loginCreateAccount => 'Create account';

  @override
  String get signupTitle => 'Create account';

  @override
  String get signupSubtitle => 'Start tracking your hours.';

  @override
  String get signupNameLabel => 'Full name';

  @override
  String get signupNameRequired => 'Enter your name';

  @override
  String get signupCourseLabel => 'Program';

  @override
  String get signupCourseHint => 'E.g.: Software Engineering';

  @override
  String get signupCourseRequired => 'Enter your program';

  @override
  String get signupTermLabel => 'Term';

  @override
  String get signupTermHint => '1 to 12';

  @override
  String get signupTermInvalid => 'Enter a term from 1 to 12';

  @override
  String get signupPasswordTooShort => 'Use 8 characters or more';

  @override
  String get signupSubmit => 'Create account';

  @override
  String get signupHaveAccount => 'Already have an account?';

  @override
  String get signupSignIn => 'Sign in';
}
