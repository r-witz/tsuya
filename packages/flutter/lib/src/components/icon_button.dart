// An icon-only action or a toggle (DESIGN.md, IconButton).
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../foundation/pressable.dart';
import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';
import '../material/accent.dart';
import 'badge.dart';
import 'control_body.dart';
import 'tooltip.dart';

/// What an [IconButton] looks like.
enum IconButtonKind {
  /// [TsuyaColors.fill] with a hairline. The default.
  filled,

  /// No fill, the icon in [TsuyaColors.textMuted]; [TsuyaColors.fill] on hover.
  plain,

  /// The accent, for the icon-only primary action of a group (like play).
  accent,

  /// Control glass, over artwork.
  glass,
}

/// The round size of an [IconButton]: a preset ([sm], [md], [lg]) or [IconButtonSize.custom] for the large primary
/// action (40 to 72).
@immutable
class IconButtonSize {
  const IconButtonSize._(this.diameter, this.iconSize);

  /// [TsuyaSize.controlSm] (32), icon 16.
  static const sm = IconButtonSize._(TsuyaSize.controlSm, 16.0);

  /// [TsuyaSize.controlMd] (44), icon 20. The default.
  static const md = IconButtonSize._(TsuyaSize.controlMd, 20.0);

  /// [TsuyaSize.controlLg] (56), icon 24.
  static const lg = IconButtonSize._(TsuyaSize.controlLg, 24.0);

  /// A custom [diameter] from 40 to 72, its icon 38 % of it, at least 18.
  factory IconButtonSize.custom(double diameter) {
    assert(diameter >= 40 && diameter <= 72, 'a custom IconButtonSize is 40 to 72 (got $diameter)');
    return IconButtonSize._(diameter, math.max(18.0, diameter * 0.38));
  }

  /// The button's diameter.
  final double diameter;

  /// The icon's size.
  final double iconSize;
}

/// An icon-only action, round (DESIGN.md, IconButton). [label] names it for screen readers. With [toggled] it is a
/// toggle, accent-filled when on.
class IconButton extends StatelessWidget {
  /// An icon button showing [icon], named [label].
  const IconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.kind = IconButtonKind.filled,
    this.size = IconButtonSize.md,
    this.toggled,
    this.badge,
    this.expanded,
    this.tooltip = true,
    this.focusNode,
    this.autofocus = false,
  });

  /// The icon drawn (never read itself; [label] names the button).
  final Widget icon;

  /// The accessible name; shown as a tooltip on fine pointers (and at once on keyboard focus), unless [tooltip] is
  /// false.
  final String label;

  /// Called on a press; null disables it.
  final VoidCallback? onPressed;

  /// What the button looks like.
  final IconButtonKind kind;

  /// The button's size.
  final IconButtonSize size;

  /// Makes it a toggle; accent-filled, [TsuyaColors.onAccent] icon, when true.
  final bool? toggled;

  /// Pinned on the corner; fold its meaning into [label].
  final Widget? badge;

  /// Marks it as open or closed, for a button that discloses a panel (a narrow menu, say).
  final bool? expanded;

  /// Shows [label] as a tooltip on fine pointers; set false to turn it off.
  final bool tooltip;

  /// The node to track focus with, when the caller manages one.
  final FocusNode? focusNode;

  /// Focuses it as soon as it is built.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final colors = TsuyaTheme.of(context).colors;
    final on = toggled ?? false;
    final (fill, content, border) = switch (kind) {
      _ when on || kind == IconButtonKind.accent => (Accent.of(context), colors.onAccent, null),
      IconButtonKind.filled => (colors.fill, colors.text, colors.border),
      IconButtonKind.plain => (null, colors.textMuted, null),
      IconButtonKind.glass || IconButtonKind.accent => (null, colors.text, null),
    };
    final radius = BorderRadius.circular(size.diameter / 2);
    final button = Pressable(
      onPressed: onPressed,
      label: label,
      toggled: toggled,
      expanded: expanded,
      borderRadius: radius,
      quiet: kind == IconButtonKind.plain && !on,
      tooltip: tooltip ? label : null,
      focusNode: focusNode,
      autofocus: autofocus,
      child: pinBadge(
        context,
        ControlBody(
          fill: fill,
          border: border,
          radius: radius,
          glass: kind == IconButtonKind.glass && !on,
          child: SizedBox.square(
            dimension: size.diameter,
            child: Center(
              child: IconTheme(
                data: IconThemeData(color: content, size: size.iconSize),
                child: ExcludeSemantics(child: icon),
              ),
            ),
          ),
        ),
        badge,
      ),
    );
    return tooltip ? Tooltip(message: label, describe: false, child: button) : button;
  }
}
