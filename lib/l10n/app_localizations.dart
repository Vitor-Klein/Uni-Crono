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
    Locale('pt'),
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @webViewDeviceDisclaimer.
  ///
  /// In pt, this message translates to:
  /// **'A exibição pode variar conforme o seu dispositivo.'**
  String get webViewDeviceDisclaimer;

  /// No description provided for @webViewDismiss.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get webViewDismiss;

  /// No description provided for @webViewErrorTitle.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar a página'**
  String get webViewErrorTitle;

  /// No description provided for @webViewErrorMessage.
  ///
  /// In pt, this message translates to:
  /// **'Verifique sua conexão e tente novamente.'**
  String get webViewErrorMessage;

  /// No description provided for @webViewRetry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get webViewRetry;

  /// No description provided for @notificationsEnabledMessage.
  ///
  /// In pt, this message translates to:
  /// **'Notificações ativadas.'**
  String get notificationsEnabledMessage;

  /// No description provided for @notificationsDisabledMessage.
  ///
  /// In pt, this message translates to:
  /// **'Notificações desativadas.'**
  String get notificationsDisabledMessage;

  /// No description provided for @notificationsUpdateError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível atualizar as configurações de notificação.'**
  String get notificationsUpdateError;

  /// No description provided for @homeMoreButton.
  ///
  /// In pt, this message translates to:
  /// **'MAIS'**
  String get homeMoreButton;

  /// No description provided for @notificationsSheetTitle.
  ///
  /// In pt, this message translates to:
  /// **'NOTIFICAÇÕES'**
  String get notificationsSheetTitle;

  /// No description provided for @pushNotificationsLabel.
  ///
  /// In pt, this message translates to:
  /// **'NOTIFICAÇÕES PUSH'**
  String get pushNotificationsLabel;

  /// No description provided for @enabledLabel.
  ///
  /// In pt, this message translates to:
  /// **'Ativado'**
  String get enabledLabel;

  /// No description provided for @disabledLabel.
  ///
  /// In pt, this message translates to:
  /// **'Desativado'**
  String get disabledLabel;

  /// No description provided for @notificationChannelName.
  ///
  /// In pt, this message translates to:
  /// **'Geral'**
  String get notificationChannelName;

  /// No description provided for @notificationChannelDescription.
  ///
  /// In pt, this message translates to:
  /// **'Notificações gerais'**
  String get notificationChannelDescription;

  /// No description provided for @notificationOpenLinkAction.
  ///
  /// In pt, this message translates to:
  /// **'Abrir link'**
  String get notificationOpenLinkAction;

  /// No description provided for @notificationFallbackTitle.
  ///
  /// In pt, this message translates to:
  /// **'Notificação'**
  String get notificationFallbackTitle;

  /// No description provided for @messagesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Mensagens'**
  String get messagesTitle;

  /// No description provided for @messagesClearAllTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Limpar tudo'**
  String get messagesClearAllTooltip;

  /// No description provided for @messagesCloseTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get messagesCloseTooltip;

  /// No description provided for @messageNoTitle.
  ///
  /// In pt, this message translates to:
  /// **'(Sem título)'**
  String get messageNoTitle;

  /// No description provided for @messagesDeleteTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get messagesDeleteTooltip;

  /// No description provided for @messagesEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma mensagem ainda'**
  String get messagesEmptyTitle;

  /// No description provided for @messagesEmptyMessage.
  ///
  /// In pt, this message translates to:
  /// **'As notificações push aparecerão aqui.'**
  String get messagesEmptyMessage;

  /// No description provided for @messagesFilterAll.
  ///
  /// In pt, this message translates to:
  /// **'Todas'**
  String get messagesFilterAll;

  /// No description provided for @messagesFilterUnread.
  ///
  /// In pt, this message translates to:
  /// **'Não lidas'**
  String get messagesFilterUnread;

  /// No description provided for @messagesMarkAllReadTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Marcar todas como lidas'**
  String get messagesMarkAllReadTooltip;

  /// No description provided for @messagesGroupToday.
  ///
  /// In pt, this message translates to:
  /// **'Hoje'**
  String get messagesGroupToday;

  /// No description provided for @messagesGroupYesterday.
  ///
  /// In pt, this message translates to:
  /// **'Ontem'**
  String get messagesGroupYesterday;

  /// No description provided for @messagesEmptyUnreadTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma mensagem não lida'**
  String get messagesEmptyUnreadTitle;

  /// No description provided for @messagesEmptyUnreadMessage.
  ///
  /// In pt, this message translates to:
  /// **'Você já viu tudo.'**
  String get messagesEmptyUnreadMessage;

  /// No description provided for @upgradeRequiredTitle.
  ///
  /// In pt, this message translates to:
  /// **'Atualização necessária'**
  String get upgradeRequiredTitle;

  /// No description provided for @upgradeRequiredBody.
  ///
  /// In pt, this message translates to:
  /// **'Uma nova versão é necessária para continuar usando o app.'**
  String get upgradeRequiredBody;

  /// No description provided for @upgradeNowButton.
  ///
  /// In pt, this message translates to:
  /// **'Atualizar agora'**
  String get upgradeNowButton;

  /// No description provided for @moreMessagesTitle.
  ///
  /// In pt, this message translates to:
  /// **'MENSAGENS'**
  String get moreMessagesTitle;

  /// No description provided for @moreMessagesSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Últimas novidades e notícias'**
  String get moreMessagesSubtitle;

  /// No description provided for @moreSettingsTitle.
  ///
  /// In pt, this message translates to:
  /// **'CONFIGURAÇÕES'**
  String get moreSettingsTitle;

  /// No description provided for @moreSettingsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Ajustes e preferências do app'**
  String get moreSettingsSubtitle;

  /// No description provided for @moreShareTitle.
  ///
  /// In pt, this message translates to:
  /// **'COMPARTILHAR APP'**
  String get moreShareTitle;

  /// No description provided for @moreShareSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Convide amigos para o app'**
  String get moreShareSubtitle;

  /// No description provided for @morePrivacyTitle.
  ///
  /// In pt, this message translates to:
  /// **'POLÍTICA DE PRIVACIDADE'**
  String get morePrivacyTitle;

  /// No description provided for @morePrivacySubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Leia nossa política de privacidade'**
  String get morePrivacySubtitle;

  /// No description provided for @moreTermsTitle.
  ///
  /// In pt, this message translates to:
  /// **'TERMOS DE USO'**
  String get moreTermsTitle;

  /// No description provided for @moreTermsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Leia nossos termos de uso'**
  String get moreTermsSubtitle;

  /// No description provided for @legalPrivacyPageTitle.
  ///
  /// In pt, this message translates to:
  /// **'Política de Privacidade'**
  String get legalPrivacyPageTitle;

  /// No description provided for @legalTermsPageTitle.
  ///
  /// In pt, this message translates to:
  /// **'Termos de Uso'**
  String get legalTermsPageTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In pt, this message translates to:
  /// **'CONFIGURAÇÕES'**
  String get settingsTitle;

  /// No description provided for @settingsAccessibilityTitle.
  ///
  /// In pt, this message translates to:
  /// **'ACESSIBILIDADE'**
  String get settingsAccessibilityTitle;

  /// No description provided for @settingsAccessibilitySubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Aparência e configurações de exibição'**
  String get settingsAccessibilitySubtitle;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In pt, this message translates to:
  /// **'IDIOMA'**
  String get settingsLanguageTitle;

  /// No description provided for @settingsLanguageSemantics.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar o idioma do app'**
  String get settingsLanguageSemantics;

  /// No description provided for @navDashboard.
  ///
  /// In pt, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navUpload.
  ///
  /// In pt, this message translates to:
  /// **'Enviar'**
  String get navUpload;

  /// No description provided for @navActivities.
  ///
  /// In pt, this message translates to:
  /// **'Atividades'**
  String get navActivities;

  /// No description provided for @navProfile.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get navProfile;

  /// No description provided for @settingsThemeLabel.
  ///
  /// In pt, this message translates to:
  /// **'Tema'**
  String get settingsThemeLabel;

  /// No description provided for @settingsThemeSemantics.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar o modo de tema'**
  String get settingsThemeSemantics;

  /// No description provided for @themeModeSystem.
  ///
  /// In pt, this message translates to:
  /// **'Sistema'**
  String get themeModeSystem;

  /// No description provided for @themeModeLight.
  ///
  /// In pt, this message translates to:
  /// **'Claro'**
  String get themeModeLight;

  /// No description provided for @themeModeDark.
  ///
  /// In pt, this message translates to:
  /// **'Escuro'**
  String get themeModeDark;

  /// No description provided for @settingsTextSizeLabel.
  ///
  /// In pt, this message translates to:
  /// **'Tamanho do texto'**
  String get settingsTextSizeLabel;

  /// No description provided for @settingsTextSizeSemantics.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar o tamanho do texto'**
  String get settingsTextSizeSemantics;

  /// No description provided for @textScaleDevice.
  ///
  /// In pt, this message translates to:
  /// **'Configuração do dispositivo'**
  String get textScaleDevice;

  /// No description provided for @textScaleSmall.
  ///
  /// In pt, this message translates to:
  /// **'Pequeno'**
  String get textScaleSmall;

  /// No description provided for @textScaleMedium.
  ///
  /// In pt, this message translates to:
  /// **'Médio'**
  String get textScaleMedium;

  /// No description provided for @textScaleLarge.
  ///
  /// In pt, this message translates to:
  /// **'Grande'**
  String get textScaleLarge;

  /// No description provided for @settingsEffectsLabel.
  ///
  /// In pt, this message translates to:
  /// **'Efeitos'**
  String get settingsEffectsLabel;

  /// No description provided for @settingsEffectsSemantics.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar a preferência de animação'**
  String get settingsEffectsSemantics;

  /// No description provided for @animationPreferenceSystem.
  ///
  /// In pt, this message translates to:
  /// **'Sistema'**
  String get animationPreferenceSystem;

  /// No description provided for @animationPreferenceNormal.
  ///
  /// In pt, this message translates to:
  /// **'Normal'**
  String get animationPreferenceNormal;

  /// No description provided for @animationPreferenceReduced.
  ///
  /// In pt, this message translates to:
  /// **'Reduzido'**
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
