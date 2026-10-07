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

  /// No description provided for @shellMenuSemantics.
  ///
  /// In pt, this message translates to:
  /// **'Abrir menu'**
  String get shellMenuSemantics;

  /// No description provided for @loginSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Acesse seus recursos acadêmicos.'**
  String get loginSubtitle;

  /// No description provided for @loginInstitutionLabel.
  ///
  /// In pt, this message translates to:
  /// **'Instituição'**
  String get loginInstitutionLabel;

  /// No description provided for @loginInstitutionHint.
  ///
  /// In pt, this message translates to:
  /// **'Selecione sua universidade…'**
  String get loginInstitutionHint;

  /// No description provided for @loginEmailLabel.
  ///
  /// In pt, this message translates to:
  /// **'E-mail acadêmico'**
  String get loginEmailLabel;

  /// No description provided for @loginEmailHint.
  ///
  /// In pt, this message translates to:
  /// **'aluno@universidade.edu.br'**
  String get loginEmailHint;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get loginPasswordLabel;

  /// No description provided for @loginForgotPassword.
  ///
  /// In pt, this message translates to:
  /// **'Esqueci?'**
  String get loginForgotPassword;

  /// No description provided for @loginShowPassword.
  ///
  /// In pt, this message translates to:
  /// **'Mostrar senha'**
  String get loginShowPassword;

  /// No description provided for @loginHidePassword.
  ///
  /// In pt, this message translates to:
  /// **'Ocultar senha'**
  String get loginHidePassword;

  /// No description provided for @loginSubmit.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get loginSubmit;

  /// No description provided for @loginNewHere.
  ///
  /// In pt, this message translates to:
  /// **'Novo por aqui?'**
  String get loginNewHere;

  /// No description provided for @loginInstitutionRequired.
  ///
  /// In pt, this message translates to:
  /// **'Escolha sua instituição'**
  String get loginInstitutionRequired;

  /// No description provided for @loginEmailRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe seu e-mail acadêmico'**
  String get loginEmailRequired;

  /// No description provided for @loginEmailInvalid.
  ///
  /// In pt, this message translates to:
  /// **'E-mail inválido'**
  String get loginEmailInvalid;

  /// No description provided for @loginPasswordRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe sua senha'**
  String get loginPasswordRequired;

  /// No description provided for @comingSoon.
  ///
  /// In pt, this message translates to:
  /// **'Disponível em breve'**
  String get comingSoon;

  /// No description provided for @dashboardTitle.
  ///
  /// In pt, this message translates to:
  /// **'Progresso acadêmico'**
  String get dashboardTitle;

  /// No description provided for @hoursComplementaryTitle.
  ///
  /// In pt, this message translates to:
  /// **'Horas Complementares'**
  String get hoursComplementaryTitle;

  /// No description provided for @hoursComplementarySubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Atividades extracurriculares'**
  String get hoursComplementarySubtitle;

  /// No description provided for @hoursExtensionTitle.
  ///
  /// In pt, this message translates to:
  /// **'Horas de Extensão'**
  String get hoursExtensionTitle;

  /// No description provided for @hoursExtensionSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Envolvimento com a comunidade'**
  String get hoursExtensionSubtitle;

  /// No description provided for @hoursAccumulated.
  ///
  /// In pt, this message translates to:
  /// **'{hours} horas'**
  String hoursAccumulated(int hours);

  /// No description provided for @hoursGoalTotal.
  ///
  /// In pt, this message translates to:
  /// **'{goal} no total'**
  String hoursGoalTotal(int goal);

  /// No description provided for @dashboardRecentTitle.
  ///
  /// In pt, this message translates to:
  /// **'Aprovados recentemente'**
  String get dashboardRecentTitle;

  /// No description provided for @dashboardSeeAll.
  ///
  /// In pt, this message translates to:
  /// **'Ver todos'**
  String get dashboardSeeAll;

  /// No description provided for @certificateHours.
  ///
  /// In pt, this message translates to:
  /// **'+{hours} h'**
  String certificateHours(int hours);

  /// No description provided for @certificateApproved.
  ///
  /// In pt, this message translates to:
  /// **'Aprovado'**
  String get certificateApproved;

  /// No description provided for @settingsThemeLabel.
  ///
  /// In pt, this message translates to:
  /// **'Tema'**
  String get settingsThemeLabel;

  /// No description provided for @hoursProgressSemantics.
  ///
  /// In pt, this message translates to:
  /// **'{hours} de {goal} horas'**
  String hoursProgressSemantics(int hours, int goal);

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

  /// No description provided for @authInvalidCredentials.
  ///
  /// In pt, this message translates to:
  /// **'E-mail ou senha incorretos'**
  String get authInvalidCredentials;

  /// No description provided for @authNetworkFailure.
  ///
  /// In pt, this message translates to:
  /// **'Sem conexão. Tente de novo.'**
  String get authNetworkFailure;

  /// No description provided for @authWrongInstitution.
  ///
  /// In pt, this message translates to:
  /// **'Esta conta é de outra instituição'**
  String get authWrongInstitution;

  /// No description provided for @authEmailAlreadyRegistered.
  ///
  /// In pt, this message translates to:
  /// **'Este e-mail já tem conta'**
  String get authEmailAlreadyRegistered;

  /// No description provided for @authConfirmationRequired.
  ///
  /// In pt, this message translates to:
  /// **'Conta criada. Confirme o e-mail para entrar.'**
  String get authConfirmationRequired;

  /// No description provided for @loginCreateAccount.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get loginCreateAccount;

  /// No description provided for @signupTitle.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get signupTitle;

  /// No description provided for @signupSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Comece a acompanhar suas horas.'**
  String get signupSubtitle;

  /// No description provided for @signupNameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome completo'**
  String get signupNameLabel;

  /// No description provided for @signupNameRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe seu nome'**
  String get signupNameRequired;

  /// No description provided for @signupCourseLabel.
  ///
  /// In pt, this message translates to:
  /// **'Curso'**
  String get signupCourseLabel;

  /// No description provided for @signupCourseHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Engenharia de Software'**
  String get signupCourseHint;

  /// No description provided for @signupCourseRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe seu curso'**
  String get signupCourseRequired;

  /// No description provided for @signupTermLabel.
  ///
  /// In pt, this message translates to:
  /// **'Período'**
  String get signupTermLabel;

  /// No description provided for @signupTermHint.
  ///
  /// In pt, this message translates to:
  /// **'1 a 12'**
  String get signupTermHint;

  /// No description provided for @signupTermInvalid.
  ///
  /// In pt, this message translates to:
  /// **'Informe um período de 1 a 12'**
  String get signupTermInvalid;

  /// No description provided for @signupPasswordTooShort.
  ///
  /// In pt, this message translates to:
  /// **'Use 8 caracteres ou mais'**
  String get signupPasswordTooShort;

  /// No description provided for @signupSubmit.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get signupSubmit;

  /// No description provided for @signupHaveAccount.
  ///
  /// In pt, this message translates to:
  /// **'Já tem conta?'**
  String get signupHaveAccount;

  /// No description provided for @signupSignIn.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get signupSignIn;

  /// No description provided for @dashboardEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum certificado ainda'**
  String get dashboardEmpty;

  /// No description provided for @dashboardLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar suas horas'**
  String get dashboardLoadError;

  /// No description provided for @retryAction.
  ///
  /// In pt, this message translates to:
  /// **'Tentar de novo'**
  String get retryAction;

  /// No description provided for @uploadTitle.
  ///
  /// In pt, this message translates to:
  /// **'Lançar certificado'**
  String get uploadTitle;

  /// No description provided for @uploadSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Envie o PDF do certificado: o sistema lê as horas e a categoria para você.'**
  String get uploadSubtitle;

  /// No description provided for @uploadDropTitle.
  ///
  /// In pt, this message translates to:
  /// **'Escolha o arquivo'**
  String get uploadDropTitle;

  /// No description provided for @uploadDropHint.
  ///
  /// In pt, this message translates to:
  /// **'PDF (até 10 MB)'**
  String get uploadDropHint;

  /// No description provided for @uploadOr.
  ///
  /// In pt, this message translates to:
  /// **'ou'**
  String get uploadOr;

  /// No description provided for @uploadBrowse.
  ///
  /// In pt, this message translates to:
  /// **'Procurar arquivos'**
  String get uploadBrowse;

  /// No description provided for @uploadCancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get uploadCancel;

  /// No description provided for @uploadSubmit.
  ///
  /// In pt, this message translates to:
  /// **'Enviar certificado'**
  String get uploadSubmit;

  /// No description provided for @uploadInvalidFile.
  ///
  /// In pt, this message translates to:
  /// **'Use um PDF de até 10 MB'**
  String get uploadInvalidFile;

  /// No description provided for @uploadReading.
  ///
  /// In pt, this message translates to:
  /// **'Lendo certificado…'**
  String get uploadReading;

  /// No description provided for @uploadLaunched.
  ///
  /// In pt, this message translates to:
  /// **'Certificado lançado: +{hours} h em {category}'**
  String uploadLaunched(int hours, String category);

  /// No description provided for @uploadDuplicate.
  ///
  /// In pt, this message translates to:
  /// **'Este certificado já foi lançado'**
  String get uploadDuplicate;

  /// No description provided for @uploadUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível ler o certificado. Tente de novo.'**
  String get uploadUnavailable;

  /// No description provided for @uploadSizeKb.
  ///
  /// In pt, this message translates to:
  /// **'{size} KB'**
  String uploadSizeKb(String size);

  /// No description provided for @uploadSizeMb.
  ///
  /// In pt, this message translates to:
  /// **'{size} MB'**
  String uploadSizeMb(String size);

  /// No description provided for @manualTitle.
  ///
  /// In pt, this message translates to:
  /// **'Informe os dados do certificado'**
  String get manualTitle;

  /// No description provided for @manualMessage.
  ///
  /// In pt, this message translates to:
  /// **'Não encontramos as horas neste certificado. Informe os dados.'**
  String get manualMessage;

  /// No description provided for @manualActivityLabel.
  ///
  /// In pt, this message translates to:
  /// **'Atividade'**
  String get manualActivityLabel;

  /// No description provided for @manualActivityRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe a atividade'**
  String get manualActivityRequired;

  /// No description provided for @manualHoursLabel.
  ///
  /// In pt, this message translates to:
  /// **'Carga horária (h)'**
  String get manualHoursLabel;

  /// No description provided for @manualHoursInvalid.
  ///
  /// In pt, this message translates to:
  /// **'Informe as horas (1 a 999)'**
  String get manualHoursInvalid;

  /// No description provided for @manualCategoryLabel.
  ///
  /// In pt, this message translates to:
  /// **'Categoria'**
  String get manualCategoryLabel;

  /// No description provided for @manualSubmit.
  ///
  /// In pt, this message translates to:
  /// **'Lançar'**
  String get manualSubmit;

  /// No description provided for @hubTitle.
  ///
  /// In pt, this message translates to:
  /// **'Hub de Oportunidades'**
  String get hubTitle;

  /// No description provided for @hubSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Cursos e eventos em que você ganha certificado de horas.'**
  String get hubSubtitle;

  /// No description provided for @hubSearchLabel.
  ///
  /// In pt, this message translates to:
  /// **'Buscar oportunidades'**
  String get hubSearchLabel;

  /// No description provided for @hubSearchHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar oportunidades…'**
  String get hubSearchHint;

  /// No description provided for @hubFilterAll.
  ///
  /// In pt, this message translates to:
  /// **'Todas'**
  String get hubFilterAll;

  /// No description provided for @hubFilterCourses.
  ///
  /// In pt, this message translates to:
  /// **'Cursos'**
  String get hubFilterCourses;

  /// No description provided for @hubFilterEvents.
  ///
  /// In pt, this message translates to:
  /// **'Eventos'**
  String get hubFilterEvents;

  /// No description provided for @hubFilterExtension.
  ///
  /// In pt, this message translates to:
  /// **'Extensão'**
  String get hubFilterExtension;

  /// No description provided for @hubFilterComplementary.
  ///
  /// In pt, this message translates to:
  /// **'Complementares'**
  String get hubFilterComplementary;

  /// No description provided for @hubKindCourse.
  ///
  /// In pt, this message translates to:
  /// **'Curso'**
  String get hubKindCourse;

  /// No description provided for @hubKindEvent.
  ///
  /// In pt, this message translates to:
  /// **'Evento'**
  String get hubKindEvent;

  /// No description provided for @hubModalityOnline.
  ///
  /// In pt, this message translates to:
  /// **'Online'**
  String get hubModalityOnline;

  /// No description provided for @hubModalityPresencial.
  ///
  /// In pt, this message translates to:
  /// **'Presencial'**
  String get hubModalityPresencial;

  /// No description provided for @hubModalityHibrido.
  ///
  /// In pt, this message translates to:
  /// **'Híbrido'**
  String get hubModalityHibrido;

  /// No description provided for @hubHours.
  ///
  /// In pt, this message translates to:
  /// **'{hours} h'**
  String hubHours(int hours);

  /// No description provided for @hubSignUp.
  ///
  /// In pt, this message translates to:
  /// **'Inscrever-se'**
  String get hubSignUp;

  /// No description provided for @hubEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma oportunidade encontrada'**
  String get hubEmpty;

  /// No description provided for @hubLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar as oportunidades'**
  String get hubLoadError;

  /// No description provided for @cancelAction.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancelAction;

  /// No description provided for @profileTerm.
  ///
  /// In pt, this message translates to:
  /// **'{term}º período'**
  String profileTerm(int term);

  /// No description provided for @profileHoursValue.
  ///
  /// In pt, this message translates to:
  /// **'{hours} h'**
  String profileHoursValue(int hours);

  /// No description provided for @profileHoursLabel.
  ///
  /// In pt, this message translates to:
  /// **'horas lançadas'**
  String get profileHoursLabel;

  /// No description provided for @profileCertificatesLabel.
  ///
  /// In pt, this message translates to:
  /// **'certificados'**
  String get profileCertificatesLabel;

  /// No description provided for @profileGoalValue.
  ///
  /// In pt, this message translates to:
  /// **'{percent}%'**
  String profileGoalValue(int percent);

  /// No description provided for @profileGoalLabel.
  ///
  /// In pt, this message translates to:
  /// **'da meta'**
  String get profileGoalLabel;

  /// No description provided for @profilePreferences.
  ///
  /// In pt, this message translates to:
  /// **'PREFERÊNCIAS'**
  String get profilePreferences;

  /// No description provided for @profileAccount.
  ///
  /// In pt, this message translates to:
  /// **'CONTA'**
  String get profileAccount;

  /// No description provided for @profileNotifications.
  ///
  /// In pt, this message translates to:
  /// **'Notificações'**
  String get profileNotifications;

  /// No description provided for @profileLanguage.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get profileLanguage;

  /// No description provided for @profileAccessibility.
  ///
  /// In pt, this message translates to:
  /// **'Acessibilidade'**
  String get profileAccessibility;

  /// No description provided for @profileSignOut.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get profileSignOut;

  /// No description provided for @profileSignOutTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sair da conta?'**
  String get profileSignOutTitle;

  /// No description provided for @profileSignOutBody.
  ///
  /// In pt, this message translates to:
  /// **'Você vai precisar entrar de novo para ver suas horas.'**
  String get profileSignOutBody;

  /// No description provided for @profileLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar seu perfil'**
  String get profileLoadError;

  /// No description provided for @configMissingMessage.
  ///
  /// In pt, this message translates to:
  /// **'O app não encontrou a configuração do servidor. Rode com --dart-define-from-file=config/app.json.'**
  String get configMissingMessage;
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
