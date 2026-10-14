// The tsuya colour engine: the accent pair of a colour or an image, and the opacity of its ambient background
// (DESIGN.md, The engine). This file follows packages/core/src/engine/color.ts line by line and is tested against
// spec/cases.json, which the build writes from it, so both platforms give the same accent to the hex digit.
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../foundation/tokens.g.dart';
import 'colorspace.dart';

/// The accent of a content for both modes, and the opacity of its ambient background in each.
@immutable
class AccentPair {
  /// A pair; without computed opacities the ambient background uses [TsuyaAmbient.safeOpacity].
  const AccentPair({
    required this.light,
    required this.dark,
    this.seed,
    this.ambientLight = TsuyaAmbient.safeOpacity,
    this.ambientDark = TsuyaAmbient.safeOpacity,
  });

  /// The accent when no content leads and the product has no brand colour: the text colour of each mode.
  static final neutral = AccentPair(light: TsuyaColors.light.accent, dark: TsuyaColors.dark.accent);

  /// The colour the pair comes from as '#RRGGBB', the value to store with a content; null for the neutral pair.
  final String? seed;

  /// The accent in light mode.
  final Color light;

  /// The accent in dark mode.
  final Color dark;

  /// The opacity of the ambient background in light mode.
  final double ambientLight;

  /// The opacity of the ambient background in dark mode.
  final double ambientDark;

  /// The accent for a mode.
  Color of(Brightness brightness) => brightness == Brightness.dark ? dark : light;

  /// The ambient opacity for a mode.
  double ambientOf(Brightness brightness) => brightness == Brightness.dark ? ambientDark : ambientLight;

  @override
  bool operator ==(Object other) =>
      other is AccentPair &&
      other.seed == seed &&
      other.light == light &&
      other.dark == dark &&
      other.ambientLight == ambientLight &&
      other.ambientDark == ambientDark;

  @override
  int get hashCode => Object.hash(seed, light, dark, ambientLight, ambientDark);

  @override
  String toString() =>
      'AccentPair(seed: $seed, light: ${hexOf(light)}, dark: ${hexOf(dark)}, ambient: $ambientLight / $ambientDark)';
}

TsuyaColors _colors(Brightness mode) => mode == Brightness.dark ? TsuyaColors.dark : TsuyaColors.light;
TsuyaMaterial _material(Brightness mode) => mode == Brightness.dark ? TsuyaMaterial.dark : TsuyaMaterial.light;

// ---------------------------------------------------------------- accent of a colour

// The colour of tone l along the unit hue direction (ua, ub) with the largest chroma ≤ c that sRGB can show
String _fit(double l, double c, double ua, double ub) {
  for (var k = 0; k <= 100; k++) {
    final ck = c * (1 - k / 100);
    final rgb = fromLab(Lab(l, ck * ua, ck * ub));
    if (inGamut(rgb)) return toHex(rgb);
  }
  return toHex(fromLab(Lab(l, 0, 0)));
}

String _accentFor(String seed, Brightness mode) {
  final m = _material(mode);
  final colors = _colors(mode);
  final lab = labOfHex(seed);
  final l = math.min(m.accentToneMax, math.max(m.accentToneMin, lab.l));
  final c = chroma(lab.a, lab.b);
  var ua = c > 0 ? lab.a / c : 1.0;
  var ub = c > 0 ? lab.b / c : 0.0;
  final status = [colors.danger, colors.warning, colors.success, colors.info].map((s) => toLab(rgbOf(s))).toList();
  bool farEnough(String hex) {
    final p = labOfHex(hex);
    return status.every((s) => distance(p, s) >= TsuyaAccent.statusDistance);
  }

  final first = _fit(l, c, ua, ub);
  if (farEnough(first)) return first;

  // turn away from the nearest status colour: the sign of the cross product says on which side it is
  final firstLab = labOfHex(first);
  var near = status[0];
  for (final s in status) {
    if (distance(firstLab, s) < distance(firstLab, near)) near = s;
  }
  final sine = ua * near.b - ub * near.a <= 0 ? sin1 : -sin1;
  for (var step = 1; step <= 180; step++) {
    final ra = ua * cos1 - ub * sine;
    ub = ua * sine + ub * cos1;
    ua = ra;
    final out = _fit(l, c, ua, ub);
    if (farEnough(out)) return out;
  }
  return _fit(l, 0, 1, 0);
}

/// The accent pair of a colour, '#RRGGBB' or '#RRGGBBAA' (alpha is ignored): a brand colour, or a seed stored with
/// a content. Throws a [FormatException] on a malformed colour.
AccentPair accentFromColor(String seed) {
  final hex = toHex(parseColor(seed));
  return AccentPair(
    seed: hex,
    light: colorOfHex(_accentFor(hex, Brightness.light)),
    dark: colorOfHex(_accentFor(hex, Brightness.dark)),
  );
}

// ---------------------------------------------------------------- accent of an image

// Box-averages straight RGBA bytes into n × n cells, channels 0..1, colour weighted by alpha
List<Rgb> _sample(Uint8List rgba, int width, int height) {
  final n = TsuyaAccent.sample.toInt();
  final cells = <Rgb>[];
  for (var oy = 0; oy < n; oy++) {
    final y0 = (oy * height) ~/ n;
    final y1 = math.max(((oy + 1) * height) ~/ n, y0 + 1);
    for (var ox = 0; ox < n; ox++) {
      final x0 = (ox * width) ~/ n;
      final x1 = math.max(((ox + 1) * width) ~/ n, x0 + 1);
      var sr = 0;
      var sg = 0;
      var sb = 0;
      var sa = 0;
      for (var y = y0; y < y1; y++) {
        for (var x = x0; x < x1; x++) {
          final i = (y * width + x) * 4;
          final alpha = rgba[i + 3];
          sr += rgba[i] * alpha;
          sg += rgba[i + 1] * alpha;
          sb += rgba[i + 2] * alpha;
          sa += alpha;
        }
      }
      final count = (y1 - y0) * (x1 - x0);
      cells.add(sa == 0 ? const Rgb(0, 0, 0, 0) : Rgb(sr / sa / 255, sg / sa / 255, sb / sa / 255, sa / count / 255));
    }
  }
  return cells;
}

// The chroma-weighted mean colour of the best window of three neighbouring hue bins, or null
String? _seedOf(List<Rgb> cells) {
  final bins = TsuyaAccent.bins.toInt();
  final width = 360 / bins;
  final weight = List<double>.filled(bins, 0);
  final kept = <(int, double, Lab)>[];
  for (final cell in cells) {
    if (cell.a < 0.5) continue;
    final lab = toLab(cell);
    final c = chroma(lab.a, lab.b);
    if (c < TsuyaAccent.minChroma || lab.l < TsuyaAccent.minTone || lab.l > TsuyaAccent.maxTone) continue;
    var degrees = atan2(lab.b, lab.a) * degreesPerRadian;
    if (degrees < 0) degrees += 360;
    final bin = (degrees / width).floor() % bins;
    weight[bin] += c;
    kept.add((bin, c, lab));
  }
  if (kept.isEmpty) return null;

  // a window of three bins, so a colour split by a bin boundary still counts whole
  double w(int i) => weight[(i + bins) % bins];
  var best = 0;
  var bestScore = -1.0;
  for (var i = 0; i < bins; i++) {
    final score = w(i - 1) + w(i) + w(i + 1);
    if (score > bestScore || (score == bestScore && w(i) > w(best))) {
      best = i;
      bestScore = score;
    }
  }
  var sw = 0.0;
  var sl = 0.0;
  var sa = 0.0;
  var sb = 0.0;
  for (final (bin, c, lab) in kept) {
    if (bin != best && bin != (best + 1) % bins && bin != (best + bins - 1) % bins) continue;
    sw += c;
    sl += lab.l * c;
    sa += lab.a * c;
    sb += lab.b * c;
  }
  return toHex(fromLab(Lab(sl / sw, sa / sw, sb / sw)));
}

// ---------------------------------------------------------------- ambient opacity

// The saturate matrix of CSS and SVG filters
Rgb _saturate(Rgb c) {
  const s = TsuyaAmbient.saturate;
  double clamp(double v) => math.min(1.0, math.max(0.0, v));
  return Rgb(
    clamp((0.213 + 0.787 * s) * c.r + (0.715 - 0.715 * s) * c.g + (0.072 - 0.072 * s) * c.b),
    clamp((0.213 - 0.213 * s) * c.r + (0.715 + 0.285 * s) * c.g + (0.072 - 0.072 * s) * c.b),
    clamp((0.213 - 0.213 * s) * c.r + (0.715 - 0.715 * s) * c.g + (0.072 + 0.928 * s) * c.b),
  );
}

// A cell as it is and saturated, in sRGB and in linear light: platforms saturate in either space
List<Rgb> _variantsOf(Rgb px) => [px, _saturate(px), _saturate(px.map(lin)).map(gam)];

// The highest opacity, in steps of 0.01 and at most the mode's maximum, at which every cell over bg stays within
// the luminance cap. The range is halved, and the cells within the cap at a failing opacity are dropped from the next
// steps: a cell within the cap at some opacity is taken to be within it below too. Luminance is convex in the
// opacity, so that holds for any cell in dark mode, where bg is within the cap; in light mode a cell could dip below
// the cap and come back, which the tokens rule out (tests/core/color.test.ts).
double _ambientOpacity(List<Rgb> cells, List<List<Rgb>?> opaqueVariants, Brightness mode) {
  final base = rgbOf(_colors(mode).bg);
  final cap = _material(mode).ambientCap;
  final max = _material(mode).ambientMaxOpacity;
  bool within(Rgb px, double opacity) {
    final k = 1 - opacity;
    final y =
        0.2126 * lin(px.r * opacity + base.r * k) +
        0.7152 * lin(px.g * opacity + base.g * k) +
        0.0722 * lin(px.b * opacity + base.b * k);
    return mode == Brightness.dark ? y <= cap : y >= cap;
  }

  var low = 0;
  var high = roundHalfUp(max * 100);
  var risky = <Rgb>[];
  for (var i = 0; i < cells.length; i++) {
    for (final variant in opaqueVariants[i] ?? _variantsOf(over(cells[i], base))) {
      if (!within(variant, high / 100)) risky.add(variant);
    }
  }
  if (risky.isEmpty) return high / 100;
  while (high - low > 1) {
    final mid = (low + high) ~/ 2;
    final failing = risky.where((px) => !within(px, mid / 100)).toList();
    if (failing.isEmpty) {
      low = mid;
    } else {
      high = mid;
      risky = failing;
    }
  }
  return low / 100;
}

/// The accent pair and ambient opacities of an image, from its straight (not premultiplied) RGBA bytes; a thumbnail
/// is enough. With no colourful cell, [AccentPair.seed] is null and the pair is the neutral one. Throws a
/// [RangeError] if the bytes do not hold the image.
///
/// It takes some tens of milliseconds: compute it once, when the content is added, off the UI thread (as
/// `accentFromImage` does), and store it with the content.
AccentPair accentFromPixels(Uint8List rgba, int width, int height) {
  if (width < 1 || height < 1) throw RangeError('accentFromPixels: $width × $height is not an image size');
  if (rgba.length < width * height * 4) {
    throw RangeError('accentFromPixels: ${rgba.length} bytes do not hold a $width × $height RGBA image');
  }
  final cells = _sample(rgba, width, height);
  final seed = _seedOf(cells);
  final pair = seed == null ? AccentPair.neutral : accentFromColor(seed);
  // an opaque cell looks the same over either background: its variants are computed once for both modes
  final opaqueVariants = [for (final cell in cells) cell.a == 1 ? _variantsOf(cell) : null];
  return AccentPair(
    seed: pair.seed,
    light: pair.light,
    dark: pair.dark,
    ambientLight: _ambientOpacity(cells, opaqueVariants, Brightness.light),
    ambientDark: _ambientOpacity(cells, opaqueVariants, Brightness.dark),
  );
}
