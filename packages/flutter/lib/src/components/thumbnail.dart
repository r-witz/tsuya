// The picture of a content (DESIGN.md, Thumbnail).
import 'package:flutter/widgets.dart';

import '../foundation/cover_image.dart';
import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';

/// The shape of a [Thumbnail]: [square] (the default), [portrait] (2:3) or [wide] (16:9).
enum ThumbnailRatio {
  /// 1:1.
  square,

  /// 2:3.
  portrait,

  /// 16:9.
  wide,
}

/// The picture of a content (DESIGN.md, Thumbnail): [ThumbnailRatio.square] by default, [ThumbnailRatio.portrait] or
/// [ThumbnailRatio.wide], with a radius that grows with [size]. A [TsuyaColors.fill] placeholder, with an optional
/// [placeholder] icon, shows while [image] loads, fails, or is null. Decorative unless it has [label]. [image] is
/// decoded at the thumbnail's own display size.
class Thumbnail extends StatelessWidget {
  /// A thumbnail of [image], [size] wide.
  const Thumbnail({
    super.key,
    this.image,
    this.size = 48,
    this.ratio = ThumbnailRatio.square,
    this.label,
    this.placeholder,
  });

  /// The picture; the [placeholder] shows while it is null, loading or failed.
  final ImageProvider? image;

  /// Its width, in px; the height follows from [ratio]. Default 48.
  final double size;

  /// Its shape.
  final ThumbnailRatio ratio;

  /// The accessible name; decorative when left out.
  final String? label;

  /// Shown, centred, on the placeholder.
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    final colors = TsuyaTheme.of(context).colors;
    final height = switch (ratio) {
      ThumbnailRatio.square => size,
      ThumbnailRatio.portrait => size * 1.5,
      ThumbnailRatio.wide => size * 9 / 16,
    };
    final radius = BorderRadius.circular(switch (size) {
      <= 40 => TsuyaRadius.xs,
      <= 64 => TsuyaRadius.sm,
      <= 160 => TsuyaRadius.md,
      _ => TsuyaRadius.lg,
    });

    final placeholder = this.placeholder;
    final Widget content = Container(
      width: size,
      height: height,
      // the hairline is a foreground decoration, following control_body.dart: it must not inflate the box, and it
      // must sit over the clipped picture, not under it
      foregroundDecoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: colors.border, strokeAlign: BorderSide.strokeAlignInside),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(color: colors.fill),
              child: placeholder == null
                  ? null
                  : Center(
                      child: IconTheme.merge(
                        data: IconThemeData(color: colors.textMuted),
                        child: ExcludeSemantics(child: placeholder),
                      ),
                    ),
            ),
            if (image case final image?)
              Image(
                image: coverDecoded(context, image, width: size, height: height),
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (context, error, stack) => const SizedBox.shrink(),
              ),
          ],
        ),
      ),
    );

    if (label == null) return ExcludeSemantics(child: content);
    return Semantics(
      image: true,
      label: label,
      child: ExcludeSemantics(child: content),
    );
  }
}
