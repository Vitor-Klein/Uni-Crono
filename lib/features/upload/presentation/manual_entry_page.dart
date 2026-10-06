import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/auth_form_fields.dart';
import '../../auth/presentation/form_error.dart';
import '../../hours/domain/hours.dart';
import '../../hours/presentation/hour_category_labels.dart';
import '../domain/certificate_file_rules.dart';
import 'finish_launch.dart';
import 'upload_cubit.dart';

/// The data of a certificate the reader could not read, typed by the
/// student.
class ManualEntryPage extends StatefulWidget {
  const ManualEntryPage({super.key});

  static const maxHours = 999;
  static const maxTitle = 120;

  @override
  State<ManualEntryPage> createState() => _ManualEntryPageState();
}

class _ManualEntryPageState extends State<ManualEntryPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  final _hours = TextEditingController();
  HourCategory _category = HourCategory.complementary;

  @override
  void initState() {
    super.initState();
    final pending = context.read<UploadCubit>().state.pending;
    _title = TextEditingController(
      text: pending == null ? '' : titleFromFileName(pending.fileName),
    );
    if (pending == null) {
      // Opened without a PDF waiting (a stale link): nothing to describe.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(AppRoutes.upload);
      });
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _hours.dispose();
    super.dispose();
  }

  static int? _parseHours(String? value) {
    final hours = int.tryParse(value?.trim() ?? '');
    if (hours == null || hours < 1 || hours > ManualEntryPage.maxHours) {
      return null;
    }
    return hours;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final launched = await context.read<UploadCubit>().launchManual(
      title: _title.text.trim(),
      category: _category,
      hours: _parseHours(_hours.text)!,
    );
    if (!mounted || launched == null) return;
    finishLaunch(context, launched);
  }

  Future<void> _cancel() async {
    final router = GoRouter.of(context);
    await context.read<UploadCubit>().discardPending();
    if (router.canPop()) {
      router.pop();
    } else {
      router.go(AppRoutes.upload);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final state = context.watch<UploadCubit>().state;
    return Scaffold(
      // Not a lazy list: a form field built off screen would leave the form
      // and skip its validation.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenGutter),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.manualTitle, style: theme.textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.manualMessage,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              LabeledField(
                label: l10n.manualActivityLabel,
                child: TextFormField(
                  controller: _title,
                  autovalidateMode: AutovalidateMode.onUserInteractionIfError,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(ManualEntryPage.maxTitle),
                  ],
                  decoration: authInputDecoration(),
                  validator: (value) => (value?.trim() ?? '').isEmpty
                      ? l10n.manualActivityRequired
                      : null,
                ),
              ),
              LabeledField(
                label: l10n.manualHoursLabel,
                child: TextFormField(
                  controller: _hours,
                  autovalidateMode: AutovalidateMode.onUserInteractionIfError,
                  keyboardType: TextInputType.number,
                  inputFormatters: [LengthLimitingTextInputFormatter(4)],
                  decoration: authInputDecoration(),
                  validator: (value) => _parseHours(value) == null
                      ? l10n.manualHoursInvalid
                      : null,
                ),
              ),
              LabeledField(
                label: l10n.manualCategoryLabel,
                child: DropdownButtonFormField<HourCategory>(
                  initialValue: _category,
                  isExpanded: true,
                  decoration: authInputDecoration(),
                  items: [
                    for (final category in HourCategory.values)
                      DropdownMenuItem(
                        value: category,
                        child: Text(category.title(l10n)),
                      ),
                  ],
                  onChanged: (category) {
                    if (category != null) setState(() => _category = category);
                  },
                ),
              ),
              if (state.failure case final failure?)
                FormError(launchFailureMessage(l10n, failure)),
              Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  TextButton(
                    onPressed: state.sending ? null : _cancel,
                    child: Text(l10n.uploadCancel),
                  ),
                  FilledButton(
                    onPressed: state.sending ? null : _submit,
                    child: Text(l10n.manualSubmit),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
