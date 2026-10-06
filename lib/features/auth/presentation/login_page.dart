import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:next_widgets_service/next_widgets_service.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../data/auth_gateway.dart';
import '../domain/email_format.dart';
import 'auth_failure_message.dart';
import 'auth_form_fields.dart';
import 'form_error.dart';
import 'session_cubit.dart';

/// Sign-in screen: e-mail and password go to the account server, and the
/// account has to belong to the chosen institution.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _institutionId;
  bool _submitting = false;
  AuthFailure? _failure;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _submitting = true;
      _failure = null;
    });
    try {
      await context.read<SessionCubit>().signIn(
        email: _email.text.trim(),
        password: _password.text,
        institutionId: _institutionId!,
      );
    } on AuthFailure catch (failure) {
      if (mounted) setState(() => _failure = failure);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenGutter),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xxl),
                AuthHeader(subtitle: l10n.loginSubtitle),
                const SizedBox(height: AppSpacing.xxl),
                LabeledField(
                  label: l10n.loginInstitutionLabel,
                  child: InstitutionField(
                    value: _institutionId,
                    onChanged: (id) => setState(() => _institutionId = id),
                  ),
                ),
                LabeledField(
                  label: l10n.loginEmailLabel,
                  child: TextFormField(
                    controller: _email,
                    autovalidateMode: AutovalidateMode.onUserInteractionIfError,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.next,
                    decoration: authInputDecoration(hint: l10n.loginEmailHint),
                    validator: (value) {
                      final email = value?.trim() ?? '';
                      if (email.isEmpty) return l10n.loginEmailRequired;
                      if (!isValidEmail(email)) return l10n.loginEmailInvalid;
                      return null;
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(child: FieldLabel(l10n.loginPasswordLabel)),
                    TextButton(
                      onPressed: () => NextSnack.showNextSnack(
                        context,
                        message: l10n.comingSoon,
                      ),
                      child: Text(l10n.loginForgotPassword),
                    ),
                  ],
                ),
                NamedField(
                  label: l10n.loginPasswordLabel,
                  child: PasswordField(
                    controller: _password,
                    onSubmitted: _submit,
                    validator: (value) => (value ?? '').isEmpty
                        ? l10n.loginPasswordRequired
                        : null,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                if (_failure case final failure?)
                  FormError(authFailureMessage(l10n, failure)),
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: Text(l10n.loginSubmit),
                ),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(l10n.loginNewHere, style: theme.textTheme.bodyMedium),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.signup),
                      child: Text(l10n.loginCreateAccount),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
