import 'package:flutter/material.dart';

import '../../../app/app_info.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/institution.dart';

/// The outlined border of every field on the account screens.
InputDecoration authInputDecoration({String? hint}) => InputDecoration(
  hintText: hint,
  border: const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(AppRadii.sm)),
  ),
);

/// Brand mark, app name and a line of support text, on top of the account
/// screens.
class AuthHeader extends StatelessWidget {
  const AuthHeader({required this.subtitle, super.key});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: CircleAvatar(
            radius: 28,
            backgroundColor: cs.primaryContainer,
            child: Icon(Icons.school_outlined, color: cs.onPrimaryContainer),
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
          subtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// The visible label above a field. Hidden from screen readers: the field
/// carries the same label through [NamedField], so it is announced once.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: ExcludeSemantics(
        child: Text(text, style: Theme.of(context).textTheme.labelLarge),
      ),
    );
  }
}

/// Gives [child] the accessible name [label].
class NamedField extends StatelessWidget {
  const NamedField({required this.label, required this.child, super.key});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(label: label, child: child);
  }
}

/// A label and its field, with the space that follows them.
class LabeledField extends StatelessWidget {
  const LabeledField({required this.label, required this.child, super.key});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FieldLabel(label),
          NamedField(label: label, child: child),
        ],
      ),
    );
  }
}

/// The choice among [Institutions.all].
class InstitutionField extends StatelessWidget {
  const InstitutionField({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      autovalidateMode: AutovalidateMode.onUserInteractionIfError,
      hint: Text(l10n.loginInstitutionHint),
      decoration: authInputDecoration(),
      items: [
        for (final institution in Institutions.all)
          DropdownMenuItem(
            value: institution.id,
            child: Text(institution.name),
          ),
      ],
      onChanged: onChanged,
      validator: (id) => id == null ? l10n.loginInstitutionRequired : null,
    );
  }
}

/// The password field with the button that shows or hides it.
class PasswordField extends StatefulWidget {
  const PasswordField({
    required this.controller,
    required this.validator,
    this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final VoidCallback? onSubmitted;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: widget.controller,
      autovalidateMode: AutovalidateMode.onUserInteractionIfError,
      obscureText: _obscure,
      autofillHints: const [AutofillHints.password],
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => widget.onSubmitted?.call(),
      decoration: authInputDecoration().copyWith(
        suffixIcon: IconButton(
          tooltip: _obscure ? l10n.loginShowPassword : l10n.loginHidePassword,
          icon: Icon(
            _obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
      validator: widget.validator,
    );
  }
}
