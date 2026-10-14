// The content page block: an album, lit by its own cover.
import 'package:flutter/widgets.dart' hide Banner, RadioGroup;
import 'package:tsuya/tsuya.dart';

import '../ui/block.dart';
import '../ui/covers.dart';
import '../ui/icons.dart';
import '../ui/text.dart';

void _noop() {}

/// The album page, in the accent and the ambient of its cover.
class ContentPageBlock extends StatelessWidget {
  /// The page of [cover].
  const ContentPageBlock({super.key, this.cover = 1});

  /// An index into [covers].
  final int cover;

  @override
  Widget build(BuildContext context) {
    final album = covers[cover];
    return Accent(
      pair: album.accent,
      child: BlockScreen(
        ambient: album.image,
        builder: (context, layout) {
          final phone = layout == Layout.phone;
          final side = phone ? 232.0 : 280.0;
          final art = coverShadow(
            context,
            radius: TsuyaRadius.lg,
            child: Thumbnail(image: album.image, size: side, label: album.title),
          );
          final text = _Text(album: album, centred: phone);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (phone) ...[
                Center(child: art),
                const SizedBox(height: TsuyaSpace.s24),
                text,
              ] else
                // the text sits against the bottom edge of the cover
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    art,
                    const SizedBox(width: TsuyaSpace.s32),
                    Expanded(child: text),
                  ],
                ),
              const SizedBox(height: TsuyaSpace.s32),
              Section(
                label: 'Tracks',
                children: [
                  for (final (i, track) in _tracks.indexed)
                    ListItem(
                      title: track.$1,
                      subtitle: i == 1 ? 'Mira Vale, Noa Reyes' : null,
                      leading: SizedBox(
                        width: 24,
                        child: Center(child: styled(context, tabular(TsuyaType.small), '${i + 1}', muted: true)),
                      ),
                      trailing: styled(context, tabular(TsuyaType.small), track.$2, muted: true),
                      current: i == 0,
                      onPressed: _noop,
                    ),
                ],
              ),
              const SectionHeader(title: 'More by Mira Vale', actionLabel: 'See all', onAction: _noop),
              Wrap(
                spacing: TsuyaSpace.s16,
                runSpacing: TsuyaSpace.s16,
                children: [
                  for (final other in covers.where((c) => c != album).take(phone ? 4 : 5))
                    SizedBox(
                      width: 148,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Thumbnail(image: other.image, size: 148, label: other.title),
                          const SizedBox(height: TsuyaSpace.s8),
                          styled(context, TsuyaType.bodyStrong, other.title, maxLines: 1),
                          styled(context, TsuyaType.small, other.artist, muted: true, maxLines: 1),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

const _tracks = [
  ('Open Windows', '3:52'),
  ('Salt and Lime', '4:10'),
  ('Harbour Lights', '3:31'),
  ('Slow Light', '5:02'),
  ('The Long Way Round', '4:44'),
  ('Last Ferry', '3:18'),
];

class _Text extends StatelessWidget {
  const _Text({required this.album, required this.centred});

  final Cover album;
  final bool centred;

  @override
  Widget build(BuildContext context) {
    final align = centred ? TextAlign.center : TextAlign.start;
    return Column(
      crossAxisAlignment: centred ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        styled(context, TsuyaType.label, 'ALBUM', muted: true),
        const SizedBox(height: TsuyaSpace.s8),
        styled(context, centred ? TsuyaType.displayS : TsuyaType.displayM, album.title, align: align),
        const SizedBox(height: TsuyaSpace.s8),
        styled(context, TsuyaType.small, '${album.artist} · 2024 · 11 tracks · 48 min', muted: true, align: align),
        const SizedBox(height: TsuyaSpace.s16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: styled(
            context,
            TsuyaType.bodyL,
            'Written over one winter in a studio by the water, with the doors open to the tide.',
            align: align,
          ),
        ),
        const SizedBox(height: TsuyaSpace.s24),
        Wrap(
          spacing: TsuyaSpace.s12,
          runSpacing: TsuyaSpace.s12,
          alignment: centred ? WrapAlignment.center : WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Button(label: 'Play', icon: GIconView(GIcon.play), kind: ButtonKind.primary, onPressed: _noop),
            const IconButton(icon: GIconView(GIcon.heart), label: 'Like', onPressed: _noop),
            const IconButton(icon: GIconView(GIcon.download), label: 'Download', onPressed: _noop),
            MenuButton(
              icon: const GIconView(GIcon.more),
              label: 'More',
              items: [
                MenuItem(label: 'Add to playlist', icon: const GIconView(GIcon.plus), onSelect: _noop),
                MenuItem(label: 'Share', icon: const GIconView(GIcon.share), onSelect: _noop),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
