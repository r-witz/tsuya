// The secondary button that opens a floating panel (DESIGN.md, Menu, Popover). Shared by
// MenuButton and Popover, not exported.
import 'package:flutter/widgets.dart';

import '../foundation/pressable.dart';
import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';
import 'control_body.dart';

/// A secondary-style button, with an optional [icon] before its [label], that reports whether its panel is
/// [open] as `expanded`. A press that closed the panel (an outside press closes it as the pointer goes down) does
/// not open it again as the pointer comes up: the button toggles.
class OpenerButton extends StatefulWidget {
  /// An opener labelled [label].
  const OpenerButton({
    super.key,
    this.icon,
    required this.label,
    required this.open,
    required this.onPressed,
    required this.focusNode,
    this.autofocus = false,
  });

  /// Before the label; never read itself.
  final Widget? icon;

  /// The button's one-line label.
  final String label;

  /// Whether the panel it opens is showing.
  final bool open;

  /// Called by a press that opens the panel.
  final VoidCallback onPressed;

  /// Tracks the button's focus.
  final FocusNode focusNode;

  /// Focuses it as soon as it is built.
  final bool autofocus;

  @override
  State<OpenerButton> createState() => _OpenerButtonState();
}

class _OpenerButtonState extends State<OpenerButton> {
  bool _openAtPointerDown = false;

  @override
  Widget build(BuildContext context) {
    final theme = TsuyaTheme.of(context);
    final colors = theme.colors;
    const radius = BorderRadius.all(Radius.circular(TsuyaRadius.sm));
    return Listener(
      onPointerDown: (_) => _openAtPointerDown = widget.open,
      child: Pressable(
        onPressed: () {
          if (_openAtPointerDown) {
            _openAtPointerDown = false;
            return;
          }
          widget.onPressed();
        },
        expanded: widget.open,
        borderRadius: radius,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        child: ControlBody(
          fill: colors.fill,
          border: colors.border,
          radius: radius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: TsuyaSpace.s20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: TsuyaSize.controlMd),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    ExcludeSemantics(
                      child: IconTheme(
                        data: IconThemeData(color: colors.text, size: TsuyaSize.icon),
                        child: widget.icon!,
                      ),
                    ),
                    const SizedBox(width: TsuyaSpace.s8),
                  ],
                  Flexible(
                    child: Text(
                      widget.label,
                      style: theme.text(TsuyaType.button).copyWith(color: colors.text),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
