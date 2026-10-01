import 'package:flutter/material.dart';

import '../../../app/app_info.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/email_format.dart';
import '../domain/institution.dart';

/// Sign-in screen of the prototype: it checks the format of what is typed and
/// keeps the session on this device. No server is consulted.
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
  bool _obscurePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
  }

  InputDecoration _decoration({String? hint}) => InputDecoration(
    hintText: hint,
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppRadii.sm)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
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
                Center(
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: cs.primaryContainer,
                    child: Icon(
                      Icons.school_outlined,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  kAppName,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.loginSubtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                _FieldLabel(l10n.loginInstitutionLabel),
                DropdownButtonFormField<String>(
                  initialValue: _institutionId,
                  hint: Text(l10n.loginInstitutionHint),
                  decoration: _decoration(),
                  items: [
                    for (final institution in Institutions.all)
                      DropdownMenuItem(
                        value: institution.id,
                        child: Text(institution.name),
                      ),
                  ],
                  onChanged: (id) => setState(() => _institutionId = id),
                  validator: (id) =>
                      id == null ? l10n.loginInstitutionRequired : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                _FieldLabel(l10n.loginEmailLabel),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  decoration: _decoration(hint: l10n.loginEmailHint),
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (email.isEmpty) return l10n.loginEmailRequired;
                    if (!isValidEmail(email)) return l10n.loginEmailInvalid;
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(child: _FieldLabel(l10n.loginPasswordLabel)),
                    TextButton(
                      onPressed: () {},
                      child: Text(l10n.loginForgotPassword),
                    ),
                  ],
                ),
                TextFormField(
                  controller: _password,
                  obscureText: _obscurePassword,
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.done,
                  decoration: _decoration().copyWith(
                    suffixIcon: IconButton(
                      tooltip: _obscurePassword
                          ? l10n.loginShowPassword
                          : l10n.loginHidePassword,
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (value) =>
                      (value ?? '').isEmpty ? l10n.loginPasswordRequired : null,
                ),
                const SizedBox(height: AppSpacing.xl),
                FilledButton(onPressed: _submit, child: Text(l10n.loginSubmit)),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l10n.loginNewHere, style: theme.textTheme.bodyMedium),
                    TextButton(
                      onPressed: () {},
                      child: Text(l10n.loginRequestAccess),
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

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(text, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}
