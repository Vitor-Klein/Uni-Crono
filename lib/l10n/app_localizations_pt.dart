// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get webViewDeviceDisclaimer =>
      'A exibição pode variar conforme o seu dispositivo.';

  @override
  String get webViewDismiss => 'Fechar';

  @override
  String get webViewErrorTitle => 'Não foi possível carregar a página';

  @override
  String get webViewErrorMessage => 'Verifique sua conexão e tente novamente.';

  @override
  String get webViewRetry => 'Tentar novamente';

  @override
  String get notificationsEnabledMessage => 'Notificações ativadas.';

  @override
  String get notificationsDisabledMessage => 'Notificações desativadas.';

  @override
  String get notificationsUpdateError =>
      'Não foi possível atualizar as configurações de notificação.';

  @override
  String get homeMoreButton => 'MAIS';

  @override
  String get notificationsSheetTitle => 'NOTIFICAÇÕES';

  @override
  String get pushNotificationsLabel => 'NOTIFICAÇÕES PUSH';

  @override
  String get enabledLabel => 'Ativado';

  @override
  String get disabledLabel => 'Desativado';

  @override
  String get notificationChannelName => 'Geral';

  @override
  String get notificationChannelDescription => 'Notificações gerais';

  @override
  String get notificationOpenLinkAction => 'Abrir link';

  @override
  String get notificationFallbackTitle => 'Notificação';

  @override
  String get messagesTitle => 'Mensagens';

  @override
  String get messagesClearAllTooltip => 'Limpar tudo';

  @override
  String get messagesCloseTooltip => 'Fechar';

  @override
  String get messageNoTitle => '(Sem título)';

  @override
  String get messagesDeleteTooltip => 'Excluir';

  @override
  String get messagesEmptyTitle => 'Nenhuma mensagem ainda';

  @override
  String get messagesEmptyMessage => 'As notificações push aparecerão aqui.';

  @override
  String get messagesFilterAll => 'Todas';

  @override
  String get messagesFilterUnread => 'Não lidas';

  @override
  String get messagesMarkAllReadTooltip => 'Marcar todas como lidas';

  @override
  String get messagesGroupToday => 'Hoje';

  @override
  String get messagesGroupYesterday => 'Ontem';

  @override
  String get messagesEmptyUnreadTitle => 'Nenhuma mensagem não lida';

  @override
  String get messagesEmptyUnreadMessage => 'Você já viu tudo.';

  @override
  String get upgradeRequiredTitle => 'Atualização necessária';

  @override
  String get upgradeRequiredBody =>
      'Uma nova versão é necessária para continuar usando o app.';

  @override
  String get upgradeNowButton => 'Atualizar agora';

  @override
  String get moreMessagesTitle => 'MENSAGENS';

  @override
  String get moreMessagesSubtitle => 'Últimas novidades e notícias';

  @override
  String get moreSettingsTitle => 'CONFIGURAÇÕES';

  @override
  String get moreSettingsSubtitle => 'Ajustes e preferências do app';

  @override
  String get moreShareTitle => 'COMPARTILHAR APP';

  @override
  String get moreShareSubtitle => 'Convide amigos para o app';

  @override
  String get morePrivacyTitle => 'POLÍTICA DE PRIVACIDADE';

  @override
  String get morePrivacySubtitle => 'Leia nossa política de privacidade';

  @override
  String get moreTermsTitle => 'TERMOS DE USO';

  @override
  String get moreTermsSubtitle => 'Leia nossos termos de uso';

  @override
  String get legalPrivacyPageTitle => 'Política de Privacidade';

  @override
  String get legalTermsPageTitle => 'Termos de Uso';

  @override
  String get settingsTitle => 'CONFIGURAÇÕES';

  @override
  String get settingsAccessibilityTitle => 'ACESSIBILIDADE';

  @override
  String get settingsAccessibilitySubtitle =>
      'Aparência e configurações de exibição';

  @override
  String get settingsLanguageTitle => 'IDIOMA';

  @override
  String get settingsLanguageSemantics => 'Selecionar o idioma do app';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navUpload => 'Enviar';

  @override
  String get navActivities => 'Atividades';

  @override
  String get navProfile => 'Perfil';

  @override
  String get shellMenuSemantics => 'Abrir menu';

  @override
  String get loginSubtitle => 'Acesse seus recursos acadêmicos.';

  @override
  String get loginInstitutionLabel => 'Instituição';

  @override
  String get loginInstitutionHint => 'Selecione sua universidade…';

  @override
  String get loginEmailLabel => 'E-mail acadêmico';

  @override
  String get loginEmailHint => 'aluno@universidade.edu.br';

  @override
  String get loginPasswordLabel => 'Senha';

  @override
  String get loginForgotPassword => 'Esqueci?';

  @override
  String get loginShowPassword => 'Mostrar senha';

  @override
  String get loginHidePassword => 'Ocultar senha';

  @override
  String get loginSubmit => 'Entrar';

  @override
  String get loginNewHere => 'Novo por aqui?';

  @override
  String get loginInstitutionRequired => 'Escolha sua instituição';

  @override
  String get loginEmailRequired => 'Informe seu e-mail acadêmico';

  @override
  String get loginEmailInvalid => 'E-mail inválido';

  @override
  String get loginPasswordRequired => 'Informe sua senha';

  @override
  String get comingSoon => 'Disponível em breve';

  @override
  String get dashboardTitle => 'Progresso acadêmico';

  @override
  String get hoursComplementaryTitle => 'Horas Complementares';

  @override
  String get hoursComplementarySubtitle => 'Atividades extracurriculares';

  @override
  String get hoursExtensionTitle => 'Horas de Extensão';

  @override
  String get hoursExtensionSubtitle => 'Envolvimento com a comunidade';

  @override
  String hoursAccumulated(int hours) {
    return '$hours horas';
  }

  @override
  String hoursGoalTotal(int goal) {
    return '$goal no total';
  }

  @override
  String get dashboardRecentTitle => 'Aprovados recentemente';

  @override
  String get dashboardSeeAll => 'Ver todos';

  @override
  String certificateHours(int hours) {
    return '+$hours h';
  }

  @override
  String get certificateApproved => 'Aprovado';

  @override
  String get settingsThemeLabel => 'Tema';

  @override
  String hoursProgressSemantics(int hours, int goal) {
    return '$hours de $goal horas';
  }

  @override
  String get settingsThemeSemantics => 'Selecionar o modo de tema';

  @override
  String get themeModeSystem => 'Sistema';

  @override
  String get themeModeLight => 'Claro';

  @override
  String get themeModeDark => 'Escuro';

  @override
  String get settingsTextSizeLabel => 'Tamanho do texto';

  @override
  String get settingsTextSizeSemantics => 'Selecionar o tamanho do texto';

  @override
  String get textScaleDevice => 'Configuração do dispositivo';

  @override
  String get textScaleSmall => 'Pequeno';

  @override
  String get textScaleMedium => 'Médio';

  @override
  String get textScaleLarge => 'Grande';

  @override
  String get settingsEffectsLabel => 'Efeitos';

  @override
  String get settingsEffectsSemantics => 'Selecionar a preferência de animação';

  @override
  String get animationPreferenceSystem => 'Sistema';

  @override
  String get animationPreferenceNormal => 'Normal';

  @override
  String get animationPreferenceReduced => 'Reduzido';

  @override
  String get authInvalidCredentials => 'E-mail ou senha incorretos';

  @override
  String get authNetworkFailure => 'Sem conexão. Tente de novo.';

  @override
  String get authWrongInstitution => 'Esta conta é de outra instituição';

  @override
  String get authEmailAlreadyRegistered => 'Este e-mail já tem conta';

  @override
  String get authConfirmationRequired =>
      'Conta criada. Confirme o e-mail para entrar.';

  @override
  String get loginCreateAccount => 'Criar conta';

  @override
  String get signupTitle => 'Criar conta';

  @override
  String get signupSubtitle => 'Comece a acompanhar suas horas.';

  @override
  String get signupNameLabel => 'Nome completo';

  @override
  String get signupNameRequired => 'Informe seu nome';

  @override
  String get signupCourseLabel => 'Curso';

  @override
  String get signupCourseHint => 'Ex.: Engenharia de Software';

  @override
  String get signupCourseRequired => 'Informe seu curso';

  @override
  String get signupTermLabel => 'Período';

  @override
  String get signupTermHint => '1 a 12';

  @override
  String get signupTermInvalid => 'Informe um período de 1 a 12';

  @override
  String get signupPasswordTooShort => 'Use 8 caracteres ou mais';

  @override
  String get signupSubmit => 'Criar conta';

  @override
  String get signupHaveAccount => 'Já tem conta?';

  @override
  String get signupSignIn => 'Entrar';
}
