// The Flutter usage shown on the TopBar page: read, not invented, from packages/flutter/lib/src/components/top_bar.dart and screen_bar.dart.
export const FLUTTER_TOP_BAR = `
TopBar(
  start: const Text('tsuya'),
  links: [
    TopBarLink(label: 'Components', current: true, onPressed: () {}),
    TopBarLink(label: 'Theming', onPressed: () {}),
  ],
  end: IconButton(
    icon: const Glyph(TsuyaGlyph.search), // tsuya draws a few glyphs itself; bring your own icons for the rest
    label: 'Search',
    kind: IconButtonKind.plain,
    onPressed: () {},
  ),
)`.trim();

export const FLUTTER_SCREEN_BAR = `
ScreenBar(
  title: 'Albums',
  subtitle: '412 albums',
  onBack: () => Navigator.of(context).pop(),
  backLabel: 'Back',
)`.trim();
