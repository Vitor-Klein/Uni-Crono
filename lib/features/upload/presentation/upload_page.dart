import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/form_error.dart';
import '../domain/picked_file.dart';
import 'finish_launch.dart';
import 'upload_cubit.dart';

/// Sends a certificate PDF to be read and counted.
class UploadPage extends StatelessWidget {
  const UploadPage({super.key});

  Future<void> _send(BuildContext context) async {
    final cubit = context.read<UploadCubit>();
    final launched = await cubit.send();
    if (!context.mounted) return;
    if (launched != null) {
      finishLaunch(context, launched);
    } else if (cubit.state.pending != null) {
      context.go(AppRoutes.uploadManual);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final state = context.watch<UploadCubit>().state;
    final cubit = context.read<UploadCubit>();
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenGutter),
      children: [
        Text(
          l10n.uploadTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.uploadSubtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        _DropArea(
          file: state.file,
          busy: state.sending,
          onBrowse: cubit.choose,
        ),
        const SizedBox(height: AppSpacing.lg),
        if (state.invalid) FormError(l10n.uploadInvalidFile),
        if (state.failure case final failure?)
          FormError(launchFailureMessage(l10n, failure)),
        if (state.sending)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Semantics(
              liveRegion: true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox.square(
                    dimension: AppSpacing.lg,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(child: Text(l10n.uploadReading)),
                ],
              ),
            ),
          ),
        Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            TextButton(
              onPressed: state.sending ? null : cubit.clear,
              child: Text(l10n.uploadCancel),
            ),
            FilledButton(
              onPressed: state.file == null || state.sending
                  ? null
                  : () => _send(context),
              child: Text(l10n.uploadSubmit),
            ),
          ],
        ),
      ],
    );
  }
}

class _DropArea extends StatelessWidget {
  const _DropArea({
    required this.file,
    required this.busy,
    required this.onBrowse,
  });

  final PickedFile? file;
  final bool busy;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final chosen = file;
    return CustomPaint(
      painter: _DashedBorderPainter(color: cs.outlineVariant),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: cs.surfaceContainer,
                child: Icon(
                  chosen == null
                      ? Icons.cloud_upload_outlined
                      : Icons.picture_as_pdf_outlined,
                  color: cs.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (chosen == null) ...[
                Text(
                  l10n.uploadDropTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.uploadDropHint,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              ] else ...[
                Text(
                  chosen.name,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _size(context, chosen.sizeBytes),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Text(
                      l10n.uploadOr,
                      style: theme.textTheme.labelLarge,
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton(
                onPressed: busy ? null : onBrowse,
                child: Text(l10n.uploadBrowse),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _size(BuildContext context, int bytes) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    const kb = 1024;
    if (bytes < kb * kb) {
      return l10n.uploadSizeKb((bytes / kb).ceil().toString());
    }
    final mb = NumberFormat('0.#', locale).format(bytes / (kb * kb));
    return l10n.uploadSizeMb(mb);
  }
}

/// The dashed outline of the drop area.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color});

  final Color color;

  static const _dash = AppSpacing.sm;
  static const _gap = AppSpacing.xs;
  static const _stroke = 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke;
    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(AppRadii.lg),
        ),
      );
    for (final metric in outline.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += _dash + _gap) {
        canvas.drawPath(metric.extractPath(d, d + _dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => old.color != color;
}
