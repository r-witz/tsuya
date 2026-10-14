// The Flutter usage shown on the Toast page: read, not invented, from packages/flutter/lib/src/components/toast.dart.
export const FLUTTER_TOAST = `
Toast.show(
  context,
  message: 'Photo deleted',
  actionLabel: 'Undo',
  onAction: () {
    // …
  },
);`.trim();

export const FLUTTER_ICON = `
Toast.show(
  context,
  message: 'Photo restored',
  icon: const Glyph(TsuyaGlyph.check), // tsuya draws a few glyphs itself; bring your own icons for the rest
);`.trim();
