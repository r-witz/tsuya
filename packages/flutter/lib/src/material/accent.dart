// The accent region (DESIGN.md, The material: Accent).
import 'package:flutter/widgets.dart';

import '../engine/color.dart';
import '../foundation/motion.dart';
import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';

/// A region in the colours of its content: everything inside takes [pair]'s colour for the nearest mode, including
/// inside a nested [TsuyaTheme] of the other mode. A change of [pair] cross-fades over [TsuyaDuration.accent]
/// (instant under reduced motion).
class Accent extends StatelessWidget {
  /// A region taking [pair] as its accent.
  const Accent({super.key, required this.pair, required this.child});

  /// The accent for both modes, and the opacity of the ambient background it lights.
  final AccentPair pair;

  /// The region.
  final Widget child;

  /// The accent of the nearest [Accent] region for the current mode, or the neutral accent
  /// ([TsuyaColors.accent]) outside any region.
  static Color of(BuildContext context) {
    final theme = TsuyaTheme.of(context);
    final scope = context.dependOnInheritedWidgetOfExactType<_AccentScope>();
    if (scope == null) return theme.colors.accent;
    // a region of the other mode nested inside this one takes the pair's colour for its own mode
    return scope.brightness == theme.brightness ? scope.color : scope.pair.of(theme.brightness);
  }

  /// The pair of the nearest [Accent] region, or null outside any region.
  static AccentPair? pairOf(BuildContext context) => context.dependOnInheritedWidgetOfExactType<_AccentScope>()?.pair;

  @override
  Widget build(BuildContext context) {
    final brightness = TsuyaTheme.of(context).brightness;
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: pair.of(brightness)),
      duration: motionOf(context, TsuyaDuration.accent),
      curve: TsuyaEasing.standard,
      builder: (context, color, child) =>
          _AccentScope(pair: pair, brightness: brightness, color: color!, child: child!),
      child: child,
    );
  }
}

class _AccentScope extends InheritedTheme {
  const _AccentScope({required this.pair, required this.brightness, required this.color, required super.child});

  final AccentPair pair;
  final Brightness brightness;
  final Color color;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      _AccentScope(pair: pair, brightness: brightness, color: color, child: child);

  @override
  bool updateShouldNotify(_AccentScope oldWidget) =>
      color != oldWidget.color || pair != oldWidget.pair || brightness != oldWidget.brightness;
}
