// Theme nesting and inheritance (mode, typeface), TsuyaThemeData.check(), TsuyaColors.of (DESIGN.md, Theme
// and mode; Theming).
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

TsuyaThemeData? _theme;
Color? _textStyleColor;
Widget _probe() => Builder(
  builder: (context) {
    _theme = TsuyaTheme.of(context);
    _textStyleColor = DefaultTextStyle.of(context).style.color;
    return const SizedBox();
  },
);

void main() {
  testWidgets('an explicit system mode follows the platform brightness', (tester) async {
    await tester.pumpWidget(
      host(
        TsuyaTheme(mode: TsuyaMode.system, child: _probe()),
        platform: Brightness.dark,
      ),
    );
    expect(_theme!.colors, TsuyaColors.dark);
  });

  testWidgets('a nested theme forces its own mode; the DefaultTextStyle colour follows it', (tester) async {
    await tester.pumpWidget(host(TsuyaTheme(mode: TsuyaMode.dark, child: _probe())));
    expect(_theme!.colors, TsuyaColors.dark);
    expect(_textStyleColor, TsuyaColors.dark.text);
  });

  testWidgets('text() sets a style in the typeface as the app registered it, and keeps the rest', (tester) async {
    await tester.pumpWidget(host(TsuyaTheme(typeface: 'Custom', child: _probe())));
    const title = TsuyaType.titleM;
    final style = _theme!.text(title.copyWith(color: TsuyaColors.light.text));
    expect(style.fontFamily, 'Custom');
    expect(
      [style.fontSize, style.fontWeight, style.height, style.letterSpacing, style.leadingDistribution, style.color],
      [
        title.fontSize,
        title.fontWeight,
        title.height,
        title.letterSpacing,
        title.leadingDistribution,
        TsuyaColors.light.text,
      ],
    );
    expect(_theme!.text(TsuyaType.mono), TsuyaType.mono, reason: 'Geist Mono stays');
  });

  testWidgets('a nested theme inherits the typeface it does not set itself', (tester) async {
    await tester.pumpWidget(
      host(
        TsuyaTheme(
          typeface: 'Custom',
          child: TsuyaTheme(mode: TsuyaMode.dark, child: _probe()),
        ),
      ),
    );
    expect(_theme!.typeface, 'Custom');
    expect(_theme!.colors, TsuyaColors.dark, reason: 'the inner theme still forces its own mode');
  });

  testWidgets('a nested theme overrides only the typeface it sets, keeping the parent mode', (tester) async {
    await tester.pumpWidget(
      host(
        TsuyaTheme(
          mode: TsuyaMode.dark,
          child: TsuyaTheme(typeface: 'Inner', child: _probe()),
        ),
      ),
    );
    expect(_theme!.typeface, 'Inner');
    expect(_theme!.colors, TsuyaColors.dark);
  });

  testWidgets('TsuyaColors.of reads the nearest theme', (tester) async {
    late TsuyaColors colors;
    await tester.pumpWidget(
      host(
        TsuyaTheme(
          mode: TsuyaMode.dark,
          child: Builder(
            builder: (context) {
              colors = TsuyaColors.of(context);
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(colors, TsuyaColors.dark);
  });

  test('check() finds no failure in the generated tokens', () {
    expect(TsuyaThemeData.light.check(), isEmpty);
    expect(TsuyaThemeData.dark.check(), isEmpty);
  });

  test('check() catches a border-strong weakened below 3:1', () {
    final weak = TsuyaColors(
      bg: TsuyaColors.light.bg,
      surface: TsuyaColors.light.surface,
      text: TsuyaColors.light.text,
      textMuted: TsuyaColors.light.textMuted,
      border: TsuyaColors.light.border,
      borderStrong: const Color(0x100A0A0C), // far below the 3:1 mark needs
      fill: TsuyaColors.light.fill,
      fillStrong: TsuyaColors.light.fillStrong,
      fillSelected: TsuyaColors.light.fillSelected,
      track: TsuyaColors.light.track,
      thumb: TsuyaColors.light.thumb,
      accent: TsuyaColors.light.accent,
      onAccent: TsuyaColors.light.onAccent,
      danger: TsuyaColors.light.danger,
      warning: TsuyaColors.light.warning,
      success: TsuyaColors.light.success,
      info: TsuyaColors.light.info,
      onStatus: TsuyaColors.light.onStatus,
      scrim: TsuyaColors.light.scrim,
      glass: TsuyaColors.light.glass,
      glassShade: TsuyaColors.light.glassShade,
      glassControl: TsuyaColors.light.glassControl,
    );
    final failures = TsuyaThemeData.light.copyWith(colors: weak).check();
    expect(failures, isNotEmpty);
    expect(failures.any((f) => f.check.contains('border-strong')), isTrue);
  });
}
