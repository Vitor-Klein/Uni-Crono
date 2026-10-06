// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get webViewDeviceDisclaimer =>
      'La visualización puede variar según tu dispositivo.';

  @override
  String get webViewDismiss => 'Cerrar';

  @override
  String get webViewErrorTitle => 'No se pudo cargar la página';

  @override
  String get webViewErrorMessage =>
      'Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get webViewRetry => 'Reintentar';

  @override
  String get notificationsEnabledMessage => 'Notificaciones activadas.';

  @override
  String get notificationsDisabledMessage => 'Notificaciones desactivadas.';

  @override
  String get notificationsUpdateError =>
      'No se pudo actualizar la configuración de notificaciones.';

  @override
  String get homeMoreButton => 'MÁS';

  @override
  String get notificationsSheetTitle => 'NOTIFICACIONES';

  @override
  String get pushNotificationsLabel => 'NOTIFICACIONES PUSH';

  @override
  String get enabledLabel => 'Activado';

  @override
  String get disabledLabel => 'Desactivado';

  @override
  String get notificationChannelName => 'General';

  @override
  String get notificationChannelDescription => 'Notificaciones generales';

  @override
  String get notificationOpenLinkAction => 'Abrir enlace';

  @override
  String get notificationFallbackTitle => 'Notificación';

  @override
  String get messagesTitle => 'Mensajes';

  @override
  String get messagesClearAllTooltip => 'Borrar todo';

  @override
  String get messagesCloseTooltip => 'Cerrar';

  @override
  String get messageNoTitle => '(Sin título)';

  @override
  String get messagesDeleteTooltip => 'Eliminar';

  @override
  String get messagesEmptyTitle => 'Aún no hay mensajes';

  @override
  String get messagesEmptyMessage => 'Las notificaciones push aparecerán aquí.';

  @override
  String get messagesFilterAll => 'Todas';

  @override
  String get messagesFilterUnread => 'No leídas';

  @override
  String get messagesMarkAllReadTooltip => 'Marcar todas como leídas';

  @override
  String get messagesGroupToday => 'Hoy';

  @override
  String get messagesGroupYesterday => 'Ayer';

  @override
  String get messagesEmptyUnreadTitle => 'No hay mensajes sin leer';

  @override
  String get messagesEmptyUnreadMessage => 'Ya viste todo.';

  @override
  String get upgradeRequiredTitle => 'Actualización necesaria';

  @override
  String get upgradeRequiredBody =>
      'Se necesita una nueva versión para seguir usando la app.';

  @override
  String get upgradeNowButton => 'Actualizar ahora';

  @override
  String get moreMessagesTitle => 'MENSAJES';

  @override
  String get moreMessagesSubtitle => 'Últimas novedades y noticias';

  @override
  String get moreSettingsTitle => 'AJUSTES';

  @override
  String get moreSettingsSubtitle => 'Ajustes y preferencias de la app';

  @override
  String get moreShareTitle => 'COMPARTIR APP';

  @override
  String get moreShareSubtitle => 'Invita a tus amigos a la app';

  @override
  String get morePrivacyTitle => 'POLÍTICA DE PRIVACIDAD';

  @override
  String get morePrivacySubtitle => 'Lee nuestra política de privacidad';

  @override
  String get moreTermsTitle => 'TÉRMINOS DE USO';

  @override
  String get moreTermsSubtitle => 'Lee nuestros términos de uso';

  @override
  String get legalPrivacyPageTitle => 'Política de Privacidad';

  @override
  String get legalTermsPageTitle => 'Términos de Uso';

  @override
  String get settingsTitle => 'AJUSTES';

  @override
  String get settingsAccessibilityTitle => 'ACCESIBILIDAD';

  @override
  String get settingsAccessibilitySubtitle =>
      'Apariencia y configuración de pantalla';

  @override
  String get settingsLanguageTitle => 'IDIOMA';

  @override
  String get settingsLanguageSemantics => 'Seleccionar el idioma de la app';

  @override
  String get navDashboard => 'Panel';

  @override
  String get navUpload => 'Subir';

  @override
  String get navActivities => 'Actividades';

  @override
  String get navProfile => 'Perfil';

  @override
  String get shellMenuSemantics => 'Abrir menú';

  @override
  String get loginSubtitle => 'Accede a tus recursos académicos.';

  @override
  String get loginInstitutionLabel => 'Institución';

  @override
  String get loginInstitutionHint => 'Selecciona tu universidad…';

  @override
  String get loginEmailLabel => 'Correo académico';

  @override
  String get loginEmailHint => 'estudiante@universidad.edu';

  @override
  String get loginPasswordLabel => 'Contraseña';

  @override
  String get loginForgotPassword => '¿La olvidaste?';

  @override
  String get loginShowPassword => 'Mostrar contraseña';

  @override
  String get loginHidePassword => 'Ocultar contraseña';

  @override
  String get loginSubmit => 'Entrar';

  @override
  String get loginNewHere => '¿Eres nuevo?';

  @override
  String get loginInstitutionRequired => 'Elige tu institución';

  @override
  String get loginEmailRequired => 'Ingresa tu correo académico';

  @override
  String get loginEmailInvalid => 'Correo inválido';

  @override
  String get loginPasswordRequired => 'Ingresa tu contraseña';

  @override
  String get comingSoon => 'Disponible pronto';

  @override
  String get dashboardTitle => 'Progreso académico';

  @override
  String get hoursComplementaryTitle => 'Horas Complementarias';

  @override
  String get hoursComplementarySubtitle => 'Actividades extracurriculares';

  @override
  String get hoursExtensionTitle => 'Horas de Extensión';

  @override
  String get hoursExtensionSubtitle => 'Participación comunitaria';

  @override
  String hoursAccumulated(int hours) {
    return '$hours horas';
  }

  @override
  String hoursGoalTotal(int goal) {
    return '$goal en total';
  }

  @override
  String get dashboardRecentTitle => 'Aprobados recientemente';

  @override
  String get dashboardSeeAll => 'Ver todos';

  @override
  String certificateHours(int hours) {
    return '+$hours h';
  }

  @override
  String get certificateApproved => 'Aprobado';

  @override
  String get settingsThemeLabel => 'Tema';

  @override
  String hoursProgressSemantics(int hours, int goal) {
    return '$hours de $goal horas';
  }

  @override
  String get settingsThemeSemantics => 'Seleccionar el modo de tema';

  @override
  String get themeModeSystem => 'Sistema';

  @override
  String get themeModeLight => 'Claro';

  @override
  String get themeModeDark => 'Oscuro';

  @override
  String get settingsTextSizeLabel => 'Tamaño del texto';

  @override
  String get settingsTextSizeSemantics => 'Seleccionar el tamaño del texto';

  @override
  String get textScaleDevice => 'Configuración del dispositivo';

  @override
  String get textScaleSmall => 'Pequeño';

  @override
  String get textScaleMedium => 'Mediano';

  @override
  String get textScaleLarge => 'Grande';

  @override
  String get settingsEffectsLabel => 'Efectos';

  @override
  String get settingsEffectsSemantics =>
      'Seleccionar la preferencia de animación';

  @override
  String get animationPreferenceSystem => 'Sistema';

  @override
  String get animationPreferenceNormal => 'Normal';

  @override
  String get animationPreferenceReduced => 'Reducido';

  @override
  String get authInvalidCredentials => 'Correo o contraseña incorrectos';

  @override
  String get authNetworkFailure => 'Sin conexión. Inténtalo de nuevo.';

  @override
  String get authWrongInstitution => 'Esta cuenta es de otra institución';

  @override
  String get authEmailAlreadyRegistered => 'Este correo ya tiene cuenta';

  @override
  String get authConfirmationRequired =>
      'Cuenta creada. Confirma el correo para entrar.';

  @override
  String get loginCreateAccount => 'Crear cuenta';

  @override
  String get signupTitle => 'Crear cuenta';

  @override
  String get signupSubtitle => 'Empieza a seguir tus horas.';

  @override
  String get signupNameLabel => 'Nombre completo';

  @override
  String get signupNameRequired => 'Ingresa tu nombre';

  @override
  String get signupCourseLabel => 'Carrera';

  @override
  String get signupCourseHint => 'Ej.: Ingeniería de Software';

  @override
  String get signupCourseRequired => 'Ingresa tu carrera';

  @override
  String get signupTermLabel => 'Semestre';

  @override
  String get signupTermHint => '1 a 12';

  @override
  String get signupTermInvalid => 'Ingresa un semestre de 1 a 12';

  @override
  String get signupPasswordTooShort => 'Usa 8 caracteres o más';

  @override
  String get signupSubmit => 'Crear cuenta';

  @override
  String get signupHaveAccount => '¿Ya tienes cuenta?';

  @override
  String get signupSignIn => 'Entrar';

  @override
  String get dashboardEmpty => 'Aún no hay certificados';

  @override
  String get dashboardLoadError => 'No se pudieron cargar tus horas';

  @override
  String get retryAction => 'Intentar de nuevo';
}
