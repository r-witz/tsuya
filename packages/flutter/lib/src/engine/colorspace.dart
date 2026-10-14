// Portable maths, sRGB, CIE L*a*b* and WCAG contrast for the colour engine. Channels are 0..1.
//
// This file follows packages/core/src/engine/colorspace.ts line by line. For the same result on every platform to the
// last bit, the maths uses only +, −, ×, ÷ and sqrt, which IEEE 754 rounds the same way everywhere: ln, exp, pow and
// atan2 are written out here.
import 'dart:math' as math;
import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';

/// π as a literal.
const double pi = 3.141592653589793;
const double _ln2 = 0.6931471805599453;
const double _sqrt2 = 1.4142135623730951;
const double _sqrt1_2 = 0.7071067811865476;

/// Degrees in a radian, 180 / π.
const double degreesPerRadian = 57.29577951308232;

/// cos 1°.
const double cos1 = 0.9998476951563913;

/// sin 1°.
const double sin1 = 0.01745240643728351;

// 1 / n, computed once: IEEE division gives the same bits everywhere, and a product is cheaper than a quotient
final List<double> _inverse = List<double>.generate(26, (n) => 1 / n);

// ln x for x > 0: x = m · 2^k with m in [√½, √2), then ln m = 2 atanh z with |z| = |m − 1| / (m + 1) < 0.172
double _ln(double x) {
  var k = 0;
  while (x >= _sqrt2) {
    x *= 0.5;
    k++;
  }
  while (x < _sqrt1_2) {
    x *= 2;
    k--;
  }
  final z = (x - 1) / (x + 1);
  final z2 = z * z;
  var term = z;
  var sum = 0.0;
  for (var n = 1; n <= 25; n += 2) {
    sum += term * _inverse[n];
    term *= z2;
  }
  return 2 * sum + k.toDouble() * _ln2;
}

// e^x: x = k ln 2 + r with |r| ≤ ln 2 / 2, then e^r by its series and 2^k by halving or doubling
double _exp(double x) {
  final k = (x / _ln2 + 0.5).floor();
  final r = x - k.toDouble() * _ln2;
  var term = 1.0;
  var sum = 1.0;
  for (var n = 1; n <= 17; n++) {
    term *= r * _inverse[n];
    sum += term;
  }
  for (var i = 0; i < k; i++) {
    sum *= 2;
  }
  for (var i = 0; i > k; i--) {
    sum *= 0.5;
  }
  return sum;
}

double _pow(double x, double y) => x <= 0 ? 0 : _exp(y * _ln(x));

// atan t: folded into [0, 1], halved twice (atan t = 2 atan(t / (1 + √(1 + t²)))), then its series
double _atan(double t) {
  final negative = t < 0;
  if (negative) t = -t;
  final inverted = t > 1;
  if (inverted) t = 1 / t;
  t = t / (1 + math.sqrt(1 + t * t));
  t = t / (1 + math.sqrt(1 + t * t));
  final t2 = t * t;
  var term = t;
  var sum = 0.0;
  for (var n = 1; n <= 31; n += 2) {
    sum += (n % 4 == 1 ? term : -term) / n;
    term *= t2;
  }
  var angle = 4 * sum;
  if (inverted) angle = pi / 2 - angle;
  return negative ? -angle : angle;
}

/// The angle of (x, y) in radians, −π..π.
double atan2(double y, double x) {
  if (x > 0) return _atan(y / x);
  if (x < 0) return y >= 0 ? _atan(y / x) + pi : _atan(y / x) - pi;
  if (y > 0) return pi / 2;
  if (y < 0) return -pi / 2;
  return 0;
}

/// [x] rounded to an integer, halves up. Dart's round() and JavaScript's Math.round differ on negative halves.
int roundHalfUp(double x) => (x + 0.5).floor();

// ---------------------------------------------------------------- sRGB, CIE L*a*b*, contrast (channels 0..1)

/// An sRGB channel in linear light.
double lin(double c) => c <= 0.04045 ? c / 12.92 : _pow((c + 0.055) / 1.055, 2.4);

/// A linear-light channel in sRGB.
double gam(double c) => c <= 0.0031308 ? 12.92 * c : 1.055 * _pow(c, 1 / 2.4) - 0.055;

/// A colour as sRGB channels 0..1, alpha included.
@immutable
class Rgb {
  /// A colour from its channels, opaque unless [a] says otherwise.
  const Rgb(this.r, this.g, this.b, [this.a = 1]);

  /// Red, 0..1.
  final double r;

  /// Green, 0..1.
  final double g;

  /// Blue, 0..1.
  final double b;

  /// Alpha, 0..1.
  final double a;

  /// The opaque colour with each channel mapped through [f].
  Rgb map(double Function(double) f) => Rgb(f(r), f(g), f(b));
}

/// A colour in CIE L*a*b* (D65).
@immutable
class Lab {
  /// A colour from its coordinates.
  const Lab(this.l, this.a, this.b);

  /// Lightness L*, 0..100.
  final double l;

  /// a*, green to red.
  final double a;

  /// b*, blue to yellow.
  final double b;
}

final RegExp _hex = RegExp(r'^#?([0-9a-f]{6}|[0-9a-f]{8})$', caseSensitive: false);

/// '#RRGGBB' or '#RRGGBBAA' (the hash is optional) as channels 0..1. Throws a [FormatException] otherwise.
Rgb parseColor(String hex) {
  final n = _hex.firstMatch(hex)?.group(1);
  if (n == null) throw FormatException('Not a #RRGGBB or #RRGGBBAA colour', hex);
  double channel(int i) => int.parse(n.substring(i, i + 2), radix: 16) / 255;
  return Rgb(channel(0), channel(2), channel(4), n.length == 8 ? channel(6) : 1);
}

int _byte(double v) => roundHalfUp(math.min(1.0, math.max(0.0, v)) * 255);

/// '#RRGGBB' of a colour, each channel clamped to 0..1 and rounded half up; alpha is ignored.
String toHex(Rgb rgb) =>
    '#${[rgb.r, rgb.g, rgb.b].map((v) => _byte(v).toRadixString(16).padLeft(2, '0')).join().toUpperCase()}';

/// The channels of a [Color], alpha included.
Rgb rgbOf(Color color) {
  final argb = color.toARGB32();
  return Rgb(((argb >> 16) & 0xFF) / 255, ((argb >> 8) & 0xFF) / 255, (argb & 0xFF) / 255, ((argb >> 24) & 0xFF) / 255);
}

/// The opaque [Color] of '#RRGGBB', as [toHex] writes it.
Color colorOfHex(String hex) => Color(0xFF000000 | int.parse(hex.substring(1), radix: 16));

/// '#RRGGBB' of a [Color]; alpha is ignored.
String hexOf(Color color) => '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

/// A translucent colour seen over an opaque one.
Rgb over(Rgb top, Rgb bottom) => Rgb(
  top.r * top.a + bottom.r * (1 - top.a),
  top.g * top.a + bottom.g * (1 - top.a),
  top.b * top.a + bottom.b * (1 - top.a),
);

/// WCAG relative luminance.
double luminance(Rgb c) => 0.2126 * lin(c.r) + 0.7152 * lin(c.g) + 0.0722 * lin(c.b);

/// WCAG contrast of two opaque colours.
double contrastOf(Rgb x, Rgb y) {
  final p = luminance(x);
  final q = luminance(y);
  return p > q ? (p + 0.05) / (q + 0.05) : (q + 0.05) / (p + 0.05);
}

/// WCAG contrast of two colours; a translucent [foreground] is seen over the [background].
double contrast(Color foreground, Color background) {
  final back = rgbOf(background);
  return contrastOf(over(rgbOf(foreground), back), back);
}

/// CIE L*a*b* of an sRGB colour.
Lab toLab(Rgb c) {
  final lr = lin(c.r);
  final lg = lin(c.g);
  final lb = lin(c.b);
  final x = (0.4124 * lr + 0.3576 * lg + 0.1805 * lb) / 0.95047;
  final y = 0.2126 * lr + 0.7152 * lg + 0.0722 * lb;
  final z = (0.0193 * lr + 0.1192 * lg + 0.9505 * lb) / 1.08883;
  double f(double t) => t > 216 / 24389 ? _pow(t, 1 / 3) : (24389 / 27 * t + 16) / 116;
  final fx = f(x);
  final fy = f(y);
  final fz = f(z);
  return Lab(116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz));
}

/// sRGB of a CIE L*a*b* colour; channels may fall outside 0..1 when it is out of gamut.
Rgb fromLab(Lab lab) {
  final fy = (lab.l + 16) / 116;
  final fx = fy + lab.a / 500;
  final fz = fy - lab.b / 200;
  double inv(double t) => t * t * t > 216 / 24389 ? t * t * t : (116 * t - 16) / (24389 / 27);
  final x = inv(fx) * 0.95047;
  final y = inv(fy);
  final z = inv(fz) * 1.08883;
  return Rgb(
    gam(3.2406 * x - 1.5372 * y - 0.4986 * z),
    gam(-0.9689 * x + 1.8758 * y + 0.0415 * z),
    gam(0.0557 * x - 0.204 * y + 1.057 * z),
  );
}

/// CIE chroma of (a*, b*).
double chroma(double a, double b) => math.sqrt(a * a + b * b);

/// CIE76 distance.
double distance(Lab p, Lab q) =>
    math.sqrt((p.l - q.l) * (p.l - q.l) + (p.a - q.a) * (p.a - q.a) + (p.b - q.b) * (p.b - q.b));

/// Whether sRGB can show the colour.
bool inGamut(Rgb c) => [c.r, c.g, c.b].every((v) => v >= -1e-4 && v <= 1 + 1e-4);

/// CIE L*a*b* of '#RRGGBB'.
Lab labOfHex(String hex) => toLab(parseColor(hex));
