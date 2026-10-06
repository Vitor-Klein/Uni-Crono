import '../../../l10n/app_localizations.dart';
import '../data/auth_gateway.dart';

/// What the student reads when the account server refuses.
String authFailureMessage(AppLocalizations l10n, AuthFailure failure) =>
    switch (failure) {
      InvalidCredentials() => l10n.authInvalidCredentials,
      WrongInstitution() => l10n.authWrongInstitution,
      EmailAlreadyRegistered() => l10n.authEmailAlreadyRegistered,
      ConfirmationRequired() => l10n.authConfirmationRequired,
      NetworkFailure() => l10n.authNetworkFailure,
    };
