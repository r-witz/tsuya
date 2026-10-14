// Block: the now-playing "player" screen, the showcase of the ambient background and control glass.
import 'package:flutter/widgets.dart' hide Banner, RadioGroup;
import 'package:tsuya/tsuya.dart';

import '../ui/block.dart';
import '../ui/covers.dart';
import '../ui/demo.dart';
import '../ui/icons.dart';
import '../ui/text.dart';

void _noop() {}

String _time(double seconds) => '${seconds ~/ 60}:${(seconds % 60).floor().toString().padLeft(2, '0')}';

/// A player: the cover large with glass controls over it, the title, a position slider and the transport.
class PlayerBlock extends StatelessWidget {
  /// The player, on [cover].
  const PlayerBlock({super.key, this.cover = 0});

  /// An index into [covers].
  final int cover;

  @override
  Widget build(BuildContext context) {
    final album = covers[cover];
    return Accent(
      pair: album.accent,
      child: BlockScreen(
        ambient: album.image,
        maxWidth: 960,
        builder: (context, layout) {
          final phone = layout == Layout.phone;
          final art = coverShadow(
            context,
            radius: TsuyaRadius.lg,
            child: Stack(
              children: [
                Thumbnail(image: album.image, size: phone ? 320 : 400, label: album.title),
                const Positioned(
                  left: TsuyaSpace.s12,
                  bottom: TsuyaSpace.s12,
                  child: Chip(label: 'Lyrics', selected: false, glass: true, onPressed: _noop),
                ),
                const PositionedDirectional(
                  end: TsuyaSpace.s12,
                  bottom: TsuyaSpace.s12,
                  child: IconButton(
                    icon: GIconView(GIcon.share),
                    label: 'Share',
                    kind: IconButtonKind.glass,
                    onPressed: _noop,
                  ),
                ),
              ],
            ),
          );
          final controls = _Controls(album: album);
          if (phone) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const ScreenBar(
                  title: 'Now playing',
                  subtitle: 'Low Tide',
                  onBack: _noop,
                  backLabel: 'Close the player',
                ),
                const SizedBox(height: TsuyaSpace.s16),
                Center(child: art),
                const SizedBox(height: TsuyaSpace.s24),
                controls,
              ],
            );
          }
          return Row(
            children: [
              art,
              const SizedBox(width: TsuyaSpace.s48),
              Expanded(child: controls),
            ],
          );
        },
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.album});

  final Cover album;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                styled(context, TsuyaType.titleL, 'Harbour Lights', maxLines: 1),
                styled(context, TsuyaType.body, album.artist, muted: true, maxLines: 1),
              ],
            ),
          ),
          Hold<bool>(
            initial: true,
            builder: (context, liked, set) => IconButton(
              icon: const GIconView(GIcon.heart),
              label: 'Like',
              toggled: liked,
              onPressed: () => set(!liked),
            ),
          ),
        ],
      ),
      const SizedBox(height: TsuyaSpace.s16),
      Hold<double>(
        initial: 84,
        builder: (context, seconds, set) => Column(
          children: [
            Slider(
              value: seconds,
              min: 0,
              max: 211,
              onChanged: set,
              label: 'Position',
              valueLabel: (v) => '${_time(v)} of 3:31',
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                styled(context, tabular(TsuyaType.caption), _time(seconds), muted: true),
                styled(context, tabular(TsuyaType.caption), '-${_time(211 - seconds)}', muted: true),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: TsuyaSpace.s16),
      Hold<bool>(
        initial: true,
        builder: (context, playing, set) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const IconButton(
              icon: GIconView(GIcon.previous),
              label: 'Previous',
              kind: IconButtonKind.plain,
              size: IconButtonSize.lg,
              onPressed: _noop,
            ),
            const SizedBox(width: TsuyaSpace.s16),
            IconButton(
              icon: GIconView(playing ? GIcon.pause : GIcon.play),
              label: playing ? 'Pause' : 'Play',
              kind: IconButtonKind.accent,
              size: IconButtonSize.custom(72),
              onPressed: () => set(!playing),
            ),
            const SizedBox(width: TsuyaSpace.s16),
            const IconButton(
              icon: GIconView(GIcon.next),
              label: 'Next',
              kind: IconButtonKind.plain,
              size: IconButtonSize.lg,
              onPressed: _noop,
            ),
          ],
        ),
      ),
    ],
  );
}
