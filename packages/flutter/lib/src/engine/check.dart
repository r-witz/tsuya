// The contrast guarantees a theme must hold in one mode, checked at their worst: any accent of the mode's
// tone band, glass tinted by any of them over white or black content, the ambient background at its cap. This file
// follows packages/core/src/engine/check.ts line by line, and spec/cases.json holds the results both give for the
// tokens.
import 'package:flutter/foundation.dart';

import '../foundation/tokens.g.dart';
import 'band.dart';
import 'colorspace.dart';

/// The worst case found for one check.
@immutable
class ContrastResult {
  /// A result: the check's name, the lowest ratio found, the ratio it needs, and where the lowest one was found.
  const ContrastResult({required this.check, required this.ratio, required this.min, required this.worst});

  /// What is checked, such as 'textMuted on any glass'.
  final String check;

  /// The lowest WCAG contrast ratio found.
  final double ratio;

  /// The ratio the check needs.
  final double min;

  /// Where the lowest ratio was found, or an empty string when there is a single case.
  final String worst;

  @override
  String toString() => '$check: ${ratio.toStringAsFixed(2)}:1, needs $min:1${worst.isEmpty ? '' : ' ($worst)'}';
}

const double _text = 4.5;
const double _mark = 3;
// on-accent on the accent has to reach more than text elsewhere
const double _onAccent = 5.3;
const Rgb _white = Rgb(1, 1, 1);
const Rgb _black = Rgb(0, 0, 0);

Rgb _mix(Rgb p, Rgb q, double share) =>
    Rgb(p.r * (1 - share) + q.r * share, p.g * (1 - share) + q.g * share, p.b * (1 - share) + q.b * share);

String _describe(Rgb rgb) => '${toHex(rgb)} (L* ${toLab(rgb).l.toStringAsFixed(1)})';

/// Every check for one mode, each with its worst case: [colors] and [material] of the mode, and the
/// glass constants.
List<ContrastResult> checkMode(
  TsuyaColors colors,
  TsuyaMaterial material, {
  double glassOpacity = TsuyaGlass.opacity,
  double glassTint = TsuyaGlass.tint,
}) {
  final results = <String, ContrastResult>{};
  void need(String check, Rgb fg, Rgb back, double min, [String worst = '']) {
    final ratio = contrastOf(over(fg, back), back);
    final known = results[check];
    if (known == null || ratio < known.ratio) {
      results[check] = ContrastResult(check: check, ratio: ratio, min: min, worst: worst);
    }
  }

  final bg = rgbOf(colors.bg);
  final grounds = [('bg', bg), ('surface', over(rgbOf(colors.surface), bg))];
  final cap = gam(material.ambientCap);
  final ambient = Rgb(cap, cap, cap); // a grey whose luminance is the cap
  final band = bandAccents(material.accentToneMin, material.accentToneMax).map(parseColor).toList();
  final tints = [...band, ...bandCorners(material.accentToneMin, material.accentToneMax).map(parseColor)];
  // the neutral accent fills controls like any accent, but never tints glass: a neutral pair gives neutral glass
  final (lightest, darkest) = bandExtremes(material.accentToneMin, material.accentToneMax);
  final accents = [rgbOf(colors.accent), ...band, parseColor(lightest), parseColor(darkest)];
  final fill = rgbOf(colors.fill);
  final glass = rgbOf(colors.glass);

  for (final (fgName, fg) in [('text', rgbOf(colors.text)), ('textMuted', rgbOf(colors.textMuted))]) {
    for (final (name, ground) in grounds) {
      final filled = over(fill, ground);
      need('$fgName on $name', fg, ground, _text);
      need('$fgName on fill', fg, filled, _text, 'over $name');
      need('$fgName on fill-strong', fg, over(rgbOf(colors.fillStrong), ground), _text, 'over $name');
      need('$fgName on fill-selected over fill', fg, over(rgbOf(colors.fillSelected), filled), _text, 'over $name');
    }
    for (final tint in <Rgb?>[null, ...tints]) {
      final tinted = tint == null ? glass : _mix(glass, tint, glassTint);
      for (final (content, under) in const [('white', _white), ('black', _black)]) {
        final where = tint == null ? 'neutral' : 'tinted by ${_describe(tint)}';
        need(
          '$fgName on any glass',
          fg,
          over(Rgb(tinted.r, tinted.g, tinted.b, glassOpacity), under),
          _text,
          '$where, over $content',
        );
      }
    }
    need('$fgName on the ambient at its cap', fg, ambient, _text);
  }

  for (final (status, color) in [
    ('danger', colors.danger),
    ('warning', colors.warning),
    ('success', colors.success),
    ('info', colors.info),
  ]) {
    for (final (name, ground) in grounds) {
      need('$status on $name', rgbOf(color), ground, _text);
    }
    need('on-status on $status', rgbOf(colors.onStatus), rgbOf(color), _text);
  }

  for (final (name, ground) in grounds) {
    final filled = over(fill, ground);
    need('border-strong on $name', rgbOf(colors.borderStrong), ground, _mark);
    need('border-strong over fill', rgbOf(colors.borderStrong), filled, _mark, 'over $name');
    need('thumb on border-strong', rgbOf(colors.thumb), over(rgbOf(colors.borderStrong), ground), _mark, 'over $name');
  }
  for (final accent in accents) {
    final worst = _describe(accent);
    need('on-accent on any accent', rgbOf(colors.onAccent), accent, _onAccent, worst);
    need('on-accent thumb on any accent', rgbOf(colors.onAccent), accent, _mark, worst);
    for (final (name, ground) in grounds) {
      need('any accent on $name', accent, ground, _mark, worst);
    }
    need('any accent on the ambient at its cap', accent, ambient, _mark, worst);
  }
  need(
    'text (icons) on control glass over the ambient at its cap',
    rgbOf(colors.text),
    over(rgbOf(colors.glassControl), ambient),
    _mark,
  );

  return results.values.toList();
}

/// Whether bg looks like the mode it is given for: a light mode needs a light background.
bool looksLike(TsuyaColors colors, Brightness mode) => luminance(rgbOf(colors.bg)) > 0.5 == (mode == Brightness.light);
