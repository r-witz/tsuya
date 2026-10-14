// A labelled action (DESIGN.md, Button).
import 'package:flutter/widgets.dart';

import '../foundation/labels.dart';
import '../foundation/pressable.dart';
import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';
import '../material/accent.dart';
import 'control_body.dart';
import 'spinner.dart';

/// What a [Button] is for.
enum ButtonKind {
  /// The one accent-filled action of a screen.
  primary,

  /// [TsuyaColors.fill] with a hairline and [TsuyaColors.text].
  secondary,

  /// Text only, [TsuyaColors.fill] on hover.
  ghost,

  /// A destructive action, in [TsuyaColors.danger]. Never the accent.
  danger,

  /// Control glass, over artwork.
  glass,
}

/// The height of a [Button]: [sm] ([TsuyaSize.controlSm]), [md] ([TsuyaSize.controlMd], default) or [lg]
/// ([TsuyaSize.controlLg]).
enum ButtonSize {
  /// [TsuyaSize.controlSm], [TsuyaType.control] label.
  sm(TsuyaSize.controlSm, TsuyaSpace.s12, TsuyaType.control, TsuyaSize.iconSm),

  /// [TsuyaSize.controlMd], [TsuyaType.button] label. The default.
  md(TsuyaSize.controlMd, TsuyaSpace.s20, TsuyaType.button, TsuyaSize.icon),

  /// [TsuyaSize.controlLg], [TsuyaType.button] label.
  lg(TsuyaSize.controlLg, TsuyaSpace.s32, TsuyaType.button, TsuyaSize.iconLg);

  const ButtonSize(this.height, this.padding, this.textStyle, this.iconSize);

  /// The button's height; a pill of this height (radius = height / 2).
  final double height;

  /// The side padding.
  final double padding;

  /// The label's type style.
  final TextStyle textStyle;

  /// The icon's (or the loading spinner's) size.
  final double iconSize;
}

/// A labelled action (DESIGN.md, Button): a pill [ButtonSize.height] tall that grows with the text (up to
/// [block]'s full width). [loading] replaces [icon] with a spinner (or shows it before the label when there is no
/// icon), keeps the button's width — the label ellipsizes if it must — and ignores presses.
class Button extends StatelessWidget {
  /// A button labelled [label].
  const Button({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.kind = ButtonKind.secondary,
    this.size = ButtonSize.md,
    this.block = false,
    this.loading = false,
    this.focusNode,
    this.autofocus = false,
  });

  /// The button's one-line label; ellipsized if it must.
  final String label;

  /// Called on a press; null, or while [loading], disables it.
  final VoidCallback? onPressed;

  /// Before the label, [TsuyaSpace.s8] away; replaced by a spinner while [loading].
  final Widget? icon;

  /// What the button is for.
  final ButtonKind kind;

  /// The button's height.
  final ButtonSize size;

  /// Grows to fill the width it is given.
  final bool block;

  /// Shows a spinner, keeps the width, and ignores presses.
  final bool loading;

  /// The node to track focus with, when the caller manages one.
  final FocusNode? focusNode;

  /// Focuses it as soon as it is built.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final theme = TsuyaTheme.of(context);
    final colors = theme.colors;
    final (fill, content, border) = switch (kind) {
      ButtonKind.primary => (Accent.of(context), colors.onAccent, null),
      ButtonKind.secondary => (colors.fill, colors.text, colors.border),
      ButtonKind.ghost || ButtonKind.glass => (null, colors.text, null),
      ButtonKind.danger => (colors.danger, colors.onStatus, null),
    };
    final radius = BorderRadius.circular(size.height / 2);

    Widget row(Widget? iconSlot) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (iconSlot != null) ...[
          IconTheme(
            data: IconThemeData(color: content, size: size.iconSize),
            child: ExcludeSemantics(child: iconSlot),
          ),
          const SizedBox(width: TsuyaSpace.s8),
        ],
        Flexible(
          child: Text(
            label,
            style: theme.text(size.textStyle).copyWith(color: content),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    var inner = row(icon);
    if (loading) {
      final spinnerSize = switch (size) {
        ButtonSize.sm => SpinnerSize.sm,
        ButtonSize.md => SpinnerSize.md,
        ButtonSize.lg => SpinnerSize.lg,
      };
      inner = Stack(
        alignment: Alignment.center,
        children: [
          Visibility(visible: false, maintainState: true, maintainAnimation: true, maintainSize: true, child: inner),
          Positioned.fill(
            child: row(Spinner(size: spinnerSize, color: content)),
          ),
          Semantics(label: TsuyaLabels.of(context).loading, child: const SizedBox.shrink()),
        ],
      );
    }

    return Pressable(
      onPressed: loading ? () {} : onPressed,
      feedback: loading ? PressFeedback.none : PressFeedback.shrink,
      quiet: kind == ButtonKind.ghost,
      borderRadius: radius,
      focusNode: focusNode,
      autofocus: autofocus,
      child: SizedBox(
        width: block ? double.infinity : null,
        child: ControlBody(
          fill: fill,
          border: border,
          radius: radius,
          glass: kind == ButtonKind.glass,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: size.height),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.padding),
              child: block ? Center(child: inner) : inner,
            ),
          ),
        ),
      ),
    );
  }
}
