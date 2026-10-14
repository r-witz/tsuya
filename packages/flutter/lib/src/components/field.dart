// The frame of every form control (DESIGN.md, Field): label above, the control, then the hint or the
// error below, wired for semantics.
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import '../foundation/labels.dart';
import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';
import 'glyphs.dart';

/// The label above a field or a group (DESIGN.md, Field): [TsuyaType.control] in [TsuyaColors.textMuted]. With
/// [optional], a space and the optional label follow at normal weight, in the same run of text, so a screen reader
/// reads "Email Optional" together rather than two separate texts. A required control marks no visual change here
/// (it is in semantics only, carried by the control itself, not this label).
class FieldLabel extends StatelessWidget {
  /// A label reading [text], with the optional marker appended when [optional].
  const FieldLabel(this.text, {super.key, this.optional = false});

  /// The label text.
  final String text;

  /// Appends the optional marker after a single space, at normal weight.
  final bool optional;

  @override
  Widget build(BuildContext context) {
    final theme = TsuyaTheme.of(context);
    final style = theme.text(TsuyaType.control).copyWith(color: theme.colors.textMuted);
    if (!optional) return Text(text, style: style);
    return Text.rich(
      TextSpan(
        text: text,
        style: style,
        children: [
          TextSpan(
            text: ' ${TsuyaLabels.of(context).optional}',
            style: style.copyWith(fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}

/// The hint or the error under a field (DESIGN.md, Field): [TsuyaType.small], muted for a hint, [TsuyaColors.danger]
/// with a leading alert glyph for an error (replacing the hint).
class FieldMessage extends StatelessWidget {
  /// Shows [text], as an [error] or a plain hint.
  const FieldMessage(this.text, {super.key, this.error = false});

  /// The message text.
  final String text;

  /// Shows the alert glyph and the danger colour instead of a plain muted hint.
  final bool error;

  @override
  Widget build(BuildContext context) {
    final theme = TsuyaTheme.of(context);
    final color = error ? theme.colors.danger : theme.colors.textMuted;
    final style = theme.text(TsuyaType.small).copyWith(color: color);
    if (!error) return Text(text, style: style);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Glyph(TsuyaGlyph.alert, size: TsuyaSize.iconSm, color: color),
        const SizedBox(width: TsuyaSpace.s8),
        Expanded(child: Text(text, style: style)),
      ],
    );
  }
}

/// The frame of every form control (DESIGN.md, Field): [FieldLabel] above, [child], then the [hint] or the [error]
/// below (replacing the hint), read together with [child] by a screen reader. Every tsuya input builds this in
/// (`label:`, `hint:`, `error:`, `optional:`, `required:`); wrap a custom control in it directly.
class Field extends StatelessWidget {
  /// A frame around [child], labelled [label].
  const Field({
    super.key,
    required this.label,
    this.hint,
    this.error,
    this.optional = false,
    this.required = false,
    required this.child,
  });

  /// The label above [child].
  final String label;

  /// Shown under [child] when there is no [error].
  final String? hint;

  /// Shown under [child] instead of [hint], with the alert glyph; also marks [child] invalid in semantics.
  final String? error;

  /// Appends the optional marker to [label].
  final bool optional;

  /// Marks [child] as required in semantics; drawn no differently (not marked visually).
  final bool required;

  /// The control this frame labels.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final message = error ?? hint;
    return MergeSemantics(
      child: Semantics(
        isRequired: required ? true : null,
        validationResult: error != null ? SemanticsValidationResult.invalid : SemanticsValidationResult.none,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FieldLabel(label, optional: optional),
            const SizedBox(height: TsuyaSpace.s8),
            child,
            if (message != null) ...[
              const SizedBox(height: TsuyaSpace.s8),
              FieldMessage(message, error: error != null),
            ],
          ],
        ),
      ),
    );
  }
}
