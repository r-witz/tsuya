// A loading placeholder (DESIGN.md, Skeleton).
import 'package:flutter/widgets.dart';

import '../foundation/motion.dart';
import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';

// DESIGN.md, Skeleton: the pulse's cycle, each leg (it alternates).
const _pulseDuration = Duration(milliseconds: 1600);
// DESIGN.md, Skeleton: the pulse's opacity range.
const _pulseMin = 0.5;
const _pulseMax = 1.0;
// DESIGN.md, Skeleton: Skeleton.text's last line, so it reads like a paragraph.
const _lastLineWidth = 0.6;

/// A loading placeholder (DESIGN.md, Skeleton): a block of [TsuyaColors.fillStrong] at the final size of what
/// loads, with the radius of the real element, and a slow opacity pulse that stops under reduced motion. Hidden
/// from screen readers: marking the region that loads as busy is the app's own concern, not the block's.
class Skeleton extends StatelessWidget {
  /// A block [width] by [height] (default: fills its container, one text line tall), [radius] (default
  /// [TsuyaRadius.xs]).
  const Skeleton({super.key, this.width, this.height, this.radius}) : lines = null;

  /// [lines] rows at a text line's height (default 3), the last one at 60 % so it reads like a paragraph.
  const Skeleton.text({super.key, this.lines = 3}) : width = null, height = null, radius = null;

  /// Its width, or null to fill the container (the default).
  final double? width;

  /// Its height, or null for one text line (the ambient [DefaultTextStyle]'s size, at the text scale).
  final double? height;

  /// Its corner radius; default [TsuyaRadius.xs].
  final double? radius;

  /// How many lines, for [Skeleton.text]; null for a plain block.
  final int? lines;

  @override
  Widget build(BuildContext context) {
    if (lines case final lines?) {
      return ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < lines; i++) ...[
              if (i > 0) const SizedBox(height: TsuyaSpace.s8),
              if (i == lines - 1 && lines > 1)
                const FractionallySizedBox(
                  widthFactor: _lastLineWidth,
                  alignment: AlignmentDirectional.centerStart,
                  child: _SkeletonBlock(),
                )
              else
                const _SkeletonBlock(),
            ],
          ],
        ),
      );
    }
    return ExcludeSemantics(
      child: _SkeletonBlock(width: width, height: height, radius: radius),
    );
  }
}

class _SkeletonBlock extends StatefulWidget {
  const _SkeletonBlock({this.width, this.height, this.radius});

  final double? width;
  final double? height;
  final double? radius;

  @override
  State<_SkeletonBlock> createState() => _SkeletonBlockState();
}

class _SkeletonBlockState extends State<_SkeletonBlock> with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(vsync: this, duration: _pulseDuration);
  late final Animation<double> _opacity = CurvedAnimation(
    parent: _pulse,
    curve: Curves.easeInOut,
  ).drive(Tween(begin: _pulseMin, end: _pulseMax));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reducedMotion(context)) {
      _pulse.value = 1; // settles fully opaque, rather than merely pausing mid-pulse
    } else if (!_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = TsuyaTheme.of(context).colors;
    // one text line, 1em: it grows with the text scale like the line it stands for
    final height =
        widget.height ??
        MediaQuery.textScalerOf(context).scale(DefaultTextStyle.of(context).style.fontSize ?? TsuyaType.body.fontSize!);
    return FadeTransition(
      opacity: _opacity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.fillStrong,
          borderRadius: BorderRadius.circular(widget.radius ?? TsuyaRadius.xs),
        ),
        child: SizedBox(width: widget.width ?? double.infinity, height: height),
      ),
    );
  }
}
