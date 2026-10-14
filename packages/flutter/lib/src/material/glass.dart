// Glass, for surfaces that float above content: bars, menus, sheets, toasts (DESIGN.md, The material: Glass).
// Each glass reads its own backdrop: never wrap more than one in a shared backdrop filter.
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../engine/color.dart';
import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';
import 'accent.dart';

/// How glass looks inside a region: tinted by the accent by default, or [neutral] for settings, forms and grids;
/// [reduce] makes every glass opaque and unblurred (reduced transparency; high contrast forces it too). A scope
/// changes only the fields it sets; the rest comes from the scope above.
class GlassScope extends StatelessWidget {
  /// A scope changing [neutral] and/or [reduce] for [child]'s subtree.
  const GlassScope({super.key, this.neutral, this.reduce, required this.child});

  /// Glass without the accent tint. Null keeps the scope above (false at the root).
  final bool? neutral;

  /// Opaque, unblurred glass (reduced transparency). Null keeps the scope above (false at the root).
  final bool? reduce;

  /// The region.
  final Widget child;

  /// The resolved scope at [context]: [reduce] is also true under high contrast, whatever the nearest [GlassScope]
  /// says.
  static ({bool neutral, bool reduce}) of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_GlassScope>();
    final highContrast = MediaQuery.maybeHighContrastOf(context) ?? false;
    return (neutral: scope?.neutral ?? false, reduce: (scope?.reduce ?? false) || highContrast);
  }

  @override
  Widget build(BuildContext context) {
    final parent = context.dependOnInheritedWidgetOfExactType<_GlassScope>();
    return _GlassScope(
      neutral: neutral ?? parent?.neutral ?? false,
      reduce: reduce ?? parent?.reduce ?? false,
      child: child,
    );
  }
}

class _GlassScope extends InheritedTheme {
  const _GlassScope({required this.neutral, required this.reduce, required super.child});

  final bool neutral;
  final bool reduce;

  @override
  Widget wrap(BuildContext context, Widget child) => _GlassScope(neutral: neutral, reduce: reduce, child: child);

  @override
  bool updateShouldNotify(_GlassScope oldWidget) => neutral != oldWidget.neutral || reduce != oldWidget.reduce;
}

/// The shadow drawn outside a [Glass], if any: none for glass that sits flush (menu items, a panel's own
/// background), [md] for bars and toasts, [lg] for menus and sheets.
enum GlassShadow {
  /// No outer shadow.
  none,

  /// [TsuyaShadows.md]: floating bars, toasts.
  md,

  /// [TsuyaShadows.lg]: menus, sheets.
  lg,
}

/// Glass: a backdrop blur with a tinted, translucent fill and a shaded bottom edge, only above content. Falls
/// back to an opaque, unblurred fill under reduced transparency or high contrast ([GlassScope.reduce]).
class Glass extends StatelessWidget {
  /// Glass around [child], clipped and blurred to [borderRadius], with an outer [shadow].
  const Glass({super.key, required this.child, this.borderRadius = BorderRadius.zero, this.shadow = GlassShadow.none});

  /// The content, drawn over the glass fill.
  final Widget child;

  /// The shape glass is clipped to, and the shadow follows.
  final BorderRadius borderRadius;

  /// The outer shadow, if any.
  final GlassShadow shadow;

  /// The glass fill at [context] before its opacity: [TsuyaColors.glass] mixed with the accent at
  /// [TsuyaGlass.tint] (0 when [GlassScope.of] is neutral, outside any [Accent] region, or inside one whose pair
  /// is [AccentPair.neutral]).
  static Color fillOf(BuildContext context) {
    final colors = TsuyaTheme.of(context).colors;
    final pair = Accent.pairOf(context);
    final neutralPair = pair == null || pair == AccentPair.neutral;
    final tint = GlassScope.of(context).neutral || neutralPair ? 0.0 : TsuyaGlass.tint;
    return Color.lerp(colors.glass, Accent.of(context), tint)!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = TsuyaTheme.of(context);
    final fill = fillOf(context);
    final reduce = GlassScope.of(context).reduce;
    Widget glass = CustomPaint(
      foregroundPainter: _EdgePainter(borderRadius, theme.colors.glassShade),
      child: DecoratedBox(
        decoration: BoxDecoration(color: reduce ? fill : fill.withValues(alpha: TsuyaGlass.opacity)),
        child: child,
      ),
    );
    if (!reduce) {
      glass = BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: TsuyaGlass.blur, sigmaY: TsuyaGlass.blur),
        child: glass,
      );
    }
    glass = ClipRRect(borderRadius: borderRadius, child: glass);
    final shadows = switch (shadow) {
      GlassShadow.none => null,
      GlassShadow.md => theme.shadows.md,
      GlassShadow.lg => theme.shadows.lg,
    };
    if (shadows == null) return glass;
    return CustomPaint(painter: _OuterShadowPainter(borderRadius, shadows), child: glass);
  }
}

/// Control glass: a light veil for small controls over artwork, not a surface of its own. Falls back to
/// [TsuyaColors.surface] under reduced transparency or high contrast.
class ControlGlass extends StatelessWidget {
  /// Control glass around [child], clipped to [borderRadius].
  const ControlGlass({super.key, required this.child, this.borderRadius = BorderRadius.zero});

  /// The content, drawn over the veil.
  final Widget child;

  /// The shape control glass is clipped to.
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = TsuyaTheme.of(context).colors;
    if (GlassScope.of(context).reduce) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: ColoredBox(color: colors.surface, child: child),
      );
    }
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: TsuyaGlass.controlBlur, sigmaY: TsuyaGlass.controlBlur),
        child: ColoredBox(color: colors.glassControl, child: child),
      ),
    );
  }
}

// The shaded 1 px bottom edge (DESIGN.md, Glass)
class _EdgePainter extends CustomPainter {
  _EdgePainter(this.radius, this.shade);

  final BorderRadius radius;
  final Color shade;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRRect(radius.toRRect(Offset.zero & size));
    final line = Paint()
      ..strokeWidth = 1
      ..color = shade;
    canvas.drawLine(Offset(0, size.height - 0.5), Offset(size.width, size.height - 0.5), line);
  }

  @override
  bool shouldRepaint(_EdgePainter old) => old.radius != radius || old.shade != shade;
}

// A shadow drawn outside the shape only, as CSS does, so it does not show through translucent glass
class _OuterShadowPainter extends CustomPainter {
  _OuterShadowPainter(this.radius, this.shadows);

  final BorderRadius radius;
  final List<BoxShadow> shadows;

  @override
  void paint(Canvas canvas, Size size) {
    final shape = radius.toRRect(Offset.zero & size);
    final outside = Path.combine(
      PathOperation.difference,
      Path()..addRect((Offset.zero & size).inflate(400)),
      Path()..addRRect(shape),
    );
    canvas.save();
    canvas.clipPath(outside);
    for (final shadow in shadows) {
      canvas.drawRRect(shape.shift(shadow.offset).inflate(shadow.spreadRadius), shadow.toPaint());
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_OuterShadowPainter old) => old.radius != radius || old.shadows != shadows;
}
