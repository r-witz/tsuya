// The ambient background, and the neutral glow that replaces it when no content leads (DESIGN.md, The material:
// Ambient background, Glow).
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../foundation/motion.dart';
import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';
import 'accent.dart';
import 'glass.dart';

// the saturate(s) filter as CSS and SVG define it
const double _saturateS = TsuyaAmbient.saturate;
const _saturate = ColorFilter.matrix([
  0.213 + 0.787 * _saturateS, 0.715 - 0.715 * _saturateS, 0.072 - 0.072 * _saturateS, 0, 0, //
  0.213 - 0.213 * _saturateS, 0.715 + 0.285 * _saturateS, 0.072 - 0.072 * _saturateS, 0, 0, //
  0.213 - 0.213 * _saturateS, 0.715 - 0.715 * _saturateS, 0.072 + 0.928 * _saturateS, 0, 0, //
  0, 0, 0, 1, 0, //
]);

// the vertical fade every variant shares: opaque from the top, fading out from TsuyaAmbient.fade of the height
const _fade = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF000000), Color(0xFF000000), Color(0x00000000)],
  stops: [0, TsuyaAmbient.fade, 1],
);

/// The leading content's picture, lighting the top of its [TsuyaSurface]: scaled, blurred, saturated and
/// faded out, at an opacity from the nearest [Accent]'s pair (or [TsuyaAmbient.safeOpacity] without one). A new
/// [image] cross-fades over [TsuyaDuration.ambient] (instant under reduced motion). Hidden under reduced
/// transparency or high contrast ([GlassScope.reduce]).
class Ambient extends StatelessWidget {
  /// The ambient background of [image], or none.
  const Ambient({super.key, required this.image});

  /// A small thumbnail is enough: this is shown at [ResizeImage] width 128.
  final ImageProvider? image;

  @override
  Widget build(BuildContext context) {
    final image = this.image;
    final theme = TsuyaTheme.of(context);
    final hidden = GlassScope.of(context).reduce || image == null;
    final pair = Accent.pairOf(context);
    final opacity = pair?.ambientOf(theme.brightness) ?? TsuyaAmbient.safeOpacity;
    return IgnorePointer(
      child: SizedBox(
        height: TsuyaAmbient.height,
        width: double.infinity,
        child: AnimatedSwitcher(
          duration: motionOf(context, TsuyaDuration.ambient),
          switchInCurve: TsuyaEasing.standard,
          switchOutCurve: TsuyaEasing.standard,
          child: hidden
              ? const SizedBox.expand()
              : ShaderMask(
                  key: ValueKey(image),
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (rect) => _fade.createShader(rect),
                  child: ClipRect(
                    child: Opacity(
                      opacity: opacity,
                      child: Transform.scale(
                        scale: TsuyaAmbient.scale,
                        child: ImageFiltered(
                          imageFilter: ui.ImageFilter.blur(sigmaX: TsuyaAmbient.blur, sigmaY: TsuyaAmbient.blur),
                          child: ColorFiltered(
                            colorFilter: _saturate,
                            child: Image(
                              image: ResizeImage(image, width: 128),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              gaplessPlayback: true,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

/// The faint neutral glow that stands in for [Ambient] when no content leads (DESIGN.md, Glow):
/// [TsuyaColors.text] at [TsuyaMaterial.glowOpacity], centred at the top, radius [TsuyaGlow.radius] of the width,
/// with the same fade as [Ambient]. Hidden under reduced transparency or high contrast ([GlassScope.reduce]).
class Glow extends StatelessWidget {
  /// The neutral glow.
  const Glow({super.key});

  @override
  Widget build(BuildContext context) {
    if (GlassScope.of(context).reduce) return const SizedBox.shrink();
    final theme = TsuyaTheme.of(context);
    return IgnorePointer(
      child: SizedBox(
        height: TsuyaAmbient.height,
        width: double.infinity,
        child: CustomPaint(painter: _GlowPainter(theme.colors.text, theme.material.glowOpacity), size: Size.infinite),
      ),
    );
  }
}

class _GlowPainter extends CustomPainter {
  _GlowPainter(this.color, this.opacity);

  final Color color;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final glow = Paint()
      ..shader = ui.Gradient.radial(Offset(size.width / 2, 0), size.width * TsuyaGlow.radius, [
        color.withValues(alpha: opacity),
        color.withValues(alpha: 0),
      ]);
    final fade = Paint()
      ..shader = _fade.createShader(rect)
      ..blendMode = BlendMode.dstIn;
    canvas.saveLayer(rect, Paint());
    canvas.drawRect(rect, glow);
    canvas.drawRect(rect, fade);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GlowPainter old) => old.color != color || old.opacity != opacity;
}
