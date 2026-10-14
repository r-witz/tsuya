// The few icons tsuya draws itself, so they match the web exactly (DESIGN.md, Foundations: Icons).
import 'package:flutter/widgets.dart';

/// A shape [Glyph] draws itself, so it is pixel-identical on both platforms. Every other icon is a widget the
/// caller supplies to a component's `icon` slot.
enum TsuyaGlyph {
  /// A checkmark: the ticked option of a [Select] or a [Combobox].
  check,

  /// A single dash: a mixed or indeterminate state.
  minus,

  /// Opens a collapsed panel below its trigger: the [Select] trigger.
  chevronDown,

  /// Points to the next level or screen; mirrors in right-to-left layouts.
  chevronRight,

  /// A screen bar's back button; mirrors in right-to-left layouts.
  back,

  /// Dismisses or empties something: a text field's clear button.
  close,

  /// The links of a narrow top bar, collapsed into a menu.
  menu,

  /// A search field's leading icon.
  search,

  /// A field's error message.
  alert,

  /// An informative [Banner]'s status icon.
  info,

  /// Reveals an obscured field.
  eye,

  /// Hides a revealed field.
  eyeOff,
}

/// A glyph tsuya draws itself (DESIGN.md, Foundations: Icons): a 24×24 shape stroked at 1.8 (scaled with [size]),
/// round caps and joins, in [color] (the ambient [IconTheme] colour by default). [TsuyaGlyph.chevronRight] and
/// [TsuyaGlyph.back] mirror under a right-to-left [Directionality]; every other glyph is symmetric or
/// direction-agnostic.
class Glyph extends StatelessWidget {
  /// Draws [glyph] at [size] (the ambient icon size by default).
  const Glyph(this.glyph, {super.key, this.size, this.color});

  /// Which shape to draw.
  final TsuyaGlyph glyph;

  /// The glyph's square dimension; the ambient [IconTheme]'s size (or 24) by default.
  final double? size;

  /// The stroke colour; the ambient [IconTheme]'s colour by default.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final resolvedSize = size ?? iconTheme.size ?? 24.0;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final mirror = rtl && (glyph == TsuyaGlyph.chevronRight || glyph == TsuyaGlyph.back);
    return SizedBox.square(
      dimension: resolvedSize,
      child: CustomPaint(painter: _GlyphPainter(glyph, color ?? iconTheme.color!, mirror)),
    );
  }
}

Path _eyeOutline() => Path()
  ..moveTo(2.5, 12)
  ..cubicTo(2.5, 12, 6, 5.5, 12, 5.5)
  ..cubicTo(18, 5.5, 21.5, 12, 21.5, 12)
  ..cubicTo(21.5, 12, 18, 18.5, 12, 18.5)
  ..cubicTo(6, 18.5, 2.5, 12, 2.5, 12)
  ..close()
  ..addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 3));

Path _pathFor(TsuyaGlyph glyph) => switch (glyph) {
  TsuyaGlyph.check =>
    Path()
      ..moveTo(5, 12.5)
      ..lineTo(9.5, 17)
      ..lineTo(19, 7.5),
  TsuyaGlyph.minus =>
    Path()
      ..moveTo(6, 12)
      ..lineTo(18, 12),
  TsuyaGlyph.chevronDown =>
    Path()
      ..moveTo(6, 9)
      ..lineTo(12, 15)
      ..lineTo(18, 9),
  TsuyaGlyph.chevronRight =>
    Path()
      ..moveTo(9, 6)
      ..lineTo(15, 12)
      ..lineTo(9, 18),
  TsuyaGlyph.back =>
    Path()
      ..moveTo(15, 6)
      ..lineTo(9, 12)
      ..lineTo(15, 18),
  TsuyaGlyph.close =>
    Path()
      ..moveTo(6, 6)
      ..lineTo(18, 18)
      ..moveTo(18, 6)
      ..lineTo(6, 18),
  TsuyaGlyph.menu =>
    Path()
      ..moveTo(4, 7)
      ..lineTo(20, 7)
      ..moveTo(4, 12)
      ..lineTo(20, 12)
      ..moveTo(4, 17)
      ..lineTo(20, 17),
  TsuyaGlyph.search =>
    Path()
      ..addOval(Rect.fromCircle(center: const Offset(11, 11), radius: 7))
      ..moveTo(20, 20)
      ..lineTo(15.8, 15.8),
  TsuyaGlyph.alert =>
    Path()
      ..addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 9))
      ..moveTo(12, 7.5)
      ..lineTo(12, 12.5)
      ..moveTo(12, 16.5)
      ..lineTo(12, 16.51),
  TsuyaGlyph.info =>
    Path()
      ..addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 9))
      ..moveTo(12, 7.49)
      ..lineTo(12, 7.5)
      ..moveTo(12, 11)
      ..lineTo(12, 16.5),
  TsuyaGlyph.eye => _eyeOutline(),
  TsuyaGlyph.eyeOff =>
    _eyeOutline()
      ..moveTo(4, 4)
      ..lineTo(20, 20),
};

class _GlyphPainter extends CustomPainter {
  _GlyphPainter(this.glyph, this.color, this.mirror);

  final TsuyaGlyph glyph;
  final Color color;
  final bool mirror;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    if (mirror) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }
    canvas.scale(size.width / 24, size.height / 24);
    canvas.drawPath(
      _pathFor(glyph),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GlyphPainter old) => old.glyph != glyph || old.color != color || old.mirror != mirror;
}
