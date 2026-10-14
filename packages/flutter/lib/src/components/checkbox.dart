// A labelled checkbox, two- or three-state (DESIGN.md, Checkbox).
import 'package:flutter/widgets.dart';

import '../foundation/motion.dart';
import '../foundation/pressable.dart';
import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';
import '../material/accent.dart';

/// A labelled checkbox (DESIGN.md, Checkbox): a 20 box, [TsuyaRadius.xs], a 1.5 px [TsuyaColors.borderStrong]
/// boundary; checked, or (with [tristate]) mixed: accent-filled with a [TsuyaColors.onAccent] mark. The row (the
/// box and [label]) is pressable and at least [TsuyaSize.target] tall.
class Checkbox extends StatelessWidget {
  /// A checkbox at [value], labelled [label].
  const Checkbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.tristate = false,
    this.focusNode,
    this.autofocus = false,
  }) : assert(tristate || value != null, 'value is only null for the mixed state, which needs tristate: true');

  /// Checked, unchecked, or (only with [tristate]) null for mixed.
  final bool? value;

  /// Called with the next value on a press; null disables it.
  final ValueChanged<bool?>? onChanged;

  /// Beside the box, [TsuyaSpace.s12] away.
  final String label;

  /// Allows [value] to be null (a mixed state), which the app sets, as on the web: a press never does. It checks a
  /// mixed checkbox (as the web's `<input type="checkbox">` does), and toggles a checked or an unchecked one.
  final bool tristate;

  /// The node to track focus with, when the caller manages one.
  final FocusNode? focusNode;

  /// Focuses it as soon as it is built.
  final bool autofocus;

  // checked unless it is checked already, so mixed goes to checked, and no press reports null
  bool _next() => !(value ?? false);

  @override
  Widget build(BuildContext context) {
    final theme = TsuyaTheme.of(context);
    final mixed = tristate && value == null;
    return Pressable(
      alignment: AlignmentDirectional.centerStart,
      onPressed: onChanged == null ? null : () => onChanged!(_next()),
      checked: value ?? false,
      mixed: tristate ? mixed : null,
      focusNode: focusNode,
      autofocus: autofocus,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: TsuyaSize.target),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Box(checked: value ?? false, mixed: mixed),
            const SizedBox(width: TsuyaSpace.s12),
            Flexible(
              child: Text(label, style: theme.text(TsuyaType.body).copyWith(color: theme.colors.text)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.checked, required this.mixed});

  final bool checked;
  final bool mixed;

  static const _size = 20.0;

  @override
  Widget build(BuildContext context) {
    final colors = TsuyaTheme.of(context).colors;
    final on = checked || mixed;
    final radius = BorderRadius.circular(TsuyaRadius.xs);
    return AnimatedContainer(
      width: _size,
      height: _size,
      duration: motionOf(context, TsuyaDuration.fast),
      curve: TsuyaEasing.standard,
      decoration: BoxDecoration(color: on ? Accent.of(context) : null, borderRadius: radius),
      foregroundDecoration: on
          ? null
          : BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: colors.borderStrong, width: 1.5, strokeAlign: BorderSide.strokeAlignInside),
            ),
      child: on
          ? CustomPaint(
              painter: _MarkPainter(mixed: mixed, color: colors.onAccent),
            )
          : null,
    );
  }
}

class _MarkPainter extends CustomPainter {
  _MarkPainter({required this.mixed, required this.color});

  final bool mixed;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = mixed
        ? (Path()
            ..moveTo(5, 10)
            ..lineTo(15, 10))
        : (Path()
            ..moveTo(4.5, 10.5)
            ..lineTo(8, 14)
            ..lineTo(15.5, 6));
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.mixed != mixed || old.color != color;
}
