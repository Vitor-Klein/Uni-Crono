import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../data/auth_gateway.dart';
import '../domain/email_format.dart';
import '../domain/sign_up_data.dart';
import 'auth_failure_message.dart';
import 'auth_form_fields.dart';
import 'form_error.dart';
import 'session_cubit.dart';

/// Creates the student's account with the profile the app shows. The server
/// checks the same limits again: these checks only spare a round trip.
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  static const minPasswordLength = 8;
  static const maxTerm = 12;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _course = TextEditingController();
  final _term = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _institutionId;
  bool _submitting = false;
  AuthFailure? _failure;

  @override
  void dispose() {
    for (final controller in [_name, _course, _term, _email, _password]) {
      controller.dispose();
    }
    super.dispose();
  }

  static int? _parseTerm(String? value) {
    final term = int.tryParse(value?.trim() ?? '');
    if (term == null || term < 1 || term > SignUpPage.maxTerm) return null;
    return term;
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _submitting = true;
      _failure = null;
    });
    try {
      await context.read<SessionCubit>().signUp(
        SignUpData(
          fullName: _name.text.trim(),
          institutionId: _institutionId!,
          course: _course.text.trim(),
          term: _parseTerm(_term.text)!,
          email: _email.text.trim(),
          password: _password.text,
        ),
      );
    } on AuthFailure catch (failure) {
      if (mounted) setState(() => _failure = failure);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  FormFieldValidator<String> _required(String message) =>
      (value) => (value?.trim() ?? '').isEmpty ? message : null;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenGutter),
          child: AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  AuthHeader(subtitle: l10n.signupSubtitle),
                  const SizedBox(height: AppSpacing.xl),
                  Text(l10n.signupTitle, style: theme.textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.lg),
                  LabeledField(
                    label: l10n.signupNameLabel,
                    child: TextFormField(
                      controller: _name,
                      autovalidateMode:
                          AutovalidateMode.onUserInteractionIfError,
                      textCapitalization: TextCapitalization.words,
                      autofillHints: const [AutofillHints.name],
                      textInputAction: TextInputAction.next,
                      inputFormatters: [LengthLimitingTextInputFormatter(120)],
                      decoration: authInputDecoration(),
                      validator: _required(l10n.signupNameRequired),
                    ),
                  ),
                  LabeledField(
                    label: l10n.loginInstitutionLabel,
                    child: InstitutionField(
                      value: _institutionId,
                      onChanged: (id) => setState(() => _institutionId = id),
                    ),
                  ),
                  LabeledField(
                    label: l10n.signupCourseLabel,
                    child: TextFormField(
                      controller: _course,
                      autovalidateMode:
                          AutovalidateMode.onUserInteractionIfError,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [LengthLimitingTextInputFormatter(120)],
                      decoration: authInputDecoration(
                        hint: l10n.signupCourseHint,
                      ),
                      validator: _required(l10n.signupCourseRequired),
                    ),
                  ),
                  LabeledField(
                    label: l10n.signupTermLabel,
                    child: TextFormField(
                      controller: _term,
                      autovalidateMode:
                          AutovalidateMode.onUserInteractionIfError,
                      keyboardType: TextInputType.number,
                      inputFormatters: [LengthLimitingTextInputFormatter(2)],
                      textInputAction: TextInputAction.next,
                      decoration: authInputDecoration(
                        hint: l10n.signupTermHint,
                      ),
                      validator: (value) => _parseTerm(value) == null
                          ? l10n.signupTermInvalid
                          : null,
                    ),
                  ),
                  LabeledField(
                    label: l10n.loginEmailLabel,
                    child: TextFormField(
                      controller: _email,
                      autovalidateMode:
                          AutovalidateMode.onUserInteractionIfError,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      decoration: authInputDecoration(
                        hint: l10n.loginEmailHint,
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) return l10n.loginEmailRequired;
                        if (!isValidEmail(email)) {
                          return l10n.loginEmailInvalid;
                        }
                        return null;
                      },
                    ),
                  ),
                  LabeledField(
                    label: l10n.loginPasswordLabel,
                    child: PasswordField(
                      controller: _password,
                      onSubmitted: _submit,
                      validator: (value) {
                        final password = value ?? '';
                        if (password.isEmpty) {
                          return l10n.loginPasswordRequired;
                        }
                        if (password.length < SignUpPage.minPasswordLength) {
                          return l10n.signupPasswordTooShort;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (_failure case final failure?)
                    FormError(authFailureMessage(l10n, failure)),
                  FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child: Text(l10n.signupSubmit),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        l10n.signupHaveAccount,
                        style: theme.textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.login),
                        child: Text(l10n.signupSignIn),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
