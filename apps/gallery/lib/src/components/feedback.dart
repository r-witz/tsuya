// 11.31 CommandPalette, 11.32 Toast, 11.33 Banner.
import 'package:flutter/widgets.dart' hide Banner;
import 'package:tsuya/tsuya.dart';

import '../app/entry.dart';
import '../ui/demo.dart';
import '../ui/icons.dart';

void _noop() {}

/// The screens of the feedback components.
final feedbackEntries = [
  GalleryEntry.component('command-palette', 'CommandPalette', 'Search-driven commands. The app opens it.', _palette),
  GalleryEntry.component('toast', 'Toast', 'A short message about something that just happened.', _toast),
  GalleryEntry.component('banner', 'Banner', 'A lasting state: offline, a sync error, a trial ending.', _banner),
];

const _groups = [
  CommandGroup<String>(
    label: 'Recent',
    commands: [
      Command(value: 'play', label: 'Play Slow Light'),
      Command(value: 'queue', label: 'Open the queue'),
    ],
  ),
  CommandGroup<String>(
    label: 'Go to',
    commands: [
      Command(value: 'library', label: 'Library'),
      Command(value: 'albums', label: 'Albums'),
      Command(value: 'settings', label: 'Settings'),
      Command(value: 'offline', label: 'Offline mode', disabled: true),
    ],
  ),
];

Widget _palette(BuildContext context) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Demo(
      'Opened by the app, usually on Ctrl or Cmd + K (tsuya binds no key)',
      child: Hold<String?>(
        initial: null,
        builder: (context, what, set) {
          final theme = TsuyaTheme.of(context);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Button(
                label: 'Search commands',
                icon: const Glyph(TsuyaGlyph.search),
                onPressed: () => CommandPalette.show<String>(
                  context,
                  groups: _groups,
                  onSelected: set,
                  barrierLabel: 'Close search',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: TsuyaSpace.s12),
                child: Text(
                  what == null ? 'Nothing run yet' : 'Ran: $what',
                  style: theme.text(TsuyaType.small).copyWith(color: theme.colors.textMuted),
                ),
              ),
            ],
          );
        },
      ),
    ),
  ],
);

Widget _toast(BuildContext context) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Demo(
      'A message that leaves by itself',
      child: Builder(
        builder: (context) => Button(
          label: 'Add to queue',
          onPressed: () => Toast.show(context, message: 'Added to the queue', icon: const Glyph(TsuyaGlyph.check)),
        ),
      ),
    ),
    Demo(
      'With an action: it stays until used, closed or replaced',
      child: Builder(
        builder: (context) => Button(
          label: 'Remove track',
          kind: ButtonKind.danger,
          onPressed: () => Toast.show(
            context,
            message: 'Track removed',
            icon: const GIconView(GIcon.trash),
            actionLabel: 'Undo',
            onAction: _noop,
          ),
        ),
      ),
    ),
  ],
);

Widget _banner(BuildContext context) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Demo(
      'Tones',
      child: Stacked([
        Banner(tone: BannerTone.info, title: 'New in your library', message: '12 albums were added since Monday.'),
        Banner(tone: BannerTone.success, title: 'Backup finished', message: 'Your playlists are safe.'),
        Banner(tone: BannerTone.warning, title: 'Trial ends in 3 days', message: 'Pick a plan to keep downloads.'),
        Banner(tone: BannerTone.danger, title: 'Sync failed', message: 'Check your connection and try again.'),
      ], gap: TsuyaSpace.s12),
    ),
    Demo(
      'With actions and a close button',
      child: Stacked([
        Banner(
          tone: BannerTone.warning,
          title: 'You are offline',
          message: 'Downloaded music still plays.',
          actions: const [Button(label: 'Go to downloads', size: ButtonSize.sm, onPressed: _noop)],
          onClose: _noop,
        ),
        Banner(
          tone: BannerTone.danger,
          title: 'Payment declined',
          message: 'Update your card to keep your subscription.',
          actions: const [
            Button(label: 'Update card', size: ButtonSize.sm, kind: ButtonKind.primary, onPressed: _noop),
            Button(label: 'Later', size: ButtonSize.sm, kind: ButtonKind.ghost, onPressed: _noop),
          ],
        ),
      ], gap: TsuyaSpace.s12),
    ),
    const Demo(
      'Title only',
      child: Banner(tone: BannerTone.info, title: 'Lyrics are available for this track'),
    ),
  ],
);
