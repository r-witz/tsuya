// The mode of a region and its tokens (DESIGN.md: Theme and mode, Theming).
import 'package:flutter/widgets.dart';

import '../engine/check.dart';
import 'tokens.g.dart';

/// Which mode a region shows: the system's, or one forced.
enum TsuyaMode {
  /// Light or dark as the platform is.
  system,

  /// Always light.
  light,

  /// Always dark.
  dark,
}

/// The tokens of one mode, with what the app overrides.
@immutable
class TsuyaThemeData {
  /// A mode's tokens. An app that changes [colors] owns their contrast: see [check].
  const TsuyaThemeData({
    required this.brightness,
    required this.colors,
    required this.shadows,
    required this.material,
    this.typeface,
  });

  /// The light mode of the tokens.
  static const light = TsuyaThemeData(
    brightness: Brightness.light,
    colors: TsuyaColors.light,
    shadows: TsuyaShadows.light,
    material: TsuyaMaterial.light,
  );

  /// The dark mode of the tokens.
  static const dark = TsuyaThemeData(
    brightness: Brightness.dark,
    colors: TsuyaColors.dark,
    shadows: TsuyaShadows.dark,
    material: TsuyaMaterial.dark,
  );

  /// Light or dark.
  final Brightness brightness;

  /// The colours of the mode.
  final TsuyaColors colors;

  /// The shadows of the mode.
  final TsuyaShadows shadows;

  /// The accent tone band, the ambient limits and the glow of the mode.
  final TsuyaMaterial material;

  /// The font family that replaces Inter, or null for Inter. Geist Mono stays.
  final String? typeface;

  /// Whether this is the dark mode.
  bool get isDark => brightness == Brightness.dark;

  /// [style], a [TsuyaType] style, in this theme's typeface.
  TextStyle text(TextStyle style) {
    final family = typeface;
    if (family == null || style.fontFamily != TsuyaType.body.fontFamily) return style;
    // a new style: copyWith keeps the package of a TsuyaType style, which would make the family packages/tsuya/…
    return TextStyle(
      inherit: style.inherit,
      color: style.color,
      backgroundColor: style.backgroundColor,
      fontSize: style.fontSize,
      fontWeight: style.fontWeight,
      fontStyle: style.fontStyle,
      letterSpacing: style.letterSpacing,
      wordSpacing: style.wordSpacing,
      textBaseline: style.textBaseline,
      height: style.height,
      leadingDistribution: style.leadingDistribution,
      locale: style.locale,
      foreground: style.foreground,
      background: style.background,
      shadows: style.shadows,
      fontFeatures: style.fontFeatures,
      fontVariations: style.fontVariations,
      decoration: style.decoration,
      decorationColor: style.decorationColor,
      decorationStyle: style.decorationStyle,
      decorationThickness: style.decorationThickness,
      debugLabel: style.debugLabel,
      fontFamily: family,
      overflow: style.overflow,
    );
  }

  /// The contrast checks this mode fails, each with its worst case: none for the tokens. Run it on the
  /// colours you change, with the glass constants you use.
  List<ContrastResult> check({double glassOpacity = TsuyaGlass.opacity, double glassTint = TsuyaGlass.tint}) => [
    for (final result in checkMode(colors, material, glassOpacity: glassOpacity, glassTint: glassTint))
      if (result.ratio < result.min) result,
  ];

  /// This mode with some values replaced.
  TsuyaThemeData copyWith({TsuyaColors? colors, TsuyaShadows? shadows, TsuyaMaterial? material, String? typeface}) =>
      TsuyaThemeData(
        brightness: brightness,
        colors: colors ?? this.colors,
        shadows: shadows ?? this.shadows,
        material: material ?? this.material,
        typeface: typeface ?? this.typeface,
      );

  @override
  bool operator ==(Object other) =>
      other is TsuyaThemeData &&
      other.brightness == brightness &&
      other.colors == colors &&
      other.shadows == shadows &&
      other.material == material &&
      other.typeface == typeface;

  @override
  int get hashCode => Object.hash(brightness, colors, shadows, material, typeface);
}

/// The mode of a region and everything inside it, with its default text style and icon colour. Nest one to show a
/// region in the other mode: what it does not set comes from the theme above.
class TsuyaTheme extends StatelessWidget {
  /// A theme; at the root, [mode] defaults to the system's.
  const TsuyaTheme({super.key, this.mode, this.light, this.dark, this.typeface, required this.child});

  /// The mode of the region, or null for the mode of the theme above (the system's at the root).
  final TsuyaMode? mode;

  /// The light mode's tokens, when the app changes them.
  final TsuyaThemeData? light;

  /// The dark mode's tokens, when the app changes them.
  final TsuyaThemeData? dark;

  /// The font family that replaces Inter in both modes.
  final String? typeface;

  /// The region.
  final Widget child;

  /// The tokens of the nearest mode; light when there is no [TsuyaTheme] above.
  static TsuyaThemeData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ThemeScope>()?.data ?? TsuyaThemeData.light;

  @override
  Widget build(BuildContext context) {
    final parent = context.dependOnInheritedWidgetOfExactType<_ThemeScope>();
    TsuyaThemeData resolve(TsuyaThemeData? own, TsuyaThemeData? inherited, TsuyaThemeData tokens) {
      final data = own ?? inherited ?? tokens;
      return typeface == null ? data : data.copyWith(typeface: typeface);
    }

    final light = resolve(this.light, parent?.light, TsuyaThemeData.light);
    final dark = resolve(this.dark, parent?.dark, TsuyaThemeData.dark);
    final mode = this.mode ?? parent?.mode ?? TsuyaMode.system;
    final brightness = switch (mode) {
      TsuyaMode.system => MediaQuery.maybePlatformBrightnessOf(context) ?? Brightness.light,
      TsuyaMode.light => Brightness.light,
      TsuyaMode.dark => Brightness.dark,
    };
    final data = brightness == Brightness.dark ? dark : light;
    return _ThemeScope(
      mode: mode,
      light: light,
      dark: dark,
      data: data,
      child: DefaultTextStyle(
        style: data.text(TsuyaType.body).copyWith(color: data.colors.text),
        child: IconTheme(
          data: IconThemeData(color: data.colors.text, size: TsuyaSize.icon),
          child: child,
        ),
      ),
    );
  }
}

// An InheritedTheme (not a plain InheritedWidget) so a portal can carry the mode into an overlay built elsewhere
// in the tree (foundation/portal.dart, TsuyaPortal.wrap).
class _ThemeScope extends InheritedTheme {
  const _ThemeScope({
    required this.mode,
    required this.light,
    required this.dark,
    required this.data,
    required super.child,
  });

  final TsuyaMode mode;
  final TsuyaThemeData light;
  final TsuyaThemeData dark;
  final TsuyaThemeData data;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      _ThemeScope(mode: mode, light: light, dark: dark, data: data, child: child);

  @override
  bool updateShouldNotify(_ThemeScope oldWidget) =>
      data != oldWidget.data || light != oldWidget.light || dark != oldWidget.dark || mode != oldWidget.mode;
}
