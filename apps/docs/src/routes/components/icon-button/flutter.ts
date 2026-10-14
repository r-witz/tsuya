// The Flutter usage shown on the IconButton page: read, not invented, from packages/flutter/lib/src/components/icon_button.dart.
export const FLUTTER_ICON_BUTTON = `
IconButton(
  icon: const ShareIcon(), // your own icon widget: tsuya ships no icon set
  label: 'Share',
  kind: IconButtonKind.filled,
  size: IconButtonSize.md,
  onPressed: () {
    // …
  },
)`.trim();

export const FLUTTER_TOGGLE = `
IconButton(
  icon: const ShuffleIcon(),
  label: 'Shuffle',
  toggled: shuffle,
  onPressed: () => setState(() => shuffle = !shuffle),
)

IconButton(
  icon: const PlayIcon(),
  label: 'Play',
  kind: IconButtonKind.accent,
  size: IconButtonSize.custom(64),
  onPressed: play,
)`.trim();
