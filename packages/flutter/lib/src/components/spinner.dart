// A wait of unknown length in a small place (DESIGN.md, Progress: Spinner). Built now because Button's
// loading state needs it.
import 'dart:math' as math;

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import '../foundation/labels.dart';
import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';
import '../material/accent.dart';

/// The size of a [Spinner]: [TsuyaSize.iconSm], [TsuyaSize.icon] or [TsuyaSize.iconLg].
enum SpinnerSize {
  /// [TsuyaSize.iconSm].
  sm(TsuyaSize.iconSm),

  /// [TsuyaSize.icon].
  md(TsuyaSize.icon),

  /// [TsuyaSize.iconLg].
  lg(TsuyaSize.iconLg);

  const SpinnerSize(this.size);

  /// The spinner's square dimension.
  final double size;
}

/// A spinner (DESIGN.md, Spinner): a quarter arc in [color] (the accent by default, or a button's own content
/// colour) over its [TsuyaColors.track], turning once every 0.8 s. It keeps turning under reduced motion: its
/// motion is the information. Announced alone as a progress indicator named [label] (the `loading` label by
/// default); wrap it in `ExcludeSemantics` where another control, such as a loading [Button], already announces
/// its own state.
class Spinner extends StatefulWidget {
  /// A turning spinner, [size] square.
  const Spinner({super.key, this.label, this.size = SpinnerSize.md, this.color});

  /// Names the wait; the `loading` label by default.
  final String? label;

  /// The spinner's size.
  final SpinnerSize size;

  /// The arc's colour; the accent by default.
  final Color? color;

  @override
  State<Spinner> createState() => _SpinnerState();
}

class _SpinnerState extends State<Spinner> with SingleTickerProviderStateMixin {
  late final _turn = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat();

  @override
  void dispose() {
    _turn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Accent.of(context);
    return Semantics(
      role: SemanticsRole.loadingSpinner,
      label: widget.label ?? TsuyaLabels.of(context).loading,
      child: SizedBox.square(
        dimension: widget.size.size,
        child: RotationTransition(
          turns: _turn,
          child: CustomPaint(painter: _ArcPainter(color, TsuyaTheme.of(context).colors.track)),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter(this.color, this.rest);

  final Color color;
  final Color rest;

  @override
  void paint(Canvas canvas, Size size) {
    const width = TsuyaState.focusWidth;
    final rect = (Offset.zero & size).deflate(width / 2);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, 2 * math.pi, false, stroke..color = rest);
    canvas.drawArc(rect, -math.pi / 2, math.pi / 2, false, stroke..color = color);
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.color != color || old.rest != rest;
}
