// A person's avatar (DESIGN.md, Avatar).
import 'package:flutter/widgets.dart';

import '../engine/colorspace.dart';
import '../foundation/cover_image.dart';
import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';
import 'badge.dart';

// DESIGN.md, Avatar: the initials are white on a gradient that keeps 4.5:1 for white text.
const _white = Color(0xFFFFFFFF);

/// A person's avatar (DESIGN.md, Avatar): round, [size] by default 40: the [image], or [initials] (weight 600, 36 %
/// of [size]) on [TsuyaColors.fill] in [TsuyaColors.textMuted], or on a gradient of [colors] (from the top-start
/// corner at 135°) in white when white keeps 4.5:1 on the darker of the two (checked; falls back to
/// [TsuyaColors.fill]). Decorative unless it has [label].
class Avatar extends StatefulWidget {
  /// An avatar [size] wide.
  const Avatar({super.key, this.image, this.initials, this.size = 40, this.colors, this.label, this.badge});

  /// The photo; [initials] show while it is null, loading or failed.
  final ImageProvider? image;

  /// Shown while there is no photo, it is loading, or it failed.
  final String? initials;

  /// Its width and height, in px. Default 40.
  final double size;

  /// A gradient of the person's colours; dropped when white would not reach 4.5:1 on the darker one.
  final (Color, Color)? colors;

  /// The accessible name; decorative when left out.
  final String? label;

  /// Pinned on the corner; fold its meaning into [label].
  final Widget? badge;

  @override
  State<Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  bool _failed = false;

  @override
  void didUpdateWidget(Avatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // a new image gets its own chance to load, even one that previously failed
    if (oldWidget.image != widget.image) _failed = false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = TsuyaTheme.of(context);
    final colors = theme.colors;
    final showPhoto = widget.image != null && !_failed;
    final gradient = _passingGradient(widget.colors);

    final Widget inner;
    if (showPhoto) {
      inner = Image(
        image: coverDecoded(context, widget.image!, width: widget.size, height: widget.size),
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (context, error, stack) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _failed = true);
          });
          return const SizedBox.shrink();
        },
      );
    } else if (widget.initials case final initials?) {
      inner = Center(
        child: Text(
          initials,
          // a mark in a fixed-size circle: it does not follow the text scale, which would clip it
          textScaler: TextScaler.noScaling,
          style: theme.text(
            TextStyle(
              package: 'tsuya',
              fontFamily: TsuyaFont.sans,
              fontWeight: FontWeight.w600,
              fontSize: widget.size * 0.36,
              color: gradient == null ? colors.textMuted : _white,
            ),
          ),
        ),
      );
    } else {
      inner = const SizedBox.shrink();
    }

    final circle = ClipOval(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: gradient == null ? colors.fill : null,
          gradient: gradient == null
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [gradient.$1, gradient.$2],
                ),
        ),
        child: SizedBox(width: widget.size, height: widget.size, child: inner),
      ),
    );
    final pinned = pinBadge(context, circle, widget.badge);

    if (widget.label == null) return ExcludeSemantics(child: pinned);
    return Semantics(
      image: true,
      label: widget.label,
      child: ExcludeSemantics(child: pinned),
    );
  }
}

/// [pair], unless white would not reach 4.5:1 on its darker colour.
(Color, Color)? _passingGradient((Color, Color)? pair) {
  if (pair == null) return null;
  final (a, b) = pair;
  final darker = luminance(rgbOf(a)) <= luminance(rgbOf(b)) ? a : b;
  final passes = contrastOf(const Rgb(1, 1, 1), rgbOf(darker)) >= 4.5;
  return passes ? pair : null;
}
