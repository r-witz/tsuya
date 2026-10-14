// "Any accent of the band": the accents the contrast checks take at their worst, at both ends of a mode's
// tone band. The 15° sample, the corners that tint glass the most, and the two colours that bound the
// luminance of any accent the engine gives. This file follows packages/core/src/engine/band.ts line by line.
import 'colorspace.dart';

// cos of 0°, 15° … 90°, written out so every platform gets the same directions
const List<double> _cos = [1, 0.9659258262890683, 0.8660254037844387, 0.7071067811865476, 0.5, 0.25881904510252074, 0];

// unit hue direction of k × 15°, k in 0..23
(double, double) _direction(int k) {
  final j = k % 6;
  var a = _cos[j];
  var b = _cos[6 - j];
  for (var q = 0; q < k ~/ 6; q++) {
    (a, b) = (-b, a);
  }
  return (a, b);
}

// the colour of tone l along a hue direction with the most chroma the engine can show
Rgb _mostSaturated(double l, (double, double) direction) {
  final (ua, ub) = direction;
  Rgb at(double c) => fromLab(Lab(l, c * ua, c * ub));
  var low = 200.0;
  while (low > 0 && !inGamut(at(low))) {
    low -= 0.5;
  }
  var high = low + 0.5;
  for (var i = 0; i < 24; i++) {
    final mid = (low + high) / 2;
    if (inGamut(at(mid))) {
      low = mid;
    } else {
      high = mid;
    }
  }
  return at(low);
}

/// "Any accent of the band": at both ends of the mode's tone band, the grey and the most saturated colour every 15°
/// of hue, as hex like the engine gives them (50 colours).
List<String> bandAccents(double toneMin, double toneMax) => [
  for (final l in [toneMin, toneMax]) ...[
    toHex(fromLab(Lab(l, 0, 0))),
    for (var k = 0; k < 24; k++) toHex(_mostSaturated(l, _direction(k))),
  ],
];

const List<double> _weights = [0.2126, 0.7152, 0.0722];

// the luminance of L* (the band is above L* 8, where L* is a cube root)
double _toneLuminance(double l) {
  final f = (l + 16) / 116;
  return f * f * f;
}

/// The accents of the band that tint glass the most. Glass mixes its tint in sRGB, not in linear light, so at a
/// given L* the worst tint is not on a 15° step but at a corner of the RGB cube's slice of that luminance: two
/// channels at 0 or 1, the third solved. At both ends of the band, and the cube's own corners inside it.
List<String> bandCorners(double toneMin, double toneMax) {
  final corners = <String>[];
  for (final l in [toneMin, toneMax]) {
    final y = _toneLuminance(l);
    for (final (k, i, j) in const [(0, 1, 2), (1, 0, 2), (2, 0, 1)]) {
      for (final p in const [0, 1]) {
        for (final q in const [0, 1]) {
          final free = (y - _weights[i] * p - _weights[j] * q) / _weights[k];
          if (free < 0 || free > 1) continue;
          final linear = [0.0, 0.0, 0.0];
          linear[i] = p.toDouble();
          linear[j] = q.toDouble();
          linear[k] = free;
          corners.add(toHex(Rgb(gam(linear[0]), gam(linear[1]), gam(linear[2]))));
        }
      }
    }
  }
  for (var n = 0; n < 8; n++) {
    final corner = Rgb(n & 4 != 0 ? 1 : 0, n & 2 != 0 ? 1 : 0, n & 1 != 0 ? 1 : 0);
    final l = toLab(corner).l;
    if (l >= toneMin && l <= toneMax) corners.add(toHex(corner));
  }
  return corners;
}

/// The lightest and the darkest colour the engine can give in the band. It gives an accent at a tone of the band,
/// then rounds each channel to a byte, which moves its luminance: by most where a channel is steep, and the 15° steps
/// do not find where. A byte h comes from any channel value in [h − ½, h + ½) / 255, out to the gamut's tolerance at
/// 0 and 1; luminance grows with each channel. So no accent is lighter than the colour of most luminance whose
/// darkest preimage is at most the top of the band, nor darker than the reverse. The slack covers the rounding of the
/// Lab matrices: their luminance rows differ by less than 1e-4. On an opaque ground, the contrast of an accent only
/// depends on its luminance: these two bound every check of an accent but glass.
(String, String) bandExtremes(double toneMin, double toneMax) {
  final [wr, wg, wb] = _weights;
  double edge(int k) => lin(k == 0 ? -1e-4 : (k == 256 ? 1 + 1e-4 : (k - 0.5) / 255));
  final at = [for (var h = 0; h < 256; h++) lin(h / 255)];
  final below = [for (var h = 0; h < 256; h++) edge(h)];
  final above = [for (var h = 0; h < 256; h++) edge(h + 1)];
  final top = _toneLuminance(toneMax) + 1e-4;
  final bottom = _toneLuminance(toneMin) - 1e-4;
  var lightest = '';
  var darkest = '';
  var most = double.negativeInfinity;
  var least = double.infinity;
  for (var r = 0; r < 256; r++) {
    for (var g = 0; g < 256; g++) {
      final lr = wr * at[r] + wg * at[g];
      // the highest blue byte whose darkest preimage is not above the top
      final room = top - wr * below[r] - wg * below[g];
      if (wb * below[0] <= room) {
        var lo = 0;
        var hi = 255;
        while (lo < hi) {
          final mid = (lo + hi + 1) >> 1;
          if (wb * below[mid] <= room) {
            lo = mid;
          } else {
            hi = mid - 1;
          }
        }
        final y = lr + wb * at[lo];
        if (y > most) {
          most = y;
          lightest = toHex(Rgb(r / 255, g / 255, lo / 255));
        }
      }
      // the lowest blue byte whose lightest preimage is not below the bottom
      final need = bottom - wr * above[r] - wg * above[g];
      if (wb * above[255] >= need) {
        var lo = 0;
        var hi = 255;
        while (lo < hi) {
          final mid = (lo + hi) >> 1;
          if (wb * above[mid] >= need) {
            hi = mid;
          } else {
            lo = mid + 1;
          }
        }
        final y = lr + wb * at[lo];
        if (y < least) {
          least = y;
          darkest = toHex(Rgb(r / 255, g / 255, lo / 255));
        }
      }
    }
  }
  return (lightest, darkest);
}
