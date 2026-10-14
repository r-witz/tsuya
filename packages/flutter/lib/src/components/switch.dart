// A toggle switch, applied at once (DESIGN.md, Switch).
import 'package:flutter/widgets.dart';

import '../foundation/motion.dart';
import '../foundation/pressable.dart';
import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';
import '../material/accent.dart';

/// A toggle switch (DESIGN.md, Switch): a 48 × 28 track, a 24 thumb 2 from the edge, sliding over
/// [TsuyaDuration.fast]. Off: [TsuyaColors.borderStrong] track, [TsuyaColors.thumb] thumb; on: the accent track,
/// [TsuyaColors.onAccent] thumb. Applies at once, with no save step. Named by [label], or by the caller's row
/// (wrapped in its own `MergeSemantics`: a plain [ListItem] does it for its trailing switch) when it is null.
class Switch extends StatelessWidget {
  /// A switch at [value].
  const Switch({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.focusNode,
    this.autofocus = false,
  });

  /// On or off.
  final bool value;

  /// Called with the next value on a press; null disables it.
  final ValueChanged<bool>? onChanged;

  /// Beside the track, [TsuyaSpace.s12] away, in body; when null, the caller's row names it instead (a plain
  /// [ListItem] does), and anywhere else it needs a name from a `Semantics` around it.
  final String? label;

  /// The node to track focus with, when the caller manages one.
  final FocusNode? focusNode;

  /// Focuses it as soon as it is built.
  final bool autofocus;

  static const _width = TsuyaSpace.s48;
  static const _height = TsuyaSpace.s32 - TsuyaSpace.s4;
  static const _thumb = 24.0;

  @override
  Widget build(BuildContext context) {
    final theme = TsuyaTheme.of(context);
    final colors = theme.colors;
    final duration = motionOf(context, TsuyaDuration.fast);
    final track = AnimatedContainer(
      width: _width,
      height: _height,
      padding: const EdgeInsets.all(2),
      duration: duration,
      curve: TsuyaEasing.standard,
      decoration: BoxDecoration(
        color: value ? Accent.of(context) : colors.borderStrong,
        borderRadius: BorderRadius.circular(_height / 2),
      ),
      child: AnimatedAlign(
        alignment: value ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
        duration: duration,
        curve: TsuyaEasing.standard,
        child: Container(
          width: _thumb,
          height: _thumb,
          decoration: BoxDecoration(shape: BoxShape.circle, color: value ? colors.onAccent : colors.thumb),
        ),
      ),
    );
    return Pressable(
      alignment: AlignmentDirectional.centerStart,
      onPressed: onChanged == null ? null : () => onChanged!(!value),
      toggled: value,
      focusNode: focusNode,
      autofocus: autofocus,
      child: label == null
          ? track
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                track,
                const SizedBox(width: TsuyaSpace.s12),
                Flexible(
                  child: Text(label!, style: theme.text(TsuyaType.body).copyWith(color: colors.text)),
                ),
              ],
            ),
    );
  }
}
