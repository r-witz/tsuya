// The screen shell, back to front (DESIGN.md, The material: Surface).
import 'package:flutter/widgets.dart';

import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';
import 'ambient.dart';
import 'grain.dart';

/// Where a [TsuyaSurface] draws its [Grain]. Named apart from the generated [TsuyaGrain] tokens.
enum GrainMode {
  /// Over the background and the ambient background only (the default).
  bg,

  /// Also over the content, for poster-like pages; never put a text input under it.
  all,

  /// No grain.
  off,
}

/// A screen or a region in the right order, back to front: the background, [Ambient] (or [Glow] without an
/// [ambient] image), the [Grain], then [child] (DESIGN.md, Surface). The ambient background scrolls with [child]'s main
/// vertical scroll view.
class TsuyaSurface extends StatefulWidget {
  /// A surface lit by [ambient] (or the neutral [Glow] without one), with [grain] over its background.
  const TsuyaSurface({super.key, this.ambient, this.grain = GrainMode.bg, required this.child});

  /// The leading content's picture; a small thumbnail is enough. Its opacity comes from the nearest `Accent`'s
  /// pair. Without one, [Glow] is drawn instead.
  final ImageProvider? ambient;

  /// Where the grain is drawn.
  final GrainMode grain;

  /// The content.
  final Widget child;

  @override
  State<TsuyaSurface> createState() => _TsuyaSurfaceState();
}

class _TsuyaSurfaceState extends State<TsuyaSurface> {
  double _scrolled = 0;

  bool _onScroll(ScrollNotification notification) {
    if (notification.depth == 0 && notification.metrics.axis == Axis.vertical) {
      final scrolled = notification.metrics.pixels.clamp(0.0, TsuyaAmbient.height);
      if (scrolled != _scrolled) setState(() => _scrolled = scrolled);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final ambient = widget.ambient;
    return ColoredBox(
      color: TsuyaTheme.of(context).colors.bg,
      child: Stack(
        children: [
          Positioned(
            top: -_scrolled,
            left: 0,
            right: 0,
            child: ambient != null ? Ambient(image: ambient) : const Glow(),
          ),
          if (widget.grain != GrainMode.off) const Positioned.fill(child: Grain()),
          NotificationListener<ScrollNotification>(onNotification: _onScroll, child: widget.child),
          if (widget.grain == GrainMode.all) const Positioned.fill(child: IgnorePointer(child: Grain())),
        ],
      ),
    );
  }
}
