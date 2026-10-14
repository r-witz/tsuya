// The keyboard focus ring, for custom shapes (DESIGN.md, Foundations: States).
import 'package:flutter/widgets.dart';

import '../material/accent.dart';
import 'theme.dart';
import 'tokens.g.dart';

/// The focus ring of DESIGN.md: [TsuyaState.focusWidth] in the accent, [TsuyaState.focusOffset] away from [child],
/// the gap filled with the background so the ring keeps 3:1 on any surface. Follows [borderRadius], so it fits a
/// pill, a circle or a square alike. Painted only while [focused]; [Pressable] shows it in keyboard highlight mode
/// only. Used by [Pressable], the slider thumb and segments.
class FocusRing extends StatelessWidget {
  /// A ring around [child], shown when [focused].
  const FocusRing({super.key, required this.focused, this.borderRadius = BorderRadius.zero, required this.child});

  /// Whether the ring is painted.
  final bool focused;

  /// The shape the ring follows.
  final BorderRadius borderRadius;

  /// What the ring surrounds.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!focused) return child;
    final colors = TsuyaTheme.of(context).colors;
    return CustomPaint(foregroundPainter: _FocusRingPainter(borderRadius, Accent.of(context), colors.bg), child: child);
  }
}

class _FocusRingPainter extends CustomPainter {
  _FocusRingPainter(this.radius, this.ring, this.gap);

  final BorderRadius radius;
  final Color ring;
  final Color gap;

  @override
  void paint(Canvas canvas, Size size) {
    final shape = radius.toRRect(Offset.zero & size);
    const offset = TsuyaState.focusOffset;
    const width = TsuyaState.focusWidth;
    final stroke = Paint()..style = PaintingStyle.stroke;
    canvas.drawRRect(
      shape.inflate(offset / 2),
      stroke
        ..color = gap
        ..strokeWidth = offset,
    );
    canvas.drawRRect(
      shape.inflate(offset + width / 2),
      stroke
        ..color = ring
        ..strokeWidth = width,
    );
  }

  @override
  bool shouldRepaint(_FocusRingPainter old) => old.radius != radius || old.ring != ring || old.gap != gap;
}
