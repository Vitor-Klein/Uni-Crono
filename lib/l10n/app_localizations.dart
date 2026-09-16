import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  /// No description provided for @webViewDeviceDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'The display may vary depending on your device.'**
  String get webViewDeviceDisclaimer;

  /// No description provided for @webViewDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get webViewDismiss;

  /// No description provided for @webViewErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load page'**
  String get webViewErrorTitle;

  /// No description provided for @webViewErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get webViewErrorMessage;

  /// No description provided for @webViewRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get webViewRetry;

  /// No description provided for @notificationsEnabledMessage.
  ///
  /// In en, this message translates to:
  /// **'Notifications enabled.'**
  String get notificationsEnabledMessage;

  /// No description provided for @notificationsDisabledMessage.
  ///
  /// In en, this message translates to:
  /// **'Notifications disabled.'**
  String get notificationsDisabledMessage;

  /// No description provided for @notificationsUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Could not update notification settings.'**
  String get notificationsUpdateError;

  /// No description provided for @homeMoreButton.
  ///
  /// In en, this message translates to:
  /// **'MORE'**
  String get homeMoreButton;

  /// No description provided for @notificationsSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'NOTIFICATIONS'**
  String get notificationsSheetTitle;

  /// No description provided for @pushNotificationsLabel.
  ///
  /// In en, this message translates to:
  /// **'PUSH NOTIFICATIONS'**
  String get pushNotificationsLabel;

  /// No description provided for @enabledLabel.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabledLabel;

  /// No description provided for @disabledLabel.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabledLabel;

  /// No description provided for @notificationChannelName.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get notificationChannelName;

  /// No description provided for @notificationChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'General notifications'**
  String get notificationChannelDescription;

  /// No description provided for @notificationOpenLinkAction.
  ///
  /// In en, this message translates to:
  /// **'Open link'**
  String get notificationOpenLinkAction;

  /// No description provided for @notificationFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notificationFallbackTitle;

  /// No description provided for @messagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messagesTitle;

  /// No description provided for @messagesClearAllTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get messagesClearAllTooltip;

  /// No description provided for @messagesCloseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get messagesCloseTooltip;

  /// No description provided for @messageNoTitle.
  ///
  /// In en, this message translates to:
  /// **'(No title)'**
  String get messageNoTitle;

  /// No description provided for @messagesDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get messagesDeleteTooltip;

  /// No description provided for @messagesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get messagesEmptyTitle;

  /// No description provided for @messagesEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Push notifications will appear here.'**
  String get messagesEmptyMessage;

  /// No description provided for @messagesFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get messagesFilterAll;

  /// No description provided for @messagesFilterUnread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get messagesFilterUnread;

  /// No description provided for @messagesMarkAllReadTooltip.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get messagesMarkAllReadTooltip;

  /// No description provided for @messagesGroupToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get messagesGroupToday;

  /// No description provided for @messagesGroupYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get messagesGroupYesterday;

  /// No description provided for @messagesEmptyUnreadTitle.
  ///
  /// In en, this message translates to:
  /// **'No unread messages'**
  String get messagesEmptyUnreadTitle;

  /// No description provided for @messagesEmptyUnreadMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up.'**
  String get messagesEmptyUnreadMessage;

  /// No description provided for @upgradeRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Required'**
  String get upgradeRequiredTitle;

  /// No description provided for @upgradeRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'A new version is required to keep using the app.'**
  String get upgradeRequiredBody;

  /// No description provided for @upgradeNowButton.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get upgradeNowButton;

  /// No description provided for @moreMessagesTitle.
  ///
  /// In en, this message translates to:
  /// **'MESSAGES'**
  String get moreMessagesTitle;

  /// No description provided for @moreMessagesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Latest updates and news'**
  String get moreMessagesSubtitle;

  /// No description provided for @moreSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get moreSettingsTitle;

  /// No description provided for @moreSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'App settings and preferences'**
  String get moreSettingsSubtitle;

  /// No description provided for @moreShareTitle.
  ///
  /// In en, this message translates to:
  /// **'SHARE APP'**
  String get moreShareTitle;

  /// No description provided for @moreShareSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Invite friends to the app'**
  String get moreShareSubtitle;

  /// No description provided for @morePrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'PRIVACY POLICY'**
  String get morePrivacyTitle;

  /// No description provided for @morePrivacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read our privacy policy'**
  String get morePrivacySubtitle;

  /// No description provided for @moreTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'TERMS OF USE'**
  String get moreTermsTitle;

  /// No description provided for @moreTermsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read our terms of use'**
  String get moreTermsSubtitle;

  /// No description provided for @legalPrivacyPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get legalPrivacyPageTitle;

  /// No description provided for @legalTermsPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get legalTermsPageTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get settingsTitle;

  /// No description provided for @settingsAccessibilityTitle.
  ///
  /// In en, this message translates to:
  /// **'ACCESSIBILITY'**
  String get settingsAccessibilityTitle;

  /// No description provided for @settingsAccessibilitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance and display settings'**
  String get settingsAccessibilitySubtitle;

  /// No description provided for @settingsThemeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsThemeLabel;

  /// No description provided for @settingsThemeSemantics.
  ///
  /// In en, this message translates to:
  /// **'Select theme mode'**
  String get settingsThemeSemantics;

  /// No description provided for @themeModeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeModeSystem;

  /// No description provided for @themeModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeModeLight;

  /// No description provided for @themeModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeModeDark;

  /// No description provided for @settingsTextSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get settingsTextSizeLabel;

  /// No description provided for @settingsTextSizeSemantics.
  ///
  /// In en, this message translates to:
  /// **'Select text size'**
  String get settingsTextSizeSemantics;

  /// No description provided for @textScaleDevice.
  ///
  /// In en, this message translates to:
  /// **'Device setting'**
  String get textScaleDevice;

  /// No description provided for @textScaleSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get textScaleSmall;

  /// No description provided for @textScaleMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get textScaleMedium;

  /// No description provided for @textScaleLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get textScaleLarge;

  /// No description provided for @settingsEffectsLabel.
  ///
  /// In en, this message translates to:
  /// **'Effects'**
  String get settingsEffectsLabel;

  /// No description provided for @settingsEffectsSemantics.
  ///
  /// In en, this message translates to:
  /// **'Select animation preference'**
  String get settingsEffectsSemantics;

  /// No description provided for @animationPreferenceSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get animationPreferenceSystem;

  /// No description provided for @animationPreferenceNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get animationPreferenceNormal;

  /// No description provided for @animationPreferenceReduced.
  ///
  /// In en, this message translates to:
  /// **'Reduced'**
  String get animationPreferenceReduced;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
